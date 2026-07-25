extends Node

var cur_difficulty: Sudoku.Difficulty

# Settings
var visual_guides: bool = true ## Number & note highlighing
var validate_inputs: bool = true ## Check if input is correct
var conflict_highlighting: bool = false ## If validate_inputs = false; should conflicts be highlighted?
