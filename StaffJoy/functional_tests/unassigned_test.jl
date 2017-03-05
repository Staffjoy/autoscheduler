function unassigned_test_functional()
    test_delivery_unassigned_functional()
end

function test_delivery_unassigned_functional()
    employees = Dict() # no employees :-)
    ok, weekly_schedule = schedule(employees, test_delivery_unassigned_env)
    @test ok
end
