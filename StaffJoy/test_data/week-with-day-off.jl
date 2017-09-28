# A hypothetical env where one day requires no coverage
test_day_off_env = Dict(
    "coverage"  => Array[
        [2*ones(Int,8)],
        [2*ones(Int,8)],
        [zeros(Int,8)],
        [2*ones(Int,8)],
    ],
)

test_day_off_employees = Dict(
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
)
