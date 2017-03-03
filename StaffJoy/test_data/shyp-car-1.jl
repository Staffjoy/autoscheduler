test_shyp_car_1_env = {
    "shift_time_min" => 3,
    "shift_time_max" => 8,
    "coverage"  => Array[ # 8AM->8PM
        # Monday
        [3, 3, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3],
        # Tuesday
        [3, 3, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3],
        # Wednesday
        [3, 3, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3],
        # Thursday
        [3, 3, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3],
        # Friday
        [3, 3, 4, 4, 4, 4, 4, 4, 3, 3, 3, 3],
        # Saturday
        [2, 3, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3],
        # Sunday
        [2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
    ],
    "time_between_coverage" => 12,
    "intershift" => 13, # Time periods between shifts
}

test_shyp_car_1_employees = {
	"Aaron Caramais" => {
		"hours_min" => 18,
		"hours_max" => 32,
	    "shift_count_max" => 5,
        "availability" => Array[
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [zeros(Int, 4), ones(Int, 8)],
            [ones(Int, 12)],
        ],
	},
	"Austin Wood" => {
		"hours_min" => 12,
		"hours_max" => 28,
	    "shift_count_max" => 5,
	    "availability" => Array[
            [ones(Int, 12)],
            [zeros(Int, 12)],
            [ones(Int, 12)],
            [zeros(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [zeros(Int, 6), ones(Int, 6)],
        ],
	}, 
	"Elliott Spelman" => {
		"hours_min" => 18,
		"hours_max" => 32,
	    "shift_count_max" => 5,
	    "availability" => Array[
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
        ],
	},
	"Greg Fleischut" => {
		"hours_min" => 18,
		"hours_max" => 32,
	    "shift_count_max" => 5,
	    "availability" => Array[
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
        ],
	},
	"Kimberly de Lara" => {
		"hours_min" => 24,
		"hours_max" => 32,
	    "shift_count_max" => 5,
	    "availability" => Array[
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 7), zeros(Int, 4), 1],
            [ones(Int, 7), zeros(Int, 4), 1],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
        ],
	},
	"Lewis Gallardo" => {
		"hours_min" => 24,
		"hours_max" => 32,
	    "shift_count_max" => 5,
	    "availability" => Array[
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
        ],
	},
	# Marian Espiritu didnt' show up in availability, but she worked every day
	"Matthew Stoops" => {
		"hours_min" => 18,
		"hours_max" => 32,
	    "shift_count_max" => 5,
	    "availability" => Array[
            [zeros(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
        ],
	},
	"MerryJo Pingul" => {
		"hours_min" => 6,
		"hours_max" => 18,
	    "shift_count_max" => 3,
	    "availability" => Array[
            [zeros(Int, 12)],
            [zeros(Int, 7), ones(Int, 5)],
            [zeros(Int, 7), ones(Int, 5)],
            [zeros(Int, 7), ones(Int, 5)],
            [zeros(Int, 12)],
            [zeros(Int, 12)],
            [zeros(Int, 12)],
        ],

	},
	"Penelope Whitney" => {
		"hours_min" => 12,
		"hours_max" => 32,
	    "shift_count_max" => 5,
	    "availability" => Array[
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [zeros(Int, 12)],
            [zeros(Int, 12)],
            [zeros(Int, 12)],
        ],
	},
	"Robert Fidel" => {
		"hours_min" => 18,
		"hours_max" => 32,
	    "shift_count_max" => 5,
	    "availability" => Array[
            [ones(Int, 12)],
            [zeros(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 10), zeros(Int, 2)],
            [ones(Int, 8), zeros(Int, 4)],
            [zeros(Int, 12)],
        ],


	},
	"Scott Wilcove" => {
		"hours_min" => 12,
		"hours_max" => 32,
	    "shift_count_max" => 5,
		"availability" => Array[
            [zeros(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [zeros(Int, 12)],
        ],
	},
}
