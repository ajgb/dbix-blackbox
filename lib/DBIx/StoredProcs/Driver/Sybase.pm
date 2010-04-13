
package DBIx::BlackBox::Driver::Sybase;

use Moose;

extends qw( DBIx::BlackBox::Driver );

has '+_result_types' => (
    default => sub {
        +{
            4043 => 'status_result',
            4040 => 'row_result',
        }
    }
);

sub result_type {
    my $self = shift;

    return $self->_result_types->{ $self->sth->{syb_result_type} } || '';
}

sub has_more_result_sets {
    my $self = shift;

    return $self->sth->{syb_more_results};
}

sub columns {
    my $self = shift;

    return map { $_->{NAME} } $self->sth->syb_describe;
}

1;

