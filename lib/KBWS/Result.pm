#!/usr/bin/env perl
use warnings;
use strict;

package KBWS::Result;

use base q/Exporter/;
our @EXPORT = qw/ checkStatus checkStatus_retJobid getResult getMultiResult /;

use CGI;

use KBWS::Utils;

sub checkStatus {
    my $self=  shift;
    my $jobid= shift;

    unless ($jobid) {
        return -1;
    } elsif (-e './result/'.$jobid.'.out') {
        return 1;
    } else {
        return 0;
    }
}

sub checkStatus_retJobid {
    my $self=  shift;
    my $jobid= shift;

    return 0 unless _is_valid_jobid($jobid);

    if (-e './result/'.$jobid.'.out') {
        return $jobid;
    } else {
        return 0;
    }
}

sub getResult {
    my $self=  shift;
    my $jobid= shift;

    my $result= '';
    if ($jobid && _is_valid_jobid($jobid)) {
	open my $FILE, '<', "./result/$jobid.out";
	while (<$FILE>) {
	    $result.= $_;
	}
	close $FILE;
    } else {
	$result.= 'Please use available Job ID';
    }

    return SOAP::Data->type('string')->value($result);
}

sub getMultiResult {
    my $self=  shift;
    my $jobid= shift;
    my $type=  shift;

    if ($type eq '' || $type eq 'txt') {
        $type= 'out';
    }

    my $result_file= "result/$jobid.$type";

    my $result= '';
    if (_is_valid_jobid($jobid)) {
	if (-B './'.$result_file || $type eq 'eps' || $type eq 'pdf' || $type eq 'gif' || $type eq 'svg') {
	    # result file is binary data or image file : return URL
	    $result= 'http://soap.g-language.org/kbws/'.$result_file;
	} else {
	    # result file is not binary data (text data)
	    open my $FILE, '<', $result_file;
	    while (<$FILE>) {
		$result .= $_;
	    }
	    close $FILE;
	}
    }

    return SOAP::Data->type('string')->value($result);
}

1;
