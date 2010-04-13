
use strict;
use warnings;

#use Test::More tests => 1;                      # last test to print


use Data::Dumper;
$Data::Dumper::Indent=1;
use Devel::StackTrace;
use Scalar::Util qw( refaddr );

my $ALL = 1;

{
    package MyDBSP;
    use Moose;

    with 'DBIx::BlackBox' => {
        connect_info => [
            'dbi:Sybase:server=kp-dev3',
#            'dbi:Sybase:server=kpdb2',
            'tds_test',
            'p@$$word',
#            'pass30rd',
            {
                RaiseError => 1,
                PrintError => 0,
            }
        ]
    };

    package MyDBSP::Procedures::ListCatalogs;
    use Moose;
    use Scalar::Util qw( refaddr );

    with 'DBIx::BlackBox::Procedure' => {
        name => 'error_test',
        resultsets => [qw(
            MyDBSP::ResultSet::Catalogs
        )],
    };

    has 'root_id' => (
        is => 'rw',
        isa => 'Int',
        required => 1,
    );
    has 'org_id' => (
        is => 'rw',
        isa => 'Maybe[Int]',
    );

    package MyDBSP::Procedures::ListCatalogsWithData;
    use Moose;

    with 'DBIx::BlackBox::Procedure' => {
        name => 'error_test2',
        resultsets => [qw(
            MyDBSP::ResultSet::Catalogs
            MyDBSP::ResultSet::CatalogData
        )],
    };

    has 'root_id' => (
        is => 'rw',
        isa => 'Int',
        required => 1,
    );
    has 'org_id' => (
        is => 'rw',
        isa => 'Maybe[Int]',
    );

    package MyDBSP::Procedures::ErrorTest3;
    use Moose;

    with 'DBIx::BlackBox::Procedure' => {
        name => 'error_test3',
        resultsets => [qw(
            MyDBSP::ResultSet::CatalogStructure
        )],
    };

    package MyDBSP::Procedures::ListCatalogStructure;
    use Moose;

    with 'DBIx::BlackBox::Procedure' => {
        name => 'CBS_Live..list_catalog_structure',
        resultsets => [qw(
            MyDBSP::ResultSet::CatalogStructure
        )],
    };

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

    has [qw(
        node_id parent_id catalog type name prod_ref prod_id special
        delivery_type _new db_node_id db_parent_id deleted specification
        additional_info additional_info_type highlighted preferred recommended
        duration display_duration valid_service customer_nett_amount
        customer_tax_amount customer_gross_amount standard_nett_amount
        standard_tax_amount standard_gross_amount nett_saving gross_saving
        saving_percent currency supplier_name in_house prod_manager_prole_id
        events tc0_count tc1_count tc2_count tc3_count tc4_count tc5_count
        tc0_new tc1_new tc2_new tc3_new tc4_new tc5_new tc0_special
        tc1_special tc2_special tc3_special tc4_special tc5_special prod_id
        has_equivalent rating_indicator rating_percent rating_count
        multi_session attributes
    )] => (
        is => 'rw',
        isa => 'Any',
    );

}

use Text::TabularDisplay;


my $dbsp = MyDBSP->new();

print $dbsp->_conn->connector->dbh->{syb_oc_version}, "\n";
print $dbsp->_conn->connector->dbh->{syb_server_version}, "\n";
print $dbsp->_conn->connector->dbh->{syb_server_version_string}, "\n";

if (0 || $ALL) {
    my $rs = $dbsp->exec('ErrorTest3');

    print "proc_res: ", $rs->procedure_result, "\n";

}

if (0 || $ALL) {

    my $rs = $dbsp->exec('ListCatalogStructure',
        catalog => 'trainingexpert',
        parent_id => $ARGV[0] || 5895,
    );

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
}

if (0 || $ALL) {

    my $rs = $dbsp->exec('ListCatalogs',
        root_id => 1,
        org_id => 2,
    );

    do {
        my @c = qw(
            id
            name
        );

        my $t = Text::TabularDisplay->new( @c );
        while ( my $row = $rs->next_row ) {
            $t->add( map { $row->$_ } @c );
        }
        print $t->render, "\n";
    } while ( $rs->next_resultset );

    print "proc_res: ", $rs->procedure_result, "\n";

}

if (0 || $ALL) {

    my $rs = $dbsp->exec('ListCatalogsWithData',
        root_id => 1,
        org_id => 2,
    );

    my $rs2 = $dbsp->exec('ListCatalogs',
        root_id => 1,
        org_id => 2,
    );


    do {
        if ( $rs->idx == 0 ) {
            do {
                my @c = qw(
                    id
                    name
                );

                my $t = Text::TabularDisplay->new( @c );
                while ( my $row = $rs2->next_row ) {
                    $t->add( map { $row->$_ } @c );
                }
                print "**\n", $t->render, "\n**\n";
            } while ( $rs2->next_resultset );

            print "** proc_res: ", $rs2->procedure_result, "\n";

        }

        my @c;
        if ( $rs->idx ) {
            @c = qw(
                id
                hierarchy
                description
            );
        } else {
            @c = qw(
                id
                name
            );
        }
        my $t = Text::TabularDisplay->new( @c );
        while ( my $row = $rs->next_row ) {
            $t->add( map { $row->$_ } @c );
        }
        print $t->render, "\n";
    } while ( $rs->next_resultset );

    print "proc_res: ", $rs->procedure_result, "\n";

}


if (0 || $ALL) {

    my $rs = $dbsp->exec('ListCatalogsWithData',
        root_id => 1,
        org_id => 2,
    );

    my @columns = (
        [qw( id name )],
        [qw( id hierarchy description )],
    );
    do {
        my @c = @{ $columns[ $rs->idx ] };
        my $t = Text::TabularDisplay->new( @c );
        while ( my $row = $rs->next_row ) {
            $t->add( map { $row->$_ } @c );
        }
        print $t->render, "\n";
    } while ( $rs->next_resultset );

    print "proc_res: ", $rs->procedure_result, "\n";

}

 
if (0 || $ALL) {

    my ( $catalogs, $data, $rv ) = $dbsp->exec('ListCatalogsWithData',
        root_id => 1,
        org_id => 2,
    )->all;

    {
        my @c = qw(
            id
            name
        );

        my $t = Text::TabularDisplay->new( @c );
        for my $row ( @$catalogs ) {
            $t->add( map { $row->$_ } @c );
        }
        print $t->render, "\n";
    }
    {
        my @c = qw(
            id
            hierarchy
            description
        );

        my $t = Text::TabularDisplay->new( @c );
        for my $row ( @$data ) {
            $t->add( map { $row->$_ } @c );
        }
        print $t->render, "\n";
    }

    print "proc_res: ", $rv, "\n";

}

__END__

