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

# Fix ansi colors for windows.
def puts(str = "\n")
  __printansistr__(str)
  __printstr__("\n") unless str[-1] == "\n"
end

# Parse the command-line arguments.
#
# @param [ Array<String> ] args The command-line arguments to parse.
#
# @return [ Hash<Symbol, Object> ]
def parse(args)
  opts = @parser.parse(args.empty? ? ['-h'] : args)
ensure
  opts[:mode] = opts[:mode].to_s.to_i(8) if opts
end

# rubocop:disable CyclomaticComplexity, AbcSize, LineLength

# Validate the parsed command-line arguments.
# Raises an error in case of something is missing or invalid.
#
# @param [ Hash<Symbol, Object> ] opt The parsed arguments.
#
# @return [ Void ]
def validate(opt)
  raise ArgumentError,     'Missing local file'            unless opt[:local] || opt[:download]
  raise ArgumentError,     'Missing remote file'           unless opt[:remote]
  raise ArgumentError,     'Missing matcher'               unless @parser.tail.any?
  raise File::NoFileError, "No such file - #{opt[:local]}" unless opt[:download] || File.file?(opt[:local])
end

# rubocop:enable CyclomaticComplexity, AbcSize, LineLength

# Server list retrieved from fifa.
#
# @return [ Array<"user@host"> ]
def planets
  @planets ||= `fifa -f=ssh #{@parser.tail.join(' ')}`
               .split("\n")
               .map! { |ssh| ssh.split('@') }
end

# Logging device that writes into $ORBIT_HOME/log/plip.log
#
# @return [ Logger ]
def logger
  $logger ||= begin
    dir = File.join(ENV['ORBIT_HOME'], 'log')
    Dir.mkdir(dir) unless Dir.exist? dir

    Logger.new("#{dir}/plip.log", formatter: lambda do |sev, ts, _, msg|
      "[#{sev[0, 3]}] #{ts}: #{msg}\n"
    end)
  end
end

# Devide the list of planets into slices and execute the code block
# for each slice within an own thread.
#
# @param [ Proc ] &block A code block to execute per slice.
#
# @return [ Void ]
def async(&block)
  size = [(planets.count / 20.0).round, 1].max
  ths  = []

  planets.each_slice(size) do |slice|
    ths << Thread.new(slice) { |list| block&.call(list) && true }
  end

  ths.each(&:join)
end

# Start a sftp session for each planet in the list.
#
# @param [ Array<String, String> ] planets A list of user@host connections.
#
# @return [ Void ]
def start_sftp_for_each(planets)
  planets.each do |user, host|
    yield sftp = SFTP.start(host, user, key: ENV['ORBIT_KEY'], compress: true)
  rescue RuntimeError
    logger.error "#{user}@#{host} #{sftp.session.last_error} #{sftp.session.last_errno} #{sftp.last_errno}"
  ensure
    sftp.session.close
  end
end
