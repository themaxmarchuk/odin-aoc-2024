package main

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:thread"
import "core:time"

@(rodata)
PUZZLE_INPUT := string(#load("input.txt"))


sort_slice_proc :: proc(data: rawptr) {
	slice_to_sort := transmute(^[]int)data
	slice.sort(slice_to_sort^)
}

main :: proc() {
	time_begin := time.tick_now()

	total_distance: int

	left_list: [dynamic]int
	right_list: [dynamic]int

	puzzle_input := PUZZLE_INPUT[:]
	{
		line_count := 0

		for _ in strings.split_lines_iterator(&puzzle_input) {
			line_count += 1
		}

		left_list = make([dynamic]int, 0, line_count)
		right_list = make([dynamic]int, 0, line_count)
	}

	puzzle_input = PUZZLE_INPUT[:]
	// NOTE: Technically this can also be parallelized as well, one thread for each list while both
	// threads are reading the same data? Not quite sure if that is faster as likely it will not be
	// as cache efficient.
	for line in strings.split_lines_iterator(&puzzle_input) {
		// NOTE: This allocates here, but that is not needed
		// can just manually look for the separator and it will be faster without touching the
		// allocator.
		line_parts := strings.fields(line)

		left_side := line_parts[0]
		right_side := line_parts[1]

		left_number: int
		right_number: int
		{
			ok: bool
			left_number, ok = strconv.parse_int(left_side)
			if !ok {
				fmt.eprintln("Failed to parse a number from string: %v", left_side)
				os.exit(1)
			}
		}
		{
			ok: bool
			right_number, ok = strconv.parse_int(right_side)
			if !ok {
				fmt.eprintln("Failed to parse a number from string: %v", right_side)
				os.exit(1)
			}
		}

		append(&left_list, left_number)
		append(&right_list, right_number)
	}

	assert(len(left_list) == len(right_list))

	left_thread := thread.create_and_start_with_data(&left_list, sort_slice_proc)
	right_thread := thread.create_and_start_with_data(&right_list, sort_slice_proc)
	thread.join_multiple(left_thread, right_thread)

	for i in 0 ..< len(left_list) {
		// NOTE: really good use case for simd and parallelization here..
		total_distance = abs(left_list[i] - right_list[i])
	}

	fmt.println("Took", time.tick_since(time_begin))
	fmt.println("Total distance is", total_distance)
}
