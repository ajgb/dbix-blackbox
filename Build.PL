use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'DBIx::BlackBox',
    license             => 'perl',
    dist_author         => q{Alex J. G. Burzyński <ajgb@cpan.org>},
    dist_version_from   => 'lib/DBIx/BlackBox.pm',
    build_requires => {
        'Test::More' => 0,
        'MooseX::Role::Parameterized' => 0.18,
    },
    add_to_cleanup      => [ 'DBIx-BlackBox-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
