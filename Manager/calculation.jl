# This is the file that executes on tasks, aka where the magic happens

function run_task(task)
    organization = fetch_organization(task)
    schedule = fetch_schedule(task)

    if organization["plan"] == "per-seat-v1"
        workers_raw = fetch_workers(task)
        api_availability = fetch_availability(task)
        workers = fill_missing_availability(schedule, api_availability, workers_raw, organization, task)
        workers = downgrade_availability(schedule, workers, organization, task)
    else  # Unassigned shifts mode
        workers = Dict()
        api_availability = Dict()
    end

    shifts = run_calculation(schedule, workers, organization)
    set_shifts(shifts, task, organization)
end

function run_calculation(schedule, workers_input, organization)
    # Do some merging into StaffJoy.jl format and run calculation

    env = deepcopy(schedule)

    # build coverage
    coverage = Array[]
    for day in days(organization)
        push!(coverage, schedule["demand"][day])
    end
    env["coverage"] = coverage

    env["shift_time_min"] = organization["min_shift_length"]
    env["shift_time_max"] = organization["max_shift_length"]
    env["intershift"] = organization["hours_between_shifts"]

    # time between coverage is 0 in manager by definition. 
    # Windowing happens at scheduler level.
    env["time_between_coverage"] = 0


    workers = Dict()
    for worker in workers_input
        w = Dict()
        w["hours_min"] = int(worker["min_hours_per_week"])
        w["hours_max"] = int(worker["max_hours_per_week"])
        w["shift_time_min"] = int(worker["min_shift_length"])
        w["shift_time_max"] = int(worker["max_shift_length"])
        w["shift_count_min"] = int(worker["min_shifts_per_week"])
        w["shift_count_max"] = int(worker["max_shifts_per_week"])
        # Offset from absolute time to the 4AM thing
        if "no_shifts_after" in keys(worker)
            w["no_shifts_after"] = int(worker["no_shifts_after"]) - TIME_OFFSET
        end

        # Convert availability to array of arrays - no day of week
        w["availability"] = Array[]
        for day in days(organization)
            push!(w["availability"], worker["availability"][day])
        end

        workers[string(worker["id"])] = w
    end
    ok, shifts = StaffJoy.schedule(workers, env)
    if !ok
        Logging.err("Schedule failed")
        error()
    end
    return shifts
end
