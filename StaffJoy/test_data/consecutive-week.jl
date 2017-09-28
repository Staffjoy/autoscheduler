# A hypothetical env where consecutive days off are DEFINITELY possible
test_consecutive_env = Dict(
    "coverage"  => Array[
        [2*ones(Int,8)],
        [2*ones(Int,8)],
        [2*ones(Int,8)],
        [2*ones(Int,8)],
    ],
)

test_consecutive_employees = Dict(
    "a" => Dict(
        "hours_min" => 15,
        "hours_max" => 17,
        "shift_count_min" => 2,
        "shift_count_max" => 2,
        "availability"  => Array[
            [ones(Int,8)],
            [ones(Int,8)],
            [ones(Int,8)],
            [ones(Int,8)],
        ],
        "longest_availability" => 8*ones(Int, 8),
    ),
    "b" => Dict(
        "hours_min" => 15,
        "hours_max" => 17,
        "shift_count_min" => 2,
        "shift_count_max" => 2,
        "availability"  => Array[
            [ones(Int,8)],
            [ones(Int,8)],
            [ones(Int,8)],
            [ones(Int,8)],
        ],
        "longest_availability" => 8*ones(Int, 8),
    ),
    "c" => Dict(
        "hours_min" => 15,
        "hours_max" => 17,
        "shift_count_min" => 2,
        "shift_count_max" => 2,
        "availability"  => Array[
            [ones(Int,8)],
            [ones(Int,8)],
            [ones(Int,8)],
            [ones(Int,8)],
        ],
        "longest_availability" => 8*ones(Int, 8),
    ),
    "d" => Dict(
        "hours_min" => 15,
        "hours_max" => 17,
        "shift_count_min" => 2,
        "shift_count_max" => 2,
        "availability"  => Array[
            [ones(Int,8)],
            [ones(Int,8)],
            [ones(Int,8)],
            [ones(Int,8)],
        ],
        "longest_availability" => 8*ones(Int, 8),
    ),
)
