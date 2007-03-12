
=head1 NAME

YawnsBlog - A module for working with blog entries on a Yawns Site.

=head1 SYNOPSIS

=for example begin

    #!/usr/bin/perl -w

    use strict;
    use YawnsBlog;

    # Get all tags used upon this site.
    my $holder   = Yawns::Tags->new();
    my $all_tags = $holder->getAllTags();

=for example end


=head1 DESCRIPTION

This module contains some code for working with Yawns Blog Entries,
the code is unique to the Yawns Planet, unlike the code which is
contains in the Yawns project itself.

=cut


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
use HTML::Cleanup;



=begin doc

  Return the most recent weblog entries from the database.

=end doc

=cut

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
    #  Get the prefix
    #
    my $user_prefix = get_conf( "user_prefix" );

    #
    # Execute the query
    #
    my $sql;
    if ( $has_comments )
    {
	$sql = $dbh->prepare( 'SELECT id, username, title, bodytext,  date_format( ondate, "%D %M %Y" ), TIME( ondate ),comments FROM weblogs WHERE bodytext != "" AND title != "" AND score>0 ORDER BY ondate DESC LIMIT 0,' . $count );
    }
    else
    {
	$sql = $dbh->prepare( 'SELECT id, username, title, bodytext,  date_format( ondate, "%D %M %Y" ), TIME( ondate ) FROM weblogs  WHERE bodytext != "" AND title != "" AND score>0 ORDER BY ondate DESC LIMIT 0,' . $count );
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

	my $body = $entry[3];

	#
	#  Handle the cut ..
	#
	my $cut      = 0;
        my $cut_text = "";
	if ( ( $body =~ /(.*)<cut([^>]*)>(.*)/gis ) ||
             ( $body =~ /(.*)&lt;cut([a-zA-Z0-9 \t'"]*)&gt;(.*)/gis ) )
	{
	    $body = $1;
	    $cut  = 1;

            #
            #  See if they supplied text="xxxxx"
            #
            my $text = $2;
            if ( defined( $text ) && ( $text =~ /text=['"]([^'"]+)['"]/i ) )
            {
                $cut_text = $1;
            }
	}

	$body = HTML::Cleanup::sanitize( $body );
	$body = HTML::Cleanup::balance($body);

	if ( $cut )
	{
            my $host = 'http://debian-administration.org';

            #
            # User specified truncation text.
            #
            if ( length( $cut_text ) )
            {
                $body .= "<p><b>(</b><a href=\"$host/users/$entry[1]/weblog/$entry[0]\" title=\"This entry has been truncated; click to read more.\">$cut_text</a><b>)</b></p>";
            }
            else
            {
                $body .= "<p>This entry has been truncated <a href=\"$host/users/$entry[1]/weblog/$entry[0]\">read the full entry</a>.</p>";
            }
	}

        my $tags = getTags( $entry[1], $entry[0] );

        if ( $tags )
        {
            push ( @$weblogs,
	       {
		   id           => $entry[0],
		   user         => $entry[1],
		   title        => $entry[2],
		   body         => $body,
		   date         => $date,
		   time         => $time,
		   comments     => $comments,
	           has_comments => $has_comments,
		   no_comments  => $no_comments,
		   disabled     => $comments_disabled,
		   plural       => $plural,
		   new_date     => $new_date,
                   tags         => $tags,
                   user_prefix  => $user_prefix,
	       } );
        }
        else
        {
            push ( @$weblogs,
	       {
		   id           => $entry[0],
		   user         => $entry[1],
		   title        => $entry[2],
		   body         => $body,
		   date         => $date,
		   time         => $time,
		   comments     => $comments,
	           has_comments => $has_comments,
		   no_comments  => $no_comments,
		   disabled     => $comments_disabled,
		   plural       => $plural,
		   new_date     => $new_date,
                   user_prefix  => $user_prefix,
	       } );

        }
    }

    return( $weblogs );
}



=begin doc

  Find the tags upon a particular entry.

=end doc

=cut

sub getTags
{
    my( $user, $id ) =  (@_);

    #
    # Get the database handle.
    #
    my $dbh    = Singleton::DBI->instance();

    #
    #  Find the weblog GID.
    #
    my $query = $dbh->prepare( 'SELECT gid FROM weblogs WHERE id=? AND username=?' );
    $query->execute( $id, $user ) or die "Failed to run query " . $db->errstr();
    my $gid = $query->fetchrow_array();
    $query->finish();

    #
    # Tag prefix.
    #
    my $tag_prefix   = get_conf( "tag_prefix" );


    #
    #  Tags we'll find
    #
    my $tags;


    #
    # Find the posters.
    #
    my $sql    = $dbh->prepare( "SELECT DISTINCT(tag) FROM tags WHERE root=? AND TYPE=? ORDER BY tag " );
    $sql->execute( $gid, 'w' );
    #
    # Bind the columns.
    #
    my ( $tag );
    $sql->bind_columns( undef, \$tag );

    while( $sql->fetch() )
    {
	push ( @$tags, {
			tag        => $tag,
                        tag_prefix => $tag_prefix,
		       }
	     );
    }
    $sql->finish();

    return( $tags );
}



=begin doc

  Return the list of subscribed users - we prefer to use their
 real names, but if they are not available fall back to returning
 only their account names.

=end doc

=cut

sub Posters
{
    #
    # Connect to the database.
    #
    my ( $dbh ) = Singleton::DBI->instance();

    #
    #  Get the prefix
    #
    my $user_prefix = get_conf( "user_prefix" );

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
               {  account     => $user_name,
                  fullname    => $real_name,
                  user_prefix => $user_prefix,
               });
    }


    #
    # Sort the subscriptions appropriately.
    #
    @$subscriptions = sort sortByName @$subscriptions;

    return( $subscriptions );
}



=begin doc

  Sort a list of subscriptions by their username, case-insensitive.

=end doc

=cut

sub sortByName()
{
    return( lc($::a->{'fullname'}) cmp lc($::b->{'fullname'}) );
}



=begin doc

  Perform a search against blog entries.  Optionally ignore the
 comment field in the database - it might not be present.

=end doc

=cut

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
    #  Get the prefix
    #
    my $user_prefix = get_conf( "user_prefix" );

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

        my $tags = getTags( $result[1], $result[0] );

        if ( $tags )
        {

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
			       new_date    => $new_date,
                               tags        => $tags,
                               user_prefix => $user_prefix
				  } );
        }
        else
        {
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
			       new_date    => $new_date,
                               user_prefix => $user_prefix,
				  } );
        }
    }

    return ( $rcount, $resultsloop );
}



#
# End of module
#
1;
