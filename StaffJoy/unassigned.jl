#
# Functions for handling unassigned shifts
#

# Use this when there are not enough employees (or no employees)
# so we don't have 80 loops of unassigned shifts
function meet_base_coverage(env, employees)
    employees = deepcopy(employees)
    days_per_week = size(env["coverage"], 1)
    sum_coverage = sum(sum(env["coverage"]))
    shift_count = 0

    # Sum the hours of employees
    employee_hour_sum = 0
    for e in keys(employees)
        employee_hour_sum += employees[e]["hours_max"]
    end

    # min_lift actually raises the minimum number of hours needed.
    # It helps feasibility, but could hurt the one case of a perfect, single-
    # solution optimal schedule.
    while employee_hour_sum < (sum_coverage*MIN_LYFT)
        name, value = generate_unassigned_shift(env)
        employees[name] = value
        employee_hour_sum += value["hours_max"]
        shift_count += 1
    end

    Logging.info( "Generated $shift_count shifts during pre-processing")
    return employees
end

# Generate lots of unassigned shifts - more than we need - 
# so it is fast
function meet_unassigned_base_coverage(env, day)
    sum_coverage = sum(env["coverage"][day])

    average_unassigned_shift_length = env["shift_time_min"] + (env["shift_time_max"] - env["shift_time_min"]) * UNASSIGNED_RATIO
    unassigned_shift_count = ceil(sum_coverage / average_unassigned_shift_length)

    # Meet peak staffing level
    peak = 0
    for t in 1:length(env["coverage"][day])
        if env["coverage"][day][t] > peak
            peak = env["coverage"][day][t]
        end
    end
    if peak > unassigned_shift_count
        Logging.info("Peak coverage ($peak shifts) chosen instead for unassigned shift count ($unassigned_shift_count shifts) as starting point")
        unassigned_shift_count = peak
    end

    employees = Dict()
    for i in 1:unassigned_shift_count
        name, value = generate_unassigned_shift(env)
        employees[name] = value
    end


    Logging.info( "Generated $unassigned_shift_count unassigned shifts during pre-processing for day $day")
    return employees
end

function generate_unassigned_shift(env)
    shift_time_min = env["shift_time_min"]
    shift_time_max = env["shift_time_max"]
    shift_count = 1 # Each unassigned shift is a single shift

    # need unique names
    name = string(UNASSIGNED_PREFIX, randstring(8))

    # Available all the time
    availability = Array[]
    days_per_week = size(env["coverage"], 1)
    for day in 1:days_per_week
        push!(availability, [ones(Int, length(env["coverage"][day]))])
    end

    # return tuple so you can do employees[name] = values
    return name, {
        "hours_min" => shift_time_min,
        "shift_time_min" => shift_time_min,
        "hours_max" => shift_time_max,
        "shift_time_max" => shift_time_max,
        "shift_count_max" => shift_count,
        "shift_count_min" => shift_count,
        "availability" => availability,
    }
end

function is_unassigned_shift(name)
    # Julia doesn't wrap bounds :-(
    if length(UNASSIGNED_PREFIX) > length(name)
        return false
    end
    return name[1:length(UNASSIGNED_PREFIX)] == UNASSIGNED_PREFIX
end
