package App::pmuninstall;
use strict;
use warnings;
our $VERSION = "0.13";

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

