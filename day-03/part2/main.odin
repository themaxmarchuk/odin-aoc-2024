package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:time"

@(rodata)
PUZZLE_INPUT := string(#load("input.txt"))

Mul_Parser_State :: enum {
	M,
	U,
	L,
	Open_Paren,
	First_Number,
	Second_Number,
}

Do_Parser_State :: enum {
	D,
	O,
	Open_Paren,
	Close_Paren,
}

Dont_Parser_State :: enum {
	D,
	O,
	N,
	Apostrophe,
	T,
	Open_Paren,
	Close_Paren,
}

Multiply_Instruction :: [2]int

main :: proc() {
	time_begin := time.tick_now()

	puzzle_input := PUZZLE_INPUT[:]

	answer := 0

	inst_buffer := make([dynamic]Multiply_Instruction, 0, 64)

	mul_parser_enabled := true

	mul_state: Mul_Parser_State
	do_state: Do_Parser_State
	dont_state: Dont_Parser_State

	number_start: int
	number_end: int // exclusive

	number_slot_one, number_slot_two: int

	for c_rune, idx in puzzle_input {
		switch dont_state {
		case .D:
			if c_rune == 'd' {
				dont_state = .O
			} else {
				dont_state = {}
			}
		case .O:
			if c_rune == 'o' {
				dont_state = .N
			} else {
				dont_state = {}
			}
		case .N:
			if c_rune == 'n' {
				dont_state = .Apostrophe
			} else {
				dont_state = {}
			}
		case .Apostrophe:
			if c_rune == '\'' {
				dont_state = .T
			} else {
				dont_state = {}
			}
		case .T:
			if c_rune == 't' {
				dont_state = .Open_Paren
			} else {
				dont_state = {}
			}
		case .Open_Paren:
			if c_rune == '(' {
				dont_state = .Close_Paren
			} else {
				dont_state = {}
			}
		case .Close_Paren:
			if c_rune == ')' {
				mul_parser_enabled = false
				// fmt.println("Parsed a DONT instruction, parser disabled")
				dont_state = {}
			} else {
				dont_state = {}
			}
		}

		switch do_state {
		case .D:
			if c_rune == 'd' {
				do_state = .O
			} else {
				do_state = {}
			}
		case .O:
			if c_rune == 'o' {
				do_state = .Open_Paren
			} else {
				do_state = {}
			}
		case .Open_Paren:
			if c_rune == '(' {
				do_state = .Close_Paren
			} else {
				do_state = {}
			}
		case .Close_Paren:
			if c_rune == ')' {
				mul_parser_enabled = true
				do_state = {}
				// fmt.println("Parsed a DO instruction, parser enabled")
			} else {
				do_state = {}
			}
		}

		// fmt.printfln("rune = '%v' idx = %v do_state = %v", c_rune, idx, do_state)
		// fmt.printfln("rune = '%v' idx = %v dont_state = %v", c_rune, idx, dont_state)
		if mul_parser_enabled {
			// fmt.printfln(
			// 	"rune = '%v' idx = %v mul_state = %v (start: %v end: %v) slot (0 = %v 1 = %v)",
			// 	c_rune,
			// 	idx,
			// 	mul_state,
			// 	number_start,
			// 	number_end,
			// 	number_slot_one,
			// 	number_slot_two,
			// )
			switch mul_state {
			case .M:
				if c_rune == 'm' {
					mul_state = .U
				} else {
					mul_state = {}
				}
			case .U:
				if c_rune == 'u' {
					mul_state = .L
				} else {
					mul_state = {}
				}
			case .L:
				if c_rune == 'l' {
					mul_state = .Open_Paren
				} else {
					mul_state = {}
				}
			case .Open_Paren:
				if c_rune == '(' {
					mul_state = .First_Number
					number_start = idx + 1
					number_end = idx + 1
				} else {
					mul_state = {}
				}
			case .First_Number:
				if '0' <= c_rune && c_rune <= '9' {
					number_end += 1
				} else if c_rune == ',' {
					if number_end - number_start > 0 {
						number, parse_ok := strconv.parse_int(
							PUZZLE_INPUT[number_start:number_end],
						)
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
						mul_state = .Second_Number
					}
				} else {
					mul_state = {}
				}
			case .Second_Number:
				if '0' <= c_rune && c_rune <= '9' {
					number_end += 1
				} else if c_rune == ')' {
					if number_end - number_start > 0 {
						number, parse_ok := strconv.parse_int(
							PUZZLE_INPUT[number_start:number_end],
						)
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
						mul_state = {}
					}
				} else {
					mul_state = {}
				}
			}
		}
	}

	for inst in inst_buffer {
		answer += inst.x * inst.y
	}

	fmt.println("took", time.tick_since(time_begin))

	fmt.println("The answer is:", answer)
}
