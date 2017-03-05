function week_test_functional()
    test_courier_bike_1()
    test_courier_car_1()
end

function test_courier_bike_1()
    info("STARTING COURIER BIKE 1")
    ok, weekly_schedule = schedule(test_bike_week_1_employees, test_bike_week_1_env)
    @test ok == true
    @test week_sum_coverage(test_bike_week_1_env) * TEST_THRESHOLD > week_hours_scheduled(weekly_schedule)
    info("ENDING COURIER BIKE 1")

end

function test_courier_car_1()
    info("STARTING COURIER CAR 1")
    ok, weekly_schedule = schedule(test_courier_car_1_employees, test_courier_car_1_env)
    @test ok == true
    @test week_sum_coverage(test_courier_car_1_env) * TEST_THRESHOLD > week_hours_scheduled(weekly_schedule)
    info("ENDING COURIER CAR 1")
end

function test_courier_incorrect_availability()
    info("STARTING COURIER INCORRECT AVAILABILITY LENGTH")
    ok, _ = schedule(test_bike_incorrect_availability_length_employees, test_bike_incorrect_availability_length_env)
    @test ok != true
    info("ENDING COURIER INCORRECT AVAILABILITY LENGTH")
end
