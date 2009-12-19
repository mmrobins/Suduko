require 'sudoku'

describe Cell do
  it "should fill in value if only one possibility" do
    cell = Cell.new
    cell.possibilities.should == (1..9).to_a
    cell.value.should == nil
    cell.possibilities = [2]
    cell.value.should == 2
  end

  it "should fill in value if initialized with only one possibility" do
    cell = Cell.new(3)
    cell.possibilities.should == [3]
    cell.value.should == 3
  end
end

describe CellGroup do
  it "should fill in only empty cell in a cell group" do
    solved_cells = (1..7).map {|num| Cell.new(num)}
    unsolved_cells = [ Cell.new, Cell.new ]

    cell_group = CellGroup.new(solved_cells + unsolved_cells)
    cell_group.solved_values.should == (1..7).to_a
    cell_group.solved_cells.should == solved_cells
    cell_group.unsolved_cells.should == unsolved_cells

    cell_group.remove_solved_values_from_possibilities
    cell_group.unsolved_cells.first.possibilities.should == [8,9]

    cell_group.unsolved_cells.first.possibilities = [9]
    cell_group.solved_values.should == (1..7).to_a + [9]
    cell_group.unsolved_cells.size.should == 1
    cell_group.unsolved_cells.first.possibilities.should == [8,9]

    cell_group.remove_solved_values_from_possibilities
    cell_group.solved_cells.size.should == 9
    cell_group.solved_values.sort.should == (1..9).to_a
    cell_group.unsolved_cells.size.should == 0
  end
  it "remove possibility from cell if other cell in group has that value" do
    cell_group = CellGroup.new([
      Cell.new,
      Cell.new(1)
    ])
    cell_group.remove_solved_values_from_possibilities
    cell_group.map {|cell| cell.possibilities }.should == [
      [2, 3],
      [1]
    ]
  end
end

describe Sudoku do
  before do
    @unsolved = Sudoku.new([
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
    ])
  end
  it "should take an array or arrays and convert to arrays of cells" do
    @unsolved.rows.map{|row| row.map {|cell| cell.value}}.should == [
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 5, 6, 7, 8, 9],
    ]
    @unsolved.columns.map {|col| col.map {|cell| cell.value}}.should == [
      [1, 1, 1, 1, 1, 1, 1, 1, 1],
      [2, 2, 2, 2, 2, 2, 2, 2, 2],
      [3, 3, 3, 3, 3, 3, 3, 3, 3],
      [4, 4, 4, 4, 4, 4, 4, 4, 4],
      [5, 5, 5, 5, 5, 5, 5, 5, 5],
      [6, 6, 6, 6, 6, 6, 6, 6, 6],
      [7, 7, 7, 7, 7, 7, 7, 7, 7],
      [8, 8, 8, 8, 8, 8, 8, 8, 8],
      [9, 9, 9, 9, 9, 9, 9, 9, 9],
    ]
    @unsolved.squares.map {|squ| squ.map {|cell| cell.value}}.should == [
      [1, 2, 3, 1, 2, 3, 1, 2, 3],
      [4, 5, 6, 4, 5, 6, 4, 5, 6],
      [7, 8, 9, 7, 8, 9, 7, 8, 9],
      [1, 2, 3, 1, 2, 3, 1, 2, 3],
      [4, 5, 6, 4, 5, 6, 4, 5, 6],
      [7, 8, 9, 7, 8, 9, 7, 8, 9],
      [1, 2, 3, 1, 2, 3, 1, 2, 3],
      [4, 5, 6, 4, 5, 6, 4, 5, 6],
      [7, 8, 9, 7, 8, 9, 7, 8, 9],
    ]
  end
end
