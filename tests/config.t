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


#
#  Test that the output HTML file value is sensible.
#
my $HTMLOutput = conf::SiteConfig::get_conf( "htmlOutput" );
ok( defined( $HTMLOutput ), "HTML Output is setup" );

#
# If it exists then make sure it is writable.
# (Modify it to be as seen from the main directory.)
#
if ( -e "../" . $HTMLOutput )
{
   my $writable = ( -w "../" . $HTMLOutput );
   ok( ( $writable > 0 ), "HTML Output exists but is writable" );
}



#
#  Test that the output RSS v1.0 file value is sensible.
#
my $RSS1Output = conf::SiteConfig::get_conf( "rss1Output" );
ok( defined( $RSS1Output ), "RSS v1.0 Output is setup" );

#
# If it exists then make sure it is writable.
#
# (Modify it to be as seen from the main directory.)
#
if ( -e "../" . $RSS1Output )
{
   my $writable = ( -w "../" . $RSS1Output );
   ok( ( $writable > 0 ), "RSS v1.0 Output exists but is writable" );
}



#
#  Test that the output RSS v2.0 file value is sensible.
#
my $RSS2Output = conf::SiteConfig::get_conf( "rss2Output" );
ok( defined( $RSS2Output ), "RSS v2.0 Output is setup" );

#
# If it exists then make sure it is writable.
#
# (Modify it to be as seen from the main directory.)
#
if ( -e "../" . $RSS2Output )
{
   my $writable = ( -w "../" . $RSS2Output );
   ok( ( $writable > 0 ), "RSS v2.0 Output exists but is writable" );
}




#
#  Test that the output HTML file value is sensible.
#
my $TEMPLATE = conf::SiteConfig::get_conf( "template_dir" );
ok( defined( $TEMPLATE ), "Template input directory is setup" );

if ( $TEMPLATE =~ /^\/(.*)/ )
{
    # Absolute path.
    ok( -d $TEMPLATE, "Template directory exists" );
}
else
{
    # Relative path.
    $TEMPLATE = "../" . $TEMPLATE;
    # Modify it to be as seen from the main directory.
    ok( -d $TEMPLATE, "Template directory exists" );
}


#
#  Test that all the expected template files exist.
#
ok( -e $TEMPLATE . "index.tmpl",   "index.tmpl exists" );
ok( -e $TEMPLATE . "rss10.tmpl",   "rss10.tmpl exists" );
ok( -e $TEMPLATE . "rss20.tmpl",   "rss20.tmpl exists" );
ok( -e $TEMPLATE . "results.tmpl", "results.tmpl exists" );
