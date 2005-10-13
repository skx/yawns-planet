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
# $Id: index.cgi,v 1.10 2005-10-13 15:35:59 steve Exp $

# Enforce good programming practices
use strict;

# Modules we use.
use CGI;
use HTML::Entities;
use HTML::Template;

# Custom modules
use conf::SiteConfig;
use YawnsBlog;
use Singleton::DBI;


#
# Read-only variables: version number from CVS.
#
my $REVISION  = '$Id: index.cgi,v 1.10 2005-10-13 15:35:59 steve Exp $';
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

#
# Only perform a search if we were given terms.
#
$terms = "Steve";
if ( defined( $terms ) && length( $terms ) )
{
   ( $count, $results ) = YawnsBlog::SearchEntries( $terms );
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
#  Show the matching results, if any, to the client
#
#  If there were no results then we will show that too.
#
#
sub showResults
{
    my ( $count, $results ) = ( @_ );

    #
    # Find the template input directory.
    #
    my $TEMPLATE = get_conf( "template_dir" );

    #
    # If it starts with a leading "/" then it is an absolute path.
    # otherwise it is realitive to the "yawns-planet" directory so
    # needs to be modified.
    #
    if ( $TEMPLATE =~ /^\/(.*)/ )
    {
	# Ignore the template directory it is fine.
    }
    else
    {
	$TEMPLATE = "../" . $TEMPLATE;
    }


    #
    # Load the template
    #
    my $template = HTML::Template->new( filename => $TEMPLATE . "results.tmpl" );

    #
    # Fill in the parameters.
    #
    $template->param( 'title',      get_conf( 'title' ) );
    $template->param( 'title_link', get_conf( 'title_link' ) );
    $template->param( 'terms',      encode_entities( $cgi->param( "terms" ) ) );
    $template->param( 'version' ,   $VERSION );
    $template->param( 'subscriptions', YawnsBlog::Posters() );


    if ( ! $results )
    {
	#
	# No results is an error so show that.
	#
	$template->param( 'error', 1 );
    }
    else
    {
	#
	# Show the results, and setup 'no_results' if no matching
	# blogs were found.
	#
	my $empty = undef;
	if ( $count == 0 ) { $empty = 1; }

	$template->param( 'no_results', $empty );
	$template->param( 'results', $results );
    }

    print $template->output();
}
