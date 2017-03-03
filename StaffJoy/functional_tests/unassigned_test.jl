function unassigned_test_functional()
    test_quiqup_unassigned_functional()
end

function test_quiqup_unassigned_functional()
    employees = Dict() # no employees :-)
    ok, weekly_schedule = schedule(employees, test_quiqup_unassigned_env)
    @test ok
end
