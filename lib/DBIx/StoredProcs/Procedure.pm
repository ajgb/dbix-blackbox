
package DBIx::StoredProcs::Procedure;

use MooseX::Role::Parameterized;

use DBIx::StoredProcs::Result;

parameter resultsets => (
    isa => 'ArrayRef',
    default => sub { [] },
);

role {
    my $p = shift;
    my %args = @_;
    my $consumer = $args{consumer};

    method 'exec' => sub {
        my ($self, $dbdriver) = @_;

        my %params = map {
            $_ => $self->$_
        } $self->meta->get_attribute_list;

        my $params = join(', ', map { '@'. $_ .' = ?' } keys %params);

        my $query = 'exec '. $self->procedure_name;
        if ( $params ) {
            $query .= ' '. $params;
        }

        my $db_driver = $dbdriver->connector->run(
            fixup => sub {
                $dbdriver->dbh( shift );
                my $sth = $dbdriver->dbh->prepare( $query );
                $sth->execute( values %params );
                $dbdriver->sth( $sth );
                $dbdriver;
            }
        );

        return DBIx::StoredProcs::Result->new(
            db_driver => $db_driver,
            resultsets => $p->resultsets, 
        );
    }
};

no MooseX::Role::Parameterized;

1;

