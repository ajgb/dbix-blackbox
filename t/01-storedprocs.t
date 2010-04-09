
use strict;
use warnings;

#use Test::More tests => 1;                      # last test to print

{
    package MyDBSP;
    use Moose;

    with 'DBIx::StoredProcs' => {
        connect_info => [
            'dbi:Sybase:server=sqlserver',
            'username',
            'password',
        ]
    };

    package MyDBSP::Procs::ListCatalogs;
    use Moose;
    use Scalar::Util qw( refaddr );

    with 'DBIx::StoredProcs::ResultSets' => {
        resultsets => [qw(
            MyDBSP::ResultSet::Catalogs
        )],
    };

    sub procedure_name { 'error_test' };

    has 'root_id' => (
        is => 'rw',
        isa => 'Int',
        required => 1,
    );
    has 'org_id' => (
        is => 'rw',
        isa => 'Maybe[Int]',
    );

    sub BUILD {
        my $self = shift;

        warn "self: ", ref $self;
        warn "self: ", refaddr $self;
    }

    package MyDBSP::Procs::ListCatalogsWithData;
    use Moose;

    with 'DBIx::StoredProcs::ResultSets' => {
        resultsets => [qw(
            MyDBSP::ResultSet::Catalogs
            MyDBSP::ResultSet::CatalogData
        )],
    };

    sub procedure_name { 'error_test' };

    has 'root_id' => (
        is => 'rw',
        isa => 'Int',
        required => 1,
    );
    has 'org_id' => (
        is => 'rw',
        isa => 'Maybe[Int]',
    );

    package MyDBSP::ResultSet::Catalogs;
    use Moose;

    has 'id' => (
        is => 'rw',
        isa => 'Int',
    );
    has 'name' => (
        is => 'rw',
        isa => 'Str',
    );

    package MyDBSP::ResultSet::CatalogData;
    use Moose;

    has 'id' => (
        is => 'rw',
        isa => 'Int',
    );
    has 'hierarchy' => (
        is => 'rw',
        isa => 'Int',
    );
    has 'description' => (
        is => 'rw',
        isa => 'Str',
    );

}


my $dbsp = MyDBSP->new();

my $rs = $dbsp->proc('ListCatalogs')->exec(
    root_id => 1,
    org_id => 2,
);

my $rs2 = $dbsp->proc('ListCatalogsWithData')->exec(
    root_id => 3,
    org_id => 4,
);

my $rs3 = $dbsp->proc('ListCatalogs')->exec(
    root_id => 5,
    org_id => 6,
);



