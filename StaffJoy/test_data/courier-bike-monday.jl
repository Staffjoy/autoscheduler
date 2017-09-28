bike_monday_env = Dict(
    "coverage"  => [3, 4, 5 * ones(Int, 6), 4 * ones(Int, 2), 2 * ones(Int, 2)],
    "cycle_length" => 12,
)

# Coverage requires 49 man hours

bike_monday_employees = Dict(
    "Cody" => Dict(
        "min" => 3,
        "max" => 8,
        "availability" => ones(Int, 12),
    ),
    "Damian" => Dict(
        "min" => 3,
        "max" => 8,
        "availability" => ones(Int, 12),
    ),
    "Douglas" => Dict(
        "min" => 3,
        "max" => 8,
        "availability" => ones(Int, 12),
    ),
    "Desmond" => Dict(
        "min" => 3,
        "max" => 8,
        "availability" => ones(Int, 12),
    ),
    "Dylan" => Dict(
        "min" => 3,
        "max" => 8,
        "availability" => [
            ones(Int, 7), zeros(Int, 5),
        ],
    ),
    "Jaeger" => Dict(
        "min" => 3,
        "max" => 8,
        "availability" => ones(Int, 12),
    ),
    "Leonardo" => Dict(
        "min" => 3,
        "max" => 8,
        "availability" => [
            ones(Int, 7), zeros(Int, 5),
        ],
    ),
    "Shaun" => Dict(
        "min" => 3, # hours worked over simulation
        "max" => 8, # hours worked over simulation
        "availability" => [
            ones(Int, 12),
        ],
    ),
)
