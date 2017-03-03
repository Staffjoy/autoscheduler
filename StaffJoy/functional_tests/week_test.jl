function week_test_functional()
    test_shyp_bike_1()
    test_shyp_car_1()
end

function test_shyp_bike_1()
    info("STARTING SHYP BIKE 1")
    ok, weekly_schedule = schedule(test_bike_week_1_employees, test_bike_week_1_env)
    @test ok == true
    @test week_sum_coverage(test_bike_week_1_env) * TEST_THRESHOLD > week_hours_scheduled(weekly_schedule)
    info("ENDING SHYP BIKE 1")

end

function test_shyp_car_1()
    info("STARTING SHYP CAR 1")
    ok, weekly_schedule = schedule(test_shyp_car_1_employees, test_shyp_car_1_env)
    @test ok == true
    @test week_sum_coverage(test_shyp_car_1_env) * TEST_THRESHOLD > week_hours_scheduled(weekly_schedule)
    info("ENDING SHYP CAR 1")
end

function test_shyp_incorrect_availability()
    info("STARTING SHYP INCORRECT AVAILABILITY LENGTH")
    ok, _ = schedule(test_bike_incorrect_availability_length_employees, test_bike_incorrect_availability_length_env)
    @test ok != true
    info("ENDING SHYP INCORRECT AVAILABILITY LENGTH")
end
