
package DBIx::StoredProcs::Driver;

use Moose;

has connector => (
    is => 'rw',
    isa => 'DBIx::Connector',
);

sub error_handler { 1 };

1;

