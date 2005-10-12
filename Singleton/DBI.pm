# -*- cperl -*- #

#
#  Singleton Wrapper around DBI
#
# Steve
# --
# www.steve.org.uk
#
# $Id: DBI.pm,v 1.1 2005-10-12 11:58:21 steve Exp $
#


package Singleton::DBI;

#
#  Get access to the database connection code.
#
use conf::SiteConfig;

#
#  The DBI modules for accessing the database.
#
use DBI qw/ :sql_types / ;




#
#  The single, global, instance of this object
#
my $_dbh = undef;


#
#  Gain access to the instance
#
sub instance
{
    $_dbh ||= (shift)->new();

    return( $_dbh );
}

sub new
{
    #
    # get necessary config info
    #
    my $dbuser = conf::SiteConfig::get_conf ( 'dbuser' );
    my $dbpass = conf::SiteConfig::get_conf ( 'dbpass' );
    my $dbname = conf::SiteConfig::get_conf ( 'dbname' );
    my $dbserv = conf::SiteConfig::get_conf ( 'dbserv' );

    # Build up DBI connection string.
    my $datasource = 'dbi:mysql:'.$dbname;
    $datasource .= "\;host=$dbserv" if ( $dbserv );

    my $t =  DBI->connect_cached( $datasource, $dbuser, $dbpass )
	or die DBI->errstr();

    return( $t );
}


1;
