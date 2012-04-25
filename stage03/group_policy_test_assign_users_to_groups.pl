#!/usr/bin/perl
use strict;

my $account_name = "group-policy-test";
my $policy_count = 3;

print "\n";
print "Create Groups and Assign Policy\n";
print "\n";
print "[ACCOUNT NAME]\t$account_name\n";
print "\n";

print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "Assign Users under \'$account_name\' to its Group in using Round-Robin\n";
print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
print "\n";
print "\n";
system("perl ./assign_users_to_groups.pl $account_name ROUND-ROBIN");
print "\n";

exit(0);

1;


