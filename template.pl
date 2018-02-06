#!/usr/bin/env perl

use strict;
use warnings;
use autodie;

use Modern::Perl;
use Clipboard;

my $continue = "";

do{
    # Call cls on windows systems, clear on unix.
    system $^O eq 'MSWin32' ? 'cls' : 'clear';
    open my $fh, "<" , "template.txt" or die "Cannot read the file!";

    my $total_score = 0;
    my $received_total = 0;

    my $out = "";

    while (<$fh>){
        say;
        #Do nothing with commented lines
        if (/^\/\/.*/){}
        # Matches [x/x]
        elsif (/.*\[([-0-9.]*\/)([0-9.]*)\].*/)
        {
            # Matches [x
            my $default = $1;
            # Matches the total score in the current line
            my $total_line = $2;
            # Keep track of the maximum possible score
            $total_score += $total_line;
            print ">";
            my $input = <STDIN>;
            chomp $input;

            # Gets every number inside square brackets
            my $pattern = qr/\[([-0-9]+)\]/;

            for ($input =~ /$pattern/g){
                $total_line += $_ if $_ < 0;
            }
            $received_total += $total_line;
            # Replace [X/ with the new score
            $_ =~ s/$default/$total_line\//;
            # Append the current line from the template
            $out  .= $_;
            $out .= $input;
            say $input;
            say $out;
        }
        else{
            $out .= $_;
        }
    }
    $out .= "\n\nTotal: [$received_total/$total_score]";
    Clipboard->copy($out);

    open my $fout, ">", "out.txt" or die "Cannot write to file";
    print $fout $out;
    close $fout;

    print "\nContinue?>";
    $continue = <STDIN>;
    chomp $continue;
} while($continue ne "n");
