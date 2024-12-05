package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:time"

@(rodata)
PUZZLE_INPUT := string(#load("input.txt"))

Puzzle_Board :: struct {
	data:   [dynamic]u8,
	width:  int,
	height: int,
}

get_width_and_height :: proc(input: string) -> (width: int, height: int) {
	input := input

	line_count, line_length: int

	for line in strings.split_lines_iterator(&input) {
		if line_length > 0 && line_length != len(line) {
			fmt.eprintfln("Line %v has an abnormal line length...", line_count + 1)
			os.exit(1)
		}

		if line_count == 0 {
			line_length = len(line)
		}

		line_count += 1
	}

	return line_length, line_count
}

make_puzzle_board :: proc(input: string) -> Puzzle_Board {
	input := input
	width, height := get_width_and_height(input)

	data := make([dynamic]u8, 0, width * height)
	for line in strings.split_lines_iterator(&input) {
		append(&data, line)
	}
	return Puzzle_Board{data, width, height}
}

char_at :: #force_inline proc "contextless" (pb: Puzzle_Board, x, y: int) -> rune {
	return cast(rune)pb.data[(x * pb.width) + y]
}

Direction :: enum {
	Up,
	Down,
	Left,
	Right,
	Top_Right,
	Top_Left,
	Bottom_Right,
	Bottom_Left,
}

check_match :: proc "contextless" (pb: Puzzle_Board, x, y: int, direction: Direction) -> bool {
	switch direction {
	case .Up:
		if char_at(pb, x, y - 1) == 'M' &&
		   char_at(pb, x, y - 2) == 'A' &&
		   char_at(pb, x, y - 3) == 'S' {
			return true
		}
	case .Down:
		if char_at(pb, x, y + 1) == 'M' &&
		   char_at(pb, x, y + 2) == 'A' &&
		   char_at(pb, x, y + 3) == 'S' {
			return true
		}
	case .Left:
		if char_at(pb, x - 1, y) == 'M' &&
		   char_at(pb, x - 2, y) == 'A' &&
		   char_at(pb, x - 3, y) == 'S' {
			return true
		}
	case .Right:
		if char_at(pb, x + 1, y) == 'M' &&
		   char_at(pb, x + 2, y) == 'A' &&
		   char_at(pb, x + 3, y) == 'S' {
			return true
		}
	case .Top_Right:
		if char_at(pb, x + 1, y - 1) == 'M' &&
		   char_at(pb, x + 2, y - 2) == 'A' &&
		   char_at(pb, x + 3, y - 3) == 'S' {
			return true
		}
	case .Top_Left:
		if char_at(pb, x - 1, y - 1) == 'M' &&
		   char_at(pb, x - 2, y - 2) == 'A' &&
		   char_at(pb, x - 3, y - 3) == 'S' {
			return true
		}
	case .Bottom_Right:
		if char_at(pb, x + 1, y + 1) == 'M' &&
		   char_at(pb, x + 2, y + 2) == 'A' &&
		   char_at(pb, x + 3, y + 3) == 'S' {
			return true
		}
	case .Bottom_Left:
		if char_at(pb, x - 1, y + 1) == 'M' &&
		   char_at(pb, x - 2, y + 2) == 'A' &&
		   char_at(pb, x - 3, y + 3) == 'S' {
			return true
		}
	}

	return false
}

main :: proc() {
	time_begin := time.tick_now()

	pb := make_puzzle_board(PUZZLE_INPUT)

	// fmt.println(PUZZLE_INPUT)

	matches_found := 0

	for x in 0 ..< pb.width {
		for y in 0 ..< pb.height {
			if char_at(pb, x, y) == 'X' {
				left := x - 3 >= 0
				right := x + 3 < pb.width
				down := y + 3 < pb.height
				up := y - 3 >= 0

				if left && check_match(pb, x, y, .Left) {
					matches_found += 1
				}
				if right && check_match(pb, x, y, .Right) {
					matches_found += 1
				}
				if down && check_match(pb, x, y, .Down) {
					matches_found += 1
				}
				if up && check_match(pb, x, y, .Up) {
					matches_found += 1
				}
				if up && right && check_match(pb, x, y, .Top_Right) {
					matches_found += 1
				}
				if up && left && check_match(pb, x, y, .Top_Left) {
					matches_found += 1
				}
				if down && left && check_match(pb, x, y, .Bottom_Left) {
					matches_found += 1
				}
				if down && right && check_match(pb, x, y, .Bottom_Right) {
					matches_found += 1
				}
			}

		}
	}

	// split the puzzle int chunks (by lines) and then give those to all threads, to find the
	// answer faster

	fmt.println("took", time.tick_since(time_begin))
	fmt.println("Matches found:", matches_found)
}
