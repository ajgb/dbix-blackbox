
package DBIx::StoredProcs::ResultSets;

use MooseX::Role::Parameterized;

parameter resultsets => (
    isa => 'ArrayRef',
);

role {
    my $p = shift;
    my %args = @_;
    my $consumer = $args{consumer};

    has '_resultsets' => (
        is => 'ro',
        isa => 'ArrayRef',
        auto_deref => 1,
        default => sub {
            $p->resultsets,
        },
    );
};

no MooseX::Role::Parameterized;

1;

