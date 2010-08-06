package App::pmuninstall;
use strict;
use warnings;
our $VERSION = "0.04";

1;
__END__

=head1 NAME

App::pmuninstall - Uninstall modules

=head1 DESCRIPTION

App::pmuninstall is Fast module uninstaller.
delete files from B<.packlist>.

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

  $ pm-uninstall -v CGI

=item -c, --checkdeps

Check dependencies

  $ pm-uninstall -c Plack

=item -h, --help

Show help message

  $ pm-uninstall -h

=head1 AUTHOR

Yuji Shimada

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<pm-uninstall>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

