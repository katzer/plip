# Apache 2.0 License
#
# Copyright (c) 2018 Sebastian Katzer, appPlant GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

@parser = OptParser.new do |opts|
  opts.add :local,    :string
  opts.add :remote,   :string
  opts.add :uid,      :int
  opts.add :gid,      :int
  opts.add :mode,     :int, 644
  opts.add :download, :bool, false
end

@parser.on! :help do
  <<-USAGE

#{PLIP::LOGO}

usage: plip [options...] -l local_file -r remote_file matchers...
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
USAGE
end

@parser.on! :version do
  "plip #{PLIP::VERSION} - #{OS.sysname} #{OS.bits(:binary)}-Bit (#{OS.machine})" # rubocop:disable LineLength
end

# Entry point of the tool.
#
# @param [ Array<String> ] args The ARGV array.
#
# @return [ Void ]
def __main__(args)
  validate && PLIP::Job.new(parse(args[1..-1])).exec
end

# Parse the command-line arguments.
#
# @param [ Array<String> ] args The command-line arguments to parse.
#
# @return [ Hash<Symbol, Object> ]
def parse(args)
  opts        = @parser.parse(args.empty? ? ['-h'] : args)
  opts[:mode] = opts[:mode].to_s.to_i(8)
  opts[:tail] = @parser.tail
  opts
end

# Validate the environment variables.
# Raises an error in case of something is missing or invalid.
#
# @return [ Void ]
def validate
  %w[ORBIT_HOME ORBIT_BIN ORBIT_KEY].each do |env|
    raise "#{env} not set"   unless ENV[env]
    raise "#{env} not found" unless File.exist? ENV[env]
  end
end
