require 'pp'
logger = Logger.new('sudoku.log')

module Enumerable
  def dups
    inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1}.keys
  end
end

class Cell
  attr_accessor :possibilities
  POSSIBLE_VALUES = (1..9).to_a
  def initialize(*possibilities)
    self.possibilities = possibilities ? possibilities : POSSIBLE_VALUES
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
  def unsolved_values
    self.unsolved_cells.map {|cell| cell.possibilities}.flatten
  end
  def two_possibility_cell_values
    self.unsolved_cells.select {|cell| cell.possibilities.size == 2}.map {|cell| cell.possibilities }
  end
  def remove_solved_values_from_possibilities
    self.unsolved_cells.each do |cell|
      cell.possibilities = (cell.possibilities - self.solved_values)
      cell.value ? logger.
    end
  end
  def fill_in_unique_possibilities
    unique_unsolved_values = self.unsolved_values_count.keys.select {|unsolved_value|
      self.unsolved_values_count[unsolved_value] == 1
    }
    unique_unsolved_values.each do |val|
      self.unsolved_cells.each do |cell|
        if cell.possibilities.include? val
          cell.possibilities = [val]
        end
      end
    end
  end
  def duplicate_solved_values
    self.solved_values.dups
  end
  def unsolved_values_count
    self.unsolved_values.inject(Hash.new(0)) {|counter_hash, unsolved_value| counter_hash[unsolved_value] += 1; counter_hash }
  end
  def iterate
    raise "A value appears twice.  Either the solver is broken or the puzzle is flawed" if self.has_same_solved_value_twice?
    self.remove_solved_values_from_possibilities
    self.fill_in_unique_possibilities
#     two_possibility_cell_values = self.unsolved_cells.select {|cell| cell.possibilities.size == 2}.map {|cell| cell.possibilities }
#     more_possibility_cells = self.unsolved_cells.select {|cell| cell.possibilities.size > 2}
#       pp more_possibility_cells.map {|cell| cell.possibilities}
#     more_possibility_cells.each do |more_possibility_cell|
#         two_possibility_cell_values.dups.each do |two_possibilities|
#             more_possibility_cell.possibilities = more_possibility_cell.possibilities - two_possibilities
#         end
#     end
#     unique_unsolved_values = unsolved_values_count.select {|k, v| v == 1}.map {|val_array| val_array[0]}
#     #pp unique_unsolved_values unless unique_unsolved_values.empty?
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
  def reasons_invalid
    reasons = []
    %w{rows columns squares}.each do |group_type|
      self.send(group_type).each_with_index do |cell_group, i|
        CellGroup.new(cell_group).duplicate_solved_values.each do |dup|
          reasons << "#{group_type} #{i+1} has the value #{dup} more than once"
        end
      end
    end
    reasons
  end
end

#lines = []
#File.open('sudoku.txt').each_line do |line|
#    next unless line =~ /\d|_/
#    line = line.split(//).grep /[\d_]/
#    line.map! {|cell_value| cell_value == '_' ? nil : cell_value.to_i}
#    lines << line
#end

#s = Sudoku.new(lines)
#
#9.times do
#  s.iterate_rows
#  s.iterate_columns
#  s.iterate_squares
#  pp s.rows.map {|row| row.map {|cell| v = cell.value}}
#  #pp s.rows.map {|row| row.map {|cell| v = cell.possibilities}}
#end

