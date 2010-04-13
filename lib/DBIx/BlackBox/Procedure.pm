
package DBIx::BlackBox::Procedure;

use MooseX::Role::Parameterized;
use DBIx::BlackBox::Result;

=encoding utf8

=head1 NAME

DBIx::BlackBox::Procedure - role consumed by procedure classes.

=cut

our $VERSION = '0.01';


=head1 ROLE PARAMETERS

    package MyDBBB::Procedure::ListCatalogs;

    with 'DBIx::BlackBox::Procedure' => {
        name => 'DB_Live..list_catalogs',
        resultsets => [qw(
            MyDBBB::ResultSet::Catalogs
            MyDBBB::ResultSet::CatalogData
        )],
    };

=head2 name

Name of the stored procedure.

Required.

isa: C<Str>.

=cut

parameter name => (
    isa => 'Str',
    required => 1,
);

=head2 resultsets

Names of the resultsets classes.

isa: C<ArrayRef>.

=cut

parameter resultsets => (
    isa => 'ArrayRef',
    default => sub { [] },
);

=head1 METHODS

=head2 exec

Executes stored procedure and returns L<DBIx::BlackBox::Result> object.

=cut

role {
    my $p = shift;
    my %args = @_;
    my $consumer = $args{consumer};

    method 'exec' => sub {
        my ($self, $dbdriver) = @_;

        my %params = map {
            my $name = $_->name;

            ( $name => $self->$name )
        } $self->meta->get_all_attributes;

        my $params = join(', ', map { '@'. $_ .' = ?' } keys %params);

        my $query = 'exec '. $p->name;
        if ( $params ) {
            $query .= ' '. $params;
        }

        my $sth = $dbdriver->connector->run(
            fixup => sub {
                my $dbh = shift;

                my $sth = $dbh->prepare( $query );
                $sth->execute( values %params );
                $sth;
            }
        );

        return DBIx::BlackBox::Result->new(
            sth => $sth,
            db_driver => $dbdriver,
            resultsets => $p->resultsets,
        );
    }
};

=head1 AUTHOR

Alex J. G. Burzyński, E<lt>ajgb at cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Alex J. G. Burzyński.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

no MooseX::Role::Parameterized;

1;

