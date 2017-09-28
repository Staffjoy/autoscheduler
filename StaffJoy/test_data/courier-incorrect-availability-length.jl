test_bike_incorrect_availability_length_env = Dict(
    "shift_time_min" => 3,
    "shift_time_max" => 8,
    "coverage"  => Array[
        # Monday
        [3, 4, 5 * ones(Int, 6), 4 * ones(Int, 2), 2 * ones(Int, 2)],
        # Tuesday
        [3, 4, 5 * ones(Int, 6), 4 * ones(Int, 2), 2 * ones(Int, 2)],
        # Wednesday
        [3, 4, 5 * ones(Int, 6), 4 * ones(Int, 2), 2 * ones(Int, 2)],
        # Thursday
        [3, 4, 5 * ones(Int, 6), 4 * ones(Int, 2), 2 * ones(Int, 2)],
        # Friday
        [3, 4, 5 * ones(Int, 6), 4 * ones(Int, 2), 2 * ones(Int, 2)],
        # Saturday
        [1, 2 * ones(Int, 11)],
        # Sunday
        [1, 2 * ones(Int, 11)],
    ],
    "time_between_coverage" => 12,
    "intershift" => 13, # Time periods between shifts   # only serve 1 shift/day
)

# Coverage requires 291 man hours

test_bike_incorrect_availability_length_employees = Dict(
    "Cody" => Dict(
        "hours_min" => 18, # hours worked over simulation
        "hours_max" => 32, # hours worked over simulation
        "shift_time_min" => 4,
        "shift_count_min" => 3,
        "shift_count_max" => 5,
        "availability" => Array[
            [ones(Int, 12)],
            [ones(Int, 12)],
            # One missing here :-P
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
        ],
    ),
    "Damian" => Dict(
        "hours_min" => 12, # hours worked over simulation
        "hours_max" => 28, # hours worked over simulation
        "intershift" => 4,
        "shift_count_min" => 2,
        "shift_count_max" => 4,
        "availability" => Array[
            [ones(Int, 5), zeros(Int, 7)],
            [ones(Int, 5), zeros(Int, 7)],
            [ones(Int, 5), zeros(Int, 7)],
            [ones(Int, 5), zeros(Int, 7)],
            [ones(Int, 5), zeros(Int, 7)],
            [zeros(Int, 12)],
            [zeros(Int, 12)],
        ],
    ),
    "David" => Dict(
        "hours_min" => 12, # hours worked over simulation
        "hours_max" => 18, # hours worked over simulation
        "shift_count_min" => 2,
        "shift_count_max" => 3,
        "availability" => Array[
            [zeros(Int, 12)],
            [zeros(Int, 2), ones(Int, 10)],
            [zeros(Int, 2), ones(Int, 10)],
            [zeros(Int, 2), ones(Int, 10)],
            [zeros(Int, 12)],
            [zeros(Int, 12)],
            [zeros(Int, 12)],
        ],
    ),
    "Douglas" => Dict(
        "hours_min" => 12, # hours worked over simulation
        "hours_max" => 28, # hours worked over simulation
        "shift_count_min" => 2,
        "shift_count_max" => 4,
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
    "Dylan" => Dict(
        # deliberately no shift count
        "hours_min" => 28, # hours worked over simulation
        "hours_max" => 32, # hours worked over simulation
        "shift_time_min" => 6,
        "shift_count_min" => 4,
        "shift_count_max" => 5,
        "availability" => Array[
            [ones(Int, 7), zeros(Int, 5)],
            [zeros(Int, 12)],
            [zeros(Int, 12)],
            [ones(Int, 7), zeros(Int, 5)],
            [ones(Int, 7), zeros(Int, 5)],
            [ones(Int, 7), zeros(Int, 5)],
            [ones(Int, 7), zeros(Int, 5)],
        ],
    ),
    "Jaeger" => Dict(
        "hours_min" => 18, # hours worked over simulation
        "hours_max" => 32, # hours worked over simulation
        "shift_count_min" => 3,
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
    "Julian" => Dict(
        "hours_min" => 28, # hours worked over simulation
        "hours_max" => 32, # hours worked over simulation
        "shift_count_min" => 4,
        "shift_count_max" => 5,
        "availability" => Array[
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [zeros(Int, 4), ones(Int, 8)],
        ],
    ),
    "Leonardo" => Dict(
        "hours_min" => 18, # hours worked over simulation
        "hours_max" => 32, # hours worked over simulation
        "shift_count_min" => 3,
        "shift_count_max" => 5,
        "availability" => Array[
            [ones(Int, 7), zeros(Int, 5)],
            [ones(Int, 7), zeros(Int, 5)],
            [ones(Int, 7), zeros(Int, 5)],
            [ones(Int, 7), zeros(Int, 5)],
            [ones(Int, 7), zeros(Int, 5)],
            [ones(Int, 7), zeros(Int, 5)],
            [ones(Int, 7), zeros(Int, 5)],
        ],
    ),
    "Patrick" => Dict(
        "hours_min" => 12, # hours worked over simulation
        "hours_max" => 32, # hours worked over simulation
        "shift_count_min" => 2,
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
    "Rufus" => Dict(
        "hours_min" => 12, # hours worked over simulation
        "hours_max" => 32, # hours worked over simulation
        "shift_count_min" => 2,
        "shift_count_max" => 5,
        "availability" => Array[
            [ones(Int, 8), zeros(Int, 4)],
            [ones(Int, 8), zeros(Int, 4)],
            [ones(Int, 8), zeros(Int, 4)],
            [ones(Int, 8), zeros(Int, 4)],
            [ones(Int, 8), zeros(Int, 4)],
            [ones(Int, 12)],
            [ones(Int, 12)],
        ],
    ),
    "Shaun" => Dict(
        "hours_min" => 18, # hours worked over simulation
        "hours_max" => 32, # hours worked over simulation
        "shift_count_min" => 3,
        "shift_count_max" => 5,
        "availability" => Array[
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [ones(Int, 12)],
            [zeros(Int, 2), ones(Int, 10)],
            [zeros(Int, 2), ones(Int, 10)],
        ],
    ),
)
