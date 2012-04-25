#!/usr/bin/perl
use strict;
use Cwd;

require "./lib_for_euare.pl";
require "./lib_for_euare_policy.pl";

$ENV{'EUCALYPTUS'} = "/opt/eucalyptus";


################################################## ASSIGN USERS TO GROUPS . PL #########################################################


###
### check for arguments
###

my $given_account_name = "";
my $given_assignment_method = "";


if ( @ARGV > 0 ){
	$given_account_name = shift @ARGV;
};

if ( @ARGV > 0 ){
	$given_assignment_method = shift @ARGV;
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
my $assignment_method = "ROUND-ROBIN";

if( $given_account_name ne "" ){
	$account_name = $given_account_name;
};

if( $given_assignment_method ne "" ){
	$assignment_method = $given_assignment_method;
};

print "\n";
print "TEST ACCOUNT NAME [$account_name]\n";
print "TEST ASSIGNMENT METHOD [$assignment_method]\n";
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
### get groups
###
my $out = get_account_groups($account_name);
print "$out\n";
print "\n";


###
### get groups in array
###
$out = get_list_of_groups($out);
print "Groups List\n";
print "$out\n";
print "\n";

my @group_array = split(" ", $out);

###
### get users
###
$out = get_account_users($account_name);
print "$out\n";
print "\n";


###
### get users in array
###
$out = get_list_of_users($out);
print "Users List\n";
print "$out\n";
print "\n";

my @user_array = split(" ", $out);


###
### Assign Users to Groups
###

my $group_count = @group_array;
my $user_count = @user_array;

for( my $i = 1; $i < $user_count; $i++){						### Starting from $i=1 to skip "admin" 
	my $user = $user_array[$i];

	my $group_index = $i % $group_count;
	my $group = $group_array[$group_index];

	print "\n";
	print "Assigning User $user to Group $group\n";
	set_account_user_to_group($account_name, $user, $group);
	print "\n";
	sleep(1);
};
print "\n";

###
### End of Script
###

print "\n";
print "[TEST_REPORT]\tASSIGN USERS TO CREATE GROUPS HAS BEEN COMPLETED\n";
print "\n";

exit(0);

1;

##################### SUB-ROUTINES ############################

