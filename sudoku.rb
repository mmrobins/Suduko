require 'pp'

module Enumerable
  def dups
    inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1}.keys
  end
end

class Cell
  attr_accessor :possibilities
  POSSIBLE_VALUES = (1..9).to_a
  def initialize(known_value = nil)
    self.possibilities = known_value ? [known_value] : POSSIBLE_VALUES
  end
  def value
    self.possibilities.size == 1 ? self.possibilities.first : nil
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
  def two_possibility_cell_values
    self.unsolved_cells.select {|cell| cell.possibilities.size == 2}.map {|cell| cell.possibilities }
  end
  def remove_solved_values_from_possibilities
    self.unsolved_cells.each do |cell|
      cell.possibilities = (cell.possibilities - self.solved_values)
    end
  end
  def unsolved_values_count
  end
  def iterate
    self.remove_solved_values_from_possibilities
#     two_possibility_cell_values = self.unsolved_cells.select {|cell| cell.possibilities.size == 2}.map {|cell| cell.possibilities }
#     more_possibility_cells = self.unsolved_cells.select {|cell| cell.possibilities.size > 2}
#       pp more_possibility_cells.map {|cell| cell.possibilities}
#     more_possibility_cells.each do |more_possibility_cell|
#         two_possibility_cell_values.dups.each do |two_possibilities|
#             more_possibility_cell.possibilities = more_possibility_cell.possibilities - two_possibilities
#         end
#     end
#     unsolved_values_count = Hash.new(0)
#     self.unsolved_cells.each do |cell|
#         cell.possibilities.each do |possibility|
#             unsolved_values_count[possibility] += 1
#         end
#     end
#     unique_unsolved_values = unsolved_values_count.select {|k, v| v == 1}.map {|val_array| val_array[0]}
#     #pp unique_unsolved_values unless unique_unsolved_values.empty?
#     unique_unsolved_values.each do |val|
#         self.unsolved_cells.each do |cell|
#             if cell.possibilities.include? val
#                 cell.possibilities = [val]
#             end
#         end
#     end
  end
end

class Sudoku
  attr_accessor :rows
  def initialize(rows)
      rows_with_cells = rows.map do |row|
        row.map do |cell_value|
          cell_value.is_a?(Fixnum) ? Cell.new(cell_value.to_i) : Cell.new
        end
      end
      self.rows = rows_with_cells
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
      self.rows.each    {|row| CellGroup.new(row).iterate }
  end
  def iterate_columns
      self.columns.each {|columns| CellGroup.new(columns).iterate }
  end
  def iterate_squares
      self.squares.each {|squares| CellGroup.new(squares).iterate }
  end

end

lines = []
File.open('sudoku.txt').each_line do |line|
    next unless line =~ /\d|_/
    line = line.split(//).grep /[\d_]/
    line.map! {|cell_value| cell_value == '_' ? nil : cell_value.to_i}
    lines << line
end

s = Sudoku.new(lines)

# 9.times do
#     s.iterate_rows
#     s.iterate_columns
#     s.iterate_squares
# end

#pp s.rows.map {|row| row.map {|cell| v = cell.value}}
#pp s.rows.map {|row| row.map {|cell| v = cell.possibilities}}
