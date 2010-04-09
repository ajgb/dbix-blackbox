
package DBIx::StoredProcs::Driver::Sybase;

use Moose;

extends qw( DBIx::StoredProcs::Driver );

sub error_handler {
    my $self = shift;

    my($err, $severity, $state, $line, $server,
           $proc, $msg, $sql, $err_type) = @_;

    return 1;
}


1;

