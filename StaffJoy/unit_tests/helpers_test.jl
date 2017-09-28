function helpers_test_unit()
    test_longest_consecutive()
    test_anneal_availability()
    test_get_day_bounds()
    test_get_longest_availability()
    test_sub_array()
    test_days_available_per_week()
    test_day_sum_coverage()
    test_week_sum_coverage()
    test_day_hours_scheduled()
    test_week_hours_scheduled()
end

function test_longest_consecutive()
    test_cases = [
        # (input, expected)
        ([1 1 1 1 1 0 0 1 1], 5),
        ([0 1 1 1 1 0 0 1 1], 4),
        (zeros(Int, 8), 0),
        (ones(Int, 10), 10),
        ([1 1 1 0 1 1 1 0 0 1 1], 3),
        ([1 1 0 1 1 1 0 0 1 1], 3),
        (ones(Int, 12), 12)
    ]

    for case in test_cases
        input, expected = case
        @test longest_consecutive(input) == expected
    end
end


function test_anneal_availability()
    test_cases = [
        # (avail, length, expected)
        (
            [1 1 1 1 1 0 0 1 1 0],
            5,
            [1 1 1 1 1 0 0 0 0 0]
        ),
        ([1 1 1 1 1 0 0 1 1], 5, [1 1 1 1 1 0 0 0 0]),
        ([1 1 1 1 1 0 1 1 1], 3, [1 1 1 1 1 0 1 1 1]),
        ([1 1 1 1], 4, [1 1 1 1]),
        ([1 1 1 1], 3, [1 1 1 1]),
        ([1 1 1 1 0 0 0 0 1 1 1 1 0 0 0], 4, [1 1 1 1 0 0 0 0 1 1 1 1 0 0 0]),
        ([1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0], 5, zeros(Int, 15)),
        ([0, 0, 1, 1, 1, 0, 1, 0], 3, [0, 0, 1, 1, 1, 0, 0, 0]),
        ([zeros(Int, 2), ones(Int, 10)], 10, [zeros(Int, 2), ones(Int, 10)]),
        (
            [[1, 1, 1, 1, 1, 0, 0, 1, 1, 0] [1, 1, 1, 1, 1, 0, 0, 1, 1, 0];],
            5,
            [[1, 1, 1, 1, 1, 0, 0, 0, 0, 0] [1, 1, 1, 1, 1, 0, 0, 0, 0, 0]]
        ),
    ]

    for case in test_cases
        avail, length, expected = case
        @test anneal_availability(avail, length) == expected
    end
end

function test_get_day_bounds()
    # Test a week where min requires you to assign full amount
    # to each day
    min, max = get_day_bounds(
        [8, 4, 3, 3, 3],
        [1, 1, 1, 1, 1],
        0,
        20,
        23,
        3
    )

    @test max == 8
    @test min == 7

    min, max = get_day_bounds(
        [4, 3, 3, 3],
        [1, 1, 1, 1],
        7,
        20,
        23,
        3
    )

    @test max == 4
    @test min == 4

    min, max = get_day_bounds(
        [3],
        [1],
        19,
        20,
        23,
        3
    )

    @test max == 3
    @test min == 3

    min, max = get_day_bounds(
        [5, 8, 8, 8],
        [1, 1, 0, 1],
        0,
        0,
        9,
        3,
    )

    @test max == 3
    @test min == 3

    min, max = get_day_bounds(
        [8, 8, 8],
        [1, 0, 1],
        3,
        0,
        9,
        3,
    )

    @test max == 3
    @test min == 3

    min, max = get_day_bounds(
        [8],
        [1],
        6,
        0,
        9,
        3,
    )

    @test max == 3
    @test min == 3

end

function test_get_longest_availability()
    day = 1
    employee = Dict(
        "availability" => Array[
            [0, 1, 1, 1, 1, 0], # Don't trigger bounds
            [0, 1, 1, 0, 0, 0], # trigger min
            [1, 1, 1, 1, 1, 1], # trigger max
        ],
        "shift_time_min" => 3,
        "shift_time_max" => 5,
    )

    @test get_longest_availability(employee, 1) == 4
    @test get_longest_availability(employee, 2) == 0
    @test get_longest_availability(employee, 3) == employee["shift_time_max"]

end

function test_sub_array()
    array = [1, 2, 3, 4, 5]

    @test sub_array(array, 1, 5) == [1, 2, 3, 4, 5]
    @test sub_array(array, 2, 1) == [[2, 3, 4, 5], [1]]
    @test sub_array(array, 3, 2) == [[3, 4, 5], [1, 2]]
    @test sub_array(array, 1, 1) == [1]
end

function test_days_available_per_week()
    lenny = Dict(
        "shift_time_min" => 4,
        "shift_time_max" => 6,
        "hours_min" => 16, # hours worked over simulation
        "hours_max" => 25, # hours worked over simulation
        "shift_count_min" => 4,
        "shift_count_max" => 5,
        "availability" => Array[
            [ones(Int, 7), zeros(Int, 5)],
            [ones(Int, 7), zeros(Int, 5)],
            [zeros(Int, 12)],
            [ones(Int, 7), zeros(Int, 5)],
            [zeros(Int, 5), ones(Int, 3), zeros(Int, 4)], # Annealed out
            [zeros(Int, 12)],
            [zeros(Int, 12)],
        ],
    )

    @test days_available_per_week(lenny) == 3
end

function test_day_sum_coverage()
    test_env = Dict(
        "coverage"  => [3, 4, 5 * ones(Int, 6), 4 * ones(Int, 2), 2 * ones(Int, 2)],
        "cycle_length" => 12,
    )
    expected = 49
    @test day_sum_coverage(test_env) == expected
end

function test_week_sum_coverage()
    test_env = Dict(
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

    expected = 49*5 + 23*2
    @test week_sum_coverage(test_env) == expected
end
function test_day_hours_scheduled()
    schedule = Dict(
        "bob" => Dict(
            "start" => 8,
            "length" => 13,
        ),
        "joe" => Dict(
            "start" => 1,
            "length" => 30,
        )
    )

    expected = 43
    @test day_hours_scheduled(schedule) == expected
end
function test_week_hours_scheduled()
    schedule = Dict(
        "bob" => [
            Dict(
                "start" => 8,
                "length" => 13,
                "day" => 2,
            ),
            Dict(
                "start" => 0,
                "length" => 3,
                "day" => 2,
            ),
        ],
        "billy" => [
            Dict(
                "start" => 8,
                "length" => 19,
                "day" => 2,
            ),
            Dict(
                "start" => 0,
                "length" => 3,
                "day" => 2,
            ),
        ],
    )

    expected = 38
    @test week_hours_scheduled(schedule) == expected
end
