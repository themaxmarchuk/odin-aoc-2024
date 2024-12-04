package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:time"

@(rodata)
PUZZLE_INPUT := string(#load("input.txt"))

main :: proc() {
	time_begin := time.tick_now()

	similarity_score: int

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

	left_map := make_map_cap(map[int]struct {}, len(left_list))
	right_map := make_map_cap(map[int]int, len(right_list))

	for num in left_list {
		left_map[num] = {}
	}

	for num in right_list {
		if num in left_map {
			right_map[num] += 1
		}
	}
	// NOTE: This can be parallelized though, because the results from each thread can just be
	// added, also simd can also be used here as well, can also try to get rid of the map lookups?
	for num, count in right_map {
		similarity_score += num * count
	}

	fmt.println("Took", time.tick_since(time_begin))
	fmt.println("The similarity score is:", similarity_score)
}
