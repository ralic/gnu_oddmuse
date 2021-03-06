# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
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

AddModuleDescription('no-question-mark.pl', 'No Questionmarks Extension');

our ($q, $OpenPageName, $ScriptName, %IndexHash, $FootnoteNumber, $UsePathInfo);

sub GetPageOrEditLink {
  my ($id, $text, $bracket, $free) = @_;
  $id = FreeToNormal($id);
  my ($class, $resolved, $title, $exists) = ResolveId($id);
  if (!$text && $resolved && $bracket) {
    $text = BracketLink(++$FootnoteNumber); # s/_/ /g happens further down!
    $class .= ' number';
    $title = $id; # override title
    $title =~ s/_/ /g if $free;
  }
  $text = "[$id]" if not $text and $bracket; # if the page exists with brackets and no text see above
  $text = $id if not $text;
  $text =~ s/_/ /g;
  if ($resolved) { # anchors don't exist as pages, therefore do not use $exists
    return ScriptLink(UrlEncode($resolved), $text, $class, undef, $title);
  } else {
    return GetEditLink($id, $text);
  }
}

sub GetDownloadLink {
  my ($name, $image, $revision, $alt) = @_;
  $alt = $name unless $alt;
  $alt =~ s/_/ /g;
  my $id = FreeToNormal($name);
  # if the page does not exist
  return GetEditLink($id, ($image ? T('image') : T('download')) . ':' . $name, 1)
    unless $IndexHash{$id};
  my $action;
  if ($revision) {
    $action = "action=download;id=" . UrlEncode($id) . ";revision=$revision";
  } elsif ($UsePathInfo) {
    $action = "download/" . UrlEncode($id);
  } else {
    $action = "action=download;id=" . UrlEncode($id);
  }
  if ($image) {
    if ($UsePathInfo and not $revision) {
      $action = $ScriptName . '/' . $action;
    } else {
      $action = $ScriptName . '?' . $action;
    }
    my $result = $q->img({-src=>$action, -alt=>$alt, -class=>'upload'});
    $result = ScriptLink(UrlEncode($id), $result, 'image') unless $id eq $OpenPageName;
    return $result;
  } else {
    return ScriptLink($action, $alt, 'upload');
  }
}
