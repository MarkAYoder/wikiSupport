#!/usr/bin/perl -w

use strict;

my @test;

for(my $i=0; $i<5; $i++) {
  $test[$i] = [$i, 'this'];
}

my $item;
foreach $item (@test) {
  print $item->[0], $item->[1], "\n";
}
