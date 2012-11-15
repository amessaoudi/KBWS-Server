#!/usr/bin/env perl
use warnings;
use strict;

package KBWS::MAPPING::PATHWAYMAP;

use base q/Exporter/;
our @EXPORT = qw/ _map2PathwayProjector /;

use lib qw( ./lib/ );
use KBWS::Utils;
use KBWS::IO;

use SOAP::Lite;

# PathwayProjector
# Type : SOAP : "http://soap.g-language.org/PathwayProjector.wsdl"
sub _map2PathwayProjector {
    my $jobid= shift;
    my $data=  shift;
    my %param= %{+shift};

    close STDOUT;

    my @input= split(/\n/, $data);

    my $drvr= SOAP::Lite->service('http://soap.g-language.org/PathwayProjector.wsdl');
    my @URL=  $drvr->mapping(SOAP::Data->type(array => \@input) );

    _download_img($URL[0] => $jobid, 'png');
    _write_file(  $URL[1] => $jobid, 'out');
}

1;
