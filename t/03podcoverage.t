use strict;
use warnings;
use Test::More tests => 2;

eval "use Test::Pod::Coverage 1.04";
plan skip_all => 'Test::Pod::Coverage 1.04 required' if $@;
#plan skip_all => 'set TEST_POD to enable this test' unless $ENV{TEST_POD};

my $parms = { trustme => [qr/_(POST|GET|DELETE|PUT)/, qr/^(begin|end)$/] };

pod_coverage_ok ( "TM::IP::Documents", $parms);
pod_coverage_ok ( "TM::IP::Documents::Controller::Root", $parms);

# all_pod_coverage_ok($parms);
