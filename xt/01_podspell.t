use Test::More;
eval q{ use Test::Spelling };
plan skip_all => "Test::Spelling is not installed." if $@;
add_stopwords(map { split /[\s\:\-]/ } <DATA>);
$ENV{LANG} = 'C';
all_pod_files_spelling_ok('lib');
__DATA__
Yuji Shimada
Tatsuhiko Miyagawa

xaicron@cpan.org
App::pmuninstall

Uninstall
uninstalls
checkdeps
packlist
uninstall
uninstaller
