    function schedule(employees, env)
    # Wrap the scheduling in windowing!
    start_index, end_index, time_delta = get_window(env["coverage"])

    # Apply the window
    env["time_between_coverage"] += time_delta
    if "cycle_length" in keys(env)
        env["cycle_length"] -= time_delta
    end
    if "no_shifts_after" in keys(env)
        env["no_shifts_after"] -= time_delta
    end
    env["coverage"] = apply_window(env["coverage"], start_index, end_index)
    # todo - do we have a "time since last shift" at start of week?
    for e in keys(employees)
        employees[e]["availability"] = apply_window(employees[e]["availability"], start_index, end_index)
    end
    Logging.info( "Windowing removed $time_delta hours per day (start index $start_index / end index $end_index)")

    ok, shifts = run_schedule(employees, env)
    if !ok
        Logging.info( "Scheduling not ok at windower")
        return ok, Any[]
    end

    # Exit the window and return
    return ok, remove_window(shifts, start_index)
end

function run_schedule(employees, env)
    if length(employees) == 0
        Logging.info( "Switching to unassigned shifts mode")
        ok, shifts = run_schedule_unassigned(env)
    else
        ok, shifts = run_schedule_standard(employees, env)
    end
    return ok, shifts
end

function run_schedule_standard(employees, env)
    attempt = 1
    employees = meet_base_coverage(env, employees)

    @label schedule_start

    ok, employees, env = build_week(employees, env)
    if !ok
        Logging.info( "Build failed")
        return false, Any[]
    end

    ok, message = validate_input(employees, env)
    if !ok
        Logging.info( message)
        return false, Any[]
    end

    # Check days per week is large enough for consec
    if size(env["coverage"], 1) > 2
        # Schedule consec first, and do non-consec as a last resort
        consecutive = true
        ok, weekly_schedule_consecutive = schedule_week(employees, env, consecutive)
        if ok
            Logging.info( "Consecutive schedule passed.")
            return true, weekly_schedule_consecutive
        end
        Logging.info( "Consecutive schedule validation failed. Trying inconsecutive.")
    end

    consecutive = false
    ok, weekly_schedule = schedule_week(employees, env, consecutive)
    if ok
        return true, weekly_schedule
    end

    # Otherwise - make an unassigned shift and restart
    name, val = generate_unassigned_shift(env)
    Logging.info( "Unable to meet coverage. Adding an unassigned shift and repeating. (end of attempt $attempt)")
    employees[name] = val
    attempt += 1
    @goto schedule_start
end

function run_schedule_unassigned(env)
    total_hours = sum(sum(env["coverage"]))
    Logging.info( "Coverage total hours: $total_hours")
    if total_hours > BIFURCATE_THRESHOLD
        # Generate subproblems
        Logging.info( "Split env into sub problems")
        ok, shifts = bifurcate_unassigned_scheduler(env)
        if !ok
            Logging.err("Bifurcatin failed in unassigned shift")
        end
        return ok, shifts
    end

    # Schedule day by day
    week_length = size(env["coverage"], 1)
    week_employees = Dict()
    shifts = Dict()
    for day in 1:week_length
        Logging.info( "Starting day scheduler day $day of $week_length")
        # Build a day env
        day_env = deepcopy(env)
        day_env["coverage"] = env["coverage"][day]

        # Generate lots of shifts
        day_employees = meet_unassigned_base_coverage(env, day)


        ok = false
        attempt = 1
        # Define day_shifts up here due to scoping
        day_shifts = Dict()
        while !ok
            # Change week employees to day employees
            day_employees_filtered = Dict()
            for e in keys(day_employees)
                d = deepcopy(day_employees[e])
                d["availability"] = day_employees[e]["availability"][day]
                d["min"] = d["shift_time_min"]
                d["max"] = d["shift_time_max"]
                day_employees_filtered[e] = d
            end

            # Run day schedule
            ok, day_shifts = schedule_day(day_employees_filtered, day_env)

            if !ok
                Logging.info( "Unable to meet coverage. Adding an unassigned shift and repeating. (end of attempt $attempt on day $day)")
                name, val = generate_unassigned_shift(env)
                day_employees[name] = val
                attempt += 1
            end
        end

        # push for testing later
        for k in keys(day_employees)
            week_employees[k] = day_employees[k]
        end

        # Now we  have to do post-processing to adjust the day correctly
        for name in keys(day_shifts)
            shift =  day_shifts[name]
            # Being really careful
            shift["day"] = day
            if !(name in keys(shifts))
                shifts[name] = Any[]
            end
            push!(shifts[name], shift)
        end
    end

    ok, message= validate_schedule(week_employees, env, shifts)
    if !ok
        Logging.err("Unassigned shift schedule invalid after post-processing - $message")
    end
    return ok, shifts
end

function schedule_week(employees, env, consecutive)

    # Setup
    valid_schedules = Any[]
    prior_lift = false
    lift_ceiling = false
    weekly_schedule = Dict(Any,Any)
    start_day = 0
    start_time = time()
    perfect_optimality = week_sum_coverage(env)

    # Start the loop, captain!
    while (prior_lift == false || (prior_lift * LYFT_THROTTLE > MIN_LYFT))
        if (time() > start_time + ITERATION_TIMEOUT) && (length(valid_schedules) == 0)
            Logging.info("Iteration timeout hit")
            break
        end

        if (time() > start_time + SEARCH_TIMEOUT) && length(valid_schedules) > 0
            Logging.info("Search timeout hit")
            break
        end

        if prior_lift != false
            lift_ceiling = prior_lift * LYFT_THROTTLE
        end

        ok, employees, prior_lift = assign_employees_to_days(employees, env, consecutive, lift_ceiling)
        if !ok
            Logging.info( "consecutive $consecutive day assignment failed")
            break
        end

        # Set up parallel calculations
        calculations = Any[]

        # Only run one scheduler if it's a single day.
        if size(env["coverage"], 1) > 1
            methods = ["balanced", "greedy"]
        else
            methods = ["balanced"]
        end

        for start_day=1:size(env["coverage"], 1)
            for method in methods
                push!(calculations, Dict(
                    "start_day" => start_day,
                    "method" => method,
                    "employees" => employees,
                    "env" => env,
                ))
            end
        end

        results = pmap(schedule_by_day, calculations)
        lift_schedules = map(return_schedules, filter(valid_schedules_net, results))
        num = length(lift_schedules)
        Logging.info( "Found $num schedules this lift")
        for valid_schedule=lift_schedules
            hours = week_hours_scheduled(valid_schedule)
            if hours == perfect_optimality
                return true, valid_schedule
            end
            push!(valid_schedules, valid_schedule)
        end
    end

    if length(valid_schedules) == 0
        return false, Any[]
    end

    best_hours = 0
    best_schedule = None
    for test_schedule=valid_schedules
        test_hours = week_hours_scheduled(test_schedule)
        if (test_hours < best_hours) || (best_schedule == None)
            best_hours = test_hours
            best_schedule = test_schedule
        end
    end

    if best_schedule == None
        num = length(valid_schedules)
        Logging.info( "Found $num schedules")
        return false, Any[]
    end
    elapsed = (time() - start_time) / 60
    num_schedules = length(valid_schedules)
    hours = week_hours_scheduled(best_schedule)
    overage = (hours - perfect_optimality) / perfect_optimality
    Logging.info( "Full time took $elapsed minutes and ended at lift $prior_lift. Found $num_schedules valid schedules. Best overage $overage")
    return true, best_schedule

end

function build_week(employees, env)
    # First check for some required shit in the environment
    if !("shift_time_min" in keys(env))
        # turn employees into a message variable
        return false, "shift_time_min not in environment", Any[]
    end

    if !("shift_time_max" in keys(env))
        Logging.info( "shift_time_max not in environment")
        return false, Any[], Any[]
    end


    days_per_week = size(env["coverage"], 1)
    # Pick number of shifts per employee
    for e in keys(employees)

        # This has to be run now due to later function dependencies
        if (size(employees[e]["availability"], 1) != days_per_week)
            Logging.info( string("Employee ", e, " availability wrong number days per week"))
            return false, Any[], Any[]
        end

        # set employee to unavailable when coverage is 0
        for day in 1:days_per_week
            for t in size(env["coverage"][day])
                if env["coverage"][day][t] == 0
                    employees[e]["availability"][day][t] = 0
                end
            end
        end

        # shift time
        if !("shift_time_min" in keys(employees[e]))
            # inherit from env if not defined
            employees[e]["shift_time_min"] = env["shift_time_min"]
        end

        if !("shift_time_max" in keys(employees[e]))
            employees[e]["shift_time_max"] = env["shift_time_max"]
        end

        if (
            "shift_count_min" in keys(employees[e])
            && "shift_count_max" in keys(employees[e])
        )
            continue
        end

        # calculate based on min/max
        if "shift_count" in keys(employees[e])
            employees[e]["shift_count_min"] = employees[e]["shift_count"]
            employees[e]["shift_count_max"] = employees[e]["shift_count"]
            continue
        end

        if !("shift_count_min" in keys(employees[e]))
            # calculate from limits
            employees[e]["shift_count_min"] = int(ceil(employees[e]["hours_min"] / employees[e]["shift_time_max"]))
        end

        if !("shift_count_max" in keys(employees[e]))
            max = int(floor(employees[e]["hours_max"] / employees[e]["shift_time_min"]))
            # can't exceed days per week
            if max > days_per_week
                max = days_per_week
            end
            employees[e]["shift_count_max"] = max
        end

        # Set ceiling of shift_count_max at availability
        days_available = days_available_per_week(employees[e])
        if employees[e]["shift_count_max"] > days_available
            employees[e]["shift_count_max"] = days_available
        end

    end

    # Anneal availability - get rid of availability that isn't feasible
    for e in keys(employees)
        employees[e]["availability"] = anneal_availability(employees[e]["availability"], employees[e]["shift_time_min"])
    end

    # day availability - num hours using longest_shift
    for e in keys(employees)
        longest_per_day = Int[]
        for day in 1:days_per_week
            push!(longest_per_day, get_longest_availability(employees[e], day))
        end
        employees[e]["longest_availability"] = longest_per_day
    end


    return true, employees, env
end

function validate_input(employees, env)
    # first build an array that is the length of each day of the week
    day_length = Int[]
    days_per_week = size(env["coverage"], 1)

    for day in 1:days_per_week
        push!(day_length, length(env["coverage"][day]))
    end

    # Days must be the same length
    overage = 0
    for day in 2:days_per_week
        if day_length[day] != day_length[1]
            return false, "ERROR: excessive day length mismatch"
        end
    end

    # Build the coverage count
    coverage_count_per_hour = Any[]
    for day in 1:size(day_length, 1)
        push!(coverage_count_per_hour, zeros(Int, day_length[day]))
    end

    # sum this from employee longest_availability variable
    coverage_count_per_day = zeros(Int, days_per_week)

    # Loop through employees
    # do shit, including adding to coverage
    for e in keys(employees)
        for t in 1:days_per_week
            if size(employees[e]["availability"][t], 1) != day_length[t]
                return false, string("Employee ", e, " availability for day ", t, " wrong number of hours")
            end
            # 1) Push hourly availability to per-hour coverage
            for h in day_length[t]
                coverage_count_per_hour[t][h] += employees[e]["availability"][t][h]
            end
            # Check their max availability per day
            coverage_count_per_day[t] += employees[e]["longest_availability"][t]
        end
        # Make copy of longest_availability then sort it; largest first
        avail = sort(employees[e]["longest_availability"], rev=true)
        # check that the sum of largest "longest avail" >= hours_min
        avail_sum_max = 0
        for i in 1:employees[e]["shift_count_max"]
            # bounds check - threw an error before
            if i <= length(avail)
                avail_sum_max += avail[i]
            end
        end

        if avail_sum_max < employees[e]["hours_min"]
            # check that sum of longest_availability > hours_min
            return false, string("Employee ", e, " not available for min_hours")
        end
    end

    for e in keys(employees)
        # Shift count validations
        shift_count_min = employees[e]["shift_count_min"]
        shift_count_max = employees[e]["shift_count_max"]
        shift_time_min = employees[e]["shift_time_min"] # inherited from env
        shift_time_max = employees[e]["shift_time_max"]
        hours_min = employees[e]["hours_min"]
        hours_max = employees[e]["hours_max"]
        days_available = days_available_per_week(employees[e])

        if shift_count_min > days_available
            return false, "Employee $e has fewer days available than minimum shift count"
        end

        if shift_count_max > days_per_week
            return false, "shift_count_max exceeds days per week"
        end


        if shift_count_min > shift_count_max
            return false, "shift count min is larger than shift count max!"
        end

        if shift_count_min * shift_time_max < hours_min
            return false, "Shift count min is too low for employee $e"
        end

        if shift_count_max * shift_time_min > hours_max
            return false, "Shift count max is too high for employee $e"
        end
    end

    return true, ""
end

function assign_employees_to_days(employees, env, consecutive=false, lift_ceiling=false)
    #=
    Consecutive days off works by looking at days_per_week, and if an employee
    is scheduled for <= (days_per_week-2) shifts, then at least two of their
    days off must be consecutive.
    =#
    days_per_week = size(env["coverage"], 1)
    number_of_employees = length(employees)
    decision_index_max = days_per_week * number_of_employees
    day_length = Int[]

    for day in 1:days_per_week
        push!(day_length, length(env["coverage"][day]))
    end

    if GUROBI
        m = Model(
            solver=GurobiSolver(
                LogToConsole=0,
                TimeLimit=CALCULATION_TIMEOUT,
                OutputFlag=0,
            )
        )
    else
        m = Model(
            solver=CbcSolver(
                threads=Base.CPU_CORES,
            )
        )
    end



    # Decision Variables
    @variable(m, decision_variable[1:decision_index_max], Bin)

    if consecutive
        @variable(m, decision_consecutive[1:decision_index_max], Bin)
    end

    #=
    Lyft tries to evenly allocate extra resources between days. This way,
    if you have excess capacity, it is spread evenly over days and thus
    maximizes likelihood of feasibility.
    Ignoring lift may mean that one day gets all the excess capacity. This sucks.
    =#
    @variable(m, lift >= 1)

    decision_index_to_employee = String[]
    decision_index_to_day = Int[]
    decision_index_hours = Int[]
    for e in keys(employees)
        for t in 1:days_per_week
            push!(decision_index_to_employee, e)
            push!(decision_index_to_day, t)
            push!(decision_index_hours, employees[e]["longest_availability"][t])
        end
    end

    # Now we do per-employee constraint
    # Note: decision var 1st e.g. use x*3 instead of 3*x
    for e in keys(employees)
        # days assigned = # shifts
        # Break into to sections due to Gurobi range issue in Julia
        @constraint(m,
            employees[e]["shift_count_min"] <= sum(decision_variable[i] for i=1:decision_index_max if decision_index_to_employee[i] == e)
        )

        @constraint(m,
            sum(decision_variable[i] for i=1:decision_index_max if decision_index_to_employee[i] == e) <= employees[e]["shift_count_max"]
        )

        # assigned days * longest availability > min week hours
        @constraint(m,
            sum(decision_index_hours[i] * decision_variable[i] for i=1:decision_index_max if decision_index_to_employee[i] == e) >= employees[e]["hours_min"]
        )

        if consecutive
            if employees[e]["shift_count_max"] < (days_per_week - 1)
                @constraint(m,
                    sum(decision_consecutive[i] for i=1:decision_index_max if decision_index_to_employee[i] == e) >= 1
                )
            end
        end
    end

    for i in 1:decision_index_max
        # If an employee has no availability - don't schedule them!
        if decision_index_hours[i] == 0
            @constraint(m, decision_variable[i] == 0)
        end

        if consecutive
            if decision_index_to_day[i] == 1
                # See if employee worked day before this week
                if ("worked_day_preceding_week" in keys(employees[decision_index_to_employee[i]])) && (employees[decision_index_to_employee[i]]["worked_day_preceding_week"] == false)
                    @constraint(m, decision_consecutive[i] + decision_variable[i] == 1)
                else
                    # throw away the first index - it defaults to zero
                    @constraint(m, decision_consecutive[i] == 0)
                end
            else # day > 1
                # Goal: decision_consecutive[i] = 1 IF AND ONLY IF
                # decision_variable[i]=0 and decision_variable[i-1]=0
                @constraint(m, (decision_variable[i] + decision_variable[i-1]) >= 1 - decision_consecutive[i])
                @constraint(m, (2 - decision_variable[i] - decision_variable[i-1]) >= 2*decision_consecutive[i])
            end

        end
    end

    for d in 1:days_per_week
        # sum of day coverage is sufficient based on longest avail.
        @constraint(m,
            sum(decision_index_hours[i] * decision_variable[i] for i=1:decision_index_max if decision_index_to_day[i] == d) >= sum(env["coverage"][d])*lift
        )

        # ensure hourly coverage
        for t in 1:day_length[d]
            @constraint(m,
                sum(employees[decision_index_to_employee[i]]["availability"][d][t] * decision_variable[i] for i=1:decision_index_max if decision_index_to_day[i] == d) >= env["coverage"][d][t]
            )
        end
    end

    # For looping if infeasible models
    if lift_ceiling != false
        @constraint(m, lift <= lift_ceiling)
    end

    # Objective is to maximize that people get assigned to days
    # when they are free
    @objective(m, Max, lift)

    status = solve(m)
    if status == :Optimal
        i = 0
        for e in keys(employees)
            assigned = Int[]
            for t in 1:days_per_week
                i += 1
                push!(assigned, round(getValue(decision_variable[i])))
            end
            employees[e]["days_assigned"] = assigned
        end
        lift_value = getValue(lift)
        if days_per_week == 1
            # override. Weird bug, but we can have different lifts per day??
            lift_value = 1
        end
        Logging.info( "Lyft: ", lift_value)
        gc()
        return true, employees, lift_value
    else
        Logging.info( "Infeasible")
        gc()
        return false, Any[], 0
    end
    # ok
    gc()
    return true, schedule
end

function validate_schedule(employees, env, weekly_schedule)
    days_per_week = size(env["coverage"], 1)

    day_length = Int[]
    days_per_week = size(env["coverage"], 1)

    for day in 1:days_per_week
        push!(day_length, length(env["coverage"][day]))
    end


    sum_hours = 0

    sum_coverage_by_hour = Any[]
    for day in 1:days_per_week
        push!(sum_coverage_by_hour, zeros(Int, day_length[day]))
    end


    for e in keys(weekly_schedule)
        num_shifts = length(weekly_schedule[e])

        # employees have shift_count within bounds
        if num_shifts < employees[e]["shift_count_min"]
            return false, "Employee $e has too few shifts"
        end

        if num_shifts > employees[e]["shift_count_max"]
            return false, "Employee $e has too many shifts"
        end

        employee_sum_hours = 0

        last_shift = null
        for i in 1:num_shifts
            shift_day = weekly_schedule[e][i]["day"]
            shift_start = weekly_schedule[e][i]["start"]
            shift_length = weekly_schedule[e][i]["length"]

            # Sum hours
            sum_hours += shift_length
            employee_sum_hours += shift_length

            # Coverage
            for t in shift_start:(shift_start + shift_length - 1)
                sum_coverage_by_hour[shift_day][t] += 1
            end

            # employees have shift lengths within bounds
            if shift_length < employees[e]["shift_time_min"]
                return false, "Employee $e shift $i length too short on Day $shift_day - $shift_length"
            end

            if shift_length > employees[e]["shift_time_max"]
                return false, "Employee $e shift $i length too long on Day $shift_day - $shift_length"
            end

            # INTERSHIFT
            if shift_day > 1 # check for intershift with last shift
                # find shift for preceding day - may not be in order
                for j in 1:num_shifts
                    # Intershift is not supposed to cover more than one day
                    last_shift_day = shift_day - 1
                    if weekly_schedule[e][j]["day"] == last_shift_day
                        last_shift_start = weekly_schedule[e][j]["start"]
                        last_shift_length = weekly_schedule[e][j]["length"]
                        last_shift_end = last_shift_start + last_shift_length - 1
                        hours_left_in_day = length(env["coverage"][last_shift_day]) - last_shift_end

                        if "intershift" in keys(employees[e])
                            intershift = employees[e]["intershift"]
                        else
                            intershift = env["intershift"]
                        end

                        overflow = intershift - hours_left_in_day - env["time_between_coverage"]
                        if overflow > shift_start
                            return false, "Not enough time before day $shift_day (overflow $overflow / shift start $shift_start)"
                        end
                    end
                end
            end
        end

        # employees have total hours within range
        if employee_sum_hours < employees[e]["hours_min"]
            return false, "Employee $e works too few hours in the week"
        end

        if employee_sum_hours > employees[e]["hours_max"]
            return false, "Employee $e works too many hours in the week"
        end

    end
    sum_coverage = sum(sum(env["coverage"]))

    # Hour by hour coverage
    for day in 1:days_per_week
        for hour in 1:day_length[day]
            if env["coverage"][day][hour] > sum_coverage_by_hour[day][hour]
                return false, "Insufficient employees working on day $day at hour $hour"
            end
        end
    end

    return true, "balling"
end

function valid_schedules_net(schedule)
    # For use with schedule_by_day in parallel mode
    return schedule["success"]
end

function return_schedules(schedule)
    # For use with schedule_by_day in parallel mode
    return schedule["schedule"]
end
