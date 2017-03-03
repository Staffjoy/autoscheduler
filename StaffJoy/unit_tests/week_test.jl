function week_test_unit()
    test_shift_count_validation()
    test_consecutive()
    test_consecutive_with_preceding()
    test_week_with_day_off()
    test_shyp_incorrect_availability()
end

function test_shift_count_validation()
    # Shift counts have to be reasonable

    # Setup
    env = {
        "coverage"  => Array[
            [1*ones(Int, 8)],
            [1*ones(Int, 8)],
            [zeros(Int, 8)],
        ],
        "time_between_coverage" => 12,
    }

    # Shift count infeasible
    employees = {
        "a" => {
            "hours_min" => 14,
            "hours_max" => 18,
            "shift_count_min" => 2,
            "shift_count_max" => 2,
            "availability"  => Array[
                [ones(Int,8)],
                [ones(Int,8)],
                [zeros(Int,8)],
            ],
            "longest_availability" => 8*ones(Int, 8),
        },
    }

    # (don't overwrite our good variables)
    ok, message, _ = build_week(employees, env)
    # It should require shift_time_min and shift_time_max
    @test(!ok)

    env["shift_time_min"] = 7
    env["shift_time_max"] = 9
    ok, employees, env = build_week(employees, env)
    @test(ok)
    ok, message = validate_input(employees, env)
    @test(ok)

    # shift_count_min has to be in bounds
    employees["a"]["shift_count_min"] = 3
    ok, message = validate_input(employees, env)
    @test(!ok)

    # shift_count_max has to be shorter than week
    employees["a"]["shift_count_min"] = 2 # revert
    employees["a"]["shift_count_max"] = 4
    ok, message = validate_input(employees, env)
    @test(!ok)

    # Test hours constraint
    employees["a"]["shift_count_max"] = 3
    ok, message = validate_input(employees, env)
    @test(!ok)
end

function test_consecutive()
    # Make sure consecutive shifts work
    ok, _ = assign_employees_to_days(test_consecutive_employees, test_consecutive_env, true)
    @test ok == true
end

function test_consecutive_with_preceding()
    # Make sure consecutive_with_preceding shifts work
    ok, employees = assign_employees_to_days(test_consecutive_with_preceding_employees, test_consecutive_with_preceding_env, true)
    @test ok == true
    # It's set up so "e" muet work these days
    @test employees["e"]["days_assigned"][1] == 0
    @test employees["e"]["days_assigned"][2] == 1
    @test employees["e"]["days_assigned"][3] == 1
    @test employees["e"]["days_assigned"][4] == 0
end

function test_week_with_day_off()
    consec_days_off = false # by design
    empty_day = 3 # when there is zero coverage
    ok, employees = assign_employees_to_days(test_day_off_employees, test_day_off_env, consec_days_off)
    @test ok == true
    for e in keys(employees)
        @test employees[e]["days_assigned"][empty_day] == 0
    end
end
