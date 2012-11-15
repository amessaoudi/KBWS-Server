#!/usr/bin/env perl -T
use Test::More tests => 4;
use strict;
use warnings;

BEGIN {
    use lib qw( ./lib );
    use_ok('KBWS::Utils');
    use KBWS::Utils;
}

my $correct_url   = "http://soap.g-language.org/kbws.wsdl";
my $uncorrect_url = "http://soap.g-language.org/kbws.wsd";

ok( !_is_available_url(), '"_is_available_url" return FALSE when given nothing');
ok( _is_available_url($correct_url) eq $correct_url, '"_is_available_url" return URL when given available URL');
ok( !_is_available_url($uncorrect_url), '"_is_available_url" return FALSE when given not available URL');

