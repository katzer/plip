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
  class Task
    # Download/Upload the file specified by the opts.
    #
    # @param [ Hash<Symbol, _> ] opts A key: value map
    #
    # @return [ Void ]
    def initialize(opts)
      @opts = opts
      @opts.freeze
    end

    # The parsed CLI params.
    #
    # @return [ Hash ]
    attr_reader :opts

    # Execute the request specified by the command-line arguments. Each
    # download or upload operation will be executed asnyc in a thread.
    #
    # @return [ Void ]
    def execute
      async do |planets|
        start_sftp_for_each(planets) do |ssftp|
          if !opts[:download] then upload(ssftp)
          elsif opts[:local]  then download(ssftp)
          else                     cat(ssftp)
          end
        end
      end
    end

    # Download the file as specified by opts.
    #
    # @param [ SFTP::Session ] sftp The connected SFTP session.
    #
    # @return [ Void ]
    def download(sftp)
      path = "#{opts[:local]}.#{sftp.host}"

      log "Downloading #{opts[:remote]} from #{sftp.host} to #{path}" do
        sftp.download(opts[:remote], path)
      end
    end

    # Download the file as specified by opts.
    #
    # @param [ SFTP::Session ] sftp The connected SFTP session.
    #
    # @return [ Void ]
    def cat(sftp)
      log "Downloading #{opts[:remote]} from #{sftp.host}" do
        print sftp.download(opts[:remote])
      end
    end

    # Upload the file as specified by opts.
    #
    # @param [ SFTP::Session ] sftp The connected SFTP session.
    #
    # @return [ Void ]
    def upload(sftp)
      log "Uploading #{opts[:local]} to #{sftp.host}" do
        sftp.upload(opts[:local], opts[:remote])
      end
    end

    private

    # Logging device that writes into $ORBIT_HOME/log/plip.log
    #
    # @return [ Logger ]
    def logger
      $logger ||= begin
        dir = File.join(ENV['ORBIT_HOME'], 'logs')
        Dir.mkdir(dir) unless Dir.exist? dir

        Logger.new("#{dir}/plip.log", formatter: lambda do |sev, ts, _, msg|
          "[#{sev[0, 3]}] #{ts}: #{msg}\n"
        end)
      end
    end

    # Write a log message, execute the code block and write another log message
    # that the task is done.
    #
    # @param [ String ] msg The message to log.
    # @param [ Proc ] block The code block to execute.
    #
    # @return [ Void ]
    def log(msg)
      logger.info msg
      yield
      logger.info "#{msg} done"
    end

    # Devide the list of planets into slices and execute the code block
    # for each slice within an own thread.
    #
    # @param [ Proc ] &block A code block to execute per slice.
    #
    # @return [ Void ]
    def async(&block)
      planets = opts[:planets]
      size    = [(planets.count / 20.0).round, 1].max
      ths     = []

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
        sftp = SFTP.start(host, user, key: ENV['ORBIT_KEY'], compress: true)
        ssh  = sftp.session
        yield(sftp)
      rescue RuntimeError
        logger.error "#{user}@#{host} #{ssh.last_error} #{ssh.last_errno} #{sftp.last_errno}"
      ensure
        ssh.close
      end
    end
  end
end
