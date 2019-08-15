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
    # @param [ Hash<Symbol,Object> ] opts A key: value map
    #
    # @return [ Void ]
    def initialize(opts)
      @opts = opts
      @opts.freeze
    end

    # Execute the request specified by the command-line arguments. Each
    # download or upload operation will be executed asnyc in a thread.
    #
    # @return [ Void ]
    def exec
      start_sftp_for_each(@opts[:planets]) do |sftp|
        if !@opts[:download] then upload(sftp)
        elsif @opts[:local]  then download(sftp)
        else                      cat(sftp)
        end
      end
    end

    # Download the file as specified by opts.
    #
    # @param [ SFTP::Session ] sftp The connected SFTP session.
    #
    # @return [ Void ]
    def download(sftp)
      path = "#{@opts[:local]}.#{sftp.host}"

      log "Downloading #{@opts[:remote]} from #{sftp.host} to #{path}" do
        sftp.download(@opts[:remote], path)
      end
    end

    # Download the file as specified by opts.
    #
    # @param [ SFTP::Session ] sftp The connected SFTP session.
    #
    # @return [ Void ]
    def cat(sftp)
      log "Downloading #{@opts[:remote]} from #{sftp.host}" do
        STDOUT.print sftp.download(@opts[:remote])
      end
    end

    # Upload the file as specified by opts.
    #
    # @param [ SFTP::Session ] sftp The connected SFTP session.
    #
    # @return [ Void ]
    def upload(sftp)
      log "Uploading #{@opts[:local]} to #{sftp.host}" do
        sftp.upload(@opts[:local], @opts[:remote])
      end
    end

    private

    # Logging device that writes into $ORBIT_HOME/log/plip.log
    #
    # @return [ Logger ]
    def logger
      $logger ||= begin
        dir = File.join(ENV.fetch('ORBIT_HOME', '.'), 'log')
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
      res = yield
      logger.info "#{msg} done"
      res
    end

    # Write an error log message.
    #
    # @param [ String ] user The remote user.
    # @param [ String ] host The remote host.
    # @param [ SSH::Session ] ssh The connected SSH session.
    # @param [ String ] msg  The error message.
    #
    # @return [ Void ]
    def log_error(usr, host, ssh, msg)
      logger.error "#{usr}@#{host} #{ssh&.last_error} #{ssh&.last_errno} #{msg}"
    end

    # Configuration for SSH connection.
    #
    # @return [ Hash<Symbol,Object> ]
    def ssh_config
      { key: ENV.fetch('ORBIT_KEY'), compress: true, timeout: 5_000 }
    rescue KeyError
      raise '$ORBIT_KEY not set'
    end

    # Establish a SSH connection to the host and make sure that the timeout is
    # only used for the connect period.
    #
    # @param [ String ] user The remote user.
    # @param [ String ] host The remote host.
    #
    # @return [ SSH::Session ]
    def __connect__(user, host)
      log "Connecting to #{user}@#{host}" do
        ssh = SSH.start(host, user, ssh_config)
        ssh.timeout = 0
        ssh
      end
    end

    # Start a sftp session for each planet in the list.
    #
    # @param [ Array<String, String> ] planets A list of user@host connections.
    #
    # @return [ Void ]
    def start_sftp_for_each(planets)
      planets.each do |user, host|
        ssh = __connect__(user, host)
        yield(sftp = ssh.sftp)
        log_error(user, host, ssh, sftp.last_errno) if ssh.last_error
      rescue RuntimeError => e
        log_error(user, host, ssh, sftp&.last_errno || e.message)
      ensure
        ssh&.close
      end
    end
  end
end
