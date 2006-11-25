
package HTML::Cleanup;

use strict;
use HTML::TreeBuilder;
use HTML::Scrubber;

# ===========================================================================
#  Sanitize HTML
# ===========================================================================
sub sanitize
{
    my ($text) = (@_);


    my @allow = qw[ ul li ol p br hr small b a i pre blockquote tt dl dd dt fieldset legend ];
    my @rules = (
		 font => 0,
		 script => 0,
         table => 0,
         td    => 0,
         tr    => 0,
         tbody => 0,
         th    => 0,
         span => 0,
         div => 0,
         p => {
            class => 0,
            style => 0,
            },
         b => {
            class => 0,
            style => 0,
            },


		 img => {
		     src => qr{^(http://)}i,   # only absolute image links allowed
		     alt => 1,                 # alt attribute allowed
		     align => 1,               # align attribute allowed
		     '*' => 0,                 # deny all other attributes
		 },
		 a => {
		     href => 1,                # HREF
		     name => 1,                # name attribute allowed
		     id   => 1,                # id attribute allowed
		     title => 1,               # title attribute allowed
		     rel   => 1,               # Link relationship
		     '*' => 0,                 # deny all other attributes
		 },
		 );
#
    my @default = (
		   0   =>    # default rule, deny all tags
		   {
		       '*'           => 1, # default rule, allow all attributes
		       'href'        => qr{^(?!(?:java)?script)}i,
		       'src'         => qr{^(?!(?:java)?script)}i,
		       'cite'        => '(?i-xsm:^(?!(?:java)?script))',
		       'language'    => 0,
		       'name'        => 1, # could be sneaky, but hey ;)
		       'onblur'      => 0,
		       'onchange'    => 0,
		       'onclick'     => 0,
		       'ondblclick'  => 0,
		       'onerror'     => 0,
		       'onfocus'     => 0,
		       'onkeydown'   => 0,
		       'onkeypress'  => 0,
		       'onkeyup'     => 0,
		       'onload'      => 0,
		       'onmousedown' => 0,
		       'onmousemove' => 0,
		       'onmouseout'  => 0,
		       'onmouseover' => 0,
		       'onmouseup'   => 0,
		       'onreset'     => 0,
		       'onselect'    => 0,
		       'onsubmit'    => 0,
		       'onunload'    => 0,
		       'src'         => 0,
		       'type'        => 0,
		       'font'        => 0,
		   }
		   );


    #
    #  Create the scrubber.
    #
    my $safe = HTML::Scrubber->new();
    $safe->allow( @allow );
    $safe->rules( @rules );
    $safe->default( @default );

    # deny HTML Comments
    $safe->comment(0);

    my $ret = $safe->scrub( $text );
    return( $ret );
}



sub balance
{
    my ( $text ) = (@_);

    my $tree = HTML::TreeBuilder->new ();

    $tree->parse ($text);
    $tree->eof ();

    my $ret = $tree->as_HTML ();

    $ret =~ s/<html><head><\/head><body>//g;
    $ret =~ s/<\/body><\/html>//g;

    return( $ret );
}


1;
