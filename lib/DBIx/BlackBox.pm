package DBIx::BlackBox;

use MooseX::Role::Parameterized;

use DBIx::Connector;
use DBI;
use Module::Find qw( findallmod );

=head1 NAME

DBIx::BlackBox - ORM using stored procedures.

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Setup base class

    package MyDBSP;
    use Moose;

    with 'DBIx::BlackBox' => {
        connect_info => [
            'dbi:Sybase:server=sqlserver',
            'username',
            'password',
            {
                RaiseError = 1,
                PrintError = 0,
            }
        ]
    };

Describe procedures

    package MyDBSP::Procs::ListCatalogs;
    use Moose;

    with 'DBIx::BlackBox::Procedure' => {
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

Describe result sets for procedures (could be shared)

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


and then

    use MyDBSP;

    my $dbsp = MyDBSP->connect();

execute stored procedure and get result object to iterate over

    my $rs = eval {
        $dbsp->exec('ListCatalogs',
            root_id => $root_id,
            org_id => $org_id,
        );
    } or do {
        die $@;
    }

    while ( my $rs = $rs->next ) {
        # 1st ref $rs eq MyDBSP::ResultSet::Catalogs
        # 2st ref $rs eq MyDBSP::ResultSet::CatalogData
        while ( my $row = $rs->next_row ) {
            print $row->column_name;
        }
    };

or get all rows at once
    
    my ( $catalogs, $data, $rv ) = $dbsp->exec('ListCatalogs',
        root_id => $root_id,
        org_id => $org_id,
    )->all;

    for my $catalog ( @$catalogs ) {
        print $catalog->name;
    }

    for my $row ( @$data ) {
        print $row->description;
    }

    print "procedure result: $rv";

=cut

parameter connect_info => (
    isa => 'ArrayRef',
    required => 1,
);

parameter db_driver => (
    isa => 'Maybe[Str]',
);

=head1 METHODS

=head2 proc

Load procedure class

=head2 connect

Connect to database

=cut

role {
    my $p = shift;
    my %args = @_;
    my $consumer = $args{consumer};

    has 'connect_info' => (
        is => 'ro',
        isa => 'ArrayRef',
        auto_deref => 1,
        default => sub {
            $p->connect_info,
        }
    );

    has '_conn' => (
        is => 'rw',
        isa => 'DBIx::BlackBox::Driver',
        lazy_build => 1,
    );

    before 'new' => sub {
        my $proc_class_ns = join('::', $consumer->name, 'Procs' );
        my @mods = findallmod( $proc_class_ns );
        Class::MOP::load_class( $_ )
            for @mods;

    };

    method '_build__conn' => sub {
        my $self = shift;

        my @coninfo = $self->connect_info;

        my $db_class;
        unless ( $db_class = $p->db_driver ) { 
            my $dsn = $coninfo[0];
            my (undef, $driver) = DBI->parse_dsn( $dsn );

            $db_class = "DBIx::BlackBox::Driver::$driver";
        };
        Class::MOP::load_class( $db_class );

        return $db_class->new(
            connector => DBIx::Connector->new( @coninfo )
        );
    };

    method 'exec' => sub {
        my ($self, $name, %args) = @_;

        my $proc_class = join('::', $consumer->name, 'Procs', $name );
        my $proc_meta = $proc_class->meta;

        unless ( $proc_meta->does_role('DBIx::BlackBox::Procedure') ) {
            DBIx::BlackBox::Procedure->meta->apply( $proc_meta );
        }

        my $proc = $proc_class->new( %args );

        return $proc->exec( $self->_conn->clone );
    }
};

no MooseX::Role::Parameterized;


=head1 AUTHOR

Alex J. G. Burzyński, C<< <ajgb at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dbix-storedprocs at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=DBIx-BlackBox>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc DBIx::BlackBox


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=DBIx-BlackBox>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/DBIx-BlackBox>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/DBIx-BlackBox>

=item * Search CPAN

L<http://search.cpan.org/dist/DBIx-BlackBox/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Alex J. G. Burzyński.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of DBIx::BlackBox