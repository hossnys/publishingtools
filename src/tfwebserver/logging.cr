module TFWeb
  module Logging
    LOG_TIME_FORMAT = "%Y-%m-%d %H:%M:%S"

    class ColoredBackend < Log::IOBackend
      property formatter = ->(entry : Log::Entry, io : IO) do
        label = entry.severity.label
        io << "["
        entry.timestamp.to_s(LOG_TIME_FORMAT, io)
        io << " #" << Process.pid << "] "
        label.rjust(7, io)
        io << " -- " << PROGRAM_NAME << ":" << entry.source << ": " << entry.message
        if entry.context.size > 0
          io << " -- " << entry.context
        end
        if ex = entry.exception
          io << " -- " << ex.class << ": " << ex
        end
      end

      # default IO of IOBackend is STDOUT
      # TODO: better to use a formatter here
      def write(entry : Log::Entry)
        case entry.severity
        when Log::Severity::Debug
          color = :blue
        when Log::Severity::Info
          color = :green
        when Log::Severity::Warning
          color = :yellow
        when Log::Severity::Error
          color = :light_red
        when Log::Severity::Fatal
          color = :red
        else
          color = :white
        end

        message = entry.message.colorize(color).to_s
        entry = Log::Entry.new(entry.source, entry.severity, message, entry.exception)
        super(entry)
      end
    end

    def self.for(what : String | Class)
      Log.for(what)
    end

    def self.severity=(severity : Log::Severity)
      Log.builder.bind "*", severity, ColoredBackend.new
    end

    def self.with_colors(for_what : String | Class, severity = Log::Severity::Debug)
      self.severity = severity
      Log.for(for_what)
    end
  end
end
