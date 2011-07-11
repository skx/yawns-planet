#!/usr/bin/env python

from __future__ import with_statement

import os
import sys
import subprocess

try:
    from fabric.api import *
    from fabric.contrib.console import confirm
except ImportError:
    print ("""The 'fabric' package is currently not installed. You can install it by typing:\n
sudo apt-get install fabric
""")
    sys.exit()


#
#  Username and hostname to ssh to.
#
env.hosts = ['www.debian-administration.org']
env.user = 'planet'



def deploy():
    """
    Deploy the application to the live site.
    """

    #
    #  Find the current revision number.
    #
    id=_mercurial_id()

    #
    #  Ensure the remote side is prepared.
    #
    _prepare_remote( id )

    #
    # now tar & upload the current codebase.
    #
    local('hg archive --type=tgz %s.tar.gz' % id )
    put( "%s.tar.gz" % id , "~/releases/"  )

    #
    #  Finally unpack the remote code.
    #
    run( "cd ~/releases && tar -zxf %s.tar.gz" %  id )

    #
    #  Now symlink in the current release
    #
    run( "rm ~/current || true" )

    run( "ln -s ~/releases/%s ~/current" % id )

    #
    # Finally clean up
    #
    _clean_local( id )
    _clean_remote()

    #
    #  And now perform post-install fixups
    #
    run( "cd ~/current && make planet" )

    #
    # Restart the HTTP server now that ~/current has changed to point to
    # a new directory.
    # 
    run( "sudo /etc/init.d/nginx restart" )


def _prepare_remote( id ):
    """
    Ensure that the remote host has ~/releases/NNN present.
    """
    with settings(warn_only=True):
        if run ("test -d ~/releases/%s" % id ).failed:
            run("mkdir -p ~/releases/%s" % id  )



def _mercurial_id():
    """
    Return the numerical identifier for the current state of the repository.
    """
    revision = [ S.strip('\n') for S in os.popen('hg id -n').readlines() ]
    revision = revision[0]
    return(revision)



def _clean_local(id ):
    """
    Remove any .tar.gz files from prior deployments.
    """

    local( "rm %s.tar.gz || true" % id )


def _clean_remote():
    """
    Remove any remote .tar.gz files from prior deployments.
    """

    run( "rm ~/releases/*.tar.gz || true" )


#
#  This is our entry point.
#
if __name__ == '__main__':

    if len(sys.argv) > 1:
        #
        #  If we got an argument then invoke fabric with it.
        #
        subprocess.call(['fab', '-f', __file__] + sys.argv[1:])
    else:
        #
        #  Otherwise list our targets.
        #
        subprocess.call(['fab', '-f', __file__, '--list'])

