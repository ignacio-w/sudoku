# Sudoku

A Sudoku game built in Godot 4.6 (GDScript) with a puzzle generator that rates difficulty by the logical techniques a human would need to solve it, instead of by clue count.

**Play it:** [https://nachoc.itch.io/sudoku](url)

## Features

- Three difficulty levels (Easy, Medium, Hard) backed by a technique-based difficulty rater
- Every puzzle has exactly one solution
- Notes (pencil marks) mode, with automatic clearing of conflicting notes when a value is placed
- Undo (including notes cleared as a side effect), erase, and hint
- Pause menu with a blurred board, so the puzzle can't be studied while the timer is stopped
- Mistake counter and stopwatch
- Keyboard navigation: arrow keys move within the board, Tab moves between the board and the action buttons
- Puzzles are generated on a background thread and pooled ahead of time, with a loading screen as a fallback

## How difficulty works

Most generators estimate difficulty from the number of given clues. That is a weak proxy: a sparse puzzle can be solved with only obvious moves, and a denser one can require an advanced deduction depending on where the clues land.

This project instead runs a logical solver that never guesses. It tries techniques in order from easiest to hardest, and after every successful step it restarts from the easiest technique. A puzzle's difficulty is the hardest technique it was forced to use.

Implemented techniques, easiest to hardest:

1. Naked singles and hidden singles
2. Naked pairs and hidden pairs
3. Pointing pairs
4. Box/line reduction

The generator builds a solved grid, removes clues while keeping the solution unique and the puzzle at or below the difficulty's ceiling, then checks that the result reaches the difficulty's minimum tier. If it does not, it retries with a different removal order. A final pass restores some clues at random (without dropping below the minimum tier) so puzzles of the same difficulty vary in clue count.

## Performance

Measured over 100 seeded runs per difficulty, from a headless run of `generate()` directly (not through the puzzle pool). Zero failures in 300 runs.

| Difficulty | Median | p95 | Max | Mean attempts |
|---|---|---|---|---|
| Easy | 98 ms | 121 ms | 158 ms | 1 |
| Medium | 1.2 s | 6.0 s | 10.0 s | 8 |
| Hard | 6.9 s | 28.0 s | 33.9 s | 10 |

Test hardware: [CPU / RAM / OS]

Medium and Hard are slow mainly because of retries: each attempt reaches the required technique tier only about one time in ten. Per-attempt cost is roughly 0.2 s for Medium and 0.9 s for Hard. To keep this out of the player's way, generation runs on a background thread and a small pool of puzzles per difficulty is kept ready.

Optimizations that mattered:

- Minimum-remaining-value heuristic in the backtracking solver (always branch on the most constrained cell)
- Bitmask-based candidate calculation
- Solving the grid once and reusing it across removal attempts, since solving from scratch is the most expensive step

## Architecture

Game logic and UI are kept separate on purpose.

- **Logic layer** (`RefCounted` classes with no dependency on the scene tree): rules, solver, difficulty rater, generator, and the puzzle state. Because it never touches nodes, it can run safely on a background thread.
- **Scene layer**: a game controller that owns the puzzle state, a UI coordinator, the board and cells (which only display state), and an action bar. Scenes that are not directly parent and child communicate through a signal bus autoload instead of holding references to each other.
- **Threading**: the background thread only does pure computation. Results are handed back to the main thread with `call_deferred`, so shared state is only ever touched on the main thread.

## Running the project

1. Install [Godot 4.6](https://godotengine.org/download)
2. Open `project.godot` in the editor
3. Press F5 to run

### Running the benchmark

Open the project in the editor once (so Godot registers the `class_name` types), then from the project folder:

```
godot --headless --path . -s benchmark.gd
```

## Roadmap

- Daily streak counter
- Settings screen and themes
- Tutorial lessons that teach each solving technique
- Additional techniques (hidden triples, X-Wing) for a wider difficulty range

## License

[Choose a license, e.g. MIT]
