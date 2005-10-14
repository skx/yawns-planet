#!/usr/bin/perl -w -I.

# ===========================================================================
# File:		YawnsBlog.pm
# Purpose:	Utility functions working with the Yawns weblogs database table
# Created:	2005-10-12
#
# ===========================================================================
# (c) 2005 Steve Kemp <steve@steve.org.uk>
# This program is free software; you can redistribute it and/or modify
# it under the terms of version 2 of the GNU General Public License as
# published by the Free Software Foundation.  See the file COPYING for
# further details.
# ===========================================================================
#
# $Id: YawnsBlog.pm,v 1.6 2005-10-14 18:22:38 steve Exp $


#
#  Make this a 'real module'.
#
package YawnsBlog;
require Exporter;
@ISA    = qw ( Exporter );
@EXPORT = qw ( Entries Posters SearchEntries );


#
# Modules we use
#
use HTML::Entities;

#
# Custom modules
#
use conf::SiteConfig;
use Singleton::DBI;


#
#  Return the most recent weblog entries the database.
#
#
sub Entries
{
    my ( $count ) = ( @_ );

    #
    #  Connect to the database.
    #
    my $dbh = Singleton::DBI->instance();

    #
    # Do we support comments
    #
    my $has_comments = get_conf( "has_comments" );

    #
    # Execute the query
    #
    my $sql;
    if ( $has_comments )
    {
	$sql = $dbh->prepare( 'SELECT id, username, title, bodytext,  date_format( ondate, "%D %M %Y" ), TIME( ondate ),comments FROM weblogs ORDER BY ondate DESC LIMIT 0,' . $count );
    }
    else
    {
	$sql = $dbh->prepare( 'SELECT id, username, title, bodytext,  date_format( ondate, "%D %M %Y" ), TIME( ondate ) FROM weblogs ORDER BY ondate DESC LIMIT 0,' . $count );
    }
    $sql->execute( );


    my $dataref = $sql->fetchall_arrayref;
    my $len = @$dataref;

    my $weblogs  = [];
    my $prevDate = '';

    for ( my $l = 0; $l < $len; $l++ )
    {
	my $entry = @$dataref[$l];
	my @entry = @$entry;


	#
	# Defaults.
	#
	my $comments          = "";
	my $plural            = 1;
	my $comments_disabled = 0;
	my $no_comments       = 0;

	#
	#  If the webblog table has comments then use them to setup
	# the links.
	#
	if ( $has_comments )
	{
	    $comments = $entry[6];

	    #
	    # 0 comments
	    # 1 comment
	    # 2 comments
	    # ..
	    if ( $comments eq 1 )
	    {
		$plural = 0;
	    }

	    #
	    # Check for comments being disabled
	    #
	    if ( $comments <  0 )
	    {
		$comments_disabled = 1;
	    }

	    #
	    # Show different text if there are no comments.
	    #
	    if ( $comments ==  0 )
	    {
		$no_comments = 1;
	    }
	}


	#
	# Check for new date
	#
	my $new_date = 0;
	my $date     = $entry[4];
	my $time     = $entry[5];
	if ( $date ne $prevDate )
	{
	    $new_date = 1;
	}
	$prevDate = $date;

	push ( @$weblogs,
	       {
		   id           => $entry[0],
		   user         => $entry[1],
		   title        => $entry[2],
		   body         => $entry[3],
		   date         => $date,
		   time         => $time,
		   comments     => $comments,
	           has_comments => $has_comments,
		   no_comments  => $no_comments,
		   disabled     => $comments_disabled,
		   plural       => $plural,
		   new_date     => $new_date,
	       } );
    }

    return( $weblogs );
}



#
#  Return the list of subscribed users - we prefer to use their
# real names, but if they are not available fall back to returning
# only their account names.
#
sub Posters
{
    #
    # Connect to the database.
    #
    my ( $dbh ) = Singleton::DBI->instance();

    #
    # Find the posters.
    #
    my $query = "SELECT DISTINCT a.realname,a.username FROM users AS a INNER JOIN weblogs AS b ON a.username = b.username";

    my $sql = $dbh->prepare( $query );
    $sql->execute();

    #
    # Get all the results.
    #
    my $dataref  = $sql->fetchall_arrayref();
    my @datalist = @$dataref;
    $sql->finish();

    # Data from the query
    my $user = ();
    my $subscriptions = [];

    foreach my $data ( @datalist )
    {
	my @user = @$data;

	#
	#  Find the data.
	#
	my $real_name = $user[0];
	my $user_name = $user[1];

	#
	# If the use has no real name set then use their account name.
	#
	if (! $real_name )
	{
	    $real_name = $user_name ;
	}

	$real_name = encode_entities( $real_name );
	push ( @$subscriptions,
	       {
		   account => $user_name,
		   fullname => $real_name
		   });

    }


    #
    # Sort the subscriptions appropriately.
    #
    @$subscriptions = sort sortByName @$subscriptions;

    return( $subscriptions );
}



#
# Sort a list of subscriptions by their username, case-insensitive.
#
sub sortByName()
{
    return( lc($::a->{'fullname'}) cmp lc($::b->{'fullname'}) );
}



#
#  Perform a search against blog entries.  Optionally ignore the
# comment field in the database - it might not be present.
#
sub SearchEntries
{
    my ( $terms ) = ( @_ );

    #
    # Connect to the database.
    #
    my ( $dbh ) = Singleton::DBI->instance();

    #
    # Split up all terms.
    #
    my @terms = split( /[ \t]/, $terms );


    #
    # Do we support comments
    #
    my $has_comments = get_conf( "has_comments" );

    #
    # Query string we execute.
    #
    my $querystr;

    #
    # Build the string up.
    #
    if ( $has_comments )
    {
	$querystr = 'SELECT id,username,title, date_format( ondate, "%D %M %Y" ),time(ondate),bodytext,comments FROM weblogs WHERE ';
    }
    else
    {
	$querystr = 'SELECT id,username,title, date_format( ondate, "%D %M %Y" ),time(ondate),bodytext FROM weblogs WHERE ';
    }

    my $count    = 0;
    my $prevDate = '';


    foreach my $term ( @terms )
    {
	if ( $count )
	{
	    $querystr .= " AND";
	}

	$querystr .= " bodytext LIKE " . $dbh->quote( "%" . $term . "%" );
	$count += 1;
    }

    #
    # Make sure the results are Newest > Oldest
    #
    $querystr .= " ORDER BY ondate DESC";

    my $query = $dbh->prepare( $querystr );
    $query->execute( ) or print $dbh->errstr();

    my $result_ref  = $query->fetchall_arrayref();
    my @results     = @$result_ref;
    my $resultsloop = [];
    my $rcount      = 0;

    foreach ( @results )
    {
	my @result = @$_;

	# Increase result count.
	$rcount ++;

	#
	# Defaults.
	#
	my $comments          = "";
	my $plural            = 1;
	my $comments_disabled = 0;
	my $no_comments       = 0;

	#
	#  If the webblog table has comments then use them to setup
	# the links.
	#
	if ( $has_comments )
	{
	    $comments = $result[6];

	    #
	    # Should there be a "s" shown on the end of "N comment" ?
	    #   0 comments
	    #   1 comment
	    #   2 comments
	    #
	    if ( $comments eq 1 )
	    {
		$plural = 0;
	    }

	    #
	    # Check for comments being disabled
	    #
	    if ( $comments <  0 )
	    {
		$comments_disabled = 1;
	    }

	    #
	    # Show different text if there are no comments.
	    #
	    if ( $comments ==  0 )
	    {
		$no_comments = 1;
	    }
	}

	#
	# Check for new date
	#
	my $new_date = 0;
	my $date     = $result[3];
	if ( $date ne $prevDate )
	{
	    $new_date = 1;
	}
	$prevDate = $date;

	push ( @$resultsloop, {
			       id          => $result[0],
			       user        => $result[1],
			       title       => $result[2],
			       date        => $result[3],
			       time        => $result[4],
			       body        => $result[5],
			       comments    => $comments,
			       has_comments => $has_comments,
			       no_comments => $no_comments,
			       disabled    => $comments_disabled,
			       plural      => $plural,
			       new_date    => $new_date
				  } );
    }

    return ( $rcount, $resultsloop );
}



#
# End of module
#
1;
