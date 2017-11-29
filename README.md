# plip [![Build Status](https://travis-ci.org/appPlant/plip.svg?branch=master)](https://travis-ci.org/appPlant/plip)

Upload a file on multiple servers in parallel.

    $ plip -h
    plip - Planet Impact Probe

    usage: plip [options...] <sourcepath> <destinationpath> <planets>...
    Options:
    -own="<owner[:group]>"    Execute script and return result
    -mod="<mode>"      	      Execute script and return result
    -l    Load bash profiles on server
    -h    Display this help text
    -v    Show version number
    -d    Show extended debug informations, set logging level to debug


## Prerequisites
Create an enviroment variable called `ORBIT_HOME` and set it to the absolute path of the plip folder-structure.

Example: You save the release at `/home/youruser/workspace/plip`. Your `ORBIT_HOME` should be `/home/youruser/workspace/plip`as well

Either create an enviroment variable called `ORBIT_KEY` containing an absolute path to the ssh private key that should be used for executing commands on the planets or save said key at `orbit/config/ssh/`.

You'll need the following installed and in your `PATH`:
- [fifa][ff]

## Installation

Download the latest version from the [release page][releases] and add the executable to your `PATH`.

## Development

Clone the repo:

    $ git clone https://github.com/appPlant/plip.git && cd plip/

And then execute:

```bash
$ scripts/compile # https://docs.docker.com/engine/installation
```

You'll be able to find the binaries in the following directories:

- Linux (64-bit, for old distros): `build/x86_64-pc-linux-gnu-glibc-2.12/bin/plip`
- Linux (32-bit, for old distros): `build/i686-pc-linux-gnu-glibc-2.12/bin/plip`
- Linux (64-bit GNU): `build/x86_64-pc-linux-gnu-glibc-2.14/bin/plip`
- Linux (32-bit GNU): `build/i686-pc-linux-gnu-glibc-2.14/bin/plip`
- Linux (64-bit BusyBox): `build/x86_64-pc-linux-busybox-musl/bin/plip`
- OS X (64-bit): `build/x86_64-apple-darwin15/bin/plip`
- OS X (32-bit): `build/i386-apple-darwin15/bin/plip`
- Windows (64-bit): `build/x86_64-w64-mingw32/bin/plip`
- Windows (32-bit): `build/i686-w64-mingw32/bin/plip`

## Basic Usage

Execute commands or collect informations on multiple servers in parallel.

    $ plip -h
    plip - Planet Impact Probe

    usage: plip [options...] <sourcepath> <destinationpath> <planets>...
    Options:
    -own="<owner[:group]>"    Execute script and return result
    -mod="<mode>"      	      Execute script and return result
    -l    Load bash profiles on server
    -h    Display this help text
    -v    Show version number
    -d    Show extended debug informations, set logging level to debug

#### Upload
Use plip to upload a file on linux server planets:
```
$ plip path/of/file/to/upload path/the/file/will/be/saved/in/on/planet app-package-1
```

#### Environment Variables
It's very likely that you have to use environment variables when uploading a file to multiple servers, as the different servers will probably not have the same folder structure.
To do this, you can make use of possibly standardized environment variables.
But beware: in order to make us of such an environment variable, you have to provide it in an escaped fashion!
```
$ plip path/of/file/to/upload \$HOME/upload/path app-package-1
```

#### File permissions
You can provide the bitwise permissions description also used by chmod to determine the uploaded files permissions on the servers.
```
$ plip -mod="777" path/of/file/to/upload path/the/file/will/be/saved/in/on/planet app-package-1
```

#### Owner
You can provide the "user:usergroup" also used by chown, to change the files owner on the server.
Attention: Keep in mind that you only have the possibilites the user specified in your ssh key has.

```
$ plip -own="user:usergroup" path/of/file/to/upload path/the/file/will/be/saved/in/on/planet app-package-1
```


## Releases

    $ scripts/release

Affer this command finishes, you'll see the /releases for each target in the releases directory.

## Tests

To run all integration tests:

    $ scripts/bintest

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/appPlant/plip.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## License

The code is available as open source under the terms of the [Apache 2.0 License][license].

Made with :yum: from Leipzig

© 2016 [appPlant GmbH][appplant]

[ff]: https://github.com/appPlant/ff/releases
[releases]: https://github.com/appPlant/ski/releases
[docker]: https://docs.docker.com/engine/installation
[license]: http://opensource.org/licenses/Apache-2.0
[appplant]: www.appplant.de
