#!/usr/bin/env perl -T
use Test::More tests => 13;

BEGIN {
    use lib qw( ./lib );
    use_ok('KBWS');

    ## Category : LOCAL ALIGNMENT
    ## Methods  : runBLAST, showBlastDB, runSsearch
    use_ok('KBWS::ALIGNMENT::LOCAL');

    ## Category : GLOBAL ALIGNMENT
    ## Methods  : runClustalw, runKalign, runMafft, runMuscle
    use_ok('KBWS::ALIGNMENT::MULTIPLE');

    ## Category : RNA 2D STRUCTURE
    ## Methods  : runCentroidfold, runRNAfold
    use_ok('KBWS::RNA::STRUCTURE');

    ## Category : PROTEIN MOTIFS
    ## Methods  : runPhobius
    use_ok('KBWS::PROTEIN::MOTIFS');

    ## Category : PROTEIN PROFILES
    ## Methods  : runFetchData runFetchBatch
    use_ok('KBWS::PROTEIN::PROFILES');

    ## Category : PROTEIN LOCALIZATION
    ## Methods  : runPsort, runPsort2, runPsortb, runWolfPsort
    use_ok('KBWS::PROTEIN::LOCALIZATION');

    ## Category : NUCLEIC GENE FINDING
    ## Methods  : runGenemarkhmm, runGlimmer
    use_ok('KBWS::NUCLEIC::GENE::FINDING');

    ## Category : NUCLEIC COMPOSITION
    ## Methods  : runWeblogo
    use_ok('KBWS::NUCLEIC::COMPOSITION');

    ## Category : MAPPING TO PATHWAY MAP
    ## Methods  : map2PathwayProjector
    use_ok('KBWS::MAPPING::PATHWAYMAP');

    ## Category : PHYLOGENY MOLECULAR SEQUENCE
    ## Methods  : runProtpars, runProtdist,    runDnapars, runDnapenny,
    ##          : runDnacomp,  runDnainvar,    runDnaml,   runDnamlk,
    ##          : runDnadist,  runGendist,     runSeqboot, runRestml,
    ##          : runClique,   runFitch,       runKitsch,  runNeighbor,
    ##          : runContml,   runMixrunPenny, runDollop,  runDolpenny
    use_ok('KBWS::PHYLOGENY::MOLECULAR::SEQUENCE');

    use_ok('KBWS::Utils');
    use_ok('KBWS::WRAPPER::EBI');
}
