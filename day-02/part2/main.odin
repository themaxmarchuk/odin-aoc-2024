package main

import sa "core:container/small_array"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:time"

@(rodata)
PUZZLE_INPUT := string(#load("input.txt"))

check_row :: proc(row_data: sa.Small_Array(32, int), skip_index := -1) -> bool {
	row_data := row_data
	if skip_index >= 0 {
		sa.ordered_remove(&row_data, skip_index)
	}
	unsafe, decreasing, saw_direction: bool

	check_levels: for idx in 0 ..< sa.len(row_data) {
		have_next := idx + 1 < sa.len(row_data)

		current := sa.get(row_data, idx)
		next := have_next ? sa.get(row_data, idx + 1) : {}

		if have_next {
			if !saw_direction {
				saw_direction = true

				if current > next {
					decreasing = true
				}
			}

			if current == next {
				unsafe = true
				break
			}

			if current > next {
				if !decreasing {
					unsafe = true
					break
				}
			} else {
				if decreasing {
					unsafe = true
					break
				}
			}

			diff := abs(current - next)

			if diff > 3 {
				unsafe = true
				break
			}
		}
	}

	if !unsafe {
		return true
	}

	return false
}

main :: proc() {
	time_begin := time.tick_now()

	puzzle_input := PUZZLE_INPUT[:]

	safe_reports := 0

	check_report: for line in strings.split_lines_iterator(&puzzle_input) {
		start := 0
		end := 0

		row_data: sa.Small_Array(32, int)

		for c_rune, idx in line {
			end += 1
			is_last := idx == len(line) - 1

			if c_rune == ' ' || is_last {
				chunk := is_last ? line[start:end] : line[start:end - 1]
				number, parse_ok := strconv.parse_int(chunk)
				if !parse_ok {
					fmt.eprintln("Failed to parse this line as an int:")
					fmt.eprintfln(
						"start = %v end = %v string = '%v'",
						start,
						end,
						line[start:end - 1],
					)
					fmt.eprintln(line)
					for i in 0 ..< end {
						fmt.eprint(' ')
					}
					fmt.eprint('^')

					os.exit(1)
				}

				sa.append(&row_data, number)
				start = end
			}
		}

		if check_row(row_data) {
			safe_reports += 1
		} else {
			is_safe: bool

			// very brute force I know, I tried the memory efficient way to do it, I really did
			// but skill issue I could not solve it that way, so I chose the brute force way, I was
			// pissed off, so it's fitting, still runs in 1ms though
			//
			// this does multiple copies for every single iteration :( but at least it works
			for idx in 0 ..< sa.len(row_data) {
				if check_row(row_data, idx) {
					is_safe = true
					break
				}
			}

			if is_safe {
				safe_reports += 1
			}
		}
	}


	fmt.println("took", time.tick_since(time_begin))

	fmt.println("Safe reports:", safe_reports)
}
