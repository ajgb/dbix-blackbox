package DBIx::BlackBox;

use MooseX::Role::Parameterized;

use DBIx::Connector;
use DBI;
use Module::Find qw( findallmod );

=encoding utf8

=head1 NAME

DBIx::BlackBox - access database with stored procedures only

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

L<DBIx::BlackBox> provides access to database using stored procedures only
(the only SQL command available is I<exec>). That allows to treat your
database as a black box into which only the database administrator provides
access by stored procedures.

Setup base class:

    package MyDBBB;
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

Create procedures classes. Attributes define stored procedure parameters.

    package MyDBBB::Procedures::ListCatalogs;
    use Moose;

    with 'DBIx::BlackBox::Procedure' => {
        name => 'DB_Live..list_catalogs',
        resultsets => [qw(
            MyDBBB::ResultSet::Catalogs
            MyDBBB::ResultSet::CatalogData
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

    package MyDBBB::Procedures::UpdateCatalog;
    use Moose;

    with 'DBIx::BlackBox::Procedure' => {
        name => 'DB_Live..update_catalog',
    };

    has 'id' => (
        is => 'rw',
        isa => 'Int',
        required => 1,
    );
    has 'name' => (
        is => 'rw',
        isa => 'Str',
        required => 1,
    );


Describe result sets for procedures. Could (and should) be shared between
procedures.

    package MyDBBB::ResultSet::Catalogs;
    use Moose;

    has 'id' => (
        is => 'rw',
        isa => 'Int',
    );
    has 'name' => (
        is => 'rw',
        isa => 'Str',
    );

    package MyDBBB::ResultSet::CatalogData;
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

    use MyDBBB;

    my $dbbb = MyDBBB->new();

execute stored procedure and get result object to iterate over

    my $rs = eval {
        $dbbb->exec('ListCatalogs',
            root_id => $root_id,
            org_id => $org_id,
        );
    } or do {
        die $@;
    }

    my @columns = (
        [qw( id name )],
        [qw( id hierarchy description )],
    );
    do {
        my @c = @{ $columns[ $rs->idx ] };
        while ( my $row = $rs->next_row ) {
            print "$_: ", $row->$_, "\n"
                for @c;
        }
    } while ( $rs->next_resultset );

    print "procedure_result: ", $rs->procedure_result, "\n";

or get all rows at once
    
    my ( $catalogs, $data, $rv ) = $dbbb->exec('ListCatalogs',
        root_id => $root_id,
        org_id => $org_id,
    )->all;

    for my $catalog ( @$catalogs ) {
        print $catalog->id, ": ", $catalog->name, "\n";
    }

    for my $row ( @$data ) {
        print $row->id, "[", $row->hierarchy, "]: ", $row->description, "\n";
    }

    print "procedure result: $rv";

=cut

parameter connect_info => (
    isa => 'ArrayRef',
    required => 1,
);

=head1 ROLE PARAMETERS

=head2 connect_info

Database connection arguments passed to L<DBI/"connect">.

Note: currently only DBD::Sybase (MS SQL Server) is supported.

=head1 METHODS

=head2 exec

    my $rs = $dbbb->exec($procedure_class, %args);

Executes procedures defined by class in the
C<join('::', ref $dbbb, 'Procedures')> namespace.

Uses named paremeters.

=cut

=head1 INSTALLATION

Following installation steps were tested with both
Microsoft SQL Server 2000 and Microsoft SQL Server 2008.

=head2 unixODBC

Install unixODBC from your system packages or download sources from
L<http://www.unixodbc.org/>.

=head2 FreeTDS

Download dev release of FreeTDS from L<http://www.freetds.org> (at the time
writing it the current version is freetds-0.83.dev.20100122).

    ./configure --with-unixodbc=/usr/local/ \
        --with-tdsver=8.0 --prefix=/usr/local/freetds
    make
    sudo make install

Edit F</usr/local/freetds/etc/freetds.conf> and specify access to your
database.

    ...
    [sqlserver]
        host = 1.2.3.4
        port = 1433
        tds version = 8.0

=head2 DBD::Sybase

Install L<DBD::Sybase>.

    SYBASE=/usr/local/freetds perl Makefile.PL
    make
    sudo make install

If you want to test DBD::Sybase most likely you would need to modify tests
that come with the module (some queries will not work with MS SQL Server).

=cut

role {
    my $p = shift;
    my %args = @_;
    my $consumer = $args{consumer};

    has 'connect_info' => (
        traits => [qw( Array )],
        is => 'ro',
        isa => 'ArrayRef',
        default => sub {
            $p->connect_info,
        },
        handles => {
            _db_connection_params => 'elements',
        }
    );

    has '_conn' => (
        is => 'rw',
        isa => 'DBIx::BlackBox::Driver',
        lazy_build => 1,
    );

    after 'new' => sub {
        my $proc_class_ns = join('::', $consumer->name, 'Procedures' );
        my @mods = findallmod( $proc_class_ns );
        do {
            my $proc_class = $_;

            Class::MOP::load_class( $proc_class );
            my $proc_meta = $proc_class->meta;

            my $proc_role = 'DBIx::BlackBox::Procedure';
            unless ( $proc_meta->does_role($proc_role) ) {
                die "Class $proc_class does not consume $proc_role role\n";
            }
        } for @mods;
    };

    method '_build__conn' => sub {
        my $self = shift;

        my @coninfo = $self->_db_connection_params;

        my $dsn = $coninfo[0];
        my (undef, $driver) = DBI->parse_dsn( $dsn );

        my $db_class = "DBIx::BlackBox::Driver::$driver";
        Class::MOP::load_class( $db_class );

        return $db_class->new(
            connector => DBIx::Connector->new( @coninfo )
        );
    };

    method 'exec' => sub {
        my ($self, $name, %args) = @_;

        my $proc_class = join('::', $consumer->name, 'Procedures', $name );

        my $proc = $proc_class->new( %args );

        return $proc->exec( $self->_conn );
    }
};

no MooseX::Role::Parameterized;

=head1 CAVEATS

Neither the stored procedures nor result sets classes can have
attributes that would clash with Moose internals, e.g. I<new>.

=head1 AUTHOR

Alex J. G. Burzyński, E<lt>ajgb at cpan.orgE<gt>

=head1 BUGS

Please report any bugs or feature requests to C<bug-dbix-blackbox at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=DBIx-BlackBox>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Alex J. G. Burzyński.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of DBIx::BlackBox
