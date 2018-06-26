## Release Notes: _plip_

### 1.4.5 - (26.06.2018)

1. Download remote file:

   ```sh
   $ plip -d -l info.txt -r tmp/info.txt mars pluto
   ```

   Once done you'll find the 2 files `info.txt.mars` and `info.txt.pluto`.

2. Improved upload speed

   - 1.5 times faster for small files
   - 15 times faster for bigger files

3. The tool writes a log under `$ORBIT_HOME/log/plip.log`.

4. Renamed target x86_64-pc-linux-busybox to x86_64-alpine-linux-musl

5. Switched from Golang to mruby

  - Shrinks binary size to 1/4

### 1.4.4 - Initial release (29.11.2017)

Upload a file on multiple "planets" in parallel via SFTP.

    $ plip -h

    usage: plip [options...] -l local_file -r remote_file matchers...
    Options:
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
