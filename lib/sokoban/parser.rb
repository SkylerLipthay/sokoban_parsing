require_relative 'level'

module Sokoban
  class Parser
    MAP_MAPPING = {
      # Reachable Void cells will be replaced with Floor cells later:
      '@' => ->(*) { Level::Void.new(Level::Character.new) },
      ' ' => ->(*) { Level::Void.new },
      '$' => ->(*) { Level::Void.new(Level::Crate.new) },
      '.' => ->(*) { Level::Goal.new },
      '*' => ->(*) { Level::Goal.new(Level::Crate.new) },
      '#' => ->(*) { Level::Wall.new }
    }

    MAP_MAPPING.default = ->(c) { raise "Unrecognized character #{c.inspect}" }

    attr_reader :map

    def initialize(map)
      @map = map
    end

    def to_level
      level = Level.new(rows)
      convert_reachable_voids_to_floors(level, level.starting_coordinates)
      level
    end

    def self.parse(map)
      new(map).to_level
    end

    private

    def convert_reachable_voids_to_floors(level, position)
      return unless level.includes_coordinates?(position)

      cell = level.at(position)
      return unless cell.is_a? Level::Void
      level.set(position, Level::Floor.new(cell.contents))

      convert_reachable_voids_to_floors(level, [position[0] - 1, position[1]])
      convert_reachable_voids_to_floors(level, [position[0] + 1, position[1]])
      convert_reachable_voids_to_floors(level, [position[0], position[1] - 1])
      convert_reachable_voids_to_floors(level, [position[0], position[1] + 1])
    end

    def length_of_longest_line
      map.lines.map(&:length).max
    end

    def normalize(line)
      line.rstrip.ljust(length_of_longest_line)
    end

    def parse_char(c)
      MAP_MAPPING[c].call(c)
    end

    def rows
      map.lines.map do |line|
        normalize(line).chars.map { |c| parse_char(c) }
      end
    end
  end
end
