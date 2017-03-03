function day_test_functional()
    test_shyp_bike_monday()
    test_prior_failure()
end

function test_shyp_bike_monday()
    ok, schedule = schedule_day(bike_monday_employees, bike_monday_env)
    @test ok == true
    @test day_sum_coverage(bike_monday_env) * TEST_THRESHOLD > day_hours_scheduled(schedule)
end

function test_prior_failure()
    ok, schedule = schedule_day(test_prior_failure_employees, test_prior_failure_env)
    @test ok == true
    @test day_sum_coverage(test_prior_failure_env) * TEST_THRESHOLD > day_hours_scheduled(schedule)
end
