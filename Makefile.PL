use ExtUtils::MakeMaker;
WriteMakefile(
    NAME => 'App::pmuninstall',
    VERSION_FROM => 'lib/App/pmuninstall.pm',
    ABSTRACT => 'Uninstall modules.',
    PREREQ_PM => {
        'ExtUtils::MakeMaker' => 6.30,
        'ExtUtils::Install' => 1.43,
        'CPAN::DistnameInfo' => 0,
        'YAML' => 0,
        'HTTP::Tiny' => 0.012,
        'Module::CoreList' => 0,
        'version' => 0,
        'JSON::PP' => 0,
    },
    LICENSE => 'perl',
    EXE_FILES => [ 'bin/pm-uninstall' ],
);

