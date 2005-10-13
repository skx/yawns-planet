#!/usr/bin/perl -I..
#
#  Test that all the Perl modules we require are available.
#

use Test::More qw( no_plan );


BEGIN { use_ok( 'conf::SiteConfig' ); }
require_ok( 'conf::SiteConfig' );

BEGIN { use_ok( 'CGI' ); }
require_ok( 'CGI' );

BEGIN { use_ok( 'Date::Manip' ); }
require_ok( 'Date::Manip' );

BEGIN { use_ok( 'DBI' ); }
require_ok( 'DBI' );

BEGIN { use_ok( 'HTML::Entities' ); }
require_ok( 'HTML::Entities' );

BEGIN { use_ok( 'HTML::Template' ); }
require_ok( 'HTML::Template' );

BEGIN { use_ok( 'POSIX' ); }
require_ok( 'POSIX' );

BEGIN { use_ok( 'Singleton::DBI' ); }
require_ok( 'Singleton::DBI' );

BEGIN { use_ok( 'YawnsBlog' ); }
require_ok( 'YawnsBlog' );


