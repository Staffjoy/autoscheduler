# Functions for filtering availability and hours per week.

function fill_missing_availability(schedule, api_availability, workers, organization, task, send_messages=true)
    #=
    This function merges availability into users, and if availability is
    not set (eg the user forgot to set it) - then it marks them as availabile all the time.
    =#
    w_out = Any[]

    for worker in workers
        if worker["max_shifts_per_week"] == 0
            # No need to send message - this is is expected behavior
            id = worker["id"]
            Logging.info( "Worker id $id has max_shifts 0 - removed")
            continue
        end

        w_availability = nothing
        for a in api_availability
            if a["user_id"] == worker["id"]
                w_availability = a["availability"]
            end
        end
        if w_availability == nothing
            w_availability = Dict()
            for day in days(organization)
                w_availability[day] = ones(Int, length(schedule["demand"][day]))
            end
            name = worker["name"]
            if send_messages
                send_message("$name did not set availability", task)
            end
        end
        worker["availability"] = w_availability
        push!(w_out, worker)
    end
    return w_out
end

function downgrade_availability(schedule, workers, organization, task, send_messages=true)
    w_out = Any[]

    for worker in workers
        # availability and max hours per shift
        max_hours = Dict() # key is day
        week_hour_sum = 0
        days_available = 0
        name = worker["name"]
        # Max hours per week depends on hours per day, which depends on 
        for day in days(organization)
            # If business is closed, mark availability as 0
            for t in 1:length(schedule["demand"][day])
                if schedule["demand"][day][t] == 0
                    worker["availability"][day][t] = 0
                end
            end

            day_avail = StaffJoy.anneal_availability(worker["availability"][day], worker["min_shift_length"])

            # This is for app->staffjoy conversion
            worker["shift_time_max"] = worker["max_shift_length"]
            worker["shift_time_min"] = worker["min_shift_length"]
            day_longest = StaffJoy.get_longest_availability(worker, day)
            # Gotta clean up for unit tests :-(
            delete!(worker, "shift_time_max")
            delete!(worker, "shift_time_min")
            max_hours[day] = day_longest
            week_hour_sum += day_longest
            if day_longest > 0
                days_available += 1
            end
        end

        completely_unavailable = false
        adjust_shifts = false
        adjust_hours = false

        # Check if completely unavailable
        if week_hour_sum == 0
            Logging.info( "$name completely unavailable")
            if send_messages
                send_message("$name is completely unavailable to work this week, so they were not scheduled", task)
            end
            continue
        end

        # First round - downgrade total hours for the week
        if week_hour_sum < worker["max_hours_per_week"]
            adjust_hours = true
            worker["max_hours_per_week"] = week_hour_sum
        end

        if week_hour_sum < worker["min_hours_per_week"]
            adjust_hours = true
            worker["min_hours_per_week"] = week_hour_sum
        end


        # Second round - check shift count
        if days_available < worker["max_shifts_per_week"]
            adjust_shifts = true
            worker["max_shifts_per_week"] = days_available
        end

        if days_available < worker["min_shifts_per_week"]
            adjust_shifts = true
            worker["min_shifts_per_week"] = days_available
        end

        if worker["min_shifts_per_week"] > worker["max_shifts_per_week"]
            adjust_shifts = true
            worker["min_shifts_per_week"] = worker["max_shifts_per_week"]
        end

        # Third - see that the shifts * hour bands are within hours per week
        while worker["max_hours_per_week"] < worker["min_shifts_per_week"] * worker["min_shift_length"]
            adjust_shifts = true
            worker["min_shifts_per_week"] -= 1
        end

        if worker["max_hours_per_week"] > worker["max_shifts_per_week"] * worker["max_shift_length"]
            adjust_shifts = true
            worker["max_hours_per_week"] = worker["max_shifts_per_week"] * worker["max_shift_length"]
        end

        if worker["min_hours_per_week"] < worker["min_shifts_per_week"] * worker["min_shift_length"]
            adjust_shifts = true
            worker["min_hours_per_week"] = worker["min_shifts_per_week"] * worker["min_shift_length"]
        end

        if worker["min_shifts_per_week"] > worker["max_shifts_per_week"]
            adjust_shifts = true
            worker["min_shifts_per_week"] = worker["max_shifts_per_week"]
        end
        if worker["min_hours_per_week"] > worker["max_hours_per_week"]
            adjust_hours = true
            worker["min_hours_per_week"] = worker["max_hours_per_week"]
        end

        while worker["min_shifts_per_week"]*worker["max_shift_length"] < worker["min_hours_per_week"]
            # This isn't really a messageable change
            worker["min_shifts_per_week"] += 1
        end


        # Message time
        push!(w_out, worker)

        if adjust_shifts && adjust_hours

            Logging.info( "$name hours and shifts downgraded")
            if send_messages
                send_message("$name is not available to work the set shifts and hours this week, so we decreased them to match their availability.", task)
            end

        elseif adjust_shifts

            Logging.info( "$name shifts downgraded")
            if send_messages
                send_message("$name is not available to work the specified number of shifts this week, so we decreased them to match their availability.", task)
            end

        elseif adjust_hours
            Logging.info( "$name hours downgraded")
            if send_messages
                send_message("$name is not available to work the specified number of hours this week, so we decreased them to match their availability.", task)
            end
        end
    end
    return w_out
end
