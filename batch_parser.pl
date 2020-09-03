#!/usr/bin/perl

# We are being lazy, and not rewriting this in bash
# Input: batch file name
# Output: list of component sets and their constituent file sets, with quantity numbers
#			for easy parsing by our bash script
# Pralit Patel and Ben Bond-Lamberty, Februrary 2009

my $batch_file_name = $ARGV[0];
my $lines;

open(BATCH_FILE_HANDLE, $batch_file_name) or die ;
while(<BATCH_FILE_HANDLE>) {
	$lines .= $_;
}
close(BATCH_FILE_HANDLE);

my @component_sets = $lines =~ /<ComponentSet\s*name="(.*?)"\s*>(.*?)<\/ComponentSet>/sg;
my @runner_sets = $lines =~ /<runner-set\s*name="(.*?)"\s*>(.*?)<\/runner-set>/sg;
my $num_component_sets = @component_sets / 2;
my $num_runner_sets = @runner_sets / 2;
my $total_sets = $num_component_sets + $num_runner_sets;
print "$total_sets\n";
while(@component_sets > 0) {
	my $comp_name = shift(@component_sets);
	print "${comp_name}\n";
	my $temp_file_set= shift(@component_sets);
	my @file_sets = $temp_file_set =~ /<FileSet\s*name="(.*?)"\s*>(.*?)<\/FileSet>/sg;
	my $num_file_sets = @file_sets / 2;
	print "$num_file_sets\n";
	while(@file_sets > 0) {
		my $file_set_name = shift(@file_sets);
		print "${file_set_name}\n";
		my $file_values = shift(@file_sets);
		$file_values =~ s/\r//g;
		$file_values =~ s/\n//g;
		print "$file_values\n";
	}
}


while(@runner_sets > 0) {
	my $comp_name = shift(@runner_sets);
	print "${comp_name}\n";
	my $temp_file_set= shift(@runner_sets);
    #my @file_sets = $temp_file_set =~ /<Value\s*name="(.*?)"\s*>(.*?)<\/Value>/sg;
    $temp_file_set =~ s/^\s+//;
    $temp_file_set =~ s/\s+$//;
	my @file_sets = split(/\n/, $temp_file_set);
	my $num_file_sets = @file_sets;
	print "$num_file_sets\n";
	while(@file_sets > 0) {
        my $line = shift(@file_sets);
        if($line =~ /<Value\s*name="(.*?)"\s*>(.*?)<\/Value>/) {
            my $file_set_name = $1;
            print "${file_set_name}\n";
            my $file_values = $2;
            $file_values =~ s/\r//g;
            $file_values =~ s/\n//g;
            print "$file_values\n";
        } elsif($line =~ /<single-scenario-runner/) {
            print "\n\n";
        } else {
            print STDERR "Unknown runner-set: $line\n";
            print "\n\n";
        }
	}
}

