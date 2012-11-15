#!/usr/bin/env perl
use warnings;
use strict;

package KBWS::ALIGNMENT::LOCAL;

use base q/Exporter/;
our @EXPORT = qw/ _runBlast _runSsearch /;

use lib qw{ ./lib/ };
use KBWS::ALIGNMENT::LOCAL::Blast;
use KBWS::ALIGNMENT::LOCAL::DB;
use KBWS::Utils;
use KBWS::IO;

use POSIX "sys_wait_h";
use LWP::UserAgent;

sub _runBlast {
    my $jobid= shift;
    my $seq=   shift;
    my %param= %{+shift};

    # This method is called by child process
    close STDOUT;

    my $program=    $param{'p'};      delete $param{'p'};
    my $database=   $param{'d'};      delete $param{'d'};
    my $e_value=    $param{'e'};      delete $param{'e'};
    my $reportForm= $param{'m'};      delete $param{'m'};
    my $server=     $param{'server'}; delete $param{'server'};

    
    if (!$e_value || $e_value < 0) {
	$e_value= 1e-10;
    }

    ### write original fasta file
    my $infile= _write_file($seq => $jobid, 'fasta');
    my $outfile= './result/'.$jobid.'.out';
    my $infoDir= './result/';
    
    if (!$program) {
	$program= 'auto';
    }
    if (!$database) {
	$database= 'swissprot';
    }
    
    # check available database or not.
    # Database table is './dat/*'
    my @switch;
    my @database= _checkDB4BLAST($database);
    my $db_kind=  shift(@database);
    
    if ( $program eq 'auto' ) {
	if ( _is_nucleotide($seq) ) {
	    if ( $db_kind eq 'nucleotide' ) {
		$program = 'blastn';
	    } elsif ( $db_kind eq 'protein' ) {
		$program = 'blastx';
	    } else {
		_write_file( 'DB select error' => $jobid, 'out' );
		exit(0);
	    }
	} else {
	    if ( $db_kind eq 'protein' ) {
		$program = 'blastp';
	    } else {
		_write_file( "DB select error" => $jobid, "out" );
		exit(0);
	    }
	}
    } elsif ( $program eq 'blastn' || $program eq 'blastx' ) {
	if ( !_is_nucleotide($seq) ) {
	    _write_file( $program." requires Nucleotide sequence" => $jobid, "out" );
	}
    } elsif ( $program eq 'blastp' ) {
	if ( _is_nucleotide($seq) ) {
	    _write_file( "blastp requires Protein sequence" => $jobid, "out" );
	}
    } else {
	_write_file( "$program is not supported" => $jobid, "out" );
	exit(0);
    }
    
    unless ( defined($database[0]) || defined($database[1]) || defined($database[2]) ) {
	_write_file( "DB select error" => $jobid, "out" );
	exit(0);
    }
    
    for (0 .. 2) {
	$switch[$_] = $database[$_+3];
	$database[$_+3] = undef;
    }
    
    # check "which server can be used?" by blast option
    ## NCBI -> -p, -d, -e, -m
    ## EBI  -> excluding @paramOnlyDDBJ
    ## DDBJ -> all
    # my @paramOnlyDDBJ = qw{ f G E X I q r v b Q J W z k P Y S l U y Z L w t B V};
    for ( keys(%param) ) {
	unless ( defined $param{$_} ) {
	    delete $param{$_};
	}
    }
    
    if (!$server) {
	$server= $switch[0] ? "NCBI"
	       : $switch[1] ? "DDBJ"
	       :              "EBI";
    }
    
    if (      $server eq 'NCBI' && $switch[0] ) {
	_write_file($e_value." server->".$server." p->".$program." d->".$database[0]."\n" => $jobid, "report");
	_runBLAST2NCBI($jobid, $program, $database[0], $e_value, $infile, $reportForm);
    } elsif ( $server eq 'DDBJ' && $switch[1] ) {
	_write_file("server->".$server." p->".$program." d->".$database[1]."\n" => $jobid, "report");
	_runBLAST2DDBJ($jobid, $program, $database[1], $e_value, $infile, $reportForm, \%param);
    } elsif ( $server eq 'EBI'  && $switch[2] ) {
	_write_file("server->".$server." p->".$program." d->".$database[2]."\n" => $jobid, "report");
	_runBLAST2EBI( $jobid, $program, $database[2], $e_value, $infile, $reportForm, \%param);
    } else {
	_write_file ("Internal error!\n" => $jobid, "out" );
    }
}

# SSEARCH
# Type : REST : 'http://www.ebi.ac.uk/Tools/services/rest/fasta';
sub _runSsearch {
    my $jobid= shift;
    my $seq=   shift;
    my %param= %{+shift};

    close STDOUT;

    # make query file
    _write_file($seq => $jobid, 'fasta');

    # initialize
    my $ua= LWP::UserAgent->new();
    $ua->env_proxy;
    my $baseUrl= 'http://www.ebi.ac.uk/Tools/services/rest/fasta';
    my $outfile= './result/'.$jobid.'.out';

    my %param4ebi= %param;

    $param4ebi{'sequence'}=   $seq;
    $param4ebi{'program'}=    'ssearch';
    $param4ebi{'database'}=   $param{d};
    $param4ebi{'email'}=      'cory@g-language.org';
    $param4ebi{'title'}=      'KBWS BLAST (EBI)';
    $param4ebi{'alignments'}= 100 unless $param4ebi{'alignments'};
    $param4ebi{'stype'}=      _is_nucleotide($seq) ? 'dna' : 'protein';

    delete $param4ebi{'d'};
    delete $param4ebi{'-d'};
    delete $param4ebi{'moltype'};
    delete $param4ebi{'-moltype'};

    for (keys(%param4ebi)) {
	unless ($param4ebi{$_}) {
	    delete $param4ebi{$_};
	    next;
	}
	if ($param4ebi{$_} eq 'false') {
	    delete $param4ebi{$_};
	} elsif ($param4ebi{$_} eq 'true') {
	    $param4ebi{$_} = 1;
	}
    }

    # throw user job to EBI
    my $response= $ua->post($baseUrl.'/run/', \%param4ebi);

    # EBI server error is occored
    if ($response->is_error()) {
	$response->content() =~ m/<h1>([^<]+)<\/h1>/;
	_write_file('http status: '.$response->code.' '.$response->message.'  '.$1 => $jobid, 'out');
	return 0;
    }

    my $jobid4ebi= $response->content();

    # polling to EBI server
    my ($status, $errorCount)= ('PENDING', 0);
    while ($status eq 'RUNNING' || $status eq 'PENDING' || ( $status eq 'ERROR' && $errorCount < 2 ) ) {
	$status = _ebi_rest_request($jobid, $baseUrl.'/status/'.$jobid4ebi) || last;

	if ( $status eq 'ERROR' ) {
	    $errorCount++;
	} elsif ( $errorCount > 0 ) {
	    $errorCount--;
	}
	if ( $status eq 'RUNNING' || $status eq 'PENDING' || $status eq 'ERROR' ) {
	    sleep 3;
	} elsif ($status eq 'FINISHED') {
	    last;
	}
    }

    my $output_URL = $baseUrl.'/result/'.$jobid4ebi.'/out';

    my $tmp_out = $outfile.".1";
    system("wget -q $output_URL -O $tmp_out");
    system("mv $tmp_out $outfile");
}


1;

