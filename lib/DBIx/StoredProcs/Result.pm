
package DBIx::StoredProcs::Result;

use Moose;


use Data::Dumper;
$Data::Dumper::Indent=1;
use Devel::StackTrace;
use Scalar::Util qw( refaddr );

has 'sth' => (
    is => 'rw',
    isa => 'DBI::st',
);

has '_procedure_result' => (
    is => 'rw',
    isa => 'Maybe[Int]',
    predicate => 'has_procedure_result',
);

has 'resultsets' => (
    is => 'rw',
    isa => 'ArrayRef',
);

has 'idx' => (
    is => 'rw',
    isa => 'Int',
    default => 0,
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
        };
    }
    return 0;
}


sub next_row {
    my $self = shift;

    my @columns = map { $_->{NAME} } $self->sth->syb_describe;

    if ( my $row = $self->sth->fetch ) {
#        warn "row fetched, type: ", $self->result_type;
        if ( $self->result_type == 4040 ) {
            if ( my $class = $self->resultsets->[ $self->idx ] ) {
                my @data = @$row;
                
                my %args = map { $_, shift @data } @columns;
    #            warn "$class => ", Dumper \%args;

                return $class->new( %args );
            };
        }
    };

    return;
}

sub procedure_result {
    my $self = shift;

    unless ( $self->has_procedure_result ) {
#        warn "procedure_result type: ", $self->result_type;
        if ( $self->result_type == 4043 ) {
            $self->_procedure_result( $self->sth->fetch->[0] );
        }

    };

    return $self->_procedure_result;
}

sub all {
    my $self = shift;

    my @result_sets;
    my $procedure_result;

    do {
        while ( my $row = $self->next_row ) {
            push @{ $result_sets[ $self->idx ] }, $row;
        }
    } while ( $self->next_resultset );

    $procedure_result = $self->procedure_result;


    return ( @result_sets, $procedure_result );
}

1;


