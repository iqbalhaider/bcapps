#!/bin/perl

# trivial script to convert skype logs to text (thin wrapper around
# Makefile.skypelog) for all my skype accounts)

# one of my few scripts that does NOT use bclib.pl!

# does not work with sh for some reason
$ENV{SHELL} = "tcsh";

for $i (glob ("/home/barrycarter/.Skype/*/")) {
  print STDERR "I: $i\n";
  chdir($i);
  unless (-f "Makefile") {
    warn "NO MAKEFILE IN: $i, creating";
    system("cp /home/barrycarter/BCGIT/Makefile.skypelog $i");
  }

  system("make");
}
