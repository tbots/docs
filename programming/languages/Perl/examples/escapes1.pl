#!/usr/bin/perl
use strict;
use warnings;
use v5.26;

my $str = 'hello,\\n world';
say "$str";

say 'backslash follows: \  ';		#  displayed as such
#say 'backslash follows: \';		#  fails, can not find closing quote
say 'backslash follows: \\';		#   no special meaning to backslash; does not escapes a closing quote
