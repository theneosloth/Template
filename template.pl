#!/usr/bin/env perl

use strict;
use warnings;
use autodie;

use Modern::Perl;
use Clipboard;

my $continue = "";

do{
    # Call cls on windows systems, clear on unix. $^0 stores the OS name

    system $^O eq 'MSWin32' ? 'cls' : 'clear';
    open my $fh, "<" , "template.txt" or die "Cannot read the file!";

    my $total_score = 0;
    my $received_score = 0;

    my $out = "";

    while (<$fh>){
        say;
        #Do nothing with commented lines
        if (/^\/\/.*/){}
        # Matches [x/x]
        elsif (/.*\[([-0-9.]*\/)([0-9.]*)\].*/)
        {
            my $default = $1;
            my $total_line = $2;
            $total_score += $total_line;
            print ">";
            my $score = <STDIN>;
            chomp $score;
            # If the score input is non numeric make it equal to the default
            $score = $total_line if $score =~ /[^0-9.-]+/ || $score eq "";
            $score = $total_line + $score if $score < 0;
            $received_score += $score;
            print "Notes>";
            my $notes = <STDIN>;
            # Replace [X/ with the new score
            $_ =~ s/$default/$score\//;
            $out  .= $_;
            $out .= $notes;
        }
        else{
            $out .= $_;
        }
    }
    $out .= "\n\nTotal: [$received_score/$total_score]";
    Clipboard->copy($out);

    open my $fout, ">", "out.txt" or die "Cannot write to file";
    print $fout $out;
    close $fout;

    print "\nContinue?>";
    $continue = <STDIN>;
    chomp $continue;
} while($continue ne "n");
