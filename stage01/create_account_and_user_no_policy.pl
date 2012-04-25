#!/usr/bin/perl
use strict;
use Cwd;

require "./lib_for_euare.pl";

$ENV{'EUCALYPTUS'} = "/opt/eucalyptus";


################################################## CREATE ACCOUNT AND USER . PL #########################################################


###
### check for arguments
###

my $given_account_name = "";
my $given_user_name = "";


if ( @ARGV > 0 ){
	$given_account_name = shift @ARGV;
};

if ( @ARGV > 0 ){
	$given_user_name = shift @ARGV;
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

my $account_name = "default-qa-account";
my $user_name = "default-qa-user";

if( $given_account_name ne "" ){
	$account_name = $given_account_name;
}elsif( is_test_account_name_from_memo() ){
	$account_name = $ENV{'QA_MEMO_TEST_ACCOUNT_NAME'};
};

if( $given_user_name ne "" ){
	$user_name = $given_user_name;
}elsif( is_test_account_user_name_from_memo() ){
	$user_name = $ENV{'QA_MEMO_TEST_ACCOUNT_USER_NAME'};
};

print "\n";
print "TEST ACCOUNT NAME [$account_name]\n";
print "TEST USER NAME [$user_name]\n";
print "\n";



###
### clean up all the pre-existing credentials
###

print "\n";
print "########################### CLEAN UP CREDENTIALS  ##############################\n";

print "\n";
print("ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$clc_ip \"cd /root; rm -f *_cred.zip; rm -fr /root/cred_depot/eucalyptus/admin; rm -fr /root/cred_depot/$account_name/$user_name\"\n");
system("ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$clc_ip \"cd /root; rm -f *_cred.zip; rm -fr /root/cred_depot/eucalytpus/admin; rm -fr /root/cred_depot/$account_name/$user_name\" ");


###
### create admin credentials first
###

my $count = 1;
while( $count > 0 ){
	if( get_user_credentials("eucalyptus", "admin") == 0 ){
		$count = 0;
	}else{
		print "Trial $count\tCould Not Create Admin Credentials\n";
		$count++;
		if( $count > 60 ){
			print "[TEST_REPORT]\tFAILED to Create Admin Credentials !!!\n";
			exit(1);
		};
		sleep(1);
	};
};
print "\n";


###
### move the admin credentials on /root/admin_cred of CLC machine
###

unzip_cred_on_clc("eucalyptus", "admin");
print "\n";


###
### create account
###

create_account($account_name);
print "\n";


###
### create test account crdentials
###

$count = 1;
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
### create user
###

create_account_user($account_name, $user_name);
print "\n";

###
### All the user full access
###
copy_all_policy_file();
print "\n";

allow_account_user_fullaccess($account_name, $user_name);
print "\n";


###
### End of Script
###

print "\n";
print "[TEST_REPORT]\tCREATE ACCOUNT AND USER HAS BEEN COMPLETED\n";
print "\n";

exit(0);

1;


