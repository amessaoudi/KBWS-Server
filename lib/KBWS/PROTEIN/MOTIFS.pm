#!/usr/bin/env perl
use warnings;
use strict;

package KBWS::PROTEIN::MOTIFS;

use base q/Exporter/;
our @EXPORT= qw/_runPhobius/;

use lib qw(./lib/);
use KBWS::WRAPPER::EBI;
use KBWS::Utils;
use KBWS::IO;

use LWP::UserAgent;

sub _runPhobius {
    my $jobid= shift;
    my $seq=   shift;
    my %param= %{+shift};

    close STDOUT;

    my $baseUrl= 'http://www.ebi.ac.uk/Tools/services/rest/phobius';
    my %paramForEbi= (
	format => $param{outputformat},
	);

    if (_is_nucleotide($seq)) {
	$paramForEbi{'stype'}= 'dna';
    } else {
	$paramForEbi{'stype'}= 'protein';
    }

    unless ($paramForEbi{format}) {
        $paramForEbi{format}= 'grp';
    }

    foreach my $key (keys(%paramForEbi)) {
	# invalid parameter name
	if (!defined($paramForEbi{$key}) || $paramForEbi{$key} eq '') {
	    delete $paramForEbi{$key};
	    next;
	}

	# invalid parameter whose value is 0
	if ($paramForEbi{$key} =~ /[0-9\.]+/ && $paramForEbi{$key} == 0) {
	    delete $paramForEbi{$key};
	    next;
	}
    }

    # default parameters
    $paramForEbi{title}=    'KbwsSoapServer';
    $paramForEbi{email}=    'cory@g-language.org';
    $paramForEbi{sequence}= $seq;

    my $ua= LWP::UserAgent->new();
    $ua->env_proxy();

    my $response= $ua->post($baseUrl.'/run/', \%paramForEbi);
    if ($response->is_error) {
	# error (connect to EBI web server)
	$response->content() =~ m/<h1>([^<]+)<\/h1>/;
	_write_file('http status: '.$response->code.' '.$response->message.'  '.$1 => $jobid, "out");
    } else {
	my $jobid4ebi= $response->content();

	# polling!
	sleep(3);

	# status about EBI server
	my $status=     'PENDING';
	my $errorCount= 0;

	while ($status eq 'RUNNING' || $status eq 'PENDING' || ($status eq 'ERROR' && $errorCount < 2)) {
	    $status= _ebi_rest_request($jobid, $baseUrl.'/status/'.$jobid4ebi) || last;

	    if ($status eq 'ERROR') {
		$errorCount++;
	    } elsif ($errorCount > 0) {
		$errorCount--;
	    }
	    if ($status eq 'RUNNING' || $status eq 'PENDING' || $status eq 'ERROR') {
		sleep 3;
	    } elsif ($status eq 'FINISHED') {
		last;
	    }
	}

	# extention for result files
	my %extention= (
	    out => 'out',
	    );

	# get all result files from EBI server
	for my $ext (keys(%extention)) {
	    my $output_URL= $baseUrl.'/result/'.$jobid4ebi.'/'.$extention{$ext};

	    # download
	    my $outfile= "./result/".$jobid.".".$ext;
	    `wget -q $output_URL -O $outfile`;

	    # timeout or some error occored
	    if ($ext eq 'out' && -z $outfile) {
		_write_file('Time out connection to EBI: '.$jobid4ebi => $jobid, 'out');
	    }
	}
    }
}

1;
