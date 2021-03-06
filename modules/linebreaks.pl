# Copyright (C) 2004  Alex Schroeder <alex@emacswiki.org>
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

AddModuleDescription('linebreaks.pl', 'Paragraph Break Alternative');

our ($q, @MyRules);
push(@MyRules, \&LineBreakRule);

sub LineBreakRule {
  if (m/\G\s*\n(\s*\n)+/cg) { # paragraphs: at least two newlines
    return CloseHtmlEnvironments() . AddHtmlEnvironment('p');
  } elsif (m/\G\s*\n/cg) { # line break: one newline
    return $q->br();
  }
  return;
}
