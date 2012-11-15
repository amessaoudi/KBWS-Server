#!/usr/bin/env perl
######################################
# sub module for kblast (runBlast)
#  throw BLAST job for each WS
######################################

package KBWS::ALIGNMENT::LOCAL::Blast;

use base q/Exporter/;
our @EXPORT = qw/ _runBLAST2NCBI _runBLAST2DDBJ _runBLAST2EBI _ebi_rest_request /;

use warnings;
use strict;

use Bio::Tools::Run::RemoteBlast;
use Bio::SearchIO;
use Bio::SeqIO;

use LWP::UserAgent;
use LWP::Simple;
use XML::Simple;

use File::Basename;
use SOAP::Lite;

# access NCBI BLAST
## input  -> jobid, program, database, e value, input sequence file, -m
## output -> void
## require : Bundle::Bioperl
sub _runBLAST2NCBI {
    my $jobid   = shift;
    my $prog    = shift;
    my $db      = shift;
    my $e_val   = shift;
    my $inseq   = shift;
    my $m       = shift;

    my $outfile = "./result/".$jobid.".out";

    my @params = qw{};
    push (@params, ( '-prog' => $prog,
                     '-data' => $db,
                     '-expect' => $e_val,
                     '-readmethod' => 'SearchIO' ));

    my $factory = Bio::Tools::Run::RemoteBlast->new(@params);
    my $v = 1;
    my $str = Bio::SeqIO->new(-file=>$inseq, '-format' => 'fasta' );

    while ( my $input = $str->next_seq() ) {
        my $r = $factory->submit_blast($input);

        while ( my @rids = $factory->each_rid ) {
            foreach my $rid ( @rids ) {
                my $rc = $factory->retrieve_blast($rid);
                if( !ref($rc) ) {
                    if( $rc < 0 ) {
                        $factory->remove_rid($rid);
                    }
                    sleep 5;
                } else {
                    my $result = $rc->next_result();
                    #save the output
                        $factory->save_output($outfile);

		    if ( $m ) {
			_blastReportConverter($outfile, $m);
		    }

                    $factory->remove_rid($rid);
                }
            }
        }
    }

    return 1;
}


sub _runBLAST2DDBJ {
    my $jobid  = shift;
    my $prog   = shift;
    my $db     = shift;
    my $e_val  = shift;
    my $inseq  = shift;
    my $m      = shift;

    my $param_ref = shift;
    my @params;
    if ($param_ref) {
        my %param = %{$param_ref};
        for ( keys(%param) ) {
            if ( $_ =~ m{ [-] }msx ) {
                push( @params, $_ );
            } else {
                push( @params, '-'.$_ );
            }
            push( @params, $param{$_} );
        }
    }

    my $outfile    = "./result/".$jobid.".out";
    my $request_id = 0;

    my $blastDriver = SOAP::Lite->service('http://xml.nig.ac.jp/wsdl/Blast.wsdl');

    my $query = `cat $inseq`;
    my $param = "";

    my %p = @params;
    for my $key (keys(%p)) {
	my $value = $p{$key};
	if ($value eq 'true') {
	    $value = "T";
	} elsif ($value eq 'false') {
	    $value = "F";
	} elsif ($key eq '-m' || $value =~ /-/) {
	    next;
	}
	if ($prog eq 'blastn') {
	    unless ($key eq '-D' || $key eq '-O' || $key eq '-U' || $key eq '-T') {
		$param .= " ".$key." ".$value;
	    }
	} else {
	    $param .= " ".$key." ".$value;
	}
    }

    if ($e_val) {
        if ($e_val =~ m/ e [-] (\d+) $/xms) {
            my $len = $1;
            $e_val = sprintf("%.${len}f", $e_val);
        } elsif ($e_val =~ m/ e [+] (\d+) $/xms) {
            my $len = $1;
            $e_val = sprintf("%${len}.f", $e_val);
        }
        $param .= " -e ".$e_val if $e_val;
    }

    if ($prog eq 'blastn') {
	$request_id = $blastDriver->searchParallelAsync($prog, $db, $query, $param);
    } else {
	$request_id = $blastDriver->searchParamAsync($prog, $db, $query, $param);
    }

    sleep(1);

    my $requestDriver = SOAP::Lite->service("http://xml.nig.ac.jp/wsdl/RequestManager.wsdl");
    my $result        = $requestDriver->getAsyncResult($request_id);

    while ( $result eq 'Your job has not been completed yet.') {
        sleep(3);
        $result = $requestDriver->getAsyncResult($request_id);
    }

    if ($result) {
	_write_file( $result => $jobid, "out" );
	if ( $m ) {
	    _blastReportConverter($outfile, $m);
	}
    } else {
	_write_file( "Time out connection to DDBJ" => $jobid, "out");
    }
    return 1;
}


sub _runBLAST2EBI {
    my $jobid    = shift;
    my $program  = shift;
    my $database = shift;
    my $evalue   = shift;
    my $infile = shift;
    my $m      = shift;
    my @param = %{shift()};

    my $baseUrl = 'http://www.ebi.ac.uk/Tools/services/rest/ncbiblast';
    my $outfile = "./result/".$jobid.".out";

    my %param4ebi = qw//;
    $param4ebi{'sequence'} = `cat $infile`;
    $param4ebi{'program'}  = $program;
    $param4ebi{'database'} = [ $database ];
    $param4ebi{'exp'}      = int($evalue);
    $param4ebi{'email'}    = 'cory@sfc.keio.ac.jp';
    $param4ebi{'title'}    = "KBWS BLAST (EBI)";

    if ($program eq 'blastp') {
        $param4ebi{'stype'} = 'protein';
    } else {
        $param4ebi{'stype'} = 'dna';
    }

    for my $param (@param) {
        if ($_ && ( $_ eq '-M' || $param4ebi{matrix} eq '-M') ) {
            $param4ebi{matrix} = $_;
        } elsif ($_ && ($_ eq '-g' || $param4ebi{gapalign} eq '-g') ) {
            $param4ebi{gapalign} = $_;
            if ($param4ebi{gapalign} ne '-g') {
                if ($param4ebi{gapalign} eq 'T') {
                    $param4ebi{gapalien} = 1;
                } elsif ($param4ebi{gapalign} eq 'F') {
                    $param4ebi{gapalign} = 0;
                }
            }
        } elsif ($_ && ($_ eq '-O' || $param4ebi{gapopen} eq '-O') ) {
            $param4ebi{gapopen} = $_;
        } elsif ($_ && ($_ eq '-D' || $param4ebi{dropoff} eq '-D') ) {
            $param4ebi{dropoff} = $_;
        } elsif ($_ && ($_ eq '-n' || $param4ebi{numal} eq '-n') ) {
            $param4ebi{numal} = $_;
        } elsif ($_ && ($_ eq '-s' || $param4ebi{scores} eq '-s') ) {
            $param4ebi{scores} = $_;
        } elsif ($_ && ($_ eq '-e' || $param4ebi{gapext} eq '-e') ) {
            $param4ebi{gapext} = $_;
        } elsif ($_ && ($_ eq '-A' || $param4ebi{alignments} eq '-A') ) {
            $param4ebi{alignments} = $_;
        } elsif ($_ && $_ eq '-f') {
            $param4ebi{filter} = 1;
        }
    }
    unless ( $param4ebi{scores} ) {
        $param4ebi{scores}     = 100;
        $param4ebi{alignments} = 100;
    }

    if ( $param4ebi{scores} < $param4ebi{alignments} ) {
        $param4ebi{alignments} = $param4ebi{scores};
    }

    for my $param_name ( keys(%param4ebi) ) {
        if ( !defined( $param4ebi{$param_name} ) ) {
            delete $param4ebi{$param_name};
        }
    }

    my $ua = LWP::UserAgent->new();
    $ua->env_proxy;

    my $response = $ua->post( $baseUrl."/run/", \%param4ebi );

    if ( $response->is_error ) {
        $response->content() =~ m/<h1>([^<]+)<\/h1>/;
        _write_file('http status: '.$response->code.' '.$response->message.'  '.$1 => $jobid, "out");
        return 0;
    }

    my $jobid4ebi = $response->content();

    sleep(20);

    my $status = "PENDING";
    my $errorCount = 0;
    while ($status eq 'RUNNING' || $status eq 'PENDING' || ( $status eq 'ERROR' && $errorCount < 2 ) ) {
        $status = _ebi_rest_request($jobid, $baseUrl.'/status/'.$jobid4ebi) || last;

        if ( $status eq 'ERROR' ) {
            $errorCount++;
        } elsif ( $errorCount > 0 ) {
            $errorCount--;
        }
        if ( $status eq 'RUNNING' || $status eq 'PENDING' || $status eq 'ERROR' ) {
            sleep 3;
        } elsif ($status eq 'FINISHED') {
            last;
        }
    }

    my $output_URL = $baseUrl.'/result/'.$jobid4ebi.'/out';

    `wget -q $output_URL -O $outfile`;

    if (-s $outfile) {
	if ( $m ) {
	    _blastReportConverter($outfile, $m);
	}
    } else {
	_write_file( "Time out connection to EBI" => $jobid, "out");
    }

    return 1;

    sub _ebi_rest_request {
        my $ua = LWP::UserAgent->new();
        $ua->agent("KBWS-SOAP-Server (kbws; Linux) ".$ua->agent());
        $ua->env_proxy;

        my $jobid = shift;
        my $requestUrl = shift;
        # Perform the request

        my $response = $ua->get($requestUrl);

        # Check for HTTP error codes

        if ( $response->is_error ) {
            $response->content() =~ m/<h1>([^<]+)<\/h1>/;
            _write_file($1, $jobid, "out");
        }

        # Return the response data
        return $response->content();
    }

    sub _write_error {
        my $jobid = shift;
        my $msg   = shift;
        open  ERROR, ">", "./result/".$jobid.".out";
        print ERROR $msg;
        close ERROR;
        return 1;
    }
}


# mold BLAST report from '-m 0' to other format
## input  -> File Path (BLAST Report) [String]
##           format type              [String]
## output -> 1                        [Integer]
### Require: Bio::SeqrchIO, Bio::SeqIO
sub _blastReportConverter {
    my $base_file = shift;
    my $format    = shift;

    ### Fatal error (from DDBJ)
    if ( `head $base_file` =~ /FATAL ERROR/ ) {
        _write_file( "FATAL ERROR cought from DDBJ server" => $base_file);
        return 0;
    }

    my $result_file = $base_file;
    while (-e $result_file) {
        $result_file .= 1;
    }

    my $searchio    = new Bio::SearchIO(-format => 'blast', -file   => $base_file);

    if ( $format eq '8' ) {    # -m 8 format (tabular table)
        open RESULT, ">", $result_file;
        while( my $result = $searchio->next_result ) {
            while( my $hit = $result->next_hit ) {
                while( my $hsp = $hit->next_hsp ) {
                    my @range_query = $hsp->range('query');
                    my @range_hit   = $hsp->range('hit');
                    my @list = (
                                "query",
                                $hit->name,
                                int($hsp->percent_identity),
                                $hsp->num_conserved,
                                ($hsp->hsp_length - $hsp->num_conserved),
                                $hsp->gaps,
                                $range_query[0],
                                $range_query[1],
                                $range_hit[0],
                                $range_hit[1],
                                $hit->significance,
                                $hit->score,
                               );

                    print RESULT join("\t", @list)."\n";
                }
            }
        }
        close RESULT;
    } elsif ( $format eq 'k1' ) {    # -m k1 format ( ID list joined by "\n" )
        my @entry = qw//;

        while( my $result = $searchio->next_result ) {
            while( my $hit = $result->next_hit ) {
                while( my $hsp = $hit->next_hsp ) {
                    my ($ID) = $hit->name =~ m{ ^ [^|]* [|] ([^|]*) }xms;
                    if ($ID =~ /\.\d$/) {
                       substr($ID, -2) = '';
                    }
                    push(@entry, $ID);
                }
            }
        }

        open  RESULT, ">", "$result_file";
        print RESULT join("\n", @entry);
        close RESULT;
    } elsif ( $format eq 'k2' ) {    # -m k2 ( ID list joined by "," )

        my @ID_list = qw//;
        while( my $result = $searchio->next_result ) {
            while( my $hit = $result->next_hit ) {
                while( my $hsp = $hit->next_hsp ) {
                    my ($ID) = $hit->name =~ m{ ^ [^|]* [|] ([^|]*) }xms;
                    if ($ID =~ /\.\d$/) {
                       substr($ID, -2) = '';
                    }
                    push @ID_list, $ID;
                }
            }
        }
        open  RESULT, ">", "$result_file";
        print RESULT  join( ",", @ID_list);
        close RESULT;
    }

    # furture work
    # -m k3 (multi fasta generated by ID list)
    rename($result_file,$base_file);

    return 1;
}

1;
