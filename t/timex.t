#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: timex.t,v 1.10 2007/08/29 16:30:35 k_wittrock Exp $
# Author: Slaven Rezic
#

use strict;

use Tk;
use Tk::PathEntry;

BEGIN {
    if (!eval q{
	use Test;
	use Timex::Project;
	1;
    }) {
	print "# tests only work with installed Test and Timex::Project module\n";
	print "1..1\n";
	print "ok 1\n";
	CORE::exit;
    }
}

BEGIN { plan tests => 2 }

if (!defined $ENV{BATCH}) { $ENV{BATCH} = 1 }

my $timex_project_text = <<'EOF';
#PJ1 -*- project -*-
>bbbike
>>perl
>>purl
>a new project
>main project
>>sub of main project
>>>sub of sub of main project
>another one
>bla
>foo
>>bar
EOF

my $t = new Timex::Project;
$t->separator('|');
my @d = split /\n/, $timex_project_text;
$t->interpret_data(\@d);
#my $first_p = ($t->subproject)[0];
my $pathname = ""; #$first_p->pathname;

ok(!!$t->isa('Timex::Project'), 1);

my $top = tkinit;
$top->title("Select Timex projects:");
$top->minsize(300,50);
my $pe;
$pe = $top->PathEntry
    (-textvariable => \$pathname,
     -separator => $t->separator,
     -isdircmd => sub {
	 my $pathname = $_[1];
	 my $p = $t->find_by_pathname($pathname);
	 return 0 if !$p;
	 @{$p->subproject} > 0;
     },
     -choicescmd => sub {
	 my($w, $pathname) = @_;
	 my $sep = $w->cget(-separator);

	 if ($pathname =~ /^(.*)\Q$sep\E$/) {
	     my $p = $t->find_by_pathname($1);
	     if ($p) {
		 return [ map { $_->pathname } $p->subproject ];
	     } else {
		 die "Project $pathname does not exist";
	     }
	 }

	 my($dirname) = $pathname =~ /^([^$sep]+)\Q$sep\E/;
	 my $dir_p;
	 if (!defined $dirname || $dirname eq '') {
	     $dir_p = $t; # root
	 } else {
	     $dir_p = $t->find_by_pathname($dirname);
	     if (!$dir_p) {
		 die "Can't find path by name: $dirname";
	     }
	 }
	 my @res;
	 foreach ($dir_p->subproject) {
	     my $path = $_->pathname;
	     push @res, $path if $path =~ /^\Q$pathname\E/;
	 }
	 \@res;
     })->grid(-sticky => "ew");
$top->gridColumnconfigure(0, -weight => 1);
ok(!!Tk::Exists($pe), 1);

$top->Label(-textvariable => \$pathname)->grid;

$top->Button(-text => "OK",
	     -command => sub { $top->destroy })->grid;

if ($ENV{BATCH}) { $top->after(1000, sub { $top->destroy }) }

MainLoop;

__END__
