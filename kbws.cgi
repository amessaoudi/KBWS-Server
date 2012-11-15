#!/usr/bin/env perl
use SOAP::Transport::HTTP;
use warnings;
use strict;

SOAP::Transport::HTTP::CGI->dispatch_to('KBWS')->handle();

BEGIN {
    use lib qw( ./lib );

    use POSIX "sys_wait_h";
    use Cwd;

    use KBWS;
}

