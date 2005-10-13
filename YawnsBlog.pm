#!/usr/bin/perl -w -I.

# ===========================================================================
# File:		Blog.pm
# Purpose:	Blog utility functions for a Yawns powered site.
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
# $Id: YawnsBlog.pm,v 1.1 2005-10-13 15:09:15 steve Exp $


#
#  Make this a 'real module'.
#
package YawnsBlog;
require Exporter;
@ISA    = qw ( Exporter );
@EXPORT = qw ( Entries Posters );


#
# Modules we use
#
use HTML::Entities;

#
# Custom modules
#
use Singleton::DBI;


#
#  Return the relevent weblog entries from the database
#
sub Entries
{
    my ( $count ) = ( @_ );

    #
    #  Connect to the database.
    #
    my $dbh = Singleton::DBI->instance();

    #
    # Execute the query
    #
    my $sql = $dbh->prepare( 'SELECT id, username, title, bodytext,  date_format( ondate, "%D %M %Y" ), TIME( ondate ),comments FROM weblogs ORDER BY ondate DESC LIMIT 0,' . $count );
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
	# 0 comments
	# 1 comment
	# 2 comments
	# ..
	my $comments = $entry[6];
	my $plural = 1;
	if ( $comments eq 1 )
	{
	   $plural = 0;
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


	#
	# Check for comments being disabled
	#
	my $comments_disabled = 0;
	if ( $comments <  0 )
	{
	    $comments_disabled = 1;
	}

	#
	# Show different text if there are no comments.
	#
	my $no_comments = 0;
	if ( $comments ==  0 )
	{
	    $no_comments = 1;
	}

	push ( @$weblogs,
	       {
		   id          => $entry[0],
		   user        => $entry[1],
		   title       => $entry[2],
		   body        => $entry[3],
		   date        => $date,
		   time        => $time,
		   comments    => $comments,
		   no_comments => $no_comments,
		   disabled    => $comments_disabled,
		   plural      => $plural,
		   new_date    => $new_date,
	       } );
    }

    return( $weblogs );
}



#
#  Return the list of subscribed users.
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
# End of module
#
1;
