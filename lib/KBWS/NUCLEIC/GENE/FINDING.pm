#!/usr/bin/env perl
use warnings;
use strict;

package KBWS::NUCLEIC::GENE::FINDING;

use base q/Exporter/;
our @EXPORT = qw/ _runGenemarkhmm _runGlimmer _runtRNAscan /;

use lib qw( ./lib/ );
use KBWS::Utils;
use KBWS::IO;

use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use HTML::Form;
use LWP::Simple;

# GeneMarkHMM
# Type : CGI : "http://exon.gatech.edu/genemark/gmhmm2_prok.cgi"
sub _runGenemarkhmm {
    my $jobid= shift;
    my $seq=   shift;
    my %param= %{+shift};

    close STDOUT;

    my $result= '';
    my $ua=     LWP::UserAgent->new();

    if ($param{list}) {
	$result= get('http://exon.gatech.edu/genemark/prokModelList.txt');
    } else {
	my $request= $ua->get('http://exon.gatech.edu/genemark/gmhmm2_prok.cgi');
	my $form=    HTML::Form->parse($request);

	$form->value('sequence', $seq);

	if ($param{title}) {
	    $form->value('title', $param{title});
	}

	if ($param{rbs} && $param{rbs} ne 'false') {
	    $form->value('use_rbs', 1);
	}

	if ($param{org}) {
	    my $org= $param{org};

	    # given organism is available or not
	    my $is_invalid_org = 1;
	    for (split /\n/, get('http://exon.gatech.edu/genemark/prokModelList.txt')) {
		if ($org eq $_) {
		    $form->value('org', $org);
		    $is_invalid_org= 0;
		    last;
		}
	    }

	    if ($is_invalid_org) {
		# error message
		$result.= "You cannot specify this species\n";
		$result.= "To show species list, you can use -list option\n";
	    }
	}

	if (!$result) {
	    my $response= $ua->request($form->click());
	    $result= $response->content();

	    $result =~ m|(Gene Predictions in Text Format.+)<PRE>(.+)</PRE>|msg;

	    my ($header,$body) = ($1,$2);
	    $header =~ s/(?:<.+?>)+/\n/gm;

	    $result= $header.$body;
	}
    }

    _write_file($result => $jobid, 'out');
}

# Glimmer
# Type : CGI : 'http://www.ncbi.nlm.nih.gov/genomes/MICROBES/glimmer_3.cgi'
sub _runGlimmer {
    my $jobid= shift;
    my $seq=   shift;
    my %param= %{+shift};

    close STDOUT;

    # 11 (Bacteria, Archaea) or 4 (Mycoplasma/Spiroplasma)
    my $gencode= $param{gencode};
    if (!$gencode || $gencode != 4) {
	$gencode= 11;
    }

    # 0 (circular) or 1 (liner)
    my $topology= $param{topology};
    if ($topology && $topology eq 'liner') {
	$topology= 1; 
    } else {
	$topology= 0;
    }

    my $url=     'http://www.ncbi.nlm.nih.gov/genomes/MICROBES/glimmer_3.cgi';
    my %formdata= (
	'sequence' => $seq,
	'gencode'  => $gencode,
	'topology' => $topology,
	);

    my $request= POST($url, [%formdata]);

    my $ua=  LWP::UserAgent->new();
    my $res= $ua->request($request);

    my $contents= $res->as_string();

    # polling
    while ($contents =~ m|<INPUT TYPE="submit" NAME="Check Status" VALUE="Check Status">|
	|| $contents =~ m|<p/>Progress message: <br/>Job is still running.<br/>|          ) {

	my ($url)= $contents =~ m|method="post" action="(.+?)"|;

	my $request= POST($url, []);

	sleep(3);

	my $res= $ua->request($request);
	$contents= $res->as_string();
    }

    $contents =~ m|<pre>(.+)</pre>|msg;
    $contents= $1;
    $contents =~ s/\&gt\;/\>/g;

    _write_file($contents => $jobid, 'out');
}


# tRNAScan-SE
# Type : CGI : "http://lowelab.ucsc.edu/tRNAscan-SE/"
sub _runtRNAscan {
    my $jobid= shift;
    my $seq=   shift;
    my %param= %{+shift};

    close STDOUT;

    my $ua=      LWP::UserAgent->new();
    my $request= $ua->get('http://lowelab.ucsc.edu/tRNAscan-SE/');

    my $form= HTML::Form->parse($request);

    $form->value('format', 'raw');
    $form->value('seq',    $seq);

    if ($param{title}) {
	$form->value('seqname', $param{title});
    }

    if ($param{source}) {
	$form->value('organism', $param{source});
    }

    for my $p (qw/ pesudogene origin ace codons fpos breakdown /) {
	if ($param{$p}) {
	    $form->value($p, 'on');
	}
    }

    for my $p (qw/ mode gcode covescore euparams euscore /) {
	if ($param{$p}) {
	    $form->value($p, $param{$p});
	}
    }

    my $response= _process_request($ua, $form->click());
    my ($result)= $response->content() =~ m{ <PRE> (.+) </PRE> }msx;

    $result =~ s/<[^\.]+?>//g;
    $result =~ s/<FORM .+?\">//g;
    $result =~ s/<INPUT .+?\">//g;

    _write_file($result => $jobid, 'out');
}

1;
