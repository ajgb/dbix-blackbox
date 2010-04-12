
package DBIx::StoredProcs::Procedure;

use MooseX::Role::Parameterized;

use Scalar::Util qw( refaddr );

use DBIx::StoredProcs::Result;

use Data::Dumper;
$Data::Dumper::Indent=1;


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

    #    warn "self: ", ref $self;
    #    warn "self: ", refaddr $self;
    #    warn "dbdriver ", refaddr $dbdriver;

        my %params = map {
            $_ => $self->$_
        } $self->meta->get_attribute_list;

        my $params = join(', ', map { '@'. $_ .' = ?' } keys %params);

        my $query = 'exec '. $self->procedure_name;
        if ( $params ) {
            $query .= ' '. $params;
        }

#        warn "query: $query"; 

        my $sth = $dbdriver->connector->run(
            fixup => sub {
                my $dbh = shift;

                unless ( $dbh->{syb_err_handler} ) {
    #                warn "   &^&^&^ adding syb_err_handler";
                    $dbh->{syb_err_handler} = sub {
                        $dbdriver->error_handler( @_);
                    };
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
            resultsets => $p->resultsets, 
        );
    }
};

no MooseX::Role::Parameterized;

1;

