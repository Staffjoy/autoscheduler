function windowing_test_unit()
    test_windowing_same_day_length()
    test_windowing_different_day_length()
    test_windowing_zero_day()
    test_windowing_noop()
end

function test_windowing_same_day_length()
    # Pulled from shyp 60 min data (Actual bike data aug 3 2015)
    input = Array[
        [0, 0, 0, 0, 2, 3, 4, 4, 4, 5, 4, 4, 4, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 2, 3, 4, 4, 4, 5, 4, 4, 4, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 2, 3, 4, 4, 4, 5, 4, 4, 4, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 2, 3, 4, 4, 4, 5, 4, 4, 4, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 2, 3, 4, 4, 4, 5, 4, 4, 4, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0]
    ]
    # (start_index, end_index, time_delta)
    expected = (5, 17, 11)

    actual = get_window(input)
    @test actual == expected
end

function test_windowing_different_day_length()
    # Pulled from shyp 60 min data (Actual bike data aug 3 2015)
    input = Array[
        [0, 0, 0, 2, 2, 3, 4, 4, 4, 5, 4, 4, 4, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 3, 4, 4, 4, 5, 4, 4, 4, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 2, 3, 4, 4, 0, 5, 4, 4, 4, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 2, 3, 4, 4, 4, 5, 4, 4, 4, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 2, 3, 4, 4, 4, 5, 4, 4, 4, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0]
    ]
    # (start_index, end_index, time_delta)
    expected = (4, 19, 8)

    actual = get_window(input)
    @test actual == expected
end

function test_windowing_zero_day()
    input = Array[
        [0, 0, 0, 0, 2, 3, 4, 4, 4, 5, 4, 4, 4, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 2, 3, 4, 4, 4, 5, 4, 4, 4, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 2, 3, 4, 4, 4, 5, 4, 4, 4, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 2, 3, 4, 4, 4, 5, 4, 4, 4, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 2, 3, 4, 4, 4, 5, 4, 4, 4, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0],
        # Zero day
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0]
    ]

    # (start_index, end_index, time_delta)
    expected = (5, 17, 11)

    actual = get_window(input)
    @test actual == expected
end

function test_windowing_noop()
    input = Array[
        [2, 3, 4, 4, 4, 5, 4, 4, 4, 4, 3, 2, 1],
        [2, 3, 4, 4, 4, 5, 4, 4, 4, 4, 3, 2, 1],
        [2, 3, 4, 4, 4, 5, 4, 4, 4, 4, 3, 2, 1],
        [2, 3, 4, 4, 4, 5, 4, 4, 4, 4, 3, 2, 1],
        [2, 3, 4, 4, 4, 5, 4, 4, 4, 4, 3, 2, 1],
        [1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1],
        [1, 1, 1, 2, 2, 2, 0, 2, 2, 2, 1, 1, 0]
    ]

    expected = (1, 13, 0)

    actual = get_window(input)
    @test actual == expected
end
