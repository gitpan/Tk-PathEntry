# -*- perl -*-

#
# $Id: PathEntry.pm,v 2.10 2001/05/05 15:58:21 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 2001 Slaven Rezic. All rights reserved.
# This package is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: srezic@cpan.org
# WWW:  http://user.cs.tu-berlin.de/~eserte/
#

package Tk::PathEntry;

use strict;
use vars qw($VERSION);
$VERSION = sprintf("%d.%02d", q$Revision: 2.10 $ =~ /(\d+)\.(\d+)/);

use base qw(Tk::Derived Tk::Entry);

Construct Tk::Widget 'PathEntry';

sub Populate {
    my($w, $args) = @_;

    my $choices_t = $w->Component("Toplevel" => "ChoicesToplevel");
    $choices_t->overrideredirect(1);
    $choices_t->withdraw;

    my $choices_l = $choices_t->Label(-justify => "left",
				      -background => "yellow",
				      -anchor => "w")->pack(-fill => "both",
							    -expand => 1);
    $w->Advertise("ChoicesLabel" => $choices_l);

    if (exists $args->{-vcmd} ||
	exists $args->{-validatecommand} ||
	exists $args->{-validate}) {
	die "-vcmd, -validatecommand or -validate are not allowed with PathEntry";
    }

    $args->{-vcmd} = sub {
	my($pathname) = @_;
	if ($w->ismapped) {
	    $w->{CurrentChoices} = $w->Callback(-choicescmd => $w, $pathname);
	    if ($w->{CurrentChoices} && @{$w->{CurrentChoices}} > 1) {
		$w->_show_choices($w->rootx);
	    } else {
		$choices_t->withdraw;
	    }
	}
	1;
    };
    $args->{-validate} = 'key';

    if (!exists $args->{-textvariable}) {
	my $pathname;
	$args->{-textvariable} = \$pathname;
    }

    $w->bind("<Tab>" => sub {
		 if (!defined $w->{CurrentChoices}) {
		     # this is called only on init:
		     my $pathref = $w->cget(-textvariable);
		     $w->{CurrentChoices} = $w->Callback(-choicescmd => $w, $$pathref);
		     if (@{$w->{CurrentChoices}} > 1) {
			 $w->_show_choices($w->rootx);
		     }
		 }
		 if (@{$w->{CurrentChoices}} > 0) {
		     my $sep = $w->cget(-separator);
		     my $common = $w->_common_match;
		     if ($w->Callback(-isdircmd => $w, $common) &&
			 $common !~ m|\Q$sep\E$|                &&
			 @{$w->{CurrentChoices}} == 1
			) {
			 $common .= $sep;
		     }
		     my $pathref = $w->cget(-textvariable);
		     $$pathref = $common;
		     $w->icursor("end");
		     $w->xview("end");
		 } else {
		     $w->bell;
		 }
		 Tk->break;
	     });

    for ("M", "Alt") {
	$w->bind("<$_-BackSpace>" => sub {
		     $w->_delete_last_path_component;
		     Tk->break;
		 });
    }
    $w->bind("<FocusOut>" => sub {
		 $w->Finish;
	     });

    $w->ConfigSpecs
	(-initialdir  => ['PASSIVE',  undef, undef, undef],
	 -initialfile => ['PASSIVE',  undef, undef, undef],
	 -separator   => ['PASSIVE',  undef, undef, "/"],
	 -isdircmd    => ['CALLBACK', undef, undef, ['_is_dir']],
	 -isdirectorycommand => 'isdircmd',
	 -choicescmd  => ['CALLBACK', undef, undef, ['_get_choices']],
	 -choicescommand     => 'choicescmd',
	);
}

sub ConfigChanged {
    my($w,$args) = @_;
    for (qw/dir file/) {
	if (defined $args->{'-initial' . $_}) {
	    $ {$w->cget(-textvariable)} = $args->{'-initial' . $_};
	}
    }
}

sub Finish {
    my $w = shift;
    my $choices_t = $w->Subwidget("ChoicesToplevel");
    $choices_t->withdraw;
    delete $w->{CurrentChoices};
}

sub _delete_last_path_component {
    my $w = shift;

    my $before_cursor = substr($w->get, 0, $w->index("insert"));
    my $after_cursor = substr($w->get, $w->index("insert"));
    my $sep = $w->cget(-separator);
    $before_cursor =~ s|\Q$sep\E$||;
    $before_cursor =~ s|[^$sep]+$||;
    my $pathref = $w->cget(-textvariable);
    $$pathref = $before_cursor . $after_cursor;
    $w->icursor(length $before_cursor);
}

sub _common_match {
    my $w = shift;
    my(@choices) = @{$w->{CurrentChoices}};
    my $common = shift @choices;
    foreach (@choices) {
	if (length $_ < length $common) {
	    $common = substr($common, 0, length $_);
	}
	for my $i (0 .. length($common) - 1) {
	    if (substr($_, $i, 1) ne substr($common, $i, 1)) {
		return "" if $i == 0;
		$common = substr($_, 0, $i);
		last;
	    }
	}
    }
    $common;
}

sub _get_choices {
    my $pathname = $_[1];
    my $glob;
    $glob = "$pathname*";
    [ glob($glob) ];
}

sub _show_choices {
    my($w, $x_pos) = @_;
    my $choices = $w->{CurrentChoices};
    my $choices_l = $w->Subwidget("ChoicesLabel");
    my $choices_t = $w->Subwidget("ChoicesToplevel");
    $choices_l->configure(-text => join("\n", @$choices));
    $choices_t->geometry("+" . $x_pos . "+" . ($w->rooty+$w->height));
    $choices_t->deiconify;
    $choices_t->raise;
}

sub _is_dir { -d $_[1] }

1;

__END__

=head1 NAME

Tk::PathEntry - Entry widget for selecting paths with completion

=head1 SYNOPSIS

    use Tk::PathEntry;
    my $pe = $mw->PathEntry(-textvariable => \$path)->pack;
    $pe->bind("<Return>" => sub { warn "The pathname is $path\n" });

=head1 DESCRIPTION

This is an alternative to classic file selection dialogs. It works
more like the file completion in modern shells like C<tcsh> or
C<bash>.

With the C<Tab> key, you can force the completion of the current path.
If there are more choices, a window is popping up with these choices.
With the C<Meta-Backspace> or C<Alt-Backspace> key, the last path
component will be deleted.

=head1 OPTIONS

B<Tk::PathEntry> supports all standard L<Tk::Entry|Tk::Entry> options
except C<-vcmd> and C<-validate> (these are used internally in
B<PathEntry>). The additional options are:

=over 4

=item -initialdir

Set the initial path to the value. Alias: C<-initialfile>. You can
also use a pre-filled C<-textvariable> to set the initial path.

=item -separator

The character used as the path component separator. For Unix, this is "/".

=item -isdircmd

Can be used to set another directory recognizing subroutine. The
directory name is passed as second parameter. Alias:
C<-isdirectorycommand>. The default is a subroutine using C<-d>.

=item -choicescmd

Can be used to set another globbing subroutine. The current pathname
is passed as second parameter. Alias: C<-choicescommand>. The
default is a subroutine using the standard C<glob> function.

=back

=head1 METHODS

=over 4

=item Finish

This will popdown the window with the completion choices. It is
advisable to bind the Return key to call this method. The popdown is
done automatically when the widget loses the input focus.

=back

=head1 EXAMPLES

If you want to not require from your users to install Tk::PathEntry,
you can use the following code snippet to create either a PathEntry or
an Entry, depending on what is installed:


    my $e;
    if (!eval '
        use Tk::PathEntry;
        $e = $mw->PathEntry(-textvariable => \$file);
        $e->bind("<Return>" => sub { $e->Finish });
        1;
    ') {
        $e = $mw->Entry(-textvariable => \$file);
    }
    $e->pack;

=head1 SEE ALSO

L<Tk::PathEntry::Dialog (3)|Tk::PathEntry::Dialog>,
L<Tk::Entry (3)|Tk::Entry>, L<tcsh (1)|tcsh>, L<bash (1)|bash>.

=head1 AUTHOR

Slaven Rezic <srezic@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2001 Slaven Rezic. All rights
reserved. This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

