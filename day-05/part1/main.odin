package main

import sa "core:container/small_array"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:time"

@(rodata)
PUZZLE_INPUT := string(#load("input.txt"))

// input data set has at most 24 possible for each one (for some reason)
// this way it's more memory efficient
Rule_Map :: map[int]sa.Small_Array(24, u8)
Update_List :: [dynamic]int

load_input_data :: proc(rule_map: ^Rule_Map, lists: ^[dynamic]Update_List) {
	rule_count, update_list_count: int
	rules_finished: bool

	puzzle_input := PUZZLE_INPUT[:]
	for line in strings.split_lines_iterator(&puzzle_input) {
		if line == "" {
			rules_finished = true
			continue
		}

		if !rules_finished {
			rule_count += 1
		} else {
			update_list_count += 1
		}
	}
	rules_finished = false

	rule_map^ = make(Rule_Map, rule_count)
	lists^ = make([dynamic]Update_List, 0, update_list_count)

	puzzle_input = PUZZLE_INPUT[:]
	for line in strings.split_lines_iterator(&puzzle_input) {
		if line == "" {
			rules_finished = true
			continue
		}

		if !rules_finished {
			page, before: int
			start, end: int

			is_first := true

			for c_rune, idx in line {
				if '0' <= c_rune && c_rune <= '9' {
					end += 1
				}

				if c_rune == '|' || idx == len(line) - 1 {
					if is_first {
						parse_ok: bool
						page, parse_ok = strconv.parse_int(line[start:end])
						if !parse_ok {
							fmt.eprintfln(
								"Could not parse this string as a number: '%v'",
								line[start:end],
							)
							os.exit(1)
						}

						start = idx + 1
						end = idx + 1
						is_first = false
					} else {
						parse_ok: bool
						before, parse_ok = strconv.parse_int(line[start:end])
						if !parse_ok {
							fmt.eprintfln(
								"Could not parse this string as a number: '%v'",
								line[start:end],
							)
							os.exit(1)
						}
					}
				}
			}

			if page not_in rule_map {
				rule_map[page] = {}
			}
			before_list := &rule_map[page]
			sa.append(before_list, cast(u8)before)

		} else {
			start, end: int

			append(lists, make(Update_List))
			list := &lists[len(lists) - 1]

			for c_rune, idx in line {
				if '0' <= c_rune && c_rune <= '9' {
					end += 1
				}

				if c_rune == ',' || idx == len(line) - 1 {
					value, parse_ok := strconv.parse_int(line[start:end])
					if !parse_ok {
						fmt.eprintfln(
							"Could not parse this string as a number: '%v'",
							line[start:end],
						)
						os.exit(1)
					}
					start = idx + 1
					end = idx + 1

					append(list, value)
				}
			}
		}
	}
}

main :: proc() {
	time_begin := time.tick_now()

	answer := 0

	lists: [dynamic]Update_List
	rule_map: Rule_Map

	load_input_data(&rule_map, &lists)

	seen_set := make(map[int]struct {})

	for list in lists {
		list_invalid: bool

		for page in list {
			seen_set[page] = {}

			if page in rule_map {
				before_list := &rule_map[page]

				for before in before_list.data[:before_list.len] {
					if cast(int)before in seen_set {
						list_invalid = true
						break
					}
				}
			}
		}
		clear(&seen_set)


		if !list_invalid {
			answer += list[len(list) / 2]
		}
	}


	fmt.println("took", time.tick_since(time_begin))
	fmt.println("The answer is:", answer)
}
