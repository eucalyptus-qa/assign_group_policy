#!/usr/bin/perl
use strict;

my $account_name = "group-policy-test";
my $user_limit = 7;

print "\n";
print "Create Group Policy Test Users\n";
print "\n";
print "[ACCOUNT NAME]\t$account_name\n";
print "[USER LIMIT]\t$user_limit\n";
print "\n";

for( my $j = 0; $j < $user_limit; $j++){
	my $user = "user" . sprintf("%02d", $j);

	print "\n";
	print "\n";
	print "\n";
	print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
	print "Create Account \'$account_name\' and User \'$user\'\n";
	print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
	print "\n";
	print "\n";
	system("perl ./create_account_and_user_no_policy.pl $account_name $user");
	print "\n";
};

exit(0);

1;


