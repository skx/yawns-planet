#!/usr/bin/perl -w


# stuff to export get_conf function properly
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

    $dbuser = 'yawns';	
    $dbpass = 'yawns';  
    $dbname = 'yawns';	
    $dbserv = '';	
    
    $count	= 30;
    
    # return the requested config variable
    return ( $$requested );
}


# ===== ( EOF ) =====
1;
