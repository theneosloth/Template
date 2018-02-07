#!/usr/bin/env perl

use strict;
use warnings;
use autodie;

use Modern::Perl;
use Clipboard;

my $continue = "";

my $file = shift @ARGV || "template.txt";
my $out = shift @ARGV || "out.txt";

# Main loop, iterates over the entire file. Terminates after a yes no prompt
do{
    # Call cls on windows systems, clear on unix.
    system $^O eq 'MSWin32' ? 'cls' : 'clear';
    # Open the file. Use either the file name passed or "template.txt"
    open my $fh, "<" , $file or die "Cannot read the file!";

    # Keeps track of the grade received
    my $total_grade = 0;
    my $received_total = 0;

    # Sub loop that iterates over each line
    while (<$fh>){
        #Print out the line to the console
        say;
        #Do nothing with commented lines
        if (/^\/\/.*/){}
        # Matches [x/x]
        elsif (/.*\[([-0-9.]*\/)([0-9.]*)\].*/)
        {
            # Matches [x
            my $default = $1;
            # Matches the total grade in the current line
            my $total_line = $2;
            # Keep track of the maximum possible grade
            $total_grade += $total_line;
            print ">";
            my $input = <STDIN>;
            chomp $input;

            # Gets every negative number inside square brackets
            my $pattern = qr/\[([-0-9]+)\]/;

            for ($input =~ /$pattern/g){
                $total_line += $_ if $_ < 0;
            }
            $received_total += $total_line;
            # Replace [X/ with the new grade
            $_ =~ s/$default/$total_line\//;
            # Append the current line from the template
            $out  .= $_;
            # Append the user input
            $out .= $input . "\n";
        }
        else{
            $out .= $_;
        }
    }
    $out .= "\n\nTotal: [$received_total/$total_grade]";
    Clipboard->copy($out);

    open my $fout, ">", "out.txt" or die "Cannot write to file";
    print $fout $out;
    close $fout;

    print "\nContinue?>";
    $continue = <STDIN>;
    chomp $continue;

} while($continue =~ /^[^n]*/i);
