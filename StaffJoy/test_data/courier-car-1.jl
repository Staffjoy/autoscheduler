test_courier_car_1_env = Dict(
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
)

test_courier_car_1_employees = Dict(
	"Aaron" => Dict(
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
	),
	"Austin" => Dict(
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
	),
	"Elliott" => Dict(
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
	),
	"Greg" => Dict(
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
	),
	"Kimberly" => Dict(
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
	),
	"Lewis" => Dict(
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
	),
	"Matthew" => Dict(
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
	),
	"MerryJo" => Dict(
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

	),
	"Penelope" => Dict(
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
	),
	"Robert" => Dict(
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
	),
	"Scott" => Dict(
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
	),
)
