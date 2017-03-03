bike_monday_env = {
    "coverage"  => [3, 4, 5 * ones(Int, 6), 4 * ones(Int, 2), 2 * ones(Int, 2)],
    "cycle_length" => 12,
}

# Coverage requires 49 man hours

bike_monday_employees = {
    "Cody Holmes" => {
        "min" => 3,
        "max" => 8,
        "availability" => ones(Int, 12),
    },
    "Damian DiPrima" => {
        "min" => 3,
        "max" => 8,
        "availability" => ones(Int, 12),
    },
    "Douglas DuFresne" => {
        "min" => 3,
        "max" => 8,
        "availability" => ones(Int, 12),
    },
    "Desmond Duggan" => {
        "min" => 3,
        "max" => 8,
        "availability" => ones(Int, 12),
    },
    "Dylan Dignle" => {
        "min" => 3,
        "max" => 8,
        "availability" => [
            ones(Int, 7), zeros(Int, 5),
        ],
    },
    "Jaeger Tang" => {
        "min" => 3,
        "max" => 8,
        "availability" => ones(Int, 12),
    },
    "Leonardo Banchero" => {
        "min" => 3,
        "max" => 8,
        "availability" => [
            ones(Int, 7), zeros(Int, 5),
        ],
    },
    "Shaun Wagner" => {
        "min" => 3, # hours worked over simulation
        "max" => 8, # hours worked over simulation
        "availability" => [
            ones(Int, 12),
        ],
    },
}
