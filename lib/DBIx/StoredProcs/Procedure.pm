
package DBIx::StoredProcs::Procedure;

use Moose::Role;
use Scalar::Util qw( refaddr );


    use Data::Dumper;
    $Data::Dumper::Indent=1;


sub exec {
    my $class = ref $_[0] ? ref shift : shift;
    my %args = @_;

    my $self = $class->new( %args );

#    die Dumper $self->meta;
    warn "exec(", Dumper(\%args), ")";

    my $conn = $self->__dbix_connector_cache;

    warn "self: ", ref $self;
    warn "self: ", refaddr $self;
    warn "conn: ", refaddr $conn;

    my $params = $self->_args2procparams( \%args );

    my $query = 'exec '. $self->procedure_name;
    if ( $params ) {
        $query .= ' '. $params;
    }

    warn "query: $query"; 

    $conn->run(
        fixup => sub {
            my $sth = $_->prepare( $query );
            $sth->execute( values %args );
            $sth;
        }
    );
}

sub _args2procparams {
    my ($self, $args) = @_;

    return join(', ', map { '@'. $_ .' = ?' } keys %$args);
}

no Moose::Role;

1;

