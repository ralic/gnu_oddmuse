# Copyright (C) 2007  Alex Schroeder <alex@emacswiki.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use v5.10;

AddModuleDescription('archive.pl', 'Archive Extension');

our ($q);

*OldArchiveGetHeader = \&GetHeader;
*GetHeader = \&NewArchiveGetHeader;

# this assumes that *all* calls to GetHeader will print!
sub NewArchiveGetHeader {
  my ($id) = @_;
  print OldArchiveGetHeader(@_);
  my %dates = ();
  for (AllPagesList()) {
    $dates{$1}++ if /^(\d\d\d\d-\d\d)-\d\d/;
  }
  print $q->div({-class=>'archive'},
		$q->p($q->span(T('Archive:')),
		      map {
			my $key = $_;
			my ($year, $month) = split(/-/, $key);
			if (defined(&month_name)) {
			  ScriptLink('action=collect;match=' . UrlEncode("^$year-$month"),
				     month_name($month) . " $year ($dates{$key})");
			} else {
			  ScriptLink('action=index;match=' . UrlEncode("^$year-$month"),
				     "$year-$month ($dates{$key})");
			}
		      } sort { $b <=> $a } keys %dates));
  return '';
}
