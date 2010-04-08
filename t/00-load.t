#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'DBIx::StoredProcs' ) || print "Bail out!
";
}

diag( "Testing DBIx::StoredProcs $DBIx::StoredProcs::VERSION, Perl $], $^X" );
