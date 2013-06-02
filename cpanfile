requires 'CPAN::DistnameInfo';
requires 'ExtUtils::Install', '1.43';
requires 'ExtUtils::MakeMaker', '6.3';
requires 'HTTP::Tiny', '0.012';
requires 'JSON::PP', '2.01';
requires 'Module::CoreList';
requires 'YAML';
requires 'version';

on build => sub {
    requires 'ExtUtils::MakeMaker';
};
