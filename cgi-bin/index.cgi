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
# $Id: index.cgi,v 1.4 2005-10-13 11:25:42 steve Exp $

# Enforce good programming practices
use strict;

# Modules we use.
use CGI;
use HTML::Entities;
use HTML::Template;

# Custom modules
use conf::SiteConfig;
use Singleton::DBI;


#
# Read-only variables: version number from CVS.
#
my $REVISION  = '$Id: index.cgi,v 1.4 2005-10-13 11:25:42 steve Exp $';
my $VERSION   = "";
$VERSION      = join (' ', (split (' ', $REVISION))[2..2]);
$VERSION      =~ s/yp,v\b//;



#
# 0. Print CGI header.
#
print "Content-type: text/html\n\n";

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
my $count;

if ( defined( $terms ) && length( $terms ) )
{
   ( $count, $results ) = performSearch( $terms );
}

#
# 4. Show results / error
#
showResults( $count, $results );


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

    my $querystr = 'SELECT id,username,title, date_format( ondate, "%D %M %Y" ),time(ondate),bodytext,comments FROM weblogs WHERE ';

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

    my $result_ref  = $query->fetchall_arrayref();
    my @results     = @$result_ref;
    my $resultsloop = [];
    my $rcount      = 0;

    foreach ( @results )
    {
	my @result = @$_;

	$rcount ++;


	#
	# 0 comments
	# 1 comment
	# 2 comments 
	# ..
	my $comments = $result[6];
	my $plural = 1;
	if ( $comments eq 1 )
	{
	   $plural = 0;
	}

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

	push ( @$resultsloop, {
			       id          => $result[0],
			       user        => $result[1],
			       title       => $result[2],
			       date        => $result[3],
			       time        => $result[4],
			       body        => $result[5],
			       comments    => $comments,
			       no_comments => $no_comments,
			       disabled    => $comments_disabled,
			       plural      => $plural,
				  }
	       );
    }

    return ( $rcount, $resultsloop );
}


sub showResults
{
    my ( $count, $results ) = ( @_ );

    #
    # Load the template.
    #
    my $template = HTML::Template->new( filename => "../templates/results.tmpl" );

    $template->param( 'title',      get_conf( 'title' ) );
    $template->param( 'title_link', get_conf( 'title_link' ) );
    $template->param( 'terms',      encode_entities( $cgi->param( "terms" ) ) );
    $template->param( 'version' ,   $VERSION );
    $template->param( 'subscriptions', getSubscriptions( ) );

    if ( ! $results )
    {
	$template->param( 'error', 1 );
    }
    else
    {
	my $empty = undef;
	if ( $count == 0 ) { $empty = 1; }

	$template->param( 'no_results', $empty );
	$template->param( 'results', $results );
    }

    print $template->output();
}


#
#  Return the list of subscribed users.
#
sub getSubscriptions
{
    my ($dbh ) = Singleton::DBI->instance();

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

