#!/usr/bin/perl -w

#
#  Make this a 'real module'.
#
package conf::SiteConfig;
require Exporter;
@ISA    = qw ( Exporter );
@EXPORT = qw ( get_conf );


# =============================================================================
# Site specific config data
# =============================================================================
sub get_conf 
{
    my $requested = $_[0];

    $dbuser = 'yawns';	# Database user to connect with.
    $dbpass = 'yawns';  # Database password to connect with.
    $dbname = 'yawns';	# Database name to connect to.
    $dbserv = '';

    #
    # Number of entries to generate. (HTML + feeds).
    #
    $count	= 30;

    #
    # The directory to load the HTML::Template files from.
    $template_dir = "templates/";


    #
    #
    # The output location for the HTML page.
    #
    $htmlOutput = "html/index.html";


    #
    # The output location for the RSS v1.0
    #
    $rss1Output = "html/rss10.xml";


    #
    # The output location for the RSS v2.0 feed.
    #
    $rss2Output = "html/rss20.xml";


    #
    # Title of the HTML output page.
    #
    $title  = 'Planet Debian Administration';

    #
    # Link shown in the header of the planet.
    #
    $title_link = 'Planet <a href="http://www.debian-administration.org/">Debian Administration</a>';


    #
    # return the requested config variable
    #
    return ( $$requested );
}


# ===== ( EOF ) =====
1;
