module Sokoban
  class Level
    class Cell
      def initialize(contents = Empty.new)
        raise 'Cell contents must be an Entity' unless contents.is_a? Entity
        @contents = contents
      end

      attr_reader :contents
    end

    class Floor < Cell; end
    class Goal < Cell; end
    class Void < Cell; end
    class Wall < Cell; end

    class Entity; end

    class Character < Entity; end
    class Crate < Entity; end
    class Empty < Entity; end

    def initialize(rows)
      @rows = rows

      validate_level
    end

    attr_reader :rows

    def [](x, y)
      rows[y][x]
    end

    def at(position)
      rows[position[1]][position[0]]
    end

    def starting_coordinates
      @starting_coordinates ||= calculate_starting_coordinates
    end

    def height
      rows.size
    end

    def includes_coordinates?(position)
      return false if position[0] < 0 || position[0] >= width
      return false if position[1] < 0 || position[1] >= height
      true
    end

    def set(position, cell)
      rows[position[1]][position[0]] = cell
    end

    def width
      rows.first.size
    end

    private

    def calculate_starting_coordinates
      rows.each_with_index do |r, y|
        r.each_with_index do |c, x|
          return [x, y] if c.contents.is_a? Character
        end
      end

      nil
    end

    def validate_dimensions
      raise 'Level height must be greater than 0' if height < 1
      raise 'Level width must be greater than 0' if width < 1
    end

    def validate_has_character
      raise 'Level must have a character' if starting_coordinates.nil?
    end

    def validate_level
      validate_dimensions
      validate_has_character
    end
  end
end
