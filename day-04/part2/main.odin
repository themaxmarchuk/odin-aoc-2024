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

check_match :: proc "contextless" (pb: Puzzle_Board, x, y: int) -> bool {
	ab, dc: bool

	// a d
	//  x
	// c b
	a := char_at(pb, x - 1, y - 1)
	b := char_at(pb, x + 1, y + 1)
	c := char_at(pb, x - 1, y + 1)
	d := char_at(pb, x + 1, y - 1)

	if a == 'M' && b == 'S' {
		ab = true
	}
	if a == 'S' && b == 'M' {
		ab = true
	}
	if c == 'M' && d == 'S' {
		dc = true
	}
	if c == 'S' && d == 'M' {
		dc = true
	}

	return ab && dc
}

main :: proc() {
	time_begin := time.tick_now()

	pb := make_puzzle_board(PUZZLE_INPUT)

	matches_found := 0

	for x in 0 ..< pb.width {
		for y in 0 ..< pb.height {
			if char_at(pb, x, y) == 'A' {
				left := x - 1 >= 0
				right := x + 1 < pb.width
				down := y + 1 < pb.height
				up := y - 1 >= 0

				if up && down && left && right && check_match(pb, x, y) {
					matches_found += 1
				}
			}

		}
	}

	// split the puzzle int chunks (by lines) and then give those to all threads, to find the
	// answer faster, but it's fast af anyways so meh...

	fmt.println("took", time.tick_since(time_begin))
	fmt.println("Matches found:", matches_found)
}
