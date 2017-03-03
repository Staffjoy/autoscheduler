function unassigned_test_unit()
    test_is_unassigned_shift_success()
    test_is_unassigned_shift_failure()
    test_meet_base_coverage_sufficient()
    test_meet_base_coverage_generate()
    test_meet_base_coverage_empty_employees()
    test_meet_unassigned_base_coverage()
end

function test_is_unassigned_shift_success()
    # Run it a few times - it generates randomly
    for i in 1:20
        name, employee = generate_unassigned_shift({
            "shift_time_min" => 4,
            "shift_time_max" => 8,
            "coverage" => Array[[2,3,4,],[1,2,3],[1,0,0]],
        })

        @test is_unassigned_shift(name)
    end
end

function test_is_unassigned_shift_failure()
    not_unassigned_shifts = Any[
        "Lenny",
        "Lenny Euler",
        "1",
        1,
        "StaffJoy.com rocks",
        "-1",
    ]

    for s in not_unassigned_shifts
        @test !is_unassigned_shift(s)
    end
end

function test_meet_base_coverage_sufficient()
    # Enough coverage - don't need to generate any more shifts
    # We'll use tests we know pass in functional testing
    new_employees = meet_base_coverage(test_bike_week_1_env, test_bike_week_1_employees)


    @test length(new_employees) == length(test_bike_week_1_employees)
end

function test_meet_base_coverage_generate()
    employees = {
        "Lenny" => {
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
    }
    new_employees = meet_base_coverage(test_bike_week_1_env, employees)
    @test length(new_employees) > length(employees)
    for e in keys(new_employees)
        if !(e in keys(employees))
            @test is_unassigned_shift(e)
        end
    end
end

function test_meet_base_coverage_empty_employees()
    # Test again with null employees
    employees = Dict()
    new_employees = meet_base_coverage(test_bike_week_1_env, employees)
    @test length(new_employees) > 0
    for e in keys(new_employees)
        @test is_unassigned_shift(e)
    end
end

function test_meet_unassigned_base_coverage()
    env = {
        "coverage" => Array[
            [1, 1, 1, 1, 1],
            [2, 2, 2, 2, 2],
            [3, 3, 3, 3, 3],
        ],
        "shift_time_min" => 1,
        "shift_time_max" => 3,
    }
    day = 2
    expected_max = 10
    expected_min = 4

    employees = meet_unassigned_base_coverage(env, day)
    shift_count = length(employees)
    @test shift_count > expected_min
    @test shift_count < expected_max
    for name in keys(employees)
        @test is_unassigned_shift(name)
    end
end
