Yawns-Planet
------------

This software is designed to output a "PlanetPlanet" like collection of webpages.


Rationale
---------

Using PlanetPlanet entries are fetched by making HTTP requests to remote servers.  In the case of Yawns it is much more efficient to directly query the database, and avoid the HTTP request and feed processing.

This approach also has at least the following advantage(s):

* It allows the display to contain more information than is permitted upon a PlanetPlanet installation.

* It avoids invoking Yawns to generate each XML feed for the subscribed users.

* It will work if your Yawns installation doesn't have weblog feeds available.




Requirements
------------

Using this software makes no sense if you're not running an installation of Yawns.

If you have Yawns installed already the only additional software you need is the perl module `Date::Manip`.

This can be installed upon a Debian host with the following command:

     # apt-get install libdate-manip-perl


Installation
------------

Once you have a copy of the software downloaded you will need to configure it by editting the file "conf/SiteConfig.pm". The settings there should be obvious.

After you have updated any settings you care about you may generate the output pages by running:

	./yp

or

	make planet

If you wish you may customize the template files before updating them.  (They are standard `HTML::Template` files.)



Steve
-- 
