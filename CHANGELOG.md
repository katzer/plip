## Release Notes: _plip_

### 1.4.5 - (not yet released)

Upload or download a file on multiple "planets" in parallel via SFTP.

    $ plip -h

    usage: plip [options...] -l local_file -r remote_file matchers...
    Options:
    -c, --compress  Enable compression
    -d, --download  Download the file from the remote host
    -l, --local     Set the path of the local file
    -r, --remote    Set the path of the remote file
    -u, --uid       Change the user ID of the remote file
    -g, --gid       Change the group ID of the remote file
    -m, --mode      Change the modes of the remote file
                    Defaults to: 644
    -h, --help      This help text
    -v, --version   Show version number

Upload a file:

    $ plip -l info.txt -r tmp/info.txt mars pluto

Download a file:

    $ plip -d -l info.txt -r tmp/info.txt mars pluto

Once done you'll find the 2 files `info.txt.mars` and `info.txt.pluto`.

__Note:__ The tool writes a log under `$ORBIT_HOME/log/plip.log`.

### 1.4.4 - Initial release (29.11.2017)

No release notes available