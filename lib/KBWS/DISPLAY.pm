#!/usr/bin/env perl
use warnings;
use strict;

package KBWS::DISPLAY;

use base q/Exporter/;
our @EXPORT = qw/ _showBlastDB /;

use lib qw{ ./lib };
use KBWS::ALIGNMENT::LOCAL::DB;

use POSIX 'sys_wait_h';

# showBlastDB (showdb for kblast)
# Type : original subrutine
sub _showBlastDB {
    my %param= %{+shift};

    my $header=<<EOF;
# Name               Type       Server  Comment
# ================== ========== ======= =======
EOF

    my $report= $header;

    if ($param{'nucleotide'} && $param{'nucleotide'} ne 'false') {
        $report.= _DB_list("nucleotide");
    }

    if ($param{'protein'} && $param{'protein'} ne 'false') {
        $report.= _DB_list('protein');
    }

    return $report;
}

1;


