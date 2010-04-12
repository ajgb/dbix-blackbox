
package DBIx::StoredProcs::Procedure;

use Moose::Role;
use Scalar::Util qw( refaddr );

use DBIx::StoredProcs::Result;


    use Data::Dumper;
    $Data::Dumper::Indent=1;


sub exec {
    my ($self, $dbdriver) = @_;

#    warn "self: ", ref $self;
#    warn "self: ", refaddr $self;
#    warn "dbdriver ", refaddr $dbdriver;

    my %params = map {
        $_ => $self->$_
    } $self->meta->get_attribute_list;

    my $params = $self->_args2procparams( \%params );

    my $query = 'exec '. $self->procedure_name;
    if ( $params ) {
        $query .= ' '. $params;
    }

#    warn "query: $query"; 

    my $sth = $dbdriver->connector->run(
        fixup => sub {
            my $dbh = shift;

            unless ( $dbh->{syb_err_handler} ) {
#                warn "   &^&^&^ adding syb_err_handler";
                $dbh->{syb_err_handler} = sub { $dbdriver->error_handler( @_); };
            };

#            warn "fixup->dbh ", refaddr $dbh;
            my $sth = $dbh->prepare( $query );
            $sth->execute( values %params );
            $sth;
        }
    );

    return DBIx::StoredProcs::Result->new(
        sth => $sth,
        idx => 0,
        _resultsets => [
           $self->_resultsets, 
        ]
    );
}

sub _args2procparams {
    my ($self, $args) = @_;

    return join(', ', map { '@'. $_ .' = ?' } keys %$args);
}

no Moose::Role;

1;

