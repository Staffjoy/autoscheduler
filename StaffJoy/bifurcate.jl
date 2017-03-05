function bifurcate_unassigned_scheduler(env)
    # Split a problem into two sub problems to increase speed.
    # Hypthetically could be called recursively.
    child_ceil = deepcopy(env)
    child_floor = deepcopy(env)
    for day in 1:length(env["coverage"])
        for t in 1:length(env["coverage"][day])
            child_ceil["coverage"][day][t] = ceil(env["coverage"][day][t] / 2)

            child_floor["coverage"][day][t] = floor(env["coverage"][day][t] / 2)
            if child_floor["coverage"][day][t] == 0 && env["coverage"][day][t] != 0
                child_floor["coverage"][day][t] = 1
            end
        end
    end

    # Run separately
    Logging.info("Starting ceiling bifurcation child")
    ok, shifts_ceil = run_schedule_unassigned(child_ceil)
    if !ok
        return ok, Dict()
    end

    Logging.info( "Starting floor bifurcation child")
    ok, shifts_floor = run_schedule_unassigned(child_floor)
    if !ok
        return ok, Dict()
    end

    # Merge shifts
    output_shifts = deepcopy(shifts_ceil)
    for name in keys(shifts_floor)
        if !(name in keys(output_shifts))
            output_shifts[name] = Any[]
        end
        for shift in shifts_floor[name]
            push!(output_shifts[name], shift)
        end
    end
    return true, output_shifts
end
