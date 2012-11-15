#!/usr/bin/env perl
use warnings;
use strict;

package KBWS::PROTEIN::LOCALIZATION;

use base q/Exporter/;
our @EXPORT = qw/ _runPsort _runPsort2 _runPsortb _runWolfPsort /;

use lib qw{ ./lib/ };
use KBWS::Utils;
use KBWS::IO;

use LWP::UserAgent;
use HTML::Form;

sub _runPsort {
    my $jobid= shift;
    my $seq=   shift;
    my %param= %{+shift};

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get('http://psort.ims.u-tokyo.ac.jp/form.html');

    my $form= HTML::Form->parse($request);

    $form->value(sequence => $seq);
    if ($param{-org}) {
	$form->value(origin => $param{-org});
    }
    if ($param{-title}) {
	$form->value(title => $param{-title});
    }

    my $response= _process_request($ua, $form->click());

    my $result=  $response->content();
    $result   =~ s/<.+?>//g;

    _write_file($result => $jobid, "out");
}

sub _runPsort2 {
    my $jobid= shift;
    my $seq=   shift;
    my %param= %{+shift};

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get('http://psort.ims.u-tokyo.ac.jp/form2.html');

    my $form= HTML::Form->parse($request);

    $form->value(sequence => $seq);

    my $response= _process_request($ua, $form->click());
    my $result=   $response->content();

    $result =~ s/<.+?>//g;
    $result =~ s/\n+/\n/g;

    _write_file($result => $jobid, 'out');
}


sub _runPsortb {
    my $jobid= shift;
    my $seq=   shift;
    my %param= %{+shift};

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get('http://www.psort.org/psortb/');

    my $form = HTML::Form->parse($request);

    my ($seqName)= split(/\n/, $seq);

    unless ($seqName =~ /^>.+$/) {
	$seq = ">YourSeq\n".$seq;
    }

    $form->value(seqs        => $seq);
    $form->value(gram        => $param{-gram});
    $form->value(sendresults => 'display');

    my $format= 'terse';
    if ($param{format}) {
	if (lc($param{format}) eq 'normal') {
	    $format= 'html';
	} elsif (lc($param{format}) eq 'long') {
	    $format= 'long';
	} elsif (lc($param{format}) eq 'short') {
	    $format= 'terse';
	}
    }

    $form->value(format => $format);

    my $response= _process_request($ua, $form->click());
    my $result=   $response->content();

    unless ($format eq 'terse' || $format eq 'long') {
	$result =~ m|<pre><code>(.+)</code>|ms;
	$result = $1;
    }

    $result =~ s/<a href=.+?>//g;
    $result =~ s/<\/a>//g;

    _write_file($result => $jobid, 'out');
}


sub _runWolfPsort {
    my $jobid= shift;
    my $seq=   shift;
    my %param= %{+shift};

    close STDOUT;

    unless ($param{org}) {
	# organisms is required parameter for WolfPsort
	_write_file("Please input 'org' parameter!" => $jobid, "out");
	exit(0);
    } else {
	my $ua=      LWP::UserAgent->new();
	my $request= $ua->get('http://wolfpsort.org/');

	my $form= HTML::Form->parse($request);

	$form->value(organism_type => lc($param{org}));
	$form->value(input_type    => 'fasta');
	$form->value(fasta_input   => $seq);

	my $response= _process_request($ua,$form->click);
	my ($url)= $response->content() =~ m|<PRE>(http.+?\.html)</PRE><BR>|ms;

	$response= $ua->request(HTTP::Request->new(GET => $url));

	my $count= 0;
	my $timeout= 1000;
	while ($count < $timeout) {
	    my $html= $response->content();

	    if ($html =~ m|<A href="(.+?)(?:#.*)?">|) {
		$url=      "http://wolfpsort.org/results/".$1;
		$response= $ua->request(HTTP::Request->new(GET => $url));

		$html= $response->content();

		my @table= $html =~ m|<TABLE.*?>(.+?)</TABLE>|msgi;

		my $result= q{};
		$result= $table[0];  # now version, return default result
		$result=~ s/\n//g;
		$result=~ s/<TD nowrap>/\t/g;
		$result=~ s/<\/TH>/\t/g;
		$result=~ s/<TR>\t?/\n/g;
		$result=~ s/<.+?>//g;

		_write_file($result => $jobid, 'out');

		$count= $timeout + 10000;
	    } else {
		$count++;
	    }
	    sleep(3);
	}
    }
}


1;
