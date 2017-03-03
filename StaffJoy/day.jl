function schedule_day(employees, env)
    # to @andhess - "ok" syntax is popular in go and I like it
    ok, message = validate_day(employees, env)
    if !ok
        Logging.info( message)
        return false, {}
    end

    ok, schedule = calculate_day(employees, env)
    if !ok
        return false, {}
    end

    # again a boolean "ok" followed by message
    ok, message = validate_day_schedule(employees, env, schedule)
    if !ok
        Logging.info( message)
        return false, {}
    end

    # boolean "ok" followed by data
    return true, schedule
end

function calculate_day(employees, env)
    total_time = length(env["coverage"])
    num_employees = length(employees)

    sum_coverage = sum(env["coverage"])

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

    ###########################################################################
    # SHIFTS
    ###########################################################################

    # Build variable
    shift_start_max = Uint8[]
    length_max = Uint8[]
    length_min = Uint8[]
    worker_keys = Any[]
    for e in keys(employees) # e is a string
        push!(shift_start_max, total_time + 1 - employees[e]["min"])
        push!(length_max, employees[e]["max"])
        push!(length_min, employees[e]["min"])
        push!(worker_keys, e)
    end

    # Shift start time
    @defVar(m, 1 <= shift_start[1:num_employees] <= total_time, Int)
    for e in 1:num_employees # e is an int
        setUpper(shift_start[e], shift_start_max[e])
    end
    # Shift length - max & min
    @defVar(m, shift_length[e=1:num_employees], Int)
    for e in 1:num_employees # e is an int
        setLower(shift_length[e], length_min[e])
        setUpper(shift_length[e], length_max[e])

        # The "quiqup" constraint:
        # prevent unassigned shifts from starting after a certain time
        if "no_shifts_after" in keys(env)
            @addConstraint(m,
                shift_start[e] <= env["no_shifts_after"],
            )
        end
    end




    ###########################################################################
    # BINARY CONVERSION
    ###########################################################################
    #=
    Set up binary variable for every employee for every week to determine
    whether somebody is working. This makes it easy to sum over the week and
    see how many people are working and whether s comply with availability.
    =#

    # build some helper varialbes to make my life more sane
    bin_total = total_time * num_employees
    i_to_t = Int[]
    i_to_e = Uint8[] # basically what is the equivalent s index
    i_employee = String[]
    #(could have used a modulus of cycle?)

    # we are stacking cycles together, offset by total_time
    # so all t=1 first, then all t=2, etc
    for t in 1:total_time
        e_index = 0
        for e in keys(employees)
            e_index+=1
            push!(i_to_t, t)
            push!(i_to_e, e_index)
            push!(i_employee, e)
        end
    end

    # This whole section is about converting a shift start time and length to
    # a binary array of whether it has started at time t and whether it is
    # active at time t

    # define variables
    @defVar(m, started[1:bin_total], Bin)
    @defVar(m, active[1:bin_total], Bin)

    # Need to split this into its constituent parts
    # (allows us to determine whether it is equal to zero, meaning
    # that the shift started)
    @defVar(m, 0 <= start_min_now_pos[1:bin_total] <= total_time, Int)
    @defVar(m, 0 <= start_min_now_neg[1:bin_total] <= total_time, Int)
    # Is it positive?
    @defVar(m, start_min_now_helper[1:bin_total], Bin)

    # Constraints
    for i in 1:bin_total
        # instead of SOS constraint on the start_min variables:
        # Use a big M approach
        M = total_time + 1
        @addConstraints m begin
            start_min_now_pos[i] <= M * start_min_now_helper[i]
            start_min_now_neg[i] <= M * (1 - start_min_now_helper[i])
            start_min_now_pos[i] - start_min_now_neg[i] == shift_start[i_to_e[i]] - i_to_t[i]
            1 <= start_min_now_pos[i] + start_min_now_neg[i] + started[i]
        end

        # Create one contiguous chunk of ones
        if i_to_t[i] == 1
            @addConstraint(m,
                started[i] == active[i],
            )
        else # not first time
            @addConstraint(m,
                # basically "t-1" for same shift
                started[i] >= active[i] - active[i-num_employees],
            )
        end
    end

    for e in 1:num_employees
        @addConstraints m begin
            # each shift can only have one start time
            1 == sum{started[i], i=e:num_employees:bin_total}
            # Shift binary array must sum to length variable
            shift_length[e] == sum{active[i], i=e:num_employees:bin_total}
        end
    end

    ###########################################################################
    # AVAILABILITY CONSTRAINTS
    ###########################################################################

    for i in 1:bin_total
        # Employees dont' work when they are unavailable
        if employees[i_employee[i]]["availability"][i_to_t[i]] == 0
            @addConstraint(m, active[i] == 0)
        end
    end


    ###########################################################################
    # ENVIRONMENT CONSTRAINTS
    ###########################################################################

    # Make sure that the organization has the proper number of people working
    for t in 1:total_time
        # No coverage == nobody working
        if env["coverage"][t] > 0
            @addConstraint(m,
                env["coverage"][t] <= sum{active[i], i=1:bin_total; i_to_t[i] == t}
            )
        else
            # nobody needed, so nobody should be working
            @addConstraint(m,
                0 == sum{active[i], i=1:bin_total; i_to_t[i] == t}
            )
        end
    end

    ###########################################################################
    # OPTIMIZATION
    ###########################################################################

    # Set the objective
    @setObjective(m, Min, sum{shift_length[e], e=1:num_employees})


    # optimize
    status = solve(m)
    sumHours = 0
    if status == :Optimal
        hours = getObjectiveValue(m)
        Logging.debug("Day scheduler: scheduled $hours / min $sum_coverage")
        e_index = 0
        schedule = Dict()
        for e in keys(employees)
            e_index += 1
            # NOTE - we round here. If we're debugging - don't round. Might get weird floats. 
            start = convert(Int, round(getValue(shift_start[e_index])))
            length = convert(Int, round(getValue(shift_length[e_index])))
            sumHours += length
            schedule[e] = {
                "start" => start,
                "length" => length,
            }
        end
        # TODO - build return function
    else
        Logging.debug( "No optimal solution found")
        gc()
        return false, {}
    end
    # ok 
    gc()
    return true, schedule
end

function validate_day(employees, env)
    total_time = length(env["coverage"])
    min_hours = 0
    max_hours = 0
    coverage_total = sum(env["coverage"])

    for e in keys(employees)
        if length(employees[e]["availability"]) != total_time
            return false, string("Incorrect availability length for ", e)
        end

        longest = longest_consecutive(employees[e]["availability"])

        if longest < employees[e]["min"]
            return false, string("employee ", e, " not available long enough")
        end

        if employees[e]["min"] > total_time
            return false, string("employee ", e, " has too long a min length")
        end

        min_hours += employees[e]["min"]
        max_hours += employees[e]["max"]
    end

    Logging.debug("Coverage $coverage_total / Min hours: $min_hours / Max hours: $max_hours")
    if coverage_total > max_hours
        return false, "coverage exceeds max employee hours"
    end

    # check that enough employees are available to work each shift
    for t in 1:total_time
        availability_sum = 0
        for e in keys(employees)
            availability_sum += employees[e]["availability"][t]
        end

        if availability_sum < env["coverage"][t]
            return false, string("not enough employees available at time ", t)
        end
    end

    return true, "42"
end

function validate_day_schedule(employees, env, schedule)
    total_time = length(env["coverage"]) 

    # helper variable for later
    coverage_check = zeros(Int, total_time)

    for e in keys(employees)
        start = schedule[e]["start"]
        length = schedule[e]["length"]

        # shift start time >= 1
        if start < 1
            return false, string("employee ", e, " start time out of bounds")
        end

        if length <= 0
            return false, string("employee ", e, " shift length invalid")
        end

        # end  time in bounds
        if (start + length - 1) > total_time # fucking non-zero-indices
            return false, string("employee ", e, " length out of bounds")
        end

        for t in start:(start + length - 1)
            # make sure employee is available then
            if employees[e]["availability"][t] == 0
                return false, string("employee ", e, " scheduled when unavailable")
            end
            # also add to coverage tab for checking later
            coverage_check[t] += 1
        end
    end

    for t in 1:total_time
        # make sure we have enough peeps working
        if coverage_check[t] < env["coverage"][t]
            return false, string("not enough people working at time ", t)
        end
    end
    return true, ""
end
