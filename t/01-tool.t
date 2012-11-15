#!/usr/bin/env perl -T
use Test::More tests => 3;

BEGIN {
    use lib qw( ./lib );
    use_ok('KBWS::Utils');
    use KBWS::Utils;
}

ok( _is_nucleotide( _return_nuc() ),    '"_is_nucleotide" return true when given nucleotide' );
ok( !_is_nucleotide( _return_amino() ), '"_is_nucleotide" return false when given amino acid' );

sub _return_nuc {
    return<<'NUC';
taagttattatttagttaatacttttaacaatattattaaggtatttaaaaaatactatt
atagtatttaacatagttaaataccttccttaatactgttaaattatattcaatcaatac
atatataatattattaaaatacttgataagtattatttagatattagacaaatactaatt
ttatattgctttaatacttaataaatactacttatgtattaagtaaatattactgtaata
ctaataacaatattattacaatatgctagaataatattgctagtatcaataattactaat
atagtattaggaaaataccataataatatttctacataatactaagttaatactatgtgt
agaataataaataatcagattaaaaaaattttatttatctgaaacatatttaatcaattg
NUC
}

sub _return_amino {
    return<<'AMINO';
MMQESATETISNSSMNQNGMSTLSSQLDAGSRDGRSSGDTSSEVSTVELLHLQQQQALQA
ARQLLLQQQTSGLKSPKSSDKQRPLQVPVSVAMMTPQVITPQQMQQILQQQVLSPQQLQA
LLQQQQAVMLQQQQLQEFYKKQQEQLHLQLLQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ
QQQQQQQQQHPGKQAKEQQQQQQQQQQLAAQQLVFQQQLLQMQQLQQQQHLLSLQRQGLI
SIPPGQAALPVQSLPQAGLSPAEIQQLWKEVTGVHSMEDNGIKHGGLDLTTNNSSSTTSS
TTSKASPPITHHSIVNGQSSVLNARRDSSSHEETGASHTLYGHGVCKWPGCESICEDFGQ
FLKHLNNEHALDDRSTAQCRVQMQVVQQLEIQLSKERERLQAMMTHLHMRPSEPKPSPKP
LNLVSSVTMSKNMLETSPQSLPQTPTTPTAPVTPITQGPSVITPASVPNVGAIRRRHSDK
YNIPMSSEIAPNYEFYKNADVRPPFTYATLIRQAIMESSDRQLTLNEIYSWFTRTFAYFR
RNAATWKNAVRHNLSLHKCFVRVENVKGAVWTVDEVEYQKRRSQKITGSPTLVKNIPTSL
GYGAALNASLQAALAESSLPLLSNPGLINNASSGLLQAVHEDLNGSLDHIDSNGNSSPGC
SPQPHIHSIHVKEEPVIAEDEDCPMSLVTTANHSPELEDDREIEEEPLSEDLE
AMINO
}
