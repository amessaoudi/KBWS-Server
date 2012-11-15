#!/usr/bin/env perl
use warnings;
use strict;

package KBWS::NUCLEIC::COMPOSITION;

use base q/Exporter/;
our @EXPORT = qw/ _runWeblogo /;

use lib qw( ./lib/ );
use KBWS::Utils;
use KBWS::IO;

use LWP::UserAgent;
use HTML::Form;

# WebLogo
# Type : Installed application
sub _runWeblogo {
    my $jobid= shift;
    my $seq=   shift;
    my %param= %{+shift};

    close STDOUT;

    my $format= 'png';
    if ($param{format}) {
	if (lc($param{format}) eq 'gif') {
	    $format= 'gif';
	} elsif (lc($param{format}) eq 'eps') {
	    $format= 'eps';
	} elsif (lc($param{format}) eq 'pdf') {
	    $format= 'pdf';
	}
    }

    my $title='';
    if ($param{title}) {
	$title= $param{title};
    }

    my $outfile= './result/'.$jobid.'.'.$format;

    my $ua= LWP::UserAgent->new();

    my $request= $ua->get('http://weblogo.threeplusone.com/create.cgi');
    my $form= HTML::Form->parse($request->decoded_content(), $request->base());

    $form->value('sequences'  => $seq);
    $form->value('format'     => $format);
    $form->value('logo_title' => $title);

    my $res = _process_request($ua, $form->click('cmd_create'));

    open my $fh, '>', $outfile;
    print $fh $res->content();
    close $fh;

    my $result_url= 'http://soap.g-language.org/kbws/result/'.$jobid.'.'.$format;
    _write_file($result_url => $jobid, 'out');
}

1;
