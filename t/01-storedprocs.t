
use strict;
use warnings;

#use Test::More tests => 1;                      # last test to print


use Data::Dumper;
$Data::Dumper::Indent=1;
use Devel::StackTrace;
use Scalar::Util qw( refaddr );

{
    package MyDBSP;
    use Moose;

    with 'DBIx::StoredProcs' => {
        connect_info => [
            'dbi:Sybase:server=kp-dev3',
            'tds_test',
            'p@$$word',
            {
                RaiseError => 0,
                ShowErrorStatement => 0,
            }
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

    package MyDBSP::Procs::ListCatalogsWithData;
    use Moose;

    with 'DBIx::StoredProcs::ResultSets' => {
        resultsets => [qw(
            MyDBSP::ResultSet::Catalogs
            MyDBSP::ResultSet::CatalogData
        )],
    };

    sub procedure_name { 'error_test2' };

    has 'root_id' => (
        is => 'rw',
        isa => 'Int',
        required => 1,
    );
    has 'org_id' => (
        is => 'rw',
        isa => 'Maybe[Int]',
    );

    package MyDBSP::Procs::ListCatalogStructure;
    use Moose;

    with 'DBIx::StoredProcs::ResultSets' => {
        resultsets => [qw(
            MyDBSP::ResultSet::CatalogStructure
        )],
    };

    sub procedure_name { 'CBS_Live..list_catalog_structure' };

    has 'catalog' => (
        is => 'rw',
        isa => 'Str',
        required => 1,
    );
    has 'parent_id' => (
        is => 'rw',
        isa => 'Int',
        required => 1,
    );
    has 'currency' => (
        is => 'rw',
        isa => 'Str',
        required => 1,
        default => 'GBP',
    );
    has 'prole_id' => (
        is => 'rw',
        isa => 'Maybe[Str]',
        default => sub { return },
    );
    has 'editing' => (
        is => 'rw',
        isa => 'Int',
        required => 1,
        default => 0,
    );
    has 'org_id' => (
        is => 'rw',
        isa => 'Maybe[Str]',
        default => sub { return },
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


    package MyDBSP::ResultSet::CatalogStructure;
    use Moose;

    has 'node_id' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'parent_id' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'catalog' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'type' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'name' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'prod_ref' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'prod_id' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'special' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'delivery_type' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has '_new' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'db_node_id' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'db_parent_id' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'deleted' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'specification' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'additional_info' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'additional_info_type' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'highlighted' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'preferred' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'recommended' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'duration' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'display_duration' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'valid_service' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'customer_nett_amount' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'customer_tax_amount' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'customer_gross_amount' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'standard_nett_amount' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'standard_tax_amount' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'standard_gross_amount' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'nett_saving' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'gross_saving' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'saving_percent' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'currency' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'supplier_name' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'in_house' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'prod_manager_prole_id' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'events' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'tc0_count' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'tc1_count' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'tc2_count' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'tc3_count' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'tc4_count' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'tc5_count' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'tc0_new' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'tc1_new' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'tc2_new' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'tc3_new' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'tc4_new' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'tc5_new' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'tc0_special' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'tc1_special' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'tc2_special' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'tc3_special' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'tc4_special' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'tc5_special' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'prod_id' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'has_equivalent' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'rating_indicator' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'rating_percent' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'rating_count' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'multi_session' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );
    has 'attributes' => (
        is => 'rw',
        isa => 'Maybe[Any]',
    );

    1;
}



my $dbsp = MyDBSP->new();


my $rs = $dbsp->proc('ListCatalogStructure')->exec(
    catalog => 'trainingexpert',
    parent_id => $ARGV[0] || 5895,
);

use Text::TabularDisplay;

do {
    my @c = qw(
        parent_id
        node_id
        name
        customer_nett_amount
    );
    my $t = Text::TabularDisplay->new( @c );
    while ( my $row = $rs->next_row ) {
        $t->add( map { $row->$_ } @c );
    }
    print $t->render, "\n";
} while ( $rs->next_resultset );

print "proc_res: ", $rs->procedure_result, "\n";


__END__
my $rs = $dbsp->proc('ListCatalogs')->exec(
    root_id => 1,
    org_id => 2,
);


do {
    while ( my $row = $rs->next_row ) {
#        warn Dumper $row;
        print ref $row, ":\t";
        print join(" | ", $row->id, $row->name), "\n";
    }
} while ( $rs->next_resultset );

print "proc_res: ", $rs->procedure_result, "\n";

my $rs2 = $dbsp->proc('ListCatalogsWithData')->exec(
    root_id => 1,
    org_id => 2,
);

do {
    while ( my $row = $rs2->next_row ) {
#        warn Dumper $row;
        print ref $row, ":\t";
        if ( $rs2->idx ) {
            print join(" | ", $row->id, $row->hierarchy, $row->description), "\n";
        } else {
            print join(" | ", $row->id, $row->name), "\n";
        }
    }
} while ( $rs2->next_resultset );

print "proc_res: ", $rs2->procedure_result, "\n";



