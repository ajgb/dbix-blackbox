
package DBIx::BlackBox::Result;

use Moose;

has 'db_driver' => (
    is => 'rw',
    isa => 'DBIx::BlackBox::Driver',
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

    return $self->db_driver->result_type;
}


sub next_resultset {
    my $self = shift;

    if ( $self->db_driver->has_more_result_sets ) {
        $self->idx( $self->idx + 1 );
        if ( $self->db_driver->result_type eq 'row_result' ) {
            return 1;
        };
    }
    return 0;
}


sub next_row {
    my $self = shift;

    my @columns = $self->db_driver->columns;

    if ( my $row = $self->db_driver->sth->fetch ) {
        if ( $self->db_driver->result_type eq 'row_result' ) {
            if ( my $class = $self->resultsets->[ $self->idx ] ) {
                my @data = @$row;
                
                my %args = map { shift @columns, $_ } @$row;

                return $class->new( %args );
            };
        }
    };

    return;
}

sub procedure_result {
    my $self = shift;

    unless ( $self->has_procedure_result ) {
        if ( $self->db_driver->result_type eq 'status_result' ) {
            my $res = $self->db_driver->sth->fetch->[0];
            $self->_procedure_result( $res );
            $self->db_driver->sth->finish;
        }
    };

    return $self->_procedure_result;
}

sub all {
    my $self = shift;

    my @result_sets = ();

    do {
        while ( my $row = $self->next_row ) {
            push @{ $result_sets[ $self->idx ] }, $row;
        }
    } while ( $self->next_resultset );

    return ( @result_sets, $self->procedure_result );
}

1;


