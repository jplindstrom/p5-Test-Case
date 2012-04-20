use strict;
use warnings;

use Test::More;
use Test::Case;

my $cases = [
    {
        prefix      => "pref1",
        description => "desc1",
        setup       => { start => 17, add => 1 },
        expected    => { sum   => 18 },
    },
    {
        prefix      => "pref2",
        description => "desc2",
        setup       => { start => 18, add => 1 },
        expected    => { sum   => 19 },
    },
    {
    },
];

my $case_count = 0;
test_each_case $cases => sub {
    my ($case, $setup, $expected) = @_;
    $case_count++;

    note "Count: $case_count";
    is(ref($case), "HASH", "Correct case type");
    is(ref($setup), "HASH", "Correct setup type, including defaults");
    is(ref($expected), "HASH", "Correct expected type, including defaults");
};

is($case_count, 3, "Correct number of cases");

done_testing;
