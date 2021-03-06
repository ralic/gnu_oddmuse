# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
#               2004  Tilmann Holst <spam@tholst.de>
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

AddModuleDescription('translations.pl', 'Translation Extension');

our (@MyRules, $FreeLinkPattern);

push(@MyRules, \&TranslationRule);

sub TranslationRule {
  if (m/\G(\&lt;translation +\[\[$FreeLinkPattern\]\] +(\d+)\&gt;[ \t]*)/cg) {
    Dirty($1);
    print GetTranslationLink($2, $3);
    return '';
  }
  return;
}

sub GetCurrentPageRevision {
  my $id   = shift;
  return ParseData(ReadFileOrDie(GetPageFile($id)))->{revision};
}

sub GetTranslationLink {
  my ($id, $revision) = @_;
  my $result = "";
  my $currentRevision;
  $id =~ s/^\s+//;		# Trim extra spaces
  $id =~ s/\s+$//;
  $id     = FreeToNormal($id);
  $result = Ts('This page is a translation of %s.', GetPageOrEditLink( $id, '', 0, 1));
  $result .= ' ';
  $currentRevision = GetCurrentPageRevision($id);
  if ($currentRevision == $revision) {
    $result .= T("The translation is up to date.");
  } elsif ( $currentRevision > $revision ) {
    $result .= T("The translation is outdated.") . ' '
      . ScriptLink("action=browse&diff=1&id=$id&revision=$currentRevision&diffrevision=$revision",
		   T("(diff)"));
  } else {
    $result .= T("The page does not exist.");
  }
  return $result;
}
