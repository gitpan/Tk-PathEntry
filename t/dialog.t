#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: dialog.t,v 1.4 2001/05/04 18:56:23 eserte Exp $
# Author: Slaven Rezic
#

use strict;

use Tk;
use Tk::PathEntry::Dialog qw(as_default);

BEGIN {
    if (!eval q{
	use Test;
	1;
    }) {
	print "# tests only work with installed Test module\n";
	print "1..1\n";
	print "ok 1\n";
	exit;
    }
}

BEGIN { plan tests => 3 }

my $top = new MainWindow;
$top->Message(-text => <<EOF)->pack;
Note:
No actual writes are performed in this test,
so you can always say "OK" or "Yes".
EOF

my $f1 = $top->getOpenFile(-title => "File to open",
			   -initialdir => $ENV{HOME},
			   -defaultextension => "ignored",
			   -filetypes => [["ignored", "*"]],
			  );
yc($f1);
ok(1);

my $f2 = $top->getSaveFile(-title => "File to save",
			   -initialfile => "$ENV{HOME}/.cshrc",
			   -defaultextension => "ignored",
			   -filetypes => ["ignored"],
			  );
yc($f2);
ok(1);

my $f3 = $top->PathEntryDialog->Show;
yc($f3);
ok(1);

sub yc {
    my $c = shift;
    print STDERR "Your choice: ";
    if (!defined $c) {
	print STDERR "undefined";
    } else {
	print STDERR $c;
    }
    print STDERR "\n";
}

__END__
