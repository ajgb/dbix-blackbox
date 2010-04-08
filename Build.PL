use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'DBIx::StoredProcs',
    license             => 'perl',
    dist_author         => q{Alex J. G. Burzyński <ajgb@cpan.org>},
    dist_version_from   => 'lib/DBIx/StoredProcs.pm',
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'DBIx-StoredProcs-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
