# plip - Planet Impact Probe <br> [![GitHub release](https://img.shields.io/github/release/katzer/plip.svg)](https://github.com/katzer/plip/releases) [![Build Status](https://travis-ci.com/katzer/fifa.svg?branch=master)](https://travis-ci.com/katzer/fifa) [![Build status](https://ci.appveyor.com/api/projects/status/y4t2hib480fgsyl0/branch/master?svg=true)](https://ci.appveyor.com/project/katzer/plip/branch/master) [![Maintainability](https://api.codeclimate.com/v1/badges/39da9afecddcd804781f/maintainability)](https://codeclimate.com/github/katzer/plip/maintainability)

Upload or download a file on multiple "planets" in parallel via SFTP.

    $ plip -h

    Usage: plip [options...] -l local_file -r remote_file matchers...
    Options:
    -d, --download  Download the file from the remote host
    -l, --local     Set the path of the local file
    -r, --remote    Set the path of the remote file
    -u, --uid       Change the user ID of the remote file
    -g, --gid       Change the group ID of the remote file
    -m, --mode      Change the modes of the remote file
                    Defaults to: 644
    -h, --help      This help text
    -v, --version   Show version number

## Prerequisites

You'll need to add `ORBIT_HOME` first to your profile:

    $ export ORBIT_HOME=/path/to/orbit

Then setup the SSH agent for passwordless authentication:

    $ ssh-add /path/to/key

## Installation

Download the latest version from the [release page][releases] and add the executable to your `PATH`.

## Usage

Upload a file:

    $ plip -l info.txt -r tmp/info.txt mars pluto

Change the modes of the remote file:

    $ plip --mode 777 -l info.txt -r tmp/info.txt mars pluto

Download a file:

    $ plip -d -l info.txt -r tmp/info.txt mars pluto

Once done you'll find the 2 files `info.txt.mars` and `info.txt.pluto`.

## Development

Clone the repo:

    $ git clone https://github.com/katzer/plip.git && cd plip/

Install the dependencies:

    $ bundle

And then execute:

    $ rake compile

To compile the sources locally for the host machine only:

    $ MRUBY_CLI_LOCAL=1 rake compile

You'll be able to find the binaries in the following directories:

- Linux (AMD64, Musl): `build/x86_64-alpine-linux-musl/bin/plip`
- Linux (AMD64, GNU): `build/x86_64-pc-linux-gnu/bin/plip`
- Linux (AMD64, for old distros): `build/x86_64-pc-linux-gnu-glibc-2.9/bin/plip`
- OS X (AMD64): `build/x86_64-apple-darwin19/bin/plip`
- OS X (ARM64): `build/arm64-apple-darwin19/bin/plip`
- Windows (AMD64): `build/x86_64-w64-mingw32/bin/plip`
- Host: `build/host/bin/plip`

For the complete list of build tasks:

    $ rake -T

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/katzer/plip.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

The code is available as open source under the terms of the [Apache 2.0 License][license].

Made with :heart: in Leipzig

© 2018 [appPlant GmbH][appplant]

[releases]: https://github.com/katzer/plip/releases
[license]: http://opensource.org/licenses/Apache-2.0
[appplant]: www.appplant.de
