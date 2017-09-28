test_prior_failure_env = Dict(
    "cycle_length" => 12,
    "coverage"=> [3,4,5,5,5,5,5,5,4,4,2,2]
)

test_prior_failure_employees = Dict(
    "Jaeger"=> Dict(
        "max"=>9,
        "min"=>3,
        "availability"=>[1,1,1,1,1,1,1,1,1,1,1,1]
    ),
    "Damian"=> Dict(
        "max"=>8,
        "min"=>3,
        "availability"=>[1,1,1,1,1,1,1,1,1,1,1,1]
    ),
    "Patrick"=> Dict(
        "max"=>8,
        "min"=>3,
        "availability"=>[1,1,1,1,1,1,1,1,1,1,1,1]
    ),
    "Rufus"=> Dict(
        "max"=>8,
        "min"=>3,
        "availability"=>[1,1,1,1,1,1,1,1,1,1,1,1]
    ),
    "Shaun"=> Dict(
        "max"=>8,
        "min"=>3,
        "availability"=>[1,1,1,1,1,1,1,1,1,1,1,1]
    ),
    "Douglas"=> Dict(
        "max"=>8,
        "min"=>3,
        "availability"=>[1,1,1,1,1,1,1,1,1,1,1,1]
    ),
    "Leonardo"=> Dict(        "max"=>8,
        "min"=>3,
        #"availability"=>[1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,0.0]
        "availability"=>[1,1,1,1,1,1,1,1,1,1,1,0],
    ),
)
