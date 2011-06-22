#!/bin/perl

# Attempts to create better maps for EL using el-wiki.net information
# --username=username [if given, colors NPCs based on username's logs]

# Desert Pines = first example

require "bclib.pl";

# if requested, see what NPCs you've spoken with
# NOTE: assumes NPC in-game name is identical to wiki name, not always true
# NOTE: this won't work if you have multiple chars

if ($globopts{"username"}) {
  $quest = read_file("$ENV{HOME}/.elc/main/quest_$globopts{username}.log");
  for $i (split(/\n/, $quest)) {
    # note that I have seen this NPC (+ how many times)
    $i=~s/:.*$//;
    # this appears in chat logs for some reason
    $i=~s/\x8a//;
    $seen{$i}++;
  }
}

debug(unfold(%seen));

# find the file where I store Desert Pines wiki page (not super efficient)
# really hard to match <tab> exactly w/o also matching spaces
($res) = cache_command("egrep -i '[[:space:]]Desert Pines\$' /usr/local/etc/wiki/EL-WIKI.NET/pageinfo-0.txt", "age=3600");

# find the exact right one
for $i (split(/\n/, $res)) {
  $i=~/^(.*?)\s+(.*?)\s+(.*?)$/;
  ($file, $time, $name) = ($1,$2,$3);
  if ($name eq "Desert Pines") {last;}
}

$page = read_file("/usr/local/etc/wiki/EL-WIKI.NET/$file");

for $i (split("\n",$page)) {
  debug("LINE: $i");

  # are we in a new section? (currently unused)
  if (/== (.*?) ==/) {$section = $1; next;}

  # does this line have coordinates (maybe more than one)
  @coords = ();
  while ($i=~s/\[(\d+\,\d+)\]//) {
    push(@coords, $1);
  }

  unless (@coords) {
#    debug("No coords, skipping");
    next;
  }

  # ignore [[File:thing]]
  $i=~s/\[\[file:.*?\]\]//isg;

  # look for the first [[thing]]; if none, use first word as name
  if ($i=~/\[\[(.*?)\]\]/) {
    $name = $1;
  } else {
    $name = $i;
    # get rid of external links and *
    $name=~s/\[.*?\]//isg;
    $name=~s/\*//isg;
    $name=~s/\s.*$//;
  }

  for $j (@coords) {

    # color code (these color choices aren't final)
    debug("NAME: $name, SEEN: $seen{$name}");
    if ($seen{$name}) {
      $color="255,255,255";
    } else {
      $color="0,0,0";
    }

    # add to marks file
    $j=~s/,/ /isg;
    push(@marks, "$j|$color| $name");
  }
}

# intentionally put this in GIT so people can have updated versions
# (kinda) w/o having to run this program [however, my versions may
# contain marks specific to me]

write_file(join("\n",@marks)."\n", "/home/barrycarter/BCGIT/EL/map3.elm.txt");

# NOTE: must change maps for new marks file to load (I have it symlinked)
