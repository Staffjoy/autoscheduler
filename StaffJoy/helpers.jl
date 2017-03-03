function longest_consecutive(avail)
    # for [1 1 1 1 0 0 1 1]
    # return 4

    longest = 0
    current = 0

    for i in 1:length(avail)
        if avail[i] == 0
            current = 0
        else
            current+=1
        end

        if current > longest
            longest = current
        end
    end

    return longest
end

function anneal_availability(avail, min_length)
    # for [1 1 1 1 0 0 1 1]
    # if min_shift_length == 3
    # return [1 1 1 1 0 0 0 0]


    start_index = 0
    current_index = 0

    for i in 1:length(avail)
        if avail[i] == 1 && start_index == 0
            start_index = i
            current_index = i
        elseif (
            (avail[i] == 0 && start_index > 0)
            || (avail[i] == 1 && i == length(avail))
        ) # also note that this must come before other avail[i] == 1
            # if it's last element  - manually correct end index
            if i == length(avail)
                current_index = i
            end

            patch_length = current_index - start_index + 1
            # plus 1 because inclusive->inclusive

            if patch_length < min_length
                for j in start_index:current_index
                    avail[j] = 0
                end
            end
            start_index = 0
            current_index = 0
        elseif avail[i] == 1 && start_index > 0
            current_index += 1
        #elseif avail[i] == 0 && start_index == 0
        end
    end
    return avail
end

function get_day_bounds(longest_availability, days_assigned, hours_scheduled, week_min, week_max, shift_min)
    # note - longest_availability should only be for days remaining

    remaining_hours_max = week_max - hours_scheduled
    remaining_hours_min = week_min - hours_scheduled

    ## Day Min ##
    # every day but today that they're working
    future_capacity = sum(dot(longest_availability[2:end], days_assigned[2:end]))

    # Calculate day min based on future schedules
    day_min = remaining_hours_min - future_capacity

    # but ceiling it at shift_min from environment
    if day_min < shift_min
        day_min = shift_min
    end

    ## Day Max
    # Do not include today
    future_min_capacity = sum(days_assigned[2:end]) * shift_min
    day_max = remaining_hours_max - future_min_capacity

    # Floor at today's longest_availability
    if day_max > longest_availability[1]
        day_max = longest_availability[1]
    end

    return day_min, day_max
end

function get_longest_availability(employee, day)
        # find longest shift on that day
        longest = longest_consecutive(employee["availability"][day])
        if longest < employee["shift_time_min"]
            # Effectively unable to work that day at all
            longest = 0
        end
        if longest > employee["shift_time_max"]
            # Effectively unable to work that day at all
            longest = employee["shift_time_max"]
        end

        return longest
end

function sub_array(array, start_index, end_index)
    # Difference: start index can be > end_index
    if start_index > end_index
        return [array[start_index:end], array[1:end_index]]
    end
    return array[start_index:end_index]
end

function days_available_per_week(employee)

    count = 0
    for t in 1:length(employee["availability"])
        employee["availability"][t] = anneal_availability(employee["availability"][t], employee["shift_time_min"])
        # Already annealed
        # Assume preprocessing sets availablility to 0 when coverage 0
        if sum(employee["availability"][t]) > 0
            count += 1
        end
    end
    return count
end

function day_sum_coverage(env)
    return sum(env["coverage"])
end

function week_sum_coverage(env)
    return sum(sum(env["coverage"]))
end

function day_hours_scheduled(schedule)
    sum = 0
    for e in keys(schedule)
        sum += schedule[e]["length"]
    end
    return sum

end

function week_hours_scheduled(weekly_schedule)
    sum_hours = 0
    for e in keys(weekly_schedule)
        num_shifts = length(weekly_schedule[e])
        for i in 1:num_shifts
            shift_length = weekly_schedule[e][i]["length"]
            sum_hours += shift_length
        end
    end
    return sum_hours
end
