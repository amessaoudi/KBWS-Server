#!/usr/bin/env perl
use warnings;
use strict;

package KBWS::PHYLOGENY::MOLECULAR::SEQUENCE;

use base q/Exporter/;
our @EXPORT=
    qw( _runProtpars _runProtdist _runDnapars _runDnapenny _runDnacomp _runDnainvar _runDnaml
        _runDnamlk   _runDnadist  _runGendist _runSeqboot  _runRestml  _runClique   _runFitch
        _runKitsch   _runNeighbor _runContml  _runMix      _runPenny   _runDollop   _runDolpenny
      );

use lib qw( ./lib/ );
use KBWS::ALIGNMENT::MULTIPLE qw/ _runClustalw /;
use KBWS::Utils;
use KBWS::IO;

use LWP::UserAgent;
use SOAP::Lite;
use HTML::Form;
use Cwd;

# Protpars
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/fprotpars"
sub _runProtpars {
    my $jobid= shift;
    my $seq=   shift;

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/fprotpars");
    my $form= HTML::Form->parse($request);

    $seq= _multiFasta4phylipFormat($seq, $jobid);
    $form->value('sequence.text' => $seq);

    my $response= _process_request($ua, $form->click());
    my $result   = $response->content();

    if ($result =~ m{application terminated}ms) {
	_write_file('Error: Unable to read frequencies file' => $jobid, 'out');
    } else {
	my %result= $result =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

	for my $ext (keys(%result)) {
	    if ($ext eq 'outfile') {
		_write_file($result{$ext} => $jobid, 'out');
	    } elsif ($ext ne '.stdout') {
		_write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	    }
	}
    }
}

# Protdist
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/fprotdist"
sub _runProtdist {
    my $jobid= shift;
    my $seq=   shift;

    close STDOUT;

    my $ua      = LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/fprotdist");
    my $form    = HTML::Form->parse($request);

    $form->value('sequence.text' => _multiFasta4phylipFormat($seq, $jobid));

    my $response= _process_request($ua, $form->click());
    my %result   = $response->content() =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

    for my $ext (keys(%result)) {
	if ($ext eq 'outfile') {
	    _write_file($result{$ext} => $jobid, 'out');
	} elsif ($ext ne '.stdout') {
	    _write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	}
    }
}

# DNApars
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/fdnapars"
sub _runDnapars {
    my $jobid= shift;
    my $seq=   shift;

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/fdnapars");
    my $form= HTML::Form->parse($request);

    $form->value('sequence.text' => _multiFasta4phylipFormat($seq, $jobid));

    my $response= _process_request($ua, $form->click());

    my %result= $response->content() =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

    for my $ext (keys(%result)) {
	if ($ext eq 'outfile') {
	    _write_file($result{$ext} => $jobid, 'out');
	} elsif ($ext ne '.stdout') {
	    _write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	}
    }
}

# DNApenny
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/fdnapenny"
sub _runDnapenny {
    my $jobid= shift;
    my $seq=   shift;

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/fdnapenny");
    my $form= HTML::Form->parse($request);

    $form->value('sequence.text' => _multiFasta4phylipFormat($seq, $jobid));

    my $response= _process_request($ua, $form->click());

    my %result= $response->content() =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

    for my $ext (keys(%result)) {
	if ($ext eq 'outfile') {
	    _write_file($result{$ext} => $jobid, 'out');
	} elsif ($ext ne '.stdout') {
	    _write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	}
    }
}

# DNAcomp
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/fdnacomp"
sub _runDnacomp {
    my $jobid= shift;
    my $seq=   shift;

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/fdnacomp");
    my $form= HTML::Form->parse($request);

    $form->value('sequence.text' => _multiFasta4phylipFormat($seq, $jobid));

    my $response= _process_request($ua, $form->click());

    my %result= $response->content() =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

    for my $ext (keys(%result)) {
	if ($ext eq 'outfile') {
	    _write_file($result{$ext} => $jobid, 'out');
	} elsif ($ext ne '.stdout') {
	    _write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	}
    }
}


# DNAinvar
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/fdnainvar"
sub _runDnainvar {
    my $jobid= shift;
    my $seq=   shift;

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/fdnainvar");
    my $form= HTML::Form->parse($request);

    $form->value('sequence.text' => _multiFasta4phylipFormat($seq, $jobid));

    my $response= _process_request($ua, $form->click());

    my %result= $response->content() =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

    for my $ext (keys(%result)) {
	if ($ext eq 'outfile') {
	    _write_file($result{$ext} => $jobid, 'out');
	} elsif ($ext ne '.stdout') {
	    _write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	}
    }
}

# DNAml
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/fdnaml"
sub _runDnaml {
    my $jobid= shift;
    my $seq=   shift;

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/fdnaml");
    my $form= HTML::Form->parse($request);

    $form->value('sequence.text' => _multiFasta4phylipFormat($seq, $jobid));

    my $response= _process_request($ua, $form->click());

    my %result= $response->content() =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

    for my $ext (keys(%result)) {
	if ($ext eq 'outfile') {
	    _write_file($result{$ext} => $jobid, 'out');
	} elsif ($ext ne '.stdout') {
	    _write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	}
    }
}

# DNAmlk
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/fdnamlk"
sub _runDnamlk {
    my $jobid= shift;
    my $seq=   shift;

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/fdnamlk");
    my $form= HTML::Form->parse($request);

    $form->value('sequence.text' => _multiFasta4phylipFormat($seq, $jobid));

    my $response= _process_request($ua, $form->click());

    my %result= $response->content() =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

    for my $ext (keys(%result)) {
	if ($ext eq 'outfile') {
	    _write_file($result{$ext} => $jobid, 'out');
	} elsif ($ext ne '.stdout') {
	    _write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	}
    }
}

# DNAdist
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/fdnadist"
sub _runDnadist {
    my $jobid= shift;
    my $seq=   shift;

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/fdnadist");
    my $form= HTML::Form->parse($request);

    $form->value('sequence.text' => _multiFasta4phylipFormat($seq, $jobid));

    my $response= _process_request($ua, $form->click());

    my %result= $response->content() =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

    for my $ext (keys(%result)) {
	if ($ext eq 'outfile') {
	    _write_file($result{$ext} => $jobid, 'out');
	} elsif ($ext ne '.stdout') {
	    _write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	}
    }
}

# Gendist
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/fgendist"
sub _runGendist {
    my $jobid= shift;
    my $data=  shift;

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/fgendist");
    my $form= HTML::Form->parse($request);

    $data =~ s/\n\n/\n/g;
    _write_file($data => $jobid, 'dat');
    $form->value('infile' => './result/'.$jobid.'.dat');

    my $response= _process_request($ua, $form->click());
    my $result= $response->content();
    
    if ($result =~ m{application terminated}ms) {
	_write_file('Error: Unable to read frequencies file' => $jobid, 'out');
    } else {
	my %result= $result =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

	for my $ext (keys(%result)) {
	    if ($ext eq 'outfile') {
		_write_file($result{$ext} => $jobid, 'out');
	    } elsif ($ext ne '.stdout') {
		_write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	    }
	}
    }

    unlink('./result/'.$jobid.'.dat');
}

# Seqboot
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/fseqboot"
sub _runSeqboot {
    my $jobid= shift;
    my $seq=   shift;

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/fseqboot");
    my $form= HTML::Form->parse($request);

    $form->value('sequence.text' => _multiFasta4phylipFormat($seq, $jobid));

    my $response= _process_request($ua, $form->click());

    my %result= $response->content() =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

    for my $ext (keys(%result)) {
	if ($ext eq 'outfile') {
	    _write_file($result{$ext} => $jobid, 'out');
	} elsif ($ext ne '.stdout') {
	    _write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	}
    }
}

# Restml
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/frestml"
sub _runRestml {
    my $jobid= shift;
    my $data=  shift;

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/frestml");
    my $form= HTML::Form->parse($request);

    $data =~ s/\n\n/\n/g;
    _write_file($data => $jobid, 'dat');
    $form->value('data' => './result/'.$jobid.'.dat');

    my $response= _process_request($ua, $form->click());

    my %result= $response->content() =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

    for my $ext (keys(%result)) {
	if ($ext eq 'outfile') {
	    _write_file($result{$ext} => $jobid, 'out');
	} elsif ($ext ne '.stdout') {
	    _write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	}
    }
}

# Clique
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/fclique"
sub _runClique {
    my $jobid= shift;
    my $data=  shift;

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/fclique");
    my $form= HTML::Form->parse($request);

    $data =~ s/\n\n/\n/g;
    _write_file($data => $jobid, 'dat');
    $form->value('infile' => './result/'.$jobid.'.dat');

    my $response= _process_request($ua, $form->click());
    my $result= $response->content();

    if ($result =~ m{application terminated}ms) {
	_write_file('Error: Unable to read frequencies file' => $jobid, 'out');
    } else {
	my %result= $result =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

	for my $ext (keys(%result)) {
	    if ($ext eq 'outfile') {
		_write_file($result{$ext} => $jobid, 'out');
	    } elsif ($ext ne '.stdout') {
		_write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	    }
	}
    }

    unlink('./result/'.$jobid.'.dat');
}

# Fitch
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/ffitsh"
sub _runFitch {
    my $jobid= shift;
    my $data=  shift;

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/ffitch");
    my $form= HTML::Form->parse($request);

    $data =~ s/\n\n/\n/g;
    _write_file($data => $jobid, 'dat');
    $form->value('datafile' => './result/'.$jobid.'.dat');

    my $response= _process_request($ua, $form->click());
    my $result= $response->content();

    if ($result =~ m{application terminated}ms) {
	_write_file('Error: Unable to read frequencies file' => $jobid, 'out');
    } else {
	my %result= $result =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

	for my $ext (keys(%result)) {
	    if ($ext eq 'outfile') {
		_write_file($result{$ext} => $jobid, 'out');
	    } elsif ($ext ne '.stdout') {
		_write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	    }
	}
    }

    unlink('./result/'.$jobid.'.dat');
}

# Kitsch
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/fkitsch"
sub _runKitsch {
    my $jobid= shift;
    my $data=  shift;

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/fkitsch");
    my $form= HTML::Form->parse($request);

    $data =~ s/\n\n/\n/g;
    _write_file($data => $jobid, 'dat');
    $form->value('datafile' => './result/'.$jobid.'.dat');

    my $response= _process_request($ua, $form->click());
    my $result= $response->content();

    if ($result =~ m{application terminated}ms) {
	_write_file('Error: Unable to read frequencies file' => $jobid, 'out');
    } else {
	my %result= $result =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

	for my $ext (keys(%result)) {
	    if ($ext eq 'outfile') {
		_write_file($result{$ext} => $jobid, 'out');
	    } elsif ($ext ne '.stdout') {
		_write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	    }
	}
    }

    unlink('./result/'.$jobid.'.dat');
}

# Neighbor
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/fneighbor"
sub _runNeighbor {
    my $jobid= shift;
    my $data=  shift;

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/fneighbor");
    my $form= HTML::Form->parse($request);

    $data =~ s/\n\n/\n/g;
    _write_file($data => $jobid, 'dat');
    $form->value('datafile' => './result/'.$jobid.'.dat');

    my $response= _process_request($ua, $form->click());
    my $result= $response->content();

    if ($result =~ m{application terminated}ms) {
	_write_file('Error: Unable to read frequencies file' => $jobid, 'out');
    } else {
	my %result= $result =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

	for my $ext (keys(%result)) {
	    if ($ext eq 'outfile') {
		_write_file($result{$ext} => $jobid, 'out');
	    } elsif ($ext ne '.stdout') {
		_write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	    }
	}
    }

    unlink('./result/'.$jobid.'.dat');
}

# Contml
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/fcontml"
sub _runContml {
    my $jobid= shift;
    my $data=  shift;

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/fcontml");
    my $form= HTML::Form->parse($request);

    $data =~ s/\n\n/\n/g;
    _write_file($data => $jobid, 'dat');
    $form->value('infile' => './result/'.$jobid.'.dat');

    my $response= _process_request($ua, $form->click());
    my $result= $response->content();

    if ($result =~ m{application terminated}ms) {
	_write_file('Error: Unable to read frequencies file' => $jobid, 'out');
    } else {
	my %result= $result =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

	for my $ext (keys(%result)) {
	    if ($ext eq 'outfile') {
		_write_file($result{$ext} => $jobid, 'out');
	    } elsif ($ext ne '.stdout') {
		_write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	    }
	}
    }

    unlink('./result/'.$jobid.'.dat');
}

# Mix
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/fmix"
sub _runMix {
    my $jobid= shift;
    my $data=  shift;

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/fmix");
    my $form= HTML::Form->parse($request);

    $data =~ s/\n\n/\n/g;
    _write_file($data => $jobid, 'dat');
    $form->value('infile' => './result/'.$jobid.'.dat');

    my $response= _process_request($ua, $form->click());
    my $result= $response->content();

    if ($result =~ m{application terminated}ms) {
	_write_file('Error: Unable to read frequencies file' => $jobid, 'out');
    } else {
	my %result= $result =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

	for my $ext (keys(%result)) {
	    if ($ext eq 'outfile') {
		_write_file($result{$ext} => $jobid, 'out');
	    } elsif ($ext ne '.stdout') {
		_write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	    }
	}
    }

    unlink('./result/'.$jobid.'.dat');
}

# Penny
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/fpenny"
sub _runPenny {
    my $jobid= shift;
    my $data=  shift;

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/fpenny");
    my $form= HTML::Form->parse($request);

    $data =~ s/\n\n/\n/g;
    _write_file($data => $jobid, 'dat');
    $form->value('infile' => './result/'.$jobid.'.dat');

    my $response= _process_request($ua, $form->click());
    my $result= $response->content();

    if ($result =~ m{application terminated}ms) {
	_write_file('Error: Unable to read frequencies file' => $jobid, 'out');
    } else {
	my %result= $result =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

	for my $ext (keys(%result)) {
	    if ($ext eq 'outfile') {
		_write_file($result{$ext} => $jobid, 'out');
	    } elsif ($ext ne '.stdout') {
		_write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	    }
	}
    }

    unlink('./result/'.$jobid.'.dat');
}

# Dollop
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/fdollop"
sub _runDollop {
    my $jobid= shift;
    my $data=  shift;

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/fdollop");
    my $form= HTML::Form->parse($request);

    $data =~ s/\n\n/\n/g;
    _write_file($data => $jobid, 'dat');
    $form->value('infile' => './result/'.$jobid.'.dat');

    my $response= _process_request($ua, $form->click());
    my $result= $response->content();

    if ($result =~ m{application terminated}ms) {
	_write_file('Error: Unable to read frequencies file' => $jobid, 'out');
    } else {
	my %result= $result =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

	for my $ext (keys(%result)) {
	    if ($ext eq 'outfile') {
		_write_file($result{$ext} => $jobid, 'out');
	    } elsif ($ext ne '.stdout') {
		_write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	    }
	}
    }

    unlink('./result/'.$jobid.'.dat');
}

# Dolpenny
# Type : CGI : "http://emboss.bioinformatics.nl/cgi-bin/emboss/fdolpenny"
sub _runDolpenny {
    my $jobid= shift;
    my $data=  shift;

    close STDOUT;

    my $ua= LWP::UserAgent->new();
    my $request= $ua->get("http://emboss.bioinformatics.nl/cgi-bin/emboss/fdolpenny");
    my $form= HTML::Form->parse($request);

    $data =~ s/\n\n/\n/g;
    _write_file($data => $jobid, 'dat');
    $form->value('infile' => './result/'.$jobid.'.dat');

    my $response= _process_request($ua, $form->click());
    my $result= $response->content();

    if ($result =~ m{application terminated}ms) {
	_write_file('Error: Unable to read frequencies file' => $jobid, 'out');
    } else {
	my %result= $result =~ m{ > ([^>]+?) </a> .+? <pre> (.+?) </pre>}msxg;

	for my $ext (keys(%result)) {
	    if ($ext eq 'outfile') {
		_write_file($result{$ext} => $jobid, 'out');
	    } elsif ($ext ne '.stdout') {
		_write_file($result{$ext} => $jobid, $ext) if $ext ne '.stdout';
	    }
	}
    }

    unlink('./result/'.$jobid.'.dat');
}

# inner subrutine
sub _multiFasta4phylipFormat {
    my $seq=   shift;
    my $jobid= shift;

    $seq =~ s/\n\n/\n/g;

    if ($seq =~ /^>/) {
	_runClustalw($jobid.'-1', $seq, {output => 'phylip'});

	open my $fh, '<', './result/'.$jobid.'-1.aln';
	$seq= do {local $/; <$fh>;};
	close $fh;
    }

    my @clustaledResult= split /\n/, $seq;

    my ($seqNum, $seqLen)= (0,0);
    my @seqName= ();
    my $step= 1;
    my $seqAfter= '';

    for (1 .. $#clustaledResult) {
	next if $clustaledResult[$_] =~ /\*/;
	$step= 0 if $clustaledResult[$_] eq '' && $seqNum > 0;

	$seqNum += $step;
	if ($step == 1) {
	    $clustaledResult[$_] =~ m/(.+?)\s+(.+)/;
	    my $line = $2;
	    $line =~ tr/ //d;
	    if ($seqNum == 1) {
		$seqLen = length($line);
	    }
	    if (length($1) > 10) {
		$seqAfter .= substr($1,0,10).$line."\n";
	    } else {
		$seqAfter .= $1." "x(10-length($1)).$line."\n";
	    }
	} elsif ($step == 0) {
	    my $line = $clustaledResult[$_];
	    $line =~ tr/ //d;
	    $seqAfter .= $line."\n";
	}
    }
    return "     $seqNum     $seqLen\n".$seqAfter;
}

1;
