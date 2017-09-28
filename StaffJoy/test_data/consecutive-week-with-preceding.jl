test_consecutive_with_preceding_env = Dict(
    "coverage"  => Array[
        [2*ones(Int,8)],
        [3*ones(Int,8)],
        [3*ones(Int,8)],
        [2*ones(Int,8)],
    ],
)

test_consecutive_with_preceding_employees = Dict(
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
        "longest_availability" => 8*ones(Int, 4),
        "worked_day_preceding_week" => true,
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
        "longest_availability" => 8*ones(Int, 4),
        "worked_day_preceding_week" => true,
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
        "longest_availability" => 8*ones(Int, 4),
        "worked_day_preceding_week" => true,
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
        "longest_availability" => 8*ones(Int, 4),
        "worked_day_preceding_week" => true,
    ),
    "e" => Dict(
        # must be scheduled days 2->3, but gets consec day off due to
        # having worked the day preceding the week
        "hours_min" => 15,
        "hours_max" => 17,
        "shift_count_min" => 2,
        "shift_count_max" => 2,
        "availability"  => Array[
            [ones(Int,8)],
            [ones(Int,8)],
            [ones(Int,8)],
            [zeros(Int,8)],
        ],
        "longest_availability" => [8, 8, 8, 0],
        "worked_day_preceding_week" => false,
    ),
)
