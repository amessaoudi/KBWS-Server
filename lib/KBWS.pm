#!/usr/bin/env perl
use warnings;
use strict;

package KBWS;

use POSIX 'sys_wait_h';
use Cwd;

use lib qw{ ./ };
use KBWS::Utils;
use KBWS::IO;


use KBWS::ALIGNMENT::LOCAL;

sub runBlast {
    my $self=  shift;
    my $seq=   shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2Mfasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runBlast($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runSsearch {
    my $self=  shift;
    my $seq=   shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runSsearch($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

use KBWS::ALIGNMENT::MULTIPLE;
sub runClustalw {
    my $self=  shift;
    my $seq=   shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2Mfasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runClustalw($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runKalign {
    my $self=  shift;
    my $seq=   shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2Mfasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runKalign($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runMafft {
    my $self=  shift;
    my $seq=   shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2Mfasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runMafft($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runMuscle {
    my $self=  shift;
    my $seq=   shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2Mfasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runMuscle($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runTcoffee {
    my $self=  shift;
    my $seq=   shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2Mfasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runTcoffee($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}


use KBWS::RNA::STRUCTURE;
sub runCentroidfold {
    my $self=  shift;
    my $seq=   shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runCentroidfold($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runRNAfold {
    my $self=  shift;
    my $seq=   shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runRNAfold($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}


use KBWS::PROTEIN::MOTIFS;
sub runPhobius {
    my $self=  shift;
    my $seq=   shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runPhobius($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

use KBWS::PROTEIN::PROFILES;
sub runFetchData {
    my $self=  shift;
    my $data=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$data= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$data= $param{in0};
	delete $param{in0};
    }

    $data= _decode_data($data);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runFetchData($jobid, $data, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runFetchBatch {
    my $self=   shift;
    my $db=     shift;
    my $idList= shift;
    my %param=  _check_parameter(@_);

    my $jobid= _generate_jobid();

    if ($param{-in0}) {
	$db= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$db= $param{in0};
	delete $param{in0};
    }

    if ($param{-in1}) {
	$idList= $param{-in1};
	delete $param{-in1};
    } elsif ($param{in1}) {
	$idList= $param{in1};
	delete $param{in1};
    }

    # decode data
    $db=     _decode_data($db);
    $idList= _decode_data($idList);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runFetchBatch($jobid, $db, $idList, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}


use KBWS::PROTEIN::LOCALIZATION;
sub runPsort {
    my $self=  shift;
    my $seq=   shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runPsort($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runPsort2 {
    my $self=  shift;
    my $seq=   shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runPsort2($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runPsortb {
    my $self=  shift;
    my $seq=   shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runPsortb($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runWolfPsort {
    my $self=  shift;
    my $seq=   shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runWolfPsort($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}


use KBWS::NUCLEIC::GENE::FINDING;
sub runGenemarkhmm {
    my $self=  shift;
    my $seq=   shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runGenemarkhmm($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runGlimmer {
    my $self=  shift;
    my $seq=   shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runGlimmer($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runtRNAscan {
    my $self=  shift;
    my $seq=   shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runtRNAscan($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}


use KBWS::NUCLEIC::COMPOSITION;
sub runWeblogo {
    my $self=  shift;
    my $seq=   shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2Mfasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runWeblogo($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}


use KBWS::MAPPING::PATHWAYMAP;
sub map2PathwayProjector {
    my $self=  shift;
    my $data=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$data= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$data= $param{in0};
	delete $param{in0};
    }

    $data= _decode_data($data);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_map2PathwayProjector($jobid, $data, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}


use KBWS::PHYLOGENY::MOLECULAR::SEQUENCE;
sub runProtpars {
    my $self=  shift;
    my $seq=   shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runProtpars($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runProtdist {
    my $self=  shift;
    my $seq=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runProtdist($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runDnapars {
    my $self=  shift;
    my $seq=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runDnapars($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runDnapenny {
    my $self=  shift;
    my $seq=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runDnapenny($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runDnacomp {
    my $self=  shift;
    my $seq=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runDnacomp($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runDnainvar {
    my $self=  shift;
    my $seq=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runDnainvar($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runDnaml {
    my $self=  shift;
    my $seq=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runDnaml($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runDnamlk {
    my $self=  shift;
    my $seq=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runDnamlk($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runDnadist {
    my $self=  shift;
    my $seq=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runDnadist($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runGendist {
    my $self=  shift;
    my $data=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$data= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$data= $param{in0};
	delete $param{in0};
    }

    $data= _decode_data($data);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runGendist($jobid, $data, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runSeqboot {
    my $self=  shift;
    my $seq=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$seq= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$seq= $param{in0};
	delete $param{in0};
    }

    $seq= _seq2fasta($seq);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runSeqboot($jobid, $seq, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runRestml {
    my $self=  shift;
    my $data=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$data= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$data= $param{in0};
	delete $param{in0};
    }

    $data= _decode_data($data);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runRestml($jobid, $data, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runClique {
    my $self=  shift;
    my $data=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$data= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$data= $param{in0};
	delete $param{in0};
    }

    $data= _decode_data($data);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runClique($jobid, $data, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runFitch {
    my $self=  shift;
    my $data=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$data= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$data= $param{in0};
	delete $param{in0};
    }

    $data= _decode_data($data);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runFitch($jobid, $data, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runKitsch {
    my $self=  shift;
    my $data=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$data= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$data= $param{in0};
	delete $param{in0};
    }

    $data= _decode_data($data);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runKitsch($jobid, $data, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runNeighbor {
    my $self=  shift;
    my $data=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$data= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$data= $param{in0};
	delete $param{in0};
    }

    $data= _decode_data($data);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runNeighbor($jobid, $data, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runContml {
    my $self=  shift;
    my $data=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$data= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$data= $param{in0};
	delete $param{in0};
    }

    $data= _decode_data($data);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runContml($jobid, $data, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runMix {
    my $self=  shift;
    my $data=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$data= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$data= $param{in0};
	delete $param{in0};
    }

    $data= _decode_data($data);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runMix($jobid, $data, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runPenny {
    my $self=  shift;
    my $data=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$data= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$data= $param{in0};
	delete $param{in0};
    }

    $data= _decode_data($data);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runPenny($jobid, $data, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runDollop {
    my $self=  shift;
    my $data=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$data= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$data= $param{in0};
	delete $param{in0};
    }

    $data= _decode_data($data);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runDollop($jobid, $data, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}

sub runDolpenny {
    my $self=  shift;
    my $data=  shift;
    my %param= _check_parameter(@_);

    my $jobid= _generate_jobid();

    # if given sequence data with '-in0' name
    if ($param{-in0}) {
	$data= $param{-in0};
	delete $param{-in0};
    } elsif ($param{in0}) {
	$data= $param{in0};
	delete $param{in0};
    }

    $data= _decode_data($data);

    if (my $pid= fork) {
        return $jobid;
    } elsif (defined $pid) {
	_runDolpenny($jobid, $data, \%param);
	exit 0;
    } else {
        _failed2forkProcess($jobid);
        exit 0;
    }
}


use KBWS::DISPLAY;
sub showBlastDB {
    my $self=  shift;
    my %param= _check_parameter(@_);

    return _showBlastDB(\%param);
}


# checkStatus, getResult, etc...
use KBWS::Result;

# undefined subroutine : 404
sub AUTOLOAD {
    return 'Undefined Method';
}

1;
