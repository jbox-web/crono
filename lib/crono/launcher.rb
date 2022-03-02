# frozen_string_literal: true

module Crono
  class Launcher

    include Util

    PROCTITLES = [
      proc { 'crono' },
      proc { Crono::VERSION::STRING },
    ]


    def initialize(check_port:)
      @heartbeat  = nil
      @poller     = nil
      @socket     = nil
      @check_port = check_port
    end


    def run
      @heartbeat = safe_thread('heartbeat', &method(:start_heartbeat))
      @poller    = safe_thread('poller', &method(:start_poller))
      @socket    = safe_thread('socket', &method(:start_socket))
    end


    def stop
      if @heartbeat
        t = @heartbeat
        @heartbeat = nil
        t.terminate
        logger.debug('Heartbeat stopped...')
      end

      if @socket
        t = @socket
        @socket = nil
        t.terminate
        logger.debug('Socket stopped...')
      end

      if @poller
        t = @poller
        @poller = nil
        t.terminate
        logger.debug('Poller stopped...')
      end
    end


    private


      def start_heartbeat
        loop do
          heartbeat
          sleep 5
        end
      end


      def heartbeat
        logger.debug('Heartbeat check')
        $0 = PROCTITLES.map { |proc| proc.call(self) }.compact.join(' ')
      end


      def start_poller
        loop do
          next_time, jobs = Crono.scheduler.next_jobs
          now = Time.zone.now

          if next_time > now
            t = next_time - now
            logger.debug("Sleeping for #{t}")
            sleep(t)
          end

          jobs.each(&:perform)
        end
      end


      def start_socket
        Socket.udp_server_loop(@check_port) do |msg, msg_src|
          resp = msg.chomp == 'ping' ? "pong\n" : msg
          msg_src.reply resp
        end
      end

  end
end
