#!/usr/bin/perl
use strict;
use Cwd;

require "./lib_for_euare.pl";
require "./lib_for_euare_policy.pl";

$ENV{'EUCALYPTUS'} = "/opt/eucalyptus";


################################################## CREATE GROUPS and ASSIGN POLICY . PL #########################################################


###
### check for arguments
###

my $given_account_name = "";
my $given_policy_count = "";


if ( @ARGV > 0 ){
	$given_account_name = shift @ARGV;
};

if ( @ARGV > 0 ){
	my $temp = shift@ARGV;
	if( $temp =~ /\d+/ ){
		$given_policy_count = $temp;
	};
};


###
### read the input list
###

print "\n";
print "########################### READ INPUT FILE  ##############################\n";

read_input_file();

my $clc_ip = $ENV{'QA_CLC_IP'};
my $source_lst = $ENV{'QA_SOURCE'};

if( $clc_ip eq "" ){
	print "[ERROR]\tCouldn't find CLC's IP !\n";
	exit(1);
};

if( $source_lst eq "PACKAGE" || $source_lst eq "REPO" ){
        $ENV{'EUCALYPTUS'} = "";
};



###
### check for TEST_ACCOUNT_NAME in MEMO
###

print "\n";
print "########################### GET ACCOUNT AND USER NAME  ##############################\n";

my $account_name = "group-policy-test";
my $policy_count = 3;

if( $given_account_name ne "" ){
	$account_name = $given_account_name;
};

if( $given_policy_count ne "" ){
	$policy_count = $given_policy_count;
};

print "\n";
print "TEST ACCOUNT NAME [$account_name]\n";
print "TEST POLICY COUNT [$policy_count]\n";
print "\n";



###
### clean up all the pre-existing credentials
###

print "\n";
print "########################### CLEAN UP CREDENTIALS  ##############################\n";

print "\n";
print("ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$clc_ip \"cd /root; rm -f *_cred.zip; rm -fr /root/cred_depot/eucalyptus/admin; rm -fr /root/cred_depot/$account_name/admin\"\n");
system("ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$clc_ip \"cd /root; rm -f *_cred.zip; rm -fr /root/cred_depot/eucalytpus/admin; rm -fr /root/cred_depot/$account_name/admin\" ");


###
### create test account crdentials
###

my $count = 1;
while( $count > 0 ){
	if( get_user_credentials($account_name, "admin") == 0 ){
		$count = 0;
	}else{
		print "Trial $count\tCould Not Create Account \'$account_name\' Credentials\n";
		$count++;
		if( $count > 60 ){
			print "[TEST_REPORT]\tFAILED to Create Account \'$account_name\' Credentials !!!\n";
			exit(1);
		};
		sleep(1);
	};
};
print "\n";


###
### move the account credentials on /root/account_cred of CLC machine
###

unzip_cred_on_clc($account_name, "admin");
print "\n";


###
### create group
###
for( my $i = 0; $i < $policy_count; $i++){
	my $group_name = "group" . sprintf("%02d", $i);
	create_account_group($account_name, $group_name);
	print "\n";
	sleep(2);
};
print "\n";

###
### set policy
###

for( my $i = 0; $i < $policy_count; $i++){
	my $group_name = "group" . sprintf("%02d", $i);
	my $policy_filename = "group" . sprintf("%02d", $i) . ".policy";
	copy_given_policy_file($policy_filename);
	set_account_group_policy($account_name, $group_name, $policy_filename);
	print "\n";
	sleep(2);
};
print "\n";

###
### Visual Display of Assigned Policies
###
print "\n";
print "++++++++++++++++++++++++++++++ VISUAL CONFIMATION OF ASSIGNED POLICIES +++++++++++++++++++++++++++++++++++++\n";
print "\n";

for( my $i = 0; $i < $policy_count; $i++){
	my $group_name = "group" . sprintf("%02d", $i);
	my $policy_filename = "group" . sprintf("%02d", $i) . ".policy";
	my $out = get_account_group_policy($account_name, $group_name, $policy_filename);
	print "[ACCOUNT $account_name, GROUP $group_name, POLICY $policy_filename]\n";
	print "\n";
	print "$out\n";
	print "\n";

	chomp($out);
	compare_contents($policy_filename, $out);

};
print "\n";


###
### End of Script
###

print "\n";
print "[TEST_REPORT]\tCREATE GROUPS AND ASSIGN POLICY HAS BEEN COMPLETED\n";
print "\n";

exit(0);

1;

##################### SUB-ROUTINES ############################

sub compare_contents{
	my $p_file = shift @_;
	my $buffer = shift @_;
	system("rm -f ./temp.policy");

	open(TEMP_P, "> temp.policy") or die $!;
	print TEMP_P $buffer . "\n";
	close(TEMP_P);
	system("diff ./$p_file ./temp.policy");
	system("rm -f ./temp.policy");
	return 0;
};
