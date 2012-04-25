#!/usr/bin/perl
use strict;

my $account_name = "group-policy-test";
my $policy_count = 3;

print "\n";
print "Create Groups and Assign Policy\n";
print "\n";
print "[ACCOUNT NAME]\t$account_name\n";
print "[POLICY COUNT]\t$policy_count\n";
print "\n";

print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "Create \'$policy_count\' Groups under \'$account_name\'\n";
print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "\n";
print "\n";
system("perl ./create_groups_and_assign_policy.pl $account_name $policy_count");
print "\n";

exit(0);

1;


