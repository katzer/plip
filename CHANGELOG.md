# Release Notes: _plip_

Upload or download a file on multiple "planets" in parallel via SFTP.

## 1.5.1

Released at: 18.03.2020

1. Singularized folder names

2. Fixed potential memory leaks.

3. Compiled with `MRB_WITHOUT_FLOAT`

4. Compiled binary for OSX build with MacOSX10.15 SDK

5. Upgraded to mruby 2.1.0

[Full Changelog](https://github.com/appplant/plip/compare/1.5.0...1.5.1)

## 1.5.0

Released at: 13.08.2019

<details><summary>Releasenotes</summary>
<p>

1. Added support for `ECDSA` for both key exchange and host key algorithms.

2. Fixed not throwing an error if `ORBIT_PATH` was not set.

3. Compiled binary for OSX build with MacOSX10.13 SDK (Darwin17).

4. Upgraded to mruby 2.0.1

</p>

[Full Changelog](https://github.com/appplant/plip/compare/1.4.7...1.5.0)
</details>

## 1.4.7

Released at: 02.01.2019

<details><summary>Releasenotes</summary>
<p>

1. Dropped compatibility with orbit v1.4.6 due to breaking changes in _fifa_

2. Removed LVAR section for non test builds

3. Upgraded to mruby 2.0.0

</p>

[Full Changelog](https://github.com/appplant/plip/compare/1.4.6...1.4.7)
</details>

## 1.4.6

Released at: 16.08.2018

<details><summary>Releasenotes</summary>
<p>

1. Ensure that _fifa_ does not include ansi colors in its output.

2. Fix tool fails on Windows because of carriage return token.

3. Increase MacOSX min SDK version from 10.5 to to 10.11

4. Remove 32-bit build targets.

</p>

[Full Changelog](https://github.com/appplant/plip/compare/1.4.5...1.4.6)
</details>

## 1.4.5

Released at: 26.06.2018

<details><summary>Releasenotes</summary>
<p>

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

</p>

[Full Changelog](https://github.com/appplant/plip/compare/1.4.4...1.4.5)
</details>

## 1.4.4

Released at: 29.11.2017

<details><summary>Releasenotes</summary>
<p>

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

To upload a file:

    $ plip -l info.txt -r tmp/info.txt mars pluto

</p>

[Full Changelog](https://github.com/appplant/plip/compare/cb39809bea74b888aea0996b9030aeed6f19fdc4...1.4.4)
</details>
