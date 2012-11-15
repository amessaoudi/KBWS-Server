#!/usr/bin/env perl
use warnings;
use strict;

use CGI;

use lib qw{ ./lib };
use KBWS;

# definition for REST interface
my %method_table= (
                   blast                 => 'runBlast',
                   ssearch               => 'runSsearch',
                   clustalw              => 'runClustalw',
                   kalign                => 'runKalign',
                   mafft                 => 'runMafft',
                   muscle                => 'runMuscle',
                   tcoffee               => 'runTcoffee',
                   centroidfold          => 'runCentroidfold',
                   rnafold               => 'runRNAfold',
                   phobius               => 'runPhobius',
                   fetchdata             => 'runFetchData',
                   fetchbatch            => 'runFetchBatch',
                   psort                 => 'runPsort',
                   psort2                => 'runPsort2',
                   psortb                => 'runPsortb',
                   wolfpsort             => 'runWolfPsort',
                   genemarkhmm           => 'runGenemarkhmm',
                   glimmer               => 'runGlimmer',
                   trnascan              => 'runtRNAscan',
                   weblogo               => 'runWeblogo',
                   pathwayprojector      => 'map2PathwayProjector',
                   map2pathwayprojector  => 'map2PathwayProjector',
                   maptopathwayprojector => 'map2PathwayProjector',
                   protpars              => 'runProtpars',
                   protdist              => 'runProtdist',
                   dnapars               => 'runDnapars',
                   dnapenny              => 'runDnapenny',
                   dnacomp               => 'runDnacomp',
                   dnainvar              => 'runDnainvar',
                   dnaml                 => 'runDnaml',
                   dnamlk                => 'runDnamlk',
                   dnadist               => 'runDnadist',
                   gendist               => 'runGendist',
                   seqboot               => 'runSeqboot',
                   restml                => 'runRestml',
                   clique                => 'runClique',
                   fitch                 => 'runFitch',
                   kitsch                => 'runKitsch',
                   neighbor              => 'runNeighbor',
                   contml                => 'runContml',
                   mix                   => 'runMix',
                   penny                 => 'runPenny',
                   dollop                => 'runDollop',
                   dolpenny              => 'runDolpenny',
                   showblastdb           => 'showBlastDB',
		  );

my $q= CGI->new();

if (!$q->param('query')) {
    # not given any query
    print $q->header(-status => '404 Not Found');
} else {
    # query -> methodName/arg1/arg2/...
    my @args= split m{/}, $q->param('query');
    my $method_name= shift @args;

    # push all parameter to @args (called by POST method)
    # main input data (seq, in0, in1) is stored first, and push into @args
    my @input= qw//;
    for ($q->param()) {
	next if $_ eq 'query';
	if ($_ eq 'seq') {
	    unshift @input, $q->param('seq');
        } elsif ($_ eq 'in0') {
	    unshift @input, $q->param('in0');
        } elsif ($_ eq 'in1') {
	    push @input, $q->param('in1');
	} else {
	    push @args, $_;
	    push @args, $q->param($_);
	}
    }

    unshift @args, @input;

    # exchange REST method name to internal method name
    if ($method_table{lc($method_name)}) {
	$method_name= $method_table{lc($method_name)};
    }

    # forbiding users to access internal subroutines (named with '_' prefix)
    if (substr($method_name, 0, 1) eq '_') {
	print $q->header(-status => '404 Not Found');
	exit(0);
    }

    # run internal subrutine named by $method_name
    my $result= KBWS->$method_name(@args);

    if (scalar $result =~ /^SOAP::Data/) {
	# $result is SOAP::Data object

	# decode SOAP::Data object and encode to simple string
	if ($#{$result->{_value}} == 0) {
	    print ${$result->{_value}}[0];
	} else {
	    print join "\n\n", @{$result->{_value}};
	}
    } elsif ($result eq 'Undefined Method') {
	# called undefined method by user
	print $q->header(-status => '404 Not Found');	
    } else {
	# $result is plain text
	print $q->header(-type => 'text/plane').$result;
    }
}
