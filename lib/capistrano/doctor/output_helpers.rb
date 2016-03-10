module Capistrano
  module Doctor
    # Helper methods for pretty-printing doctor output to stdout. All output
    # (other than `title`) is indented by four spaces to facilitate copying and
    # pasting this output into e.g. GitHub or Stack Overflow to achieve code
    # formatting.
    module OutputHelpers
      class Row
        attr_reader :color
        attr_reader :values

        def initialize
          @values = []
        end

        def <<(value)
          values << value
        end

        def yellow
          @color = :yellow
        end
      end

      # Prints a table for a given array of records. For each record, the block
      # is yielded two arguments: the record and a Row object. To print values
      # for that record, add values using `row << "some value"`. A row can
      # optionally be highlighted in yellow using `row.yellow`.
      def table(records, &block)
        return if records.empty?
        rows = collect_rows(records, &block)
        col_widths = calculate_column_widths(rows)

        rows.each do |row|
          line = row.values.each_with_index.map do |value, col|
            value.to_s.ljust(col_widths[col])
          end.join(" ").rstrip
          line = color.colorize(line, row.color) if row.color
          puts line
        end
      end

      # Prints a title in blue with surrounding newlines.
      def title(text)
        # Use $stdout directly to bypass the indentation that our `puts` does.
        $stdout.puts(color.colorize("\n#{text}\n", :blue))
      end

      # Prints text in yellow.
      def warning(text)
        puts color.colorize(text, :yellow)
      end

      # Override `Kernel#puts` to prepend four spaces to each line.
      def puts(string=nil)
        $stdout.puts(string.to_s.gsub(/^/, "    "))
      end

      private

      def collect_rows(records)
        records.map do |rec|
          Row.new.tap { |row| yield(rec, row) }
        end
      end

      def calculate_column_widths(rows)
        num_columns = rows.map { |row| row.values.length }.max
        Array.new(num_columns) do |col|
          rows.map { |row| row.values[col].to_s.length }.max
        end
      end

      def color
        @color ||= SSHKit::Color.new($stdout)
      end
    end
  end
end
