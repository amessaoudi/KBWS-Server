#!/usr/bin/env perl
use warnings;
use strict;

package KBWS::ALIGNMENT::MULTIPLE;

use base q/Exporter/;
our @EXPORT = qw/ _runClustalw _runKalign _runMafft _runMuscle _runTcoffee /;

use lib qw( ./lib/ );
use KBWS::WRAPPER::EBI;
use KBWS::Utils;
use KBWS::IO;

use File::Basename qw/ basename /;
use HTTP::Request::Common;
use LWP::UserAgent;
use LWP::Simple;
use HTML::Form;
use SOAP::Lite;

# ClustalW2
# Type : REST(EBI) : 'http://www.ebi.ac.uk/Tools/services/rest/clustalw2'
sub _runClustalw {
    my $jobid= shift;
    my $seq=   shift;
    my %param= %{+shift};

    close STDOUT;

    my $baseUrl= 'http://www.ebi.ac.uk/Tools/services/rest/clustalw2';
    my %paramForEbi= (
	"alignment"  => $param{'alignment'},     # Pairwise alignment method
	"ktup"       => $param{'ktup'},          # Word size
	"window"     => $param{'window'},        # Window size
	"score"      => $param{'score'},         # Pairwise score representation
	"topdiags"   => $param{'topdiags'},      # Number of best diags
	"pairgap"    => $param{'pairgap'},       # Gap penalty
	"pwmatrix"   => $param{'pwmatrix'},      # Protein matrix (pairwise)
	"pwdnamatrix"=> $param{'pwdnamatrix'},   # DNA matrix (pairwise)
	"pwgapopen"  => $param{'pwgapopen'},     # Gap open penalty (pairwise)
	"pwgapext"   => $param{'pwgapext'},      # Gap extension penalty (pairwise)
	"matrix"     => $param{'matrix'},        # Scoring matrix series (multi)
	"dnamatrix"  => $param{'dnamatrix'},     # DNA scoring matrix (multi)
	"gapopen"    => $param{'gapopen'},       # Gap creation penalty (multi)
	"gapext"     => $param{'gapext'},        # Gap extension penalty
	"gapdist"    => $param{'gapdist'},       # Gap separation penalty
	"iteration"  => $param{'iteration'},     # Iteration type
	"numiter"    => $param{'numiter'},       # Number of iterations
	"clustering" => $param{'clustering'},    # Clustering method
	"output"     => $param{'output'},        # Alignment format
	"outorder"   => $param{'outorder'},      # Order of sequences in alignment
	);

    if (_is_nucleotide($seq)) {
	$paramForEbi{'type'}= 'dna';
    } else {
	$paramForEbi{'type'}= 'protein';
    }

    # Compatability options, old service
    unless ($param{'endgaps'}) {
	$paramForEbi{'noendgaps'} = 1;
    }

    # Compatability options, old command-line
    if(!$paramForEbi{'alignment'} || $paramForEbi{'alignment'} eq 'full') {
	delete $paramForEbi{'alignment'};

	$paramForEbi{'alignment'}= 'fast' if($param{'quicktree'});
	$paramForEbi{'alignment'}= 'slow' if($param{'align'});
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
	    aln => "aln-clustalw",
	    dnd => "tree",
	    out => "out",
	    );

	if ($param{output} eq 'phylip') {
	    $extention{aln}= 'aln-phylip';
	}

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

# Kalign
# Type : REST(EBI) : 'http://www.ebi.ac.uk/Tools/services/rest/kalign'
sub _runKalign {
    my $jobid= shift;
    my $seq=   shift;
    my %param= %{+shift};

    close STDOUT;

    my $baseUrl= 'http://www.ebi.ac.uk/Tools/services/rest/kalign';

    my %paramForEbi= ();
    if ($param{'moltype'} && $param{'moltype'} ne 'auto') {
	$paramForEbi{'stype'}= $param{'moltype'} eq 'N' ? 'dna' : 'protein';
    } else {
	# sequence type (stype)
	if (_is_nucleotide($seq)) {
	    $paramForEbi{'stype'}= 'dna';
	} else {
	    $paramForEbi{'stype'}= 'protein';
	}
    }

    $paramForEbi{gapopen}= $param{'gpo'};
    $paramForEbi{gapext}=  $param{'gpe'};
    $paramForEbi{termgap}= $param{'tgpe'};
    $paramForEbi{bonus}=   $param{'bonus'};

    foreach my $key (keys(%paramForEbi)) {
	if (!defined($paramForEbi{$key}) || $paramForEbi{$key} eq '') {
	    delete $paramForEbi{$key};
	    next;
	}
	
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
    $ua->env_proxy;

    my $response= $ua->post($baseUrl.'/run/', \%paramForEbi);
    if ($response->is_error) {
	# error (connect to EBI web server)
	$response->content() =~ m/<h1>([^<]+)<\/h1>/;
	_write_file('http status: '.$response->code.' '.$response->message.'  '.$1 => $jobid, 'out');
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
	my %extention= (out => 'out');

	# get all result files from EBI server
	for my $ext (keys(%extention)) {
	    my $output_URL= $baseUrl.'/result/'.$jobid4ebi.'/'.$extention{$ext};

	    # download
	    my $outfile= './result/'.$jobid.'.'.$ext;
	    `wget -q $output_URL -O $outfile`;

	    if ($ext eq 'out' && -z $outfile) {
		_write_file('Time out connection to EBI: '.$jobid4ebi => $jobid, 'out');
	    }

	}
    }
}

# MAFFT
# Type : CGI : "http://mafft.cbrc.jp/alignment/server/index.html"
sub _runMafft {
    my $jobid= shift;
    my $seq=   shift;
    my %param= %{+shift};

    close STDOUT;

    # default parameter sets
    my @strategy= ('auto',     'FFT-NS-2', 'FFT-NS-1', 'FFT-NS-2', 'Medium',
		   'FFT-NS-i', 'E-INS-i',  'L-INS-i',  'G-INS-i',  'Q-INS-i');

    my %score_matrix=       ('amino'    => 'bl 62',    'nuc'      => 'kimura 200');

    my %score_matrix_amino= ('BLOSUM30' => 'bl 30',    'BLOSUM45' => 'bl 45',     'BLOSUM62' => 'bl 62',
			     'BLOSUM80' => 'bl 80',    'JTT100'   => 'jtt 100',   'JTT200'   => 'jtt 200');
    my %score_matrix_nuc=   ('1PAM'     => 'kimura 1', '20PAM'    => 'kimura 20', '200PAM'   => 'kimura 200');


    # get parameter
    my $outorder= $param{outorder} && $param{outorder} eq 'input' ? 'input'          : 'aligned';
    my $strategy= $param{strategy}                                ? $param{strategy} : 'auto';
    my $op=       $param{op}                                      ? $param{op}       : 1.53;
    my $ep=       $param{ep}                                      ? $param{ep}       : 0.0;

    my $homologs=      0;
    my $show_homologs= $param{showhomologs};
    my $num_homologs=  $param{numhomologs};
    my $threshold=     $param{threshold};
    my $reference_seq= $param{referenceseq} && $param{referenceseq} eq 'top' ? 'top' : 'longest';


    my $harrplot= 'plotandalignment';
    if ($param{harrplot}) {
	if ($param{harrplot} eq 'alignmentonly') {
	    $harrplot= 'alignmentonly';
	} elsif ($param{harrplot} eq 'plotonly') {
	    $harrplot= 'plotonly';
	}
    }

    # correct Strategy option (or 'auto')
    unless (grep /^$strategy$/, @strategy) {
	$strategy= 'auto';
    }

    # Gap opening penalty (1.0 ~ 3.0)
    if ($op < 1.0 || $op > 3.0) {
	$op= 1.53;
    }

    # Offset value (0.0 ~ 1.0)
    if ($ep < 0.0 || $ep > 1.0) {
	$ep= 0.0;
    }

    # $seq is nucleotide or not (protein)
    my $is_nucleotide= _is_nucleotide($seq);

    if (_is_nucleotide($seq)) {
	# nucleotide

	# ScoreMatrix (Nucleotide)
	if ($param{scorematrix} && $score_matrix_nuc{$param{scorematrix}}) {
	    $score_matrix{nuc}= $score_matrix_nuc{$param{scorematrix}};
	}

	# Plot BLAST hits (DNA only)
	if ($threshold > 1 || $threshold < 1e-100) {
	    $threshold= 1e-1;
	}

    } else {
	# protein

	# ScoreMatrix (Protein)
	if ($param{scorematrix} && $score_matrix_amino{$param{scorematrix}}) {
	    $score_matrix{amino}= $score_matrix_amino{$param{scorematrix}};
	}

	# Mafft-homologs (Protein only)
	if ($param{homologs} && $param{homologs} eq 'true') {
	    $homologs= 1;
	}
	if ($param{showhomologs} && $param{showhomologs} eq 'true') {
	    $show_homologs= 1;

	    if ($num_homologs < 5 || $num_homologs > 200) {
		$num_homologs= 50;
	    }
	    if ($threshold > 1e-5 || $threshold < 1e-40) {
		$threshold= 1e-10;
	    }
	}

    }

    my $ua=      LWP::UserAgent->new();
    my $request= $ua->get('http://mafft.cbrc.jp/alignment/server/index.html');
    my $form=    HTML::Form->parse($request);

    # input parameter
    $form->value('senddata'       => $seq                );
    $form->value('outorder'       => $outorder           );
    $form->value('strategy'       => $strategy           );
    $form->value('scorematrix'    => $score_matrix{amino});
    $form->value('scorematrixnuc' => $score_matrix{nuc}  );
    $form->value('op'             => $op                 );
    $form->value('ep'             => $ep                 );

    if ($is_nucleotide) {
	# nucleotide
	$form->value('referenceseq'      => $reference_seq);
	$form->value('harrplot'          => $harrplot     );
	$form->value('harrplotthreshold' => $threshold    );
    } else {
	# protein
	if ($homologs) {
	    $form->value('mafftE' => 'on');
	}
	if ($show_homologs) {
	    $form->value('mafftE_fullout' => 'on'         );
	    $form->value('mafftE_n'       => $num_homologs);
	    $form->value('mafftE_e'       => $threshold   );
	}
    }

    my $response= _process_request($ua, $form->click());
    my ($result_url)= $response->content() =~ m{ URL [=] [.] [.] (.+?) [>] }msx;

    if (get('http://mafft.cbrc.jp/alignment/server'.$result_url) =~ m{ Result </h3> <pre> (.+?) </pre> }msx) {
	_write_file($1."\n" => $jobid, 'out');
    } else {
	_write_file('something error occored!' => $jobid, 'out');
    }
}

# MUSCLE
# Type : CGI : "http://www.bioinformatics.nl/cgi-bin/muscle.pl"
sub _runMuscle {
    my $jobid= shift;
    my $seq=   shift;
    my %param= %{+shift};

    my $outfile = "../result/".$jobid.".out";

    close STDOUT;

    if (1) {
	# run WUR server (http://www.bioinformatics.nl/tools/muscle.html)

	my $url= 'http://www.bioinformatics.nl/cgi-bin/muscle.pl';
	my $ua=  LWP::UserAgent->new();

	# initialized
	my %send_param= (
	    'submit'    => 1,         # submit job
	    'rawdata'   => $seq,      # sequence (fasta only)
	    'outformat' => 'fasta',   # output format (fasta, clw, msf)
	    'outorder'  => 'aligned', # output order (aligned, input)
	    'gapopen'   => -3.00,     # gap open penalty
	    'gapextend' => -0.275,    # gap extension penalty
	    );

	# output file format
	my $outformat= $param{output};
	if ($outformat) {
	    if ($outformat eq 'clw' || $outformat eq 'msf' || $outformat eq 'html') {
		$send_param{outformat}= $outformat;
	    }
	}

	my $outorder= $param{outorder};
	if ($outorder && $outorder eq 'input') {
	    $send_param{outorder}= $outorder;
	}

	if (defined($param{gapopen})) {
	    $send_param{gapopen}= $param{gapopen};
	}

	if (defined($param{gapextend})) {
	    $send_param{gapextend}= $param{gapextend};
	}

	# send request
	my $request= POST($url, 'Content-type' => 'multipart/form-data', 'Content' => \%send_param);
	my $response= _process_request($ua, $request);

	# get response and make output file
	my ($result)= $response->content() =~ m{ <pre> \n [^\n]* [\n] (.+) </pre> }msx;
	_write_file($result => $jobid, 'out');
    } else {
        # run EBI Server
	my $wsdl= 'http://www.ebi.ac.uk/Tools/webservices/wsdl/WSMuscle.wsdl';

	my %paramForEbi= (
	    'output'     => $param{output},
	    'outputtree' => $param{outputtree},
	    'email'      => 'cory@g-language.org',
	    );

	unless ($paramForEbi{output}) {
	    $paramForEbi{output}= 'fasta';
	}

	my $soap= SOAP::Lite->service($wsdl)->proxy('http://localhost/', timeout => 600);
	my $content= {type => 'sequence', content => $seq};

	my (@contents)= ($content);

	my $paramsData=  SOAP::Data->name('params')->type(map => \%paramForEbi);
	my $contentData= SOAP::Data->name('content')->value(\@contents);

	my $jobid_EBI= $soap->runMuscle($paramsData, $contentData);

	sleep(1);

	# get response
	my $res= _getResultByEbi($soap, $jobid_EBI);
	if ($res) {
	    _write_file($res => $jobid, 'out');
	} else {
	    _write_file('Time out connection to EBI' => $jobid, 'out');
	}

    }
}

# T-COFFEE
# Type : REST(EBI) : http://www.ebi.ac.uk/Tools/services/rest/tcoffee
sub _runTcoffee {
    my $jobid= shift;
    my $seq=   shift;
    my %param= %{+shift};

    close STDOUT;

    my $baseUrl= 'http://www.ebi.ac.uk/Tools/services/rest/tcoffee';
    my %paramForEbi = (
	matrix => $param{matrix},   # Protein scoring matrix
	order  => $param{outorder}, # Order of sequences in alignment
	);

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
	_write_file('http status: '.$response->code.' '.$response->message.'  '.$1 => $jobid, 'out');
    } else {
	my $jobid4ebi= $response->content();

	# polling!
	sleep(3);

	# status about EBI server
	my $status= 'PENDING';
	my $errorCount= 0;

	while ($status eq 'RUNNING' || $status eq 'PENDING' || ( $status eq 'ERROR' && $errorCount < 2)) {
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
	    'out' => 'out',
	    'dnd' => 'tree',
	    'aln' => 'aln-clustalw',
	    );

	# get all result files from EBI server
	for my $ext (keys(%extention)) {
	    my $output_URL= $baseUrl.'/result/'.$jobid4ebi.'/'.$extention{$ext};

	    # download
	    my $outfile= './result/'.$jobid.'.'.$ext;
	    `wget -q $output_URL -O $outfile`;

	    # timeout or some error occored
	    if ($ext eq 'out' && -z $outfile) {
		_write_file('Time out connection to EBI' => $jobid, 'out');
	    }
	}
    }
}

1;
