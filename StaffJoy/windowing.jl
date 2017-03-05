# Preprocessing to narrow what we schedule

# Apply this to coverage
function get_window(data)
    start_index = length(data[1])
    end_index = 1

    # Scan 1: Find indices
    for datum in data
        first_nonzero = 1
        last_nonzero = length(datum)

        for i=1:length(datum)
            first_nonzero = i
            if datum[i] != 0
                break
            end
        end

        for j=length(datum):-1:1
            last_nonzero = j
            if datum[j] != 0
                break
            end
        end

        # Avoid case of all zeros
        if first_nonzero < last_nonzero
            if first_nonzero < start_index
                start_index = first_nonzero
            end
            if last_nonzero > end_index
                end_index = last_nonzero
            end
        end
    end

    # Check for valid window
    if start_index >= end_index
        # No window detected
        return data
    end

    # time_delta is used for adjusting time_between_shifts
    time_delta = (start_index - 1) + (length(data[1]) - end_index)
    # time_delta is what should be applied to env
    return start_index, end_index, time_delta
end

# Input can be availability, coverage, etc - by the week
function apply_window(input, start_index, end_index)
    input = deepcopy(input) # passed by reference
    for t in 1:length(input)
        input[t] = input[t][start_index:end_index]
    end
    return input
end

# Remove the window from shifts.
function remove_window(shifts, start_index)
    shifts = deepcopy(shifts)
    offset = start_index - 1 # one-indexed language!
    for e in keys(shifts)
        for shift in shifts[e]
            shift["start"] += offset
        end
    end
    return shifts
end
