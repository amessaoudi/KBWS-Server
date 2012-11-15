#!/usr/bin/env perl
use warnings;
use strict;

package KBWS::IO;

use LWP::UserAgent;
use LWP::Simple;
use MIME::Base64;

use base q/Exporter/;
our @EXPORT = qw/ _seq2fasta _seq2Mfasta _decode_data _is_base64 _check_parameter /;


# any format sequence to fasta format sequence
sub _seq2fasta {
    my $seq= shift;

    if ($seq && _is_base64($seq)) {
       $seq= decode_base64($seq);
    }

    return $seq;
}

# decode multi fasta
sub _seq2Mfasta {
    # [TODO] return '' if $seq is not multiple fasta
    my $seq= shift;

    if ($seq && _is_base64($seq)) {
       $seq= decode_base64($seq);
    }

    $seq =~ tr/\n//s;
    return $seq;
}

sub _decode_data {
   my $data= shift;

   if ($data && _is_base64($data)) {
      $data= decode_base64($data);
   }

   return $data;
}

# given string is encoded to base 64 or not
sub _is_base64 {
    my $string= shift;
    $string =~ s/\r//g;
    $string =~ s/\n//g;

    my $char_count= length $string;

    return 0 if $char_count % 4;
    return 0 if $string !~ m{ ^ [=\+/a-z0-9]+ $ }imx;
    return 1;
}

# make safe "%param"
sub _check_parameter {
    my @raw_param= @_;

    my %param= ();
    if (defined($raw_param[0]) && !defined($raw_param[1]) && ref $raw_param[0] ne 'ARRAY') {
        %param= %{$raw_param[0]};
    } elsif ($raw_param[0]) {
        %param= @raw_param;
    } else {
        return ();
    }

    for (keys %param) {
        if ($param{$_} eq '') {
            delete $param{$_};
        } else {
            $param{"-$_"}= $param{$_};
        }
    }

    return %param;
}

1;

