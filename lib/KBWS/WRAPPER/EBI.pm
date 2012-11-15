#!/usr/bin/env perl

package KBWS::WRAPPER::EBI;

use base q/Exporter/;
our @EXPORT = qw/ _ebi_soap_get_results _ebi_rest_request /;

use MIME::Base64;
use LWP::UserAgent;

sub _ebi_rest_request {
    my $ua = LWP::UserAgent->new();
    $ua->agent("KBWS-SOAP-Server (kbws; Linux) ".$ua->agent());
    $ua->env_proxy;

    my $jobid = shift;
    my $requestUrl = shift;
    # Perform the request

    my $response = $ua->get($requestUrl);

    # Check for HTTP error codes
    if ( $response->is_error ) {
        $response->content() =~ m/<h1>([^<]+)<\/h1>/;
        _write_file($1, $jobid, "out");
    }

    # Return the response data
    return $response->content();
}


sub _ebi_soap_get_status {
    my $soap  = shift;
    my $jobid = shift;

    my $res = $soap->getStatus( SOAP::Data->name('jobId' => $jobid)->attr( {'xmlns' => ''} ) );

    return $res->valueof('//status');
}

sub _ebi_soap_client_poll {
    my $soap   = shift;
    my $jobid  = shift;
    my $status = 'PENDING';

    my $errorCount = 0;
    while ($status eq 'RUNNING' || $status eq 'PENDING' || ( $status eq 'ERROR' && $errorCount < 2 ) ) {
	$status = _ebi_soap_get_status($soap, $jobid);
	if ( $status eq 'ERROR' ) {
	    $errorCount++;
	} elsif ( $errorCount > 0 ) {
	    $errorCount--;
	}
	if ( $status eq 'RUNNING' || $status eq 'PENDING' || $status eq 'ERROR' ) {
	    sleep(3);
	}
    }
    return $status;
}

sub _ebi_soap_get_results {
    my $soap  = shift;
    my $jobid = shift;
    my @exts  = @{+shift};

    my %results;
    my $status = _ebi_soap_client_poll($soap, $jobid);
    if ($status eq 'FINISHED') {
	for my $ext (@exts) {
	    my $res = $soap->getResult(
				       SOAP::Data->name( 'jobId' => $jobid )->attr( { 'xmlns' => '' } ),
				       SOAP::Data->name( 'type'  => $ext   )->attr( { 'xmlns' => '' } ),
				      );
	    $results{$ext} = decode_base64( $res->valueof('//output') );
	}
    } else {
	$results{"error"} = "Job failed, unable to get results\n";
    }

    return \%results;
}

sub _getResultByEbi {
    my $soap = shift;
    my $jobid = shift;
    my $res;
    my (@retList) = ();

    my $result = 'RUNNING';
    while ( $result eq 'RUNNING' || $result eq 'PENDING' ) {
        $result = $soap->checkStatus($jobid);
        if ( $result eq 'RUNNING' || $result eq 'PENDING' ) {
            sleep 15;
        }
    }

    my $resultTypes = $soap->getResults($jobid);

    my $outformat = 'toolraw';
    my $selResultType;
    foreach my $resultType (@$resultTypes) {
        if ( $resultType->{type} eq $outformat ) {
            $selResultType = $resultType;
        }
    }
    $res = $soap->poll( $jobid, $selResultType->{type} );

    return $res;
}

1;
