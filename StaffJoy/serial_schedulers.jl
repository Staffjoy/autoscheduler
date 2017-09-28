function schedule_by_day(config)
    # "config" is dict with keys start_day and method
    start_day = config["start_day"]
    method = config["method"]
    employees = config["employees"]
    env = config["env"]
    perfect_optimality = week_sum_coverage(env)

    if (method == "balanced")
            ok, weekly_schedule = schedule_by_day_balanced(employees, env, start_day)
    elseif (method == "greedy")
        ok, weekly_schedule = schedule_by_day_greedy(employees, env, start_day)
    else
        warn("Unknown method $method")
        return Dict("success" => false)
    end
    if ok
        valid_schedule, message = validate_schedule(employees, env, weekly_schedule)
        if !valid_schedule
            Logging.info( "Unexpected validation issue in $method scheduler - $message")
            return Dict("success" => false)
        end
        hours_scheduled = week_hours_scheduled(weekly_schedule)
        overage = (hours_scheduled - perfect_optimality) / perfect_optimality
        Logging.info( "$method day scheduler succeeded - overage $overage ")

        return Dict(
            "success" => true,
            "schedule" => weekly_schedule,
        )
    end
    return Dict("success" => false)
end


function schedule_by_day_balanced(employees, env, start_day=1)
    days_per_week = size(env["coverage"], 1)
    hours_scheduled = Dict()
    weekly_schedule = Dict()
    for e in keys(employees)
        hours_scheduled[e] = 0
        weekly_schedule[e] = Any[]
    end

    end_day = (start_day + days_per_week - 2) % days_per_week + 1

    for day_index in start_day:(days_per_week + start_day - 1)
        # stupid 1-indexing
        # Need to wrap around day so we can support different start days
        day = (day_index - 1) % days_per_week+ 1

        day_env = Dict()
        day_env["coverage"] = env["coverage"][day]
        day_env["cycle_length"] = length(env["coverage"][day])

        day_employees = Dict()
        for e in keys(employees)
            if employees[e]["days_assigned"][day] != 1
                continue
            end

            day_min, day_max = get_day_bounds(
                sub_array(employees[e]["longest_availability"], day, end_day),
                sub_array(employees[e]["days_assigned"], day, end_day),
                hours_scheduled[e],
                employees[e]["hours_min"],
                employees[e]["hours_max"],
                employees[e]["shift_time_min"],
            )

            day_employees[e] = Dict()
            day_employees[e]["min"] = day_min
            day_employees[e]["max"] = day_max
            day_employees[e]["availability"] = employees[e]["availability"][day]
        end

        ok, day_schedule = schedule_day(day_employees, day_env)
        if !ok
            return false, Any[]
        end

        for e in keys(day_schedule)
            push!(weekly_schedule[e], Dict(
                "day" => day,
                "start" => day_schedule[e]["start"],
                "length" => day_schedule[e]["length"],
            ))
            hours_scheduled[e] += day_schedule[e]["length"]
        end

        ## INTERSHIFT
        # Adjust next day's availability
        if day == days_per_week
            # only do it if there is another day
            continue
        end

        for e in keys(day_schedule)
            # Note: this assumes that intershift < day_length
            # TODO - add a check in verify function for this
            next_day = day + 1
            if next_day > days_per_week
                next_day = (next_day - 1) % days_per_week + 1
            end

            if employees[e]["days_assigned"][next_day] != 1
                continue
            end
            # last time slot where the person works
            last_shift = day_schedule[e]["start"] + day_schedule[e]["length"] - 1
            hours_left_in_day = length(env["coverage"][day]) - last_shift

            if "intershift" in keys(employees[e])
                intershift = employees[e]["intershift"]
            else
                intershift = env["intershift"]
            end

            overflow = intershift - hours_left_in_day - env["time_between_coverage"]

            if overflow <= 0
                continue
            end

            # adjust availability
            for t in 1:overflow
                employees[e]["availability"][next_day][t] = 0
                employees[e]["availability"][next_day] = anneal_availability(employees[e]["availability"][next_day], employees[e]["shift_time_min"])
            end
            employees[e]["longest_availability"][next_day] = get_longest_availability(employees[e], next_day)
        end

    end

    return true, weekly_schedule
end

#=
This scheduler does not account for future availability of employees.
Instead, when it reaches an infeasibility it tries to *drop* employee
shifts. This may behoove our algorithm because it tends to assign people
to the upper bound of their shift limits.
=#
function schedule_by_day_greedy(employees, env, start_day=1)
    days_per_week = size(env["coverage"], 1)
    hours_scheduled = Dict()
    weekly_schedule = Dict()
    shifts_scheduled = Dict()
    for e in keys(employees)
        hours_scheduled[e] = 0
        weekly_schedule[e] = Any[]
        shifts_scheduled[e] = sum(employees[e]["days_assigned"])
    end

    end_day = (start_day + days_per_week - 2) % days_per_week + 1

    for day_index in start_day:(days_per_week + start_day - 1)
        # stupid 1-indexing
        # Need to wrap around day so we can support different start days
        day = (day_index - 1) % days_per_week+ 1

        day_env = Dict()
        day_env["coverage"] = env["coverage"][day]
        day_env["cycle_length"] = length(env["coverage"][day])

        day_employees = Dict()
        for e in keys(employees)
            if employees[e]["days_assigned"][day] != 1
                continue
            end

            shift_time_min = employees[e]["shift_time_min"]
            shift_time_max = employees[e]["shift_time_max"]
            hours_min = employees[e]["hours_min"]
            hours_max = employees[e]["hours_max"]

            if (
                # Worked enough hours already
                hours_scheduled[e] >= hours_min &&
                hours_scheduled[e] < hours_max
                )
                # Either adjust the shift
                remaining_hours = hours_max - hours_scheduled[e]
                if (remaining_hours >= shift_time_min)
                    # only adjust if necessary
                    if (remaining_hours < shift_time_max)
                        shift_time_max = remaining_hours
                    end
                    # otherwise don't touch
                else # Try dropping  the shift
                    if shifts_scheduled[e] > employees[e]["shift_time_min"]
                        shifts_scheduled[e] -= 1
                        continue # will this work?
                    else
                        # We're fucked
                        return false, Any[]
                    end
                end
            end

            day_employees[e] = Dict()
            day_employees[e]["min"] = shift_time_min
            day_employees[e]["max"] = shift_time_max
            day_employees[e]["availability"] = employees[e]["availability"][day]
        end

        ok, day_schedule = schedule_day(day_employees, day_env)
        if !ok
            return false, Any[]
        end

        for e in keys(day_schedule)
            push!(weekly_schedule[e], Dict(
                "day" => day,
                "start" => day_schedule[e]["start"],
                "length" => day_schedule[e]["length"],
            ))
            hours_scheduled[e] += day_schedule[e]["length"]
        end

        ## INTERSHIFT
        # Adjust next day's availability
        if day == days_per_week
            # only do it if there is another day
            continue
        end

        for e in keys(day_schedule)
            # Note: this assumes that intershift < day_length
            # TODO - add a check in verify function for this
            next_day = day + 1
            if next_day > days_per_week
                next_day = (next_day - 1) % days_per_week + 1
            end

            if employees[e]["days_assigned"][next_day] != 1
                continue
            end
            # last time slot where the person works
            last_shift = day_schedule[e]["start"] + day_schedule[e]["length"] - 1
            hours_left_in_day = length(env["coverage"][day]) - last_shift

            if "intershift" in keys(employees[e])
                intershift = employees[e]["intershift"]
            else
                intershift = env["intershift"]
            end

            overflow = intershift - hours_left_in_day - env["time_between_coverage"]

            if overflow <= 0
                continue
            end

            # adjust availability
            for t in 1:overflow
                employees[e]["availability"][next_day][t] = 0
                employees[e]["availability"][next_day] = anneal_availability(employees[e]["availability"][next_day], employees[e]["shift_time_min"])
            end
            employees[e]["longest_availability"][next_day] = get_longest_availability(employees[e], next_day)
        end

    end

    return true, weekly_schedule
end
