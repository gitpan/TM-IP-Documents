use strict;
use warnings;
use Test::More 'no_plan';
use Data::Dumper;
use HTTP::Request::Common qw/GET POST PUT DELETE/;
use HTTP::Status qw(:constants);
use JSON;

BEGIN { use_ok 'Catalyst::Test', 'TM::IP::Documents' }

my $cwd;
chomp($cwd = `pwd`);
'TM::IP::Documents'->config->{mapbase} = $cwd . '/t/';      # we want to test this whereever it is located

my $nr_files = 0;

my $index = from_json( request (GET '/test/.docs/index', 'Accept' => 'application/json')->content );
is (keys %$index, $nr_files, 'empty document repository');

my $ramsti = request (GET '/test/.docs/ramsti.txt', 'Accept' => '*/*');
is ($ramsti->code, HTTP_NOT_FOUND, 'file does not exist');


#--
$ramsti = request (PUT '/test/.docs/ramsti.txt', 'Accept' => '*/*', 'Content-Type' => 'text/plain', Content => 'xxxxx');
#warn Dumper $ramsti;
is ($ramsti->code, HTTP_CREATED,                                                  'file was created');
is ($ramsti->header ('Location'),       'http://localhost/test/.docs/ramsti.txt', 'file location');

$ramsti = request (GET '/test/.docs/ramsti.txt', 'Accept' => '*/*');
is ($ramsti->code, HTTP_OK, 'file does now exist');
is ($ramsti->content, 'xxxxx', 'file content');
is ($ramsti->header ('Content-Length'), 5,                                        'file length');
#warn Dumper $ramsti;
is ($ramsti->header ('Content-Type'), 'text/plain',                               'file type');

$index = from_json( request (GET '/test/.docs/index', 'Accept' => 'application/json')->content );
is (keys %$index, $nr_files+1, 'size document repository');


#---
$ramsti = request (PUT '/test/.docs/ramsti.txt', 'Accept' => '*/*', 'Content-Type' => 'text/plain', Content => 'aaaaaaaa');
#warn Dumper $ramsti;
is ($ramsti->code, HTTP_CREATED,                                                           'file was created');
$ramsti = request (GET '/test/.docs/ramsti.txt', 'Accept' => '*/*');
is ($ramsti->code, HTTP_OK, 'file does now exist');
is ($ramsti->content, 'aaaaaaaa', 'file content');

$index = from_json( request (GET '/test/.docs/index', 'Accept' => 'application/json')->content );
is (keys %$index, $nr_files+1, 'size document repository');

#--
$ramsti = request (DELETE '/test/.docs/ramsti.txt', 'Accept' => '*/*');
is ($ramsti->code, HTTP_NO_CONTENT, 'file was deleted');
$ramsti = request (GET '/test/.docs/ramsti.txt', 'Accept' => '*/*');
is ($ramsti->code, HTTP_NOT_FOUND, 'file does not exist anymore');

$index = from_json( request (GET '/test/.docs/index', 'Accept' => 'application/json')->content );
is (keys %$index, $nr_files, 'size document repository');

$ramsti = request (DELETE '/test/.docs/ramsti.txt', 'Accept' => '*/*');
is ($ramsti->code, HTTP_NOT_FOUND, 'file was deleted');

#warn Dumper $ramsti;


__END__




# DELETE /test/.docs/ramsti.txt ok
# index 0 files




__END__

# TODO index as table

ok( request('/')->is_success, 'Request should succeed' );
