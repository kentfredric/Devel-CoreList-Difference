
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.4007"
  },
  "configure_requires" => {
    "Module::Build" => "0.4007"
  },
  "dist_abstract" => "Report how the *current* Perl differs from corelist",
  "dist_author" => [
    "Kent Fredric <kentfredric\@gmail.com>"
  ],
  "dist_name" => "Devel-CoreList-Difference",
  "dist_version" => "0.001000",
  "license" => "perl",
  "module_name" => "Devel::CoreList::Difference",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Class::Tiny" => 0,
    "Module::CoreList" => 0,
    "Module::Metadata" => 0,
    "Module::Runtime" => 0,
    "Path::Tiny" => 0,
    "perl" => "5.006",
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => [],
  "test_requires" => {
    "Capture::Tiny" => 0,
    "Data::Dump" => 0,
    "Test::More" => "0.99",
    "blib" => 0,
    "version" => 0
  }
);


my %fallback_build_requires = (
  "Capture::Tiny" => 0,
  "Data::Dump" => 0,
  "Module::Build" => "0.4007",
  "Test::More" => "0.99",
  "blib" => 0,
  "version" => 0
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  delete $module_build_args{test_requires};
  $module_build_args{build_requires} = \%fallback_build_requires;
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
