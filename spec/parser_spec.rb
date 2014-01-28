require_relative '../lib/sokoban/parser'

describe Sokoban::Parser do
  def enforce_cell(cell, type: nil, entity: nil)
    expect(cell).to be_an_instance_of(type) unless type.nil?
    expect(cell.contents).to be_an_instance_of(entity) unless entity.nil?
  end

  context 'basic parsing' do
    let(:level) do
      map = <<-END_MAP.gsub(/^\s*/, '')
      #######
      #@ $.*#
      #######
      END_MAP

      Sokoban::Parser.parse(map)
    end

    it 'parses maps into levels' do
      expect(level).to be_an_instance_of(Sokoban::Level)
    end

    it 'parses the character' do
      enforce_cell(level[1, 1], {
        type: Sokoban::Level::Floor,
        entity: Sokoban::Level::Character
      })
    end

    it 'parses open floor' do
      enforce_cell(level[2, 1], type: Sokoban::Level::Floor)
    end

    it 'parses a crate' do
      enforce_cell(level[3, 1], {
        type: Sokoban::Level::Floor,
        entity: Sokoban::Level::Crate
      })
    end

    it 'parses an unsatisfied goal' do
      enforce_cell(level[4, 1], type: Sokoban::Level::Goal)
    end

    it 'parses a satisfied goal' do
      enforce_cell(level[5, 1], {
        type: Sokoban::Level::Goal,
        entity: Sokoban::Level::Crate
      })
    end
  end

  context 'irregular levels' do
    let(:level) do
      map = <<-END_MAP.gsub(/^\s*/, '')
      ####
      #@ ##
      # $.#
      #####
      END_MAP

      Sokoban::Parser.parse(map)
    end

    it 'pads the outsides of the level' do
      expect(level.rows.all? { |r| r.size == level.rows.first.size }).to be_true
    end

    it 'replaces unreachable floors with voids' do
      enforce_cell(level[4, 0], type: Sokoban::Level::Void)
      enforce_cell(level[2, 1], type: Sokoban::Level::Floor)
    end
  end

  context 'invalid levels' do
    let(:map) do
      <<-END_MAP.gsub(/^\s*/, '')
      ###
      # #
      ###
      END_MAP
    end

    it 'requires a character start marker' do
      expect { Sokoban::Parser.parse(map) }.to raise_error
    end
  end
end
