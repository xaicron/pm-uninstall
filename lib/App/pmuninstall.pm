package App::pmuninstall;
use strict;
use warnings;
use File::Spec;
use File::Basename qw/dirname/;
use Getopt::Long qw/GetOptions :config bundling/;
use Pod::Usage qw/pod2usage/;
use Config;
use ExtUtils::MakeMaker;
use YAML;
use CPAN::DistnameInfo;
use Module::CoreList;
use version;
use HTTP::Tiny;

our $VERSION = "0.18";

my $perl_version = version->new($])->numify;
my $depended_on_by = 'http://deps.cpantesters.org/depended-on-by.pl?dist=';
my $cpanmetadb     = 'http://cpanmetadb.appspot.com/v1.0/package';
my @core_modules_dir = do { my %h; grep !$h{$_}++, @Config{qw/archlib archlibexp privlib privlibexp/} };

sub new {
    my $class = shift;
    bless {
        check_deps => 1,
        verbose    => 0,
        inc        => [@INC],
    }, $class;
}

sub run {
    my ($self, @args) = @_;
    local @ARGV = @args;
    GetOptions(
        'f|force'                 => \$self->{force},
        'v|verbose!'              => \$self->{verbose},
        'c|checkdeps!'            => \$self->{check_deps},
        'n|no-checkdeps!'         => sub { $self->{check_deps} = 0 },
        'h|help!'                 => \$self->{help},
        'V|version!'              => \$self->{version},
        'l|local-lib=s'           => \$self->{local_lib},
        'L|local-lib-contained=s' => sub {
            $self->{local_lib}      = $_[1];
            $self->{self_contained} = 1;
        },
    ) or $self->usage;
    $self->usage if $self->{help} || !scalar @ARGV;

    $self->uninstall(@ARGV);
}

sub uninstall {
    my ($self, @modules) = @_;

    $self->setup_local_lib;

    my $uninstalled = 0;
    for my $module (@modules) {
        my ($packlist, $dist, $vname) = $self->find_packlist($module);
        unless ($dist) {
            $self->puts("$module is not found.");
            next;
        }
        unless ($packlist) {
            $self->puts("$module is not installed.");
            next;
        }

        $packlist = File::Spec->catfile($packlist);
        if ($self->is_core_module($module, $packlist)) {
            $self->puts("$module is Core Module!! Can't be uninstall.");
            next;
        }
        
        if ($self->{force} or $self->ask_permission($module, $dist, $vname, $packlist)) {
            if ($self->uninstall_from_packlist($packlist)) {
                $self->puts("$module is successfully uninstalled.\n");
                ++$uninstalled;
            }
            else {
                $self->puts("! $module is failed uninstall.");
            }
        }
    }

    if ($uninstalled) {
        $self->puts("You may want to rebuild man(1) entires. Try `mandb -c` if needed");
    }

    return $uninstalled;
}

sub uninstall_from_packlist {
    my ($self, $packlist) = @_;

    my $inc = {
        map { File::Spec->catfile($_) => 1 } @{$self->{inc}}
    };

    my $failed;
    for my $file ($self->fixup_packilist($packlist)) {
        chomp $file;
        $self->puts(-f $file ? 'unlink   ' : 'not found', " : $file") if $self->{verbose};
        unlink $file or $self->puts("$file: $!") and $failed++;
        $self->rm_empty_dir_from_file($file, $inc);
    }
    $self->puts("unlink    : $packlist") if $self->{verbose};
    unlink $packlist or $self->puts("$packlist: $!") and $failed++;
    $self->rm_empty_dir_from_file($packlist, $inc);

    $self->puts if $self->{verbose};

    return !$failed;
}

sub rm_empty_dir_from_file {
    my ($self, $file, $inc) = @_;
    my $dir = dirname $file;
    return unless -d $dir;
    return if $inc->{+File::Spec->catfile($dir)};

    my $failed;
    if ($self->is_empty_dir($dir)) {
        $self->puts("rmdir     : $dir") if $self->{verbose};
        rmdir $dir or $self->puts("$dir: $!") and $failed++;
        $self->rm_empty_dir_from_file($dir, $inc);
    }

    return !$failed;
}

sub is_empty_dir {
    my ($self, $dir) = @_;
    opendir my $dh, $dir or die "$dir: $!";
    my @dir = grep !/^\.{1,2}$/, readdir $dh;
    closedir $dh;
    return @dir ? 0 : 1;
}

sub find_packlist {
    my ($self, $module) = @_;
    $self->puts("Finding $module in your \@INC") if $self->{verbose};

    # find with the given name first
    (my $try_dist = $module) =~ s!::!-!g;
    my $pl = $self->locate_pack($try_dist);
    return ($pl, $try_dist) if $pl;

    $self->puts("Looking up $module on cpanmetadb") if $self->{verbose};

    # map module -> dist and retry
    my $yaml = $self->fetch("$cpanmetadb/$module") or return;
    my $meta = YAML::Load($yaml);
    my $info = CPAN::DistnameInfo->new($meta->{distfile});

    my $pl2 = $self->locate_pack($info->dist);
    return ($pl2, $info->dist, $info->distvname);
}

sub locate_pack {
    my ($self, $dist) = @_;
    $dist =~ s!-!/!g;
    for my $lib (@{$self->{inc}}) {
        my $packlist = "$lib/auto/$dist/.packlist";
        return $packlist if -f $packlist && -r _;
    }
    return;
}

sub is_core_module {
    my ($self, $dist, $packlist) = @_;
    return unless exists $Module::CoreList::version{$perl_version}{$dist};

    my $is_core = 0;
    for my $dir (@core_modules_dir) {
        if ($packlist =~ /^$dir/) {
            $is_core = 1;
            last;
        }
    }
    return $is_core;
}

sub ask_permission {
    my($self, $module, $dist, $vname, $packlist) = @_;

    my(@deps, %seen);
    if ($self->{check_deps}) {
        $vname ||= $self->vname_for($module) || $module;
        $self->puts("Checking modules depending on $vname") if $self->{verbose};
        $self->puts("-> Getting from $depended_on_by$vname") if $self->{verbose};
        my $content = $self->fetch("$depended_on_by$vname") || '';
        for my $dep ($content =~ m|<li><a href=[^>]+>([a-zA-Z0-9_:-]+)|smg) {
            $dep =~ s/^\s+|\s+$//smg; # trim
            next if $seen{$dep}++;
            push @deps, $dep if $self->locate_pack($dep);
        }
    }

    $self->puts("$module is included in the distribution $dist and contains:\n");
    for my $file ($self->fixup_packilist($packlist)) {
        chomp $file;
        $self->puts("  $file");
    }
    $self->puts;

    my $default = 'y';
    if (@deps) {
        $self->puts("Also, they're depended on by the following dists you have:\n");
        for my $dep (@deps) {
            $self->puts("  $dep");
        }
        $self->puts;
        $default = 'n';
    }
    return lc(prompt("Are you sure to uninstall $dist?", $default)) eq 'y';
}

sub fixup_packilist {
    my ($self, $packlist) = @_;
    my @target_list;
    my $is_local_lib = $self->is_local_lib($packlist);
    open my $in, "<", $packlist or die "$packlist: $!";
    while (defined (my $file = <$in>)) {
        if ($is_local_lib) {
            next unless $self->is_local_lib($file);
        }
        push @target_list, $file;
    }
    return @target_list;
}

sub is_local_lib {
    my ($self, $file) = @_;
    return unless exists $INC{'local/lib.pm'};

    my $local_lib_base = quotemeta File::Spec->catfile(Cwd::realpath($self->{local_lib}));
    $file = File::Spec->catfile($file);

    return $file =~ /^$local_lib_base/ ? 1 : 0;
}

sub vname_for {
    my ($self, $module) = @_;

    my $yaml = $self->fetch("$cpanmetadb/$module") or return;
    my $meta = YAML::Load($yaml);
    my $info = CPAN::DistnameInfo->new($meta->{distfile}) or return;

    return $info->distvname;
}

# taken from cpan-outdated
sub setup_local_lib {
    my $self = shift;
    return unless $self->{local_lib};

    require local::lib;
    local $SIG{__WARN__} = sub { }; # catch 'Attempting to write ...'
    $self->{inc} = [ map { Cwd::realpath($_) } split $Config{path_sep},
        +{local::lib->build_environment_vars_for($self->{local_lib}, $self->{self_contained} ? 0 : 1)}->{PERL5LIB} ];
    push @{$self->{inc}}, @INC unless $self->{self_contained};
}

sub fetch {
    my ($self, $url) = @_;
    my $res = HTTP::Tiny->new->get($url);
    die "[$res->{status}] fetch $url failed!!\n" if !$res->{success} && $res->{status} != 404;
    return $res->{content};
}

sub puts {
    my ($self, @msg) = @_;
    push @msg, '' unless @msg;
    print @msg, "\n";
}

sub usage {
    my $self = shift;
    $self->puts(<< 'USAGE');
Usage:
      pm-uninstall [options] Module ...

      options:
          -v,--verbose                  Turns on chatty output
          -f,--force                    Uninstalls without prompts
          -c,--checkdeps                Check dependencies ( default on )
          -n,--no-checkdeps             Not check dependencies
          -h,--help                     This help message
          -V,--version                  Show version
          -l,--local-lib                Additional module path
          -L,--local-lib-contained      Additional module path (don't include non-core modules)
USAGE

    exit 1;
}

1;
__END__

=head1 NAME

App::pmuninstall - Uninstall modules

=head1 DESCRIPTION

App::pmuninstall is Fast module uninstaller.
delete files from B<.packlist>.

App:: cpanminus and, App:: cpanoutdated with a high affinity.

=head1 SYNOPSIS

uninstall MODULE

  $ pm-uninstall App::pmuninstall

=head1 OPTIONS

=over

=item -f, --force

Uninstalls without prompts

  $ pm-uninstall -f App::pmuninstall

=item -v, --verbose

Turns on chatty output

  $ pm-uninstall -v App::cpnaminus

=item -c, --checkdeps

Check dependencies ( default on )

  $ pm-uninstall -c Plack

=item -n, --no-checkdeps

Not check dependencies

  $ pm-uninstall -n LWP

=item -h, --help

Show help message

  $ pm-uninstall -h

=item -V, --version

Show version

  $ pm-uninstall -V

=item -l, --local-lib

Additional module path

  $ pm-uninstall -l extlib App::pmuninstall

=item -L, --local-lib-contained

Additional module path (don't include non-core modules)

  $ pm-uninstall -L extlib App::pmuninstall

=back

=head1 AUTHOR

Yuji Shimada

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<pm-uninstall>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

