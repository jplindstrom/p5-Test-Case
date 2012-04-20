#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Test::Case' ) || print "Bail out!
";
}

diag( "Testing Test::Case $Test::Case::VERSION, Perl $], $^X" );
