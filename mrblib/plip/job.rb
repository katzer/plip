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

module PLIP
  class Job
    # Initialize a new job that coordinates the execution of the tasks.
    #
    # @param [ Hash ] spec The parsed command line arguments.
    #
    # @return [ Void ]
    def initialize(spec)
      @spec = spec
    end

    # Download/Upload the file specified by the opts.
    #
    # @return [ Void ]
    def exec
      validate && async { |opts| PLIP::Task.new(opts).exec }
    end

    private

    # Devide the list of planets into slices and execute the code block
    # for each slice within an own thread.
    #
    # @param [ Proc ] &block A code block to execute per slice.
    #
    # @return [ Void ]
    def async(&block)
      servers = planets
      size    = [(servers.count / 20.0).round, 1].max
      ths     = []

      servers.each_slice(size) do |slice|
        ths << Thread.new(@spec.merge(planets: slice)) do |opts|
          block&.call(opts) && true
        end
      end

      ths.each(&:join)
    end

    # Validate the parsed command-line arguments.
    # Raises an error in case of something is missing or invalid.
    #
    # @return [ Boolean ] true if valid
    def validate
      validate_envs && validate_args
    end

    # rubocop:disable CyclomaticComplexity, AbcSize, LineLength

    # Validate command-line arguments.
    # Raises an error in case of something is missing or invalid.
    #
    # @return [ Boolean ] true if valid
    def validate_args
      raise ArgumentError, 'Missing local file'              unless @spec[:local] || @spec[:download]
      raise ArgumentError, 'Missing remote file'             unless @spec[:remote]
      raise ArgumentError, 'Missing matcher'                 unless @spec[:tail].any?
      raise ArgumentError, "No such file - #{@spec[:local]}" unless @spec[:download] || File.file?(@spec[:local])

      true
    end

    # Validate environment arguments.
    # Raises an error in case of something is missing or invalid.
    #
    # @return [ Boolean ] true if valid
    def validate_envs
      raise KeyError, '$ORBIT_KEY not set'   unless ENV['ORBIT_KEY']
      raise KeyError, '$ORBIT_KEY not found' unless File.exist? ENV['ORBIT_KEY']

      true
    end

    # rubocop:enable CyclomaticComplexity, AbcSize, LineLength

    # Retrieve list of servers in ssh format from fifa.
    #
    # @return [ Array<"user@host"> ]
    def planets
      query = @spec[:tail].join('" "')
      fifa  = ENV.include?('ORBIT_BIN') ? "#{ENV['ORBIT_BIN']}/fifa" : 'fifa'
      cmd   = %(#{fifa} -n -f ssh "#{query}")
      out   = `#{cmd}`

      raise "#{cmd} failed with exit code #{$?}" unless $? == 0

      out.split("\n").map! { |ssh| ssh.chomp.split('@') }
    end
  end
end
