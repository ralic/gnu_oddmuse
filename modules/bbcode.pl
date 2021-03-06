# Copyright (C) 2007, 2008, 2013  Alex Schroeder <alex@gnu.org>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

use strict;
use v5.10;

AddModuleDescription('bbcode.pl', 'bbCode Extension');

our ($q, @HtmlStack, @MyRules, %RuleOrder, $UrlProtocols, $FullUrlPattern);
push(@MyRules, \&bbCodeRule);
$RuleOrder{\&bbCodeRule} = 100; # must come after PortraitSupportRule

our ($bbBlock);
my %bbTitle = qw(h1 1 h2 1 h3 1 h4 1 h5 1 h6 1);

# This code does not allow the nesting of block elements such as quote
# and list.

sub bbCodeRule {
  if (/\G(\[([a-z*][a-z1-6]*)(?:=([^]"]+))?\])/cgi) {
    my $bbcode = $1;
    my $tag = lc($2);
    my $option = $3; # sanitize?
    if ($tag eq 'b') {
      return AddHtmlEnvironment('b'); }
    elsif ($tag eq 'i') {
      return AddHtmlEnvironment('i'); }
    elsif ($tag eq 'u') {
      return AddHtmlEnvironment('em', qq{style="text-decoration: underline; }
				. qq{font-style: normal;"}); }
    elsif ($tag eq 's' or $tag eq 'strike') {
      return AddHtmlEnvironment('del'); }
    elsif ($tag eq 'tt') {
      return AddHtmlEnvironment('tt'); }
    elsif ($tag eq 'sub') {
      return AddHtmlEnvironment('sub'); }
    elsif ($tag eq 'sup') {
      return AddHtmlEnvironment('sup'); }
    elsif ($tag eq 'color') {
      return AddHtmlEnvironment('em', qq{style="color: $option; }
				. qq{font-style: normal;"}); }
    elsif ($tag eq 'size') {
      $option *= 100;
      return $bbcode unless $option; # non-numeric?
      return AddHtmlEnvironment('em', qq{style="font-size: $option%; }
				. qq{font-style: normal;"}); }
    elsif ($tag eq 'font') {
      return AddHtmlEnvironment('span', qq{style="font-family: $option;"}); }
    elsif ($tag eq 'highlight') {
      return AddHtmlEnvironment('strong', qq{class="highlight"}); }
    elsif ($tag eq 'url') {
      if ($option) {
	$option =~ /^($UrlProtocols)/;
	my $class = "url $1";
	return AddHtmlEnvironment('a', qq{href="$option" class="$class"}); }
      elsif (/\G$FullUrlPattern\s*\[\/url\]/cgi) {
	return GetUrl($1); }}
    elsif ($tag eq 'img' and /\G$FullUrlPattern\s*\[\/img\]/cgi) {
      return GetUrl($1, undef, undef, 1); } # force image
    elsif ($tag eq 'quote') {
      my $html = CloseHtmlEnvironments();
      $html .= "</$bbBlock>" if $bbBlock;
      $html .= "<blockquote>";
      $bbBlock = 'blockquote';
      return $html . AddHtmlEnvironment('p'); }
    elsif ($tag eq 'center') {
      my $html = CloseHtmlEnvironments();
      $html .= "</$bbBlock>" if $bbBlock;
      $html .= qq{<div class="center" style="text-align: $tag">};
      $bbBlock = 'div';
      return $html . AddHtmlEnvironment('p'); }
    elsif ($tag eq 'left' or $tag eq 'right') {
      my $html = CloseHtmlEnvironments();
      $html .= "</$bbBlock>" if $bbBlock;
      $html .= qq{<div class="$tag" style="float: $tag">};
      $bbBlock = 'div';
      return $html . AddHtmlEnvironment('p'); }
    elsif ($tag eq 'list') {
      my $html = CloseHtmlEnvironments();
      $html .= "</$bbBlock>" if $bbBlock;
      $bbBlock = 'ul';
      return $html . '<ul>'; }
    elsif ($tag eq '*' and $bbBlock eq 'ul') {
      return CloseHtmlEnvironmentUntil('ul') . AddHtmlEnvironment('li'); }
    elsif ($tag eq 'code' and /\G((?:.*\n)*?.*?)\[\/code\]\n?/cgi) {
      return CloseHtmlEnvironments() . $q->pre($1) . AddHtmlEnvironment('p'); }
    elsif ($bbTitle{$tag}) {
      return CloseHtmlEnvironments() . AddHtmlEnvironment($tag); }
    # no opening tag after all
    return $bbcode; }
  # closing tags
  elsif (/\G(\[\/([a-z][a-z1-6]*)\])/cgi) {
    my $bbcode = $1;
    my $tag = lc($2);
    my %translate = qw{b b i i u em color em size em font span url a
		    quote blockquote h1 h1 h2 h2 h3 h3 h4 h4 h5 h5
		    h6 h6 center div left div right div list ul
		    s del strike del sub sub sup sup highlight strong
		    tt tt};
    # closing a block level element closes all elements
    if ($bbBlock eq $translate{$tag}) {
      /\G([ \t]*\n)*/cg; # eat whitespace after closing block level element
      $bbBlock = undef;
      return CloseHtmlEnvironments() . "</$translate{$tag}>"
	. AddHtmlEnvironment('p'); }
    # ordinary elements just close themselves
    elsif (@HtmlStack and $HtmlStack[0] eq $translate{$tag}) {
      my $html = CloseHtmlEnvironment();
      $html .= AddHtmlEnvironment('p') unless @HtmlStack;
      return $html; }
    # no closing tag after all
    else {
      return $bbcode; }}
  # smiley
  elsif (/\G(:-?[()])/cg) {
    if (substr($1,-1) eq ')') {
      # 😊 1F60A SMILING FACE WITH SMILING EYES
      return '&#x1F60A;'; }
    else {
      # 😟 1F61F WORRIED FACE
      return '&#x1F61F;'; }}
  elsif (/\G:(?:smile|happy):/cg) {
    return '&#x1F60A;'; }
  elsif (/\G:(?:sad|frown):/cg) {
    return '&#x1F61F;'; }
  # no match
  return;
}
