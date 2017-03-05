bike_monday_env = {
    "coverage"  => [3, 4, 5 * ones(Int, 6), 4 * ones(Int, 2), 2 * ones(Int, 2)],
    "cycle_length" => 12,
}

# Coverage requires 49 man hours

bike_monday_employees = {
    "Cody" => {
        "min" => 3,
        "max" => 8,
        "availability" => ones(Int, 12),
    },
    "Damian" => {
        "min" => 3,
        "max" => 8,
        "availability" => ones(Int, 12),
    },
    "Douglas" => {
        "min" => 3,
        "max" => 8,
        "availability" => ones(Int, 12),
    },
    "Desmond" => {
        "min" => 3,
        "max" => 8,
        "availability" => ones(Int, 12),
    },
    "Dylan" => {
        "min" => 3,
        "max" => 8,
        "availability" => [
            ones(Int, 7), zeros(Int, 5),
        ],
    },
    "Jaeger" => {
        "min" => 3,
        "max" => 8,
        "availability" => ones(Int, 12),
    },
    "Leonardo" => {
        "min" => 3,
        "max" => 8,
        "availability" => [
            ones(Int, 7), zeros(Int, 5),
        ],
    },
    "Shaun" => {
        "min" => 3, # hours worked over simulation
        "max" => 8, # hours worked over simulation
        "availability" => [
            ones(Int, 12),
        ],
    },
}
