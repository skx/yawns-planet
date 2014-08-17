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

    $dbuser = 'yawns';    # Database user to connect with.
    $dbpass = 'yawns';    # Database password to connect with.
    $dbname = 'yawns';    # Database name to connect to.
    $dbserv = '';

    #
    # Number of entries to generate. (HTML + feeds).
    #
    $count = 30;


    #
    # Does our version of Yawns support weblog comments?
    #
    # 1 for Steve's fork.
    # 0 for Denny's original code.
    #
    $has_comments = 1;

    #
    # The directory to load the HTML::Template files from.
    $template_dir = "templates/";


    #
    #
    # The output location for the HTML page.
    #
    $htmlOutput = "htdocs/index.html";


    #
    # The output location for the RSS v1.0
    #
    $rss1Output = "htdocs/rss10.xml";


    #
    # The output location for the RSS v2.0 feed.
    #
    $rss2Output = "htdocs/rss20.xml";


    #
    # Title of the HTML output page.
    #
    $title = 'Planet Debian Administration';

    #
    # Link to planet homepage
    #
    $link = 'http://planet.debian-administration.org/';


    #
    # Link to place in front of /tag/foo
    #
    $tag_prefix = 'http://www.debian-administration.org/tag/';

    #
    # User prefix
    #
    $user_prefix = 'http://www.debian-administration.org/users/';

    #
    # Link shown in the header of the planet.
    #
    $title_link =
      'Planet <a href="http://www.debian-administration.org/">Debian Administration</a>';


    #
    # return the requested config variable
    #
    return ($$requested);
}


# ===== ( EOF ) =====
1;
