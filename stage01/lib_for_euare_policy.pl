#!/usr/bin/perl
use strict;

########################## SUBROUTINES #####################################

sub create_account_group{
	my $account = shift @_;
	my $group = shift @_;

	print "\n";
	print "########################### EUARE-GROUPCREATE ##############################\n";

	### create group account
	print "$ENV{'QA_CLC_IP'} :: euare-groupcreate -g $group\n";
	system("ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-groupcreate -g $group\" ");
	sleep(3);

	print "\n";
	print "\n";
	print "########################### EUARE-GROUPLISTBYPATH ##############################\n";

	print "$ENV{'QA_CLC_IP'} :: euare-grouplistbypath\n";
	my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-grouplistbypath\" `;
	print "\n";
	print $out . "\n";
	print "\n";
	
	if( $out =~ /$group/ ){
		print "[TEST_REPORT]\tSucceeded in creating group $group under account $account\n\n";
		return 0;
	};

	print "[TEST_REPORT]\tFAILED in creating group $group!!\n\n";	

	return 1;
};

sub copy_given_policy_file{
	my $p_filename = shift @_;
	print "\n";
	print "########################### COPY-GIVEN-POLICY-FILE ##############################\n";

	if( !(-e "./$p_filename") ){
		print "[TEST_REPORT]\tFAILED in locating the policy file $p_filename !!\n\n";
	};

	print "\n";
	print "Content of $p_filename\n";
	print "\n";
	system("cat ./$p_filename");
	print "\n";

	### copy given policy file to CLC machine
	print "scp -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no ./$p_filename root\@$ENV{'QA_CLC_IP'}:/root/.\n";
	system("scp -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no ./$p_filename root\@$ENV{'QA_CLC_IP'}:/root/.");
	print "\n";
	print "[TEST_REPORT]\tSuccessfully Copied the Policy File $p_filename to CLC\n";
	print "\n";

	return 0;
};


sub set_account_group_policy{
	my $account = shift @_;
	my $group = shift @_;
	my $policy = shift @_;

	print "\n";
	print "########################### SET-ACCOUNT-GROUP-POLICY ##############################\n";

	### set account group policy
	print "$ENV{'QA_CLC_IP'} :: euare-groupuploadpolicy -g $group -p $policy -f $policy\n";
	system("ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-groupuploadpolicy -g $group -p $policy -f $policy\" ");
	print "\n";

	sleep(2);

	print "\n";
	print "########################### VERIFY-ACCOUNT-GROUP-POLICY ##############################\n";

	### verify account group policy via 'euare-grouplistpolicies -g'
	print "$ENV{'QA_CLC_IP'} :: euare-grouplistpolicies -g $group\n";
	my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-grouplistpolicies -g $group\"`;
	print "\n";
	print "$out\n";
	if( !($out =~ /$policy/) ){
		print "[TEST_REPORT]\tFAILED in setting policy $policy to group $group\n\n";
	};
	print "[TEST_REPORT]\tSucceeded in setting policy $policy to group $group\n\n";

	return 0;
};


sub get_account_group_policy{
	my $account = shift @_;
	my $group = shift @_;
	my $policy = shift @_;

	print "\n";
	print "########################### GET-ACCOUNT-GROUP-POLICY ##############################\n";

	### get account group policy via 'euare-groupgetpolicy'
	print "$ENV{'QA_CLC_IP'} :: euare-groupgetpolicy -g $group -p $policy\n";
	my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-groupgetpolicy -g $group -p $policy\"`;
	print "\n";

	return $out
};

sub get_account_groups{
	my $account = shift @_;

	print "\n";
	print "########################### GET-ACCOUNT-GROUPS ##############################\n";

	### get account groups
	print "$ENV{'QA_CLC_IP'} :: euare-grouplistbypath\n";
	my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-grouplistbypath\"`;
	print "\n";

	return $out
};

sub get_list_of_groups{
	my $buffer = shift @_;
	my $out = "";

	my @temp_array = split("\n", $buffer);
	foreach my $line (@temp_array){
		if( $line =~/:group\/(.+)/ ){
			$out .= $1 . " ";
		};
	};

	return $out;
};


sub get_account_users{
	my $account = shift @_;

	print "\n";
	print "########################### GET-ACCOUNT-USERS ##############################\n";

	### get account users
	print "$ENV{'QA_CLC_IP'} :: euare-userlistbypath\n";
	my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-userlistbypath\"`;
	print "\n";

	return $out
};

sub get_list_of_users{
	my $buffer = shift @_;
	my $out = "";

	my @temp_array = split("\n", $buffer);
	foreach my $line (@temp_array){
		if( $line =~/:user\/(.+)/ ){
			$out .= $1 . " ";
		};
	};

	return $out;
};


sub set_account_user_to_group{
	my $account = shift @_;
	my $user = shift @_;
	my $group = shift @_;

	print "\n";
	print "########################### ADD-ACCOUNT-USER-TO-GROUP ##############################\n";

	### add account user to group
	print "$ENV{'QA_CLC_IP'} :: euare-groupadduser -g $group -u $user\n";
	system("ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-groupadduser -g $group -u $user\" ");
	print "\n";

	sleep(2);

	print "\n";
	print "########################### VERIFY-ACCOUNT-GROUP-ADD-USER ##############################\n";

	### verify account group add user
	print "$ENV{'QA_CLC_IP'} :: euare-grouplistusers -g $group\n";
	my $out = `ssh -o ServerAliveInterval=1 -o ServerAliveCountMax=5 -o StrictHostKeyChecking=no root\@$ENV{'QA_CLC_IP'} \"source /root/cred_depot/$account/admin/eucarc; euare-grouplistusers -g $group\"`;
	print "\n";
	print "$out\n";
	if( !($out =~ /$user/) ){
		print "[TEST_REPORT]\tFAILED in adding user $user to group $group\n\n";
	};
	print "[TEST_REPORT]\tSucceeded in setting user $user to group $group\n\n";

	return 0;
};


1;
