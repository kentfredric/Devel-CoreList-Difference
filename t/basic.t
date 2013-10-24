
use strict;
use warnings;

use Test::More;

use Devel::CoreList::Difference;
my $cl = Devel::CoreList::Difference->new();
$cl->diff_map;

pass();
done_testing;
1;
