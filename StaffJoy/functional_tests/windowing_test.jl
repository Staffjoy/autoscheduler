function windowing_test_functional()
    test_windowing_end_to_end()
end

function test_windowing_end_to_end()
    # Goal: Just run a schedule that needs a window and make sure it comes out as expected
    env = Dict(
        "shift_time_min" => 3,
        "shift_time_max" => 8,
        "coverage"  => Array[
            [0, 0, 1, 1, 1, 1, 1, 0, 0],
            [0, 0, 0, 1, 1, 1, 1, 1, 0],
        ],
        "time_between_coverage" => 12,
        "intershift" => 12, # Time periods between shifts   # only serve 1 shift/day
    )

    employees = Dict(
        "Lenny" => Dict(
            "hours_min" => 6, # hours worked over simulation
            "hours_max" => 16, # hours worked over simulation
            "shift_time_min" => 3,
            "shift_time_max" => 8,
            "shift_count_min" => 1,
            "shift_count_max" => 2,
            "availability" => Array[
                [ones(Int, 8)],
                [ones(Int, 8)],
            ],
        ),
    )

    ok, s = schedule(employees, env)
    @test ok

    # Check that the offsets weren't goofy :-)
    expected = Dict("Lenny"=>Dict(Dict("length"=>5,"day"=>1,"start"=>3),Dict("length"=>5,"day"=>2,"start"=>4)))
    @test expected == s
end
