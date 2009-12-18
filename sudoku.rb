require 'pp'

module Enumerable
  def dups
    inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1}.keys
  end
end

class Cell
    attr_accessor :possibilities, :value
    POSSIBLE_VALUES = (1..9).to_a.map { |number| number }
    def initialize(known_value = nil)
        self.value = known_value
        self.possibilities = self.value ? self.value : POSSIBLE_VALUES
    end
    def mark_solved
        self.value = self.possibilities.first if self.possibilities.size == 1
        self.possibilities = self.value if self.value
    end
end

class CellGroup
    attr_accessor :cells
    def initialize(cells)
        self.cells = cells
    end
    def solved_cells
        self.cells.select{|cell| cell.value}
    end
    def unsolved_cells
        self.cells.reject{|cell| cell.value}
    end
    def solved_values
        self.solved_cells.map {|cell| cell.value}
    end
end

class Sudoku
    attr_accessor :rows
    def initialize(rows)
        self.rows = rows
    end
    def columns
        self.rows.transpose
    end
    def squares
        squares = Array.new(9, [])
        self.rows[0..2].each do |row|
            squares[0] += row[0..2]
            squares[1] += row[3..5]
            squares[2] += row[6..8]
        end
        self.rows[3..5].each do |row|
            squares[3] += row[0..2]
            squares[4] += row[3..5]
            squares[5] += row[6..8]
        end
        self.rows[6..8].each do |row|
            squares[6] += row[0..2]
            squares[7] += row[3..5]
            squares[8] += row[6..8]
        end
#       pp squares[0].map {|cell| cell.value}
        squares
    end

    def iterate_rows
        self.rows.each    {|row|    iterate(row)   }
    end
    def iterate_columns
        self.columns.each {|column| iterate(column)}
    end
    def iterate_squares
        self.squares.each {|square| iterate(square)}
    end

    def iterate(row)
        row = CellGroup.new(row)
        row.unsolved_cells.each do |cell|
            cell.possibilities = (cell.possibilities - row.solved_values)
            cell.mark_solved
        end
        two_possibility_cell_values = row.unsolved_cells.select {|cell| cell.possibilities.size == 2}.map {|cell| cell.possibilities }
        more_possibility_cells = row.unsolved_cells.select {|cell| cell.possibilities.size > 2}
#       pp more_possibility_cells.map {|cell| cell.possibilities}
        more_possibility_cells.each do |more_possibility_cell|
            two_possibility_cell_values.dups.each do |two_possibilities|
                more_possibility_cell.possibilities = more_possibility_cell.possibilities - two_possibilities
            end
            more_possibility_cell.value = more_possibility_cell.possibilities.first if more_possibility_cell.possibilities.size == 1
            more_possibility_cell.possibilities = more_possibility_cell.value if more_possibility_cell.value
        end
        unsolved_values_count = Hash.new(0)
        row.unsolved_cells.each do |cell|
            cell.possibilities.each do |possibility|
                unsolved_values_count[possibility] += 1
            end
        end
        unique_unsolved_values = unsolved_values_count.select {|k, v| v == 1}.map {|val_array| val_array[0]}
        #pp unique_unsolved_values unless unique_unsolved_values.empty?
        unique_unsolved_values.each do |val|
            row.unsolved_cells.each do |cell|
                if cell.possibilities.include? val
                    cell.possibilities = [val]
                    cell.mark_solved
                end
            end
        end
    end

end

lines = []
File.open('sudoku').each_line do |line|
    next unless line =~ /\d|_/
    line = line.split(//).grep /[\d_]/
    line.map! {|cell_value| cell_value == '_' ? nil : cell_value.to_i}
    line.map! {|cell_value| Cell.new(cell_value)}
    lines << line
end

s = Sudoku.new(lines)

30.times do
    s.iterate_rows
    s.iterate_columns
    s.iterate_squares
end

pp s.rows.map {|row| row.map {|cell| v = cell.possibilities}}
