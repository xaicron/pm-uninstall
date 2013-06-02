# NAME

App::pmuninstall - Uninstall modules

# DESCRIPTION

App::pmuninstall is a fast module uninstaller.
delete files from __.packlist__.

[App::cpanminus](http://search.cpan.org/perldoc?App::cpanminus) and, [App::cpanoutdated](http://search.cpan.org/perldoc?App::cpanoutdated) with a high affinity.

# SYNOPSIS

uninstall MODULE

    $ pm-uninstall App::pmuninstall

# OPTIONS

- \-f, --force

    Uninstalls without prompts

        $ pm-uninstall -f App::pmuninstall

- \-v, --verbose

    Turns on chatty output

        $ pm-uninstall -v App::cpnaminus

- \-c, --checkdeps

    Check dependencies ( default on )

        $ pm-uninstall -c Plack

- \-n, --no-checkdeps

    Don't check dependencies

        $ pm-uninstall -n LWP

- \-q, --quiet

    Suppress some messages

        $ pm-uninstall -q Furl

- \-h, --help

    Show help message

        $ pm-uninstall -h

- \-V, --version

    Show version

        $ pm-uninstall -V

- \-l, --local-lib

    Additional module path

        $ pm-uninstall -l extlib App::pmuninstall

- \-L, --local-lib-contained

    Additional module path (don't include non-core modules)

        $ pm-uninstall -L extlib App::pmuninstall

# AUTHOR

Yuji Shimada

Tatsuhiko Miyagawa

# SEE ALSO

[pm-uninstall](http://search.cpan.org/perldoc?pm-uninstall)

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
