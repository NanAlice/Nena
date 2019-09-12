# !/usr/local/bin/perl

use strict;
use warnings;

use Text::Diff;

# my $pro_name = $ARGV[0] or die "Please input the name of program: $!.\n";

sub comp_file {
	my $fn1 = shift or die "please use comp_file function as comp_file(filename1, filename2): $!.\n";
	my $fn2 = shift or die "please use comp_file function as comp_file(filename1, filename2): $!.\n";
	my $file1;
	my $file2;
	open($file1, "<", $fn1) or die "Cannot open $fn1: $!.\n";
	open($file2, "<", $fn2) or die "Cannot open $fn2: $!.\n";

	my $line_cur = 1;
	my $line1 = '';
	my $line2 = '';
	while ($line1 = <$file1>) {
		if (!($line2 = <$file2>)) {
			return ($line_cur, $line1, '');
		}
		if ($line1 ne $line2) {
			return ($line_cur, $line1, $line2);
		}
		++$line_cur;
	}
	if (!($line2 = <$file2>)) {
		return (0, '', '');
	}
	else {
		return ($line_cur, '', $line2);
	}
}

sub comp_file_out {
	my $fn1 = shift or die "please use comp_file function as comp_file(filename1, filename2): $!.\n";
	my $fn2 = shift or die "please use comp_file function as comp_file(filename1, filename2): $!.\n";
	my @diff = comp_file($fn1, $fn2);
	if ($diff[0] == 0) {
		print "$fn1 and $fn2 are the same.\n";
	}
	else {
		print "$fn1 and $fn2 differ at line $diff[0]:\n$fn1: \[$diff[1]\] \n$fn2: \[$diff[2]\]\n";
	}
	return $diff[0];
}

sub run_test {
	my %parms = ("-p" => '', "-n" => 10, "-std" => '.std', "-run" => '.tst', 
	"-in" => '.in', "-out" => '.out', "-ans" => '.ans', "-inn" => 0, "-outn" => 0, "-ansn" => 0, "-stt" => 0);
	my %flags = ("-rstd" => 0);
	while (my $parm = shift) {
		if (exists $parms{$parm}) {
			$parms{$parm} = shift;
		}
		elsif (exists $flags{$parm}) {
			$flags{$parm} = 1;
		}
		else {
			print "$parm is not a parameter for function run_test, exiting.";
			return ;
		}
	}

	my $pn = $parms{"-p"};

	my $test_folder = $pn . '/';
	my $test_program = $test_folder . $pn . $parms{"-run"};
	my $std_program = $test_folder . $pn . $parms{"-std"};
	my @res = ();

	my $in_name = $parms{"-inn"};
	if (!$in_name) {
		$in_name = $pn;
	}

	my $out_name = $parms{"-outn"};
	if (!$out_name) {
		$out_name = $pn;
	}

	my $ans_name = $parms{"-ansn"};
	if (!$ans_name) {
		$ans_name = $pn;
	}

	my $test_case_start = $parms{"-stt"};
	# print '$test_case_start = ' . "$test_case_start\n";

	for (my $test_i = $test_case_start; $test_i < $test_case_start + $parms{"-n"}; ++$test_i) {
		my $input_fn = $test_folder . $in_name . $test_i . $parms{"-in"};
		my $output_fn = $test_folder . $out_name . $test_i . $parms{"-out"};
		my $ans_fn = $test_folder . $ans_name . $test_i . $parms{"-ans"};

		!system("./$test_program < $input_fn > $output_fn") or die "Cannot run $test_program: $!.\n";
		if ($flags{"-rstd"}) {
			!system("./$std_program < $input_fn > $ans_fn") or die "Cannot run $std_program: $!.\n";
		}
		push(@res, comp_file_out($output_fn, $ans_fn));
	}
	return @res;
}

#comp_file_out("Nena1.txt", "Nena2.txt");
my @res = run_test(@ARGV);
for (my $resi = 0; $resi < @res; ++$resi) {
	my $res_out = "right";
	if ($res[$resi]) {
		$res_out = "wrong";
	}
	print "Test case $resi: $res_out\n";
}