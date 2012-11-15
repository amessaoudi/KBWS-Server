#!/usr/bin/env perl
use warnings;
use strict;

package KBWS::RNA::STRUCTURE;

use base q/Exporter/;
our @EXPORT = qw/ _runCentroidfold _runRNAfold /;

use lib qw( ./lib/ );
use KBWS::Utils;
use KBWS::IO;

use HTTP::Request::Common qw{POST};
use LWP::UserAgent;
use LWP::Simple;
use HTML::Form;
use JSON;

# Centroidfold
# Type : local installed : "./bin/centroid_fold"
sub _runCentroidfold {
    my $jobid= shift;
    my $seq=   shift;
    my %param= %{+shift};

    close STDOUT;

    # make query file
    _write_file($seq => $jobid, 'fasta');

    my %formdata= (
	seq   => $seq,
	model => 'CONTRAfold',
	gamma => 1024,
	);

    if ($param{model}) {
	if ($param{model} =~ /;/) {
	    ($param{model})= split /;/, $param{model};
	}

	# CONTRAfold or McCaskill
	if ($param{model} eq 'McCaskill') {
	    $formdata{model} = 'McCaskill';
	}
    }

    if ($param{gamma}) {
	if ($param{gamma} =~ /;/) {
	    ($param{gamma})= split /;/, $param{gamma};
	}
    }

    my $option=  '-g '.$formdata{gamma}.' -e '.$formdata{model};
    my $infile=  './result/'.$jobid.'.fasta';
    my $outfile= './result/'.$jobid.'.out';
    my $psfile=  './result/'.$jobid.'.ps';
    my $pngfile= './result/'.$jobid.'.png';

    system("./bin/centroid_fold $infile -o $outfile --postscript $psfile $option");

    system("convert $psfile $pngfile");
}

# RNAfold
# Type : CGI : "http://rna.tbi.univie.ac.at/cgi-bin/RNAfold.cgi"
sub _runRNAfold {
    my $jobid= shift;
    my $seq=   shift;
    my %param= %{+shift};

    close STDOUT;

    my $serv_url=  'http://rna.tbi.univie.ac.at/cgi-bin/RNAfold.cgi';
    my @dangling=  qw/ d1 d2 d3 d4 /;
    my @parameter= qw/ rna andronescu dna /;

    $seq =~ tr{/}{};

    my %form_data= (
	PAGE    => 2,    # hidden parameter (1=>start; 2=>polling; 3=>result)
	SCREEN  => $seq,
	proceed => 1,    # submit
	);

    $form_data{method}=    ($param{method} && $param{method} eq 'mfe') ? 'mfe' : 'p';
    $form_data{noCloseUG}= ($param{noclosegu}                        ) ? 'on'  : 'off';

    unless ($param{nolp}) { # check (after)
	$form_data{noLP} = 0;
    } else {
	$form_data{noLP} = 1;
    }

    if ($param{dangling}) {
	($form_data{dangling})= grep /^$param{dangling}$/, @dangling ? $param{dangling} : 'd2';
    } else {
	($form_data{dangling})= 'd2';
    }

    if ($param{param}) {
	($form_data{param})= grep /^$param{param}$/, @parameter ? $param{param} : 'rna';
    } else {
	($form_data{param})= 'rna';
    }

    $form_data{tmp}=  $param{tmp}  ? $param{tmp} : 37;
    $form_data{circ}= $param{circ} ? 'on'        : 'off';

    my $ua=       LWP::UserAgent->new();
    my $request=  POST($serv_url, [%form_data]);
    my $response= _process_request($ua, $request);

    my $base_URL=     'http://rna.tbi.univie.ac.at/RNAfold/';
    my $polling_html= $response->content();

    my ($result_URL)= $polling_html =~ m{ <meta [ ] http-equiv="refresh" [ ] content="5;URL=(.+?)"> }msx;
    my $result_html=  $ua->get($result_URL);

    while ($result_html->content() =~ m{ <meta [ ] http-equiv="refresh" [ ] content="5;URL=(.+?)"> }msx) {
	sleep(3);
	$result_html= $ua->get($1);
    }

    my ($seq_id)=   $result_html->content() =~ m{ ["] $base_URL ( .+? ) [.] vienna ["] }msx;

    $base_URL.= $seq_id;    
    my $imgURLbase= 'http://rna.tbi.univie.ac.at/cgi-bin/IC_helper.cgi?file=/u/html/'.substr($base_URL, 28);

    my $dp_img_URL= $imgURLbase.'_dp.eps&x=452&res=72&ext=png';
    my $ss_img_URL= $imgURLbase.'_ss.eps&x=452&res=72&ext=png';

    _download_img($dp_img_URL => $jobid.'_dp', 'png');
    _download_img($ss_img_URL => $jobid.'_ss', 'png');

    _write_file(get($base_URL.'.vienna') => $jobid, 'vienna');
    _write_file(get($base_URL.'.ct'    ) => $jobid, 'ct'    );
    _write_file(get($base_URL.'.out'   ) => $jobid, 'out'   );
}

1;
