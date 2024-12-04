package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:time"

@(rodata)
PUZZLE_INPUT := string(#load("input.txt"))

Parser_State :: enum {
	M,
	U,
	L,
	Open_Paren,
	First_Number,
	Second_Number,
}


Multiply_Instruction :: [2]int

main :: proc() {
	time_begin := time.tick_now()

	puzzle_input := PUZZLE_INPUT[:]

	answer := 0

	inst_buffer := make([dynamic]Multiply_Instruction, 0, 64)
	state: Parser_State
	number_start: int
	number_end: int // exclusive

	number_slot_one, number_slot_two: int

	for c_rune, idx in puzzle_input {
		// fmt.printfln(
		// 	"rune = '%v' idx = %v state = %v (start: %v end: %v) slot (0 = %v 1 = %v)",
		// 	c_rune,
		// 	idx,
		// 	state,
		// 	number_start,
		// 	number_end,
		// 	number_slot_one,
		// 	number_slot_two,
		// )
		switch state {
		case .M:
			if c_rune == 'm' {
				state = .U
			} else {
				state = {}
			}
		case .U:
			if c_rune == 'u' {
				state = .L
			} else {
				state = {}
			}
		case .L:
			if c_rune == 'l' {
				state = .Open_Paren
			} else {
				state = {}
			}
		case .Open_Paren:
			if c_rune == '(' {
				state = .First_Number
				number_start = idx + 1
				number_end = idx + 1
			} else {
				state = {}
			}
		case .First_Number:
			if '0' <= c_rune && c_rune <= '9' {
				number_end += 1
			} else if c_rune == ',' {
				if number_end - number_start > 0 {
					number, parse_ok := strconv.parse_int(PUZZLE_INPUT[number_start:number_end])
					if !parse_ok {
						fmt.eprintfln(
							"Failed to parse this as a number: '%v'",
							PUZZLE_INPUT[number_start:number_end],
						)
						os.exit(1)
					}
					number_start = idx + 1
					number_end = idx + 1
					number_slot_one = number
					state = .Second_Number
				}
			} else {
				state = {}
			}
		case .Second_Number:
			if '0' <= c_rune && c_rune <= '9' {
				number_end += 1
			} else if c_rune == ')' {
				if number_end - number_start > 0 {
					number, parse_ok := strconv.parse_int(PUZZLE_INPUT[number_start:number_end])
					if !parse_ok {
						fmt.eprintfln(
							"Failed to parse this as a number: '%v'",
							PUZZLE_INPUT[number_start:number_end],
						)
						os.exit(1)
					}
					number_start = 0
					number_end = 0
					number_slot_two = number

					append(&inst_buffer, [2]int{number_slot_one, number_slot_two})
					// fmt.println("Read instruction: MUL", inst_buffer[len(inst_buffer) - 1])
					number_slot_one = 0
					number_slot_two = 0
					state = {}
				}
			} else {
				state = {}
			}
		}
	}

	for inst in inst_buffer {
		answer += inst.x * inst.y
	}

	fmt.println("took", time.tick_since(time_begin))

	fmt.println("The answer is:", answer)
}
