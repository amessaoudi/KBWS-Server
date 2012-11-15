#!/usr/bin/env perl
######################################
# sub module for kblast (runBlast)
#  check database info
######################################

package KBWS::ALIGNMENT::LOCAL::DB;

use base q/Exporter/;
our @EXPORT = qw/ _checkDB4BLAST _DB_list/;

use warnings;
use strict;

# check database list
## input  -> Database Name                        [String]
## output -> Database List (for NCBI, EBI, DDBJ)  [Array]
sub _checkDB4BLAST {
    my $db   = lc(shift);

    my (%protDB, %nuclDB);
    my (@switch, @database);

    my $db_kind = "";
    for ( split(/\n/, `cat ./dat/nucleotide.txt`) ) {
        next if $_ =~ m/ [#] /x;
	$_ =~ m|(.+):(.+) -> (.+)|;
	$nuclDB{lc($2)}->{server}  = $1;
	$nuclDB{lc($2)}->{db}      = $2;
	$nuclDB{lc($2)}->{examine} = $3;
    }

    for ( split(/\n/, `cat ./dat/protein.txt`) ) {
        next if $_ =~ m/ [#] /x;
        $_ =~ m|(.+):(.+) -> (.+)|;
        $protDB{lc($2)}->{server}  = $1;
        $protDB{lc($2)}->{db}      = $2;
        $protDB{lc($2)}->{examine} = $3;
    }

    if ($db eq 'nt') {
        @database = ('nt','DDBJ','em_rel');
        @switch   = qw{1 1 1};
    } elsif ($db eq 'EST') {
        @database = ('est','ddbjest',undef);
        @switch   = qw{1 1 0};
    } elsif ($db eq 'STS') {
        @database = ('sts','ddbjsts',undef);
        @switch   = qw{1 1 0};
    } elsif ($db eq 'human') {
        @database = ('9606_genomic','ddbjhum',undef);
        @switch   = qw{1 1 0};
    } elsif ($db eq 'est_hum') {
        @database = ('est_human','est_hum','em_rel_est_hum');
        @switch   = qw{1 1 1};
    } elsif ($db eq 'est_mous') {
        @database = ('est_mouse','est_mous','em_rel_est_mus');
        @switch   = qw{1 1 1};
    } else {
        if (my $server = $nuclDB{$db}->{server}) {
            if ($server eq 'NCBI') {
                @database = ($nuclDB{$db}->{db},undef,undef);
                @switch   = qw{1 0 0};
            } elsif ($server eq 'DDBJ') {
                @database = (undef,$nuclDB{$db}->{db},undef);
                @switch   = qw{0 1 0};
            } elsif ($server eq 'EBI') {
                @database = (undef,undef,$nuclDB{$db}->{db});
                @switch   = qw{0 0 1};
            }
        }
    }

    if ( $#database > -1 ) {
        $db_kind = "nucleotide";
        return $db_kind, @database, @switch;
    }

    if ($db eq 'swissprot') {
        @database = ('swissprot','SWISS','uniprotkb_swissprot');
        @switch   = qw/1 1 1/;
    } elsif ($db eq 'pdb') {
        @database = ('pdbaa','PDB','pdb');
        @switch   = qw{1 1 1};
    } elsif ($db eq 'uniprot') {
        @database = (undef,'UNIPROT','uniprot');
        @switch   = qw{0 1 1};
    } else {
        my $server = $protDB{$db}->{server};
        if ($server eq 'NCBI') {
            @database = ($protDB{$db}->{db},undef,undef);
            @switch   = qw{1 0 0};
            $switch[0] = 'NCBI';
        } elsif ($server eq 'DDBJ') {
            @database = (undef,$protDB{$db}->{db},undef);
            @switch   = qw{1 0 1};
        } elsif ($server eq 'EBI') {
            @database = (undef,undef,$protDB{$db}->{db});
            @switch   = qw{0 0 1};
        }
    }

    if ( $#database > -1 ) {
        $db_kind = "protein";
        return $db_kind, @database, @switch;
    }

    return ("$db is not supported Database");
}

sub _DB_list{
    my $type      = shift;
    my $dat_file  = "./dat/".$type.".txt";
    my $e_message = "Internal Server Error: Failed to get ".$type." DB information";

    my $report = "";
    open  NUC, "<", $dat_file or return $e_message;
    while (<NUC>) {
        my $line = $_;
        next if substr($line, 0, 1) eq '#';
        chomp($line);
        my ($server, $DB, $comment) = $line =~ m{ (.+) [:] (.+) [ ] -> [ ] (.+) }msx;
        $report .= $DB." "x(21-length($DB)).ucfirst($type)."\t".$server."\t".$comment."\n";
    }
    close NUC;

    return $report;
}

1;
