#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: Makefile.PL,v 1.2 2001/05/06 08:51:12 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 2001 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: srezic@cpan.org
# WWW:  http://user.cs.tu-berlin.de/~eserte/
#

use ExtUtils::MakeMaker;

WriteMakefile
  (
   'NAME'	   => 'Tk::PathEntry',
   'VERSION_FROM'  => 'PathEntry.pm',
   'PREREQ_PM'     => { Tk => 800.020 },

   'dist'          => {'POSTOP'=>'-$(CHMOD) 644 $(DISTVNAME).tar$(SUFFIX)'},

   'ABSTRACT_FROM' => '',
   'AUTHOR'        => 'Slaven Rezic (srezic@cpan.org)',
  );

__END__
