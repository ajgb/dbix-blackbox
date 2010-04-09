
package DBIx::StoredProcs::Result;

use Moose;

has 'sth' => (
    is => 'rw',
    isa => 'DBI::st',
);

has '_resultsets' => (
    is => 'rw',
    isa => 'ArrayRef',
);

has 'idx' => (
    is => 'rw',
    isa => 'Int',
    default => 0,
);

has 'procedure_result' => (
    is => 'rw',
    isa => 'Int',
    default => -1,
);

sub result_type {
    my $self = shift;

    return $self->sth->{syb_result_type};
}

sub next_resultset {
    my $self = shift;

#    warn "next_resultset";
    if ( $self->sth->{syb_more_results} ) {
#        warn "   ->next";
        $self->idx( $self->idx + 1 );
        if ( $self->result_type == 4040 ) {
            return 1;
        }
        elsif ( $self->result_type == 4043 ) {
            my $row = $self->sth->fetch;
            $self->procedure_result( $row->[0] );
        }
    }
    return 0;
}


use Data::Dumper;
$Data::Dumper::Indent=1;
use Devel::StackTrace;
use Scalar::Util qw( refaddr );

sub next_row {
    my $self = shift;

    my @columns = map { $_->{NAME} } $self->sth->syb_describe;

    if ( my $row = $self->sth->fetch ) {
        if ( my $class = $self->_resultsets->[ $self->idx ] ) {
            my @data = @$row;
            
            my %args = map { $_, shift @data } @columns;
#            warn "$class => ", Dumper \%args;

            my $row = $class->new( %args );
            return $row;

            return $class->new( %args );
        };
    };

    return;
}

1;


