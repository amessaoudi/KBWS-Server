#!/usr/bin/env perl
package KBWS::Utils;

use base q/Exporter/;
our @EXPORT = qw/ _generate_jobid     _process_request  _is_nucleotide
                  _write_file         _download_img     _timeout       
                  _failed2forkProcess _is_available_url _is_valid_jobid /;

#'''''''''''''''
# Dependencies
#,,,,,,,,,,,,,,,
use LWP::UserAgent;
use LWP::Simple;

use warnings;
use strict;

#'''''''''''''''
# Variables
#,,,,,,,,,,,,,,,
my $result_dir = './result/';

#'''''''''''''''
# Subrutines
#,,,,,,,,,,,,,,,

# Name    : _generate_jobid
# Purpose : generate safe jobid
# Usage   : my $jobid = _generate_jobid();
sub _generate_jobid {
    my $jobid = "kbws_".( (time % 1296000)*10 + int(rand(10)) + 1048576);

    while (-e $result_dir.$jobid.".out" || -f $result_dir.$jobid) {
        $jobid = ( (time % 1296000)*10 + int(rand(10)) + 1048576);
    }

    return $jobid;
}


# Name    : _process_request
# Purpose : process request (corresponding to redirect page)
# Usage   : my $response = _process_request($ua, $request);
sub _process_request {
    my ($ua, $request) = @_;
    my $res = $ua->request($request);
    while ($res->is_redirect) {
        my $url = $res->header('Location');
        $res = $ua->request(HTTP::Request->new(GET => $url));
    }
    return $res;
}


# Name    : _is_nucleotide
# Purpose : given sequence is nucleotide (return 1) or protein (return 0)
#           sheshold -> a ratio of "atgc" in sequence is 50% over
# Usage   : my $is_nuc = _is_nucleotide($seq);
sub _is_nucleotide {
    my $seq =  lc(shift);
    $seq    =~ s/>.+\n//g;

    my $threshold = 0.5;
    my $ratio     = 0.0;

    $ratio = $seq =~ tr/atcg/atcg/ / length($seq);
    if ($ratio > $threshold) {
        return 1;
    } else {
        return 0;
    }
}

sub _write_file {
    my $content= shift;
    my $jobid=   shift;
    my $ext=     shift;

    my $outfile= $result_dir.$jobid;
    if ($ext) {
        $outfile= $outfile.".".$ext;
    }

    open my $tmp, '>', $outfile;
    print $tmp $content;
    close $tmp;

    return $outfile;
}

# Name    : _download_img
# Purpose : download image file from URL
# Usage   : _download_img ( URL => jobid, extention );
sub _download_img {
    my $URL   = shift;
    my $jobid = shift;
    my $ext   = shift || "png";

    open  IMG, ">", $result_dir.$jobid.".".$ext;
    binmode IMG;
    print IMG get($URL);
    close IMG;
}

# make error file when timeout (die session)
sub _timeout {
   my $jobid = shift;

   unless (-e "../result/".$jobid.".out") {
      my $error_message = "ERROR!\n Sorry. Your session is timeout.\n";
      _write_file( $error_message => $jobid, "out" );
   }

   return 0;
}

sub _failed2forkProcess {
    my $jobid = shift;

    my $emsg = "Internal Server Error. Please contact the service administrator.\n";
    _write_file($emsg => $jobid, "out");

    return 0;
}

sub _is_available_url {
    my $url= shift;

    return 0 unless $url;

    if (get($url)) {
	return $url;
    } else {
	return 0;
    }
}

# given Job ID is safe ID
sub _is_valid_jobid {
    my $jobid= shift;

    # invalid jobid
    return -1 if !$jobid;
    return -1 if $jobid eq '';
    return -1 if $jobid !~ /^kbws_/;

    if ($jobid =~ /[;\.]/) {
	# Directory traversal attack
	return -1
    }

    return 1;
}

1;
