# Copyright (C) 2006  Alex Schroeder <alex@emacswiki.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
#    Free Software Foundation, Inc.
#    59 Temple Place, Suite 330
#    Boston, MA 02111-1307 USA,

$ModulesDescription .= '<p>$Id: dojo.pl,v 1.3 2006/09/14 00:05:21 as Exp $</p>';

use vars qw(@DojoGroups);

@DojoGroups = qw(textGroup blockGroup justifyGroup colorGroup
		 listGroup indentGroup linkGroup);

push (@MyRules, \&WysiwygRule);

sub WysiwygRule {
  if (m/\G(&lt;.*?&gt;)/gc) {
    return $1 if substr($1,5,6) eq 'script'
      or substr($1,4,6) eq 'script';
    return UnquoteHtml($1);
  }
  return undef;
}

push (@MyInitVariables, \&WysiwygScript);

sub WysiwygScript {
  # cookie is not initialized yet so we cannot use GetParam
  if ($q->param('action') eq 'edit') {
    $HtmlHeaders .= '<script src="/dojo/dojo.js" type="text/javascript"></script>'
  }
}

*OldWysiwygGetTextArea = *GetTextArea;
*GetTextArea = *NewWysiwygGetTextArea;

sub NewWysiwygGetTextArea {
  my ($name, $text, $rows) = @_;
  if ($name =~ /text/) {
    return $q->textarea(-id=>$name, -name=>$name, -default=>$text,
			-rows=>$rows||25, -columns=>78, -override=>1,
			-dojoType=>'Editor',
		        -items=>join(';|;', @DojoGroups));
  } else {
    return OldWysiwygGetTextArea(@_);
  }
}

*OldWysiwygImproveDiff = *ImproveDiff;
*ImproveDiff = *NewWysiwygImproveDiff;

sub NewWysiwygImproveDiff {
  my $old = OldWysiwygImproveDiff(@_);
  my $new = '';
  my $protected = 0;
  # fix diff inserting change boundaries inside tags
  $old =~ s!&<strong class="changes">([a-z]+);!</strong>&$1;!g;
  $old =~ s!&</strong>([a-z]+);!</strong>&$1;!g;
  # unquote named html entities
  $old =~ s/\&amp;([a-z]+);/&$1;/g;
  foreach my $str (split(/(<strong class="changes">|<\/strong>)/, $old)) {
    # Don't remove HTML tags affected by changes.
    $protected = 1 if $str eq '<strong class="changes">';
    # strip html tags and don't get confused with the < and > created
    # by diff!
    $str =~ s/\&lt;.*?\&gt;//g unless $protected;
    $protected = 0 if $str eq '</strong>';
    $new .= $str;
  }
  return $new;
}