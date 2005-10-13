#!/usr/bin/perl -I..
#
#  Test that all Yawns-Planet configuration file contains sane settings.
#

use Test::More qw( no_plan );


BEGIN { use_ok( 'conf::SiteConfig' ); }
require_ok( 'conf::SiteConfig' );

#
#  Count is the number of entries to show upon a page.
# Should obviously be set to a number.
#
my $count = conf::SiteConfig::get_conf( "count" );
ok( defined( $count ), "Count is setup" );
ok( $count =~ /([0-9]+)/, "Count is a number" );
