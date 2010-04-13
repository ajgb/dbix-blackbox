
package DBIx::StoredProcs::Driver;

use Moose;

has 'connector' => (
    is => 'rw',
    isa => 'DBIx::Connector',
);

has 'dbh' => (
    is => 'rw',
    isa => 'DBI::db',
);

has 'sth' => (
    is => 'rw',
    isa => 'DBI::st',
);

has '_result_types' => (
    is => 'ro',
    isa => 'HashRef[Str]',
);


sub clone {
    my ( $self, %params ) = @_;

    $self->meta->clone_object($self, %params);
}

1;

