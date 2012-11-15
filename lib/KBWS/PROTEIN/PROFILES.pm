#!/usr/bin/env perl
use warnings;
use strict;

package KBWS::PROTEIN::PROFILES;

use base q/Exporter/;
our @EXPORT = qw/ _runFetchData _runFetchBatch /;

use lib qw( ./lib/ );
use KBWS::Utils;
use KBWS::IO;

use File::Basename qw/ basename /;
use SOAP::Lite;

sub _runFetchData {
    my $jobid= shift;
    my $query= shift;
    my %param= %{+shift};

    close STDOUT;

    my $wsdl= 'http://www.ebi.ac.uk/Tools/webservices/wsdl/WSDbfetch.wsdl';
    my $soap= SOAP::Lite->service($wsdl)->proxy('http://localhost/', timeout => 600);

    my $format= $param{'format'};
    unless ($format) {
	$format= 'default';
    }
    my $style= $param{"style"};
    unless ($style) {
	$style = 'raw';
    }
    my $res = $soap->fetchData( $query, $format, $style );

    $res =~ s/<.+?>//g;

    if (lc($format) eq 'fasta') {
	$res =~ m{ ^ \n ([>] .+) $ }mxs;
	$res = $1;
    }

    _write_file($res => $jobid, 'out');
}

sub _runFetchBatch{
    my $jobid=  shift;
    my $db=     shift;
    my $idList= shift;
    my %param=  %{+shift};

    close STDOUT;

    my $wsdl= 'http://www.ebi.ac.uk/Tools/webservices/wsdl/WSDbfetch.wsdl';
    my $soap= SOAP::Lite->service($wsdl)->proxy('http://localhost/', timeout => 600);

    $idList =~ s/[ \t\n\r;]+/,/g;
    $idList =~ s/,+/,/g;

    my $format= $param{'format'};
    unless ($format) {
	$format= 'default';
    }
    my $style= $param{'style'};
    unless ($style) {
	$style= 'raw';
    }

    my $res = $soap->fetchBatch($db, $idList, $format, $style);
    _write_file($res => $jobid, 'out');
}

1;
