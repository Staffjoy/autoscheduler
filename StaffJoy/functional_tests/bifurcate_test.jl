function bifurcate_test_functional()
    employees = Dict() # no employees :-)
    ok, shifts = bifurcate_unassigned_scheduler(test_delivery_unassigned_env)
    @test week_sum_coverage(test_delivery_unassigned_env) * TEST_THRESHOLD > week_hours_scheduled(shifts)
end
