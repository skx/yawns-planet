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
