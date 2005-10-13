#!/usr/bin/perl -w -I..

# ===========================================================================
# File:		index.cgi
# Purpose:	Search previous blog entries posted to a Yawns weblog entry.
# Created:	2005-10-13
#
# ===========================================================================
# (c) 2005 Steve Kemp <steve@steve.org.uk>
# This program is free software; you can redistribute it and/or modify 
# it under the terms of version 2 of the GNU General Public License as 
# published by the Free Software Foundation.  See the file COPYING for 
# further details.
# ===========================================================================
#
# $Id: index.cgi,v 1.1 2005-10-13 11:04:43 steve Exp $

# Enforce good programming practices
use strict;

# Modules we use.
use CGI;
use HTML::Template;

# Custom modules
use conf::SiteConfig;
use Singleton::DBI;



#
# 1. Connect to database.
#
my $dbh = Singleton::DBI->instance();

#
# 2. Get search terms.
#
my $cgi   = new CGI;
my $terms = $cgi->param( "terms" );

#
# 3. Find matching entries.
#
my $results;

if ( defined( $terms ) && length( $terms ) )
{
    $results = performSearch( $terms );
}

#
# 4. Show results / error
#
showResults( $results );


#
# 5. Disconnect from database.
#
$dbh->disconnect();

exit;


#
#  Perform a search of weblog entries, by all given terms.
#
sub performSearch
{
    my ( $terms ) = ( @_ );

    my @terms = split( /[ \t]/, $terms );

    my $querystr = "SELECT id,author,title,ondate,bodytext FROM weblogs WHERE ";

    my $count = 0;

    foreach my $term ( @terms )
    {
	if ( $count )
	{
	    $querystr .= " AND";
	}

	$querystr .= " bodytext LIKE " . $dbh->quote( "%" . $term . "%" );
	$count += 1;
    }


    my $query = $dbh->prepare( $querystr );
    $query->execute( ) or print $dbh->errstr();

    my $result_ref = $query->fetchall_arrayref();
    my @results = @$result_ref;
    my $resultsloop = [];
    foreach ( @results ) 
    {
	my @result = @$_;
	my ( $str_date ) = convert_date_to_site( $result[4] );
	push ( @$resultsloop, {
	                          id    => $result[0],
	                          user  => $result[1],
				  title => $result[2],
				  body  => $result[3],
				  date  => $result[4],
				  }
	       );
    }

    return ( $resultsloop );

}


sub showResults
{
    my ( $results ) = ( @_ );

    #
    # Load the template.
    #
    my $template = HTML::Template->new( filename => "../templates/results.tmpl" );

    $template->param( 'title',      get_conf( 'title' ) );
    $template->param( 'title_link', get_conf( 'title_link' ) );

    if ( ! $results )
    {
	$template->param( 'error', 1 );
    }
    else
    {
	$template->param( 'results', $results );
    }

    print $template->output();
}
