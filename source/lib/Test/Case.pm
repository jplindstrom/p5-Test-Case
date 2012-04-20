package Test::Case;

=head1 NAME

Test::Case - Declare test cases and feed the configuration data to tests

=head1 DESCRIPTION

Test::Case helps you separate the variant and invariant pieces of a
test into data and code.

While this is not rocket science, it provides a nice structure in
which to write tests along with some niceties to mitigate the
downsides.

=head1 SYNOPSIS

    use Test::More;
    use Test::Case;

    my $cases = [
        {
            prefix      => "17+1",
            description => "Adding seventeen and one is even",
            setup       => { start => 17, add     => 1 },
            expected    => { sum   => 18, is_even => 1 },
        },
        # ... more cases
    ];
    test_each_case $cases => sub {
        my ($case, $setup, $expected) = @_;
        note "Setup";
        # This would call the unit under test
        my $result = $setup->{start} + $setup->{add};

        note "Test";
        is($result, $expected->{sum}, "+ works, awesome");
        is($result %2 == 0, $expected->{is_even}, "   and is_even is ok");
    };

Runs as

    #
    #
    # *** Adding seventeen and one is even ***
    # 17+1: Setup
    # 17+1: Test
    ok 1 - + works, awesome
    ok 2 -    and is_even is ok
    1..2



=head1 EXPORTED SUBROUTINES

=head2 test_each_case(@$cases, &$test_sub)

    test_each_case $cases => sub {
        my ($case, $setup, $expected) = @_;
        # Test code here
    };

Run through each $case (hash ref with keys: prefix, setup, etc. from
the config) and call $test_sub with $case, $setup, and $expected.

$setup is shorthand for $case->{setup}

$expected is shorthand for $case->{expected};

If you provide a $case->{description} or $case->{prefix}, it is
displayed at the start of each case. This is a very good idea.

If you provide a $case->{prefix}, it is set at the start of each case
and cleared out at the end. See L<Test::More::Prefix>. This is useful
if you have a long test which needs a lot of C<note> statements to
keep the reader informed about what's going on.



=head1 PROS AND CONS

=head2 Why would I want to do this?

Splitting the test into variant data and the invariant source code
leads to a few interesting properties.

=over 4

=item Overview

It's easy to get an overview of which cases are tested just by looking
at the case descriptions, either in the configuration or in the test
output.

=item Clear

Keeping all test configuration in one place makes it clear what really
defines a test case; what distinguishes it from the other cases.

=item Extensible

It's trivial to extend the configuration with a new case, making it
more likely that you cover edge cases properly.

It's also easy to add test configuration for error conditions in a
piecemeal way.

=back

=head2 What's the downside?

As we're running the same code again and again, it's difficult to
follow along in the test output. The only thing distinguishing one
from the other is the setup data being used.

This is what makes it important to communicate which test case is
being run.

C<test_each_case> will help you with this by using the case C<description>
and C<prefix>. But you'll also find it useful to C<note> the name and
value of important varaiables in the test code.

=head1 EXAMPLE

Here is a longer, complete, example of a dummy class and the tests for
it.

    # This contrived example is a bit long, so here's a ToC
    # 1. A dummy class Squirt, to have something to test
    # 2. Test data defining test cases
    # 3. Test code using test_each_case

    use strict;
    use warnings;

    # 1. A dummy class Squirt, to have something to test
    package Squirt;
    use Moose;

    has x => (is => "ro");

    sub int_sqrt {
        my ($self) = @_;
        my $x = $self->x;
        die("Can't do sqrt on negative numbers ($x)") if($x < 0);
        return int( sqrt($x) );
    }


    package main;
    use Test::More;
    use Test::Case;

    # 2. Test data defining test cases
    my $cases = [
        {
            description => "Negative number; dies correctly",
            setup => {
                sqrt_of => -412,
            },
            expected => {
                dies_with => qr/^Can't do sqrt on negative numbers \(-412\)/,
            },
        },
        {
            description => "Normal, 0",
            setup       => { sqrt_of => 0 },
            expected    => { result => 0 },
        },
        {
            description => "Normal, 9,",
            setup       => { sqrt_of => 9 },
            expected    => { result => 3 },
        },
        {
            prefix      => "Round dn",
            description => "Normal, 9.1, rounds down correctly",
            setup       => { sqrt_of => 9.1 },
            expected    => { result => 3 },
        },
        {
            prefix      => "Round up",
            description => "Normal, 8.9, rounds up correctly",
            setup       => { sqrt_of => 8.9 },
            expected    => { result => 2 },
        },
    ];

    # 3. Test code using test_each_case
    test_each_case $cases => sub {
        my ($case, $setup, $expected) = @_;

        note "Setup";
        my $squirt = Squirt->new({ x => $setup->{sqrt_of} });

        note "Test";
        my $result = eval { $squirt->int_sqrt() };
        if(my $e = $@) {
            if(my $expected_dies_with = $expected->{dies_with}) {
                like($e, $expected_dies_with, "Dies ok ($expected_dies_with)");
            }
            else {
                fail("Didn't expect to die with ($e)");
            }
            return;
        }

        like($result, qr/^\d+$/, "Result contains only digits");
        is($result, $expected->{result}, "Correct result ($expected->{result})");
    };

    done_testing;

=head1 BUGS

Please report any bugs or feature requests to C<bug-test-case at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Test-Case>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Test::Case


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Test-Case>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Test-Case>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Test-Case>

=item * Search CPAN

L<http://search.cpan.org/dist/Test-Case/>

=back


=head1 AUTHOR

Johan Lindstrom - C<johanl@cpan.org> on behalf of
Net-A-Porter - L<http://www.net-a-porter.com/>



=head1 LICENSE AND COPYRIGHT

Copyright 2012- Net-A-Porter.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.



=head1 ACKNOWLEDGEMENTS

Thanks to Net-A-Porter for providing time during one of the regular
Hack-days.


=cut

use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(test_each_case); ## no critic

use Guard;
use Test::More;
use Test::More::Prefix qw/ test_prefix /;

sub test_each_case {
    my ($test_cases, $test_sub) = @_;

    for my $case (@$test_cases) {
        my $setup    = $case->{setup}    || {};
        my $expected = $case->{expected} || {};

        test_prefix("");
        my $description = $case->{description} || $case->{prefix};
        if( defined($description) ) {
            note("\n\n*** $description ***");
        }

        my $prefix_guard = guard { test_prefix("") };
        if(defined( my $prefix = $case->{prefix} )) {
            test_prefix($prefix);
        }

        $test_sub->($case, $setup, $expected); ###JPL: eval
    }
}


1;
