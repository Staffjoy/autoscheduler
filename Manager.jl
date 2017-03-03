module Manager

using Base.Test: @test
using HttpServer
import Requests
import StaffJoy
import JSON
import Logging

export run_server, unit_test, functional_test

if "ENV" in keys(ENV) && (
    ENV["ENV"] == "stage" || ENV["ENV"] == "prod"
    )
    env = ENV["ENV"]
    Logging.configure(level=Logging.INFO)
else
    Logging.configure(level=Logging.DEBUG)
end

# Boot Script
include("Manager/env.jl")
if "ENV" in keys(ENV)
    env = ENV["ENV"]
    if !(env in keys(env_config))
        Logging.critical("Environment $env is invalid")
    end
else
    env = "dev"
end

# We start demand at 4AM
TIME_OFFSET = 3

Logging.info("Loading environment $env")
config = env_config[env]

# Setup
include("Manager/tasking.jl")
include("Manager/server.jl")
include("Manager/calculation.jl")
include("Manager/fetching.jl")
include("Manager/setter.jl")
include("Manager/helpers.jl")
include("Manager/filters.jl")
include("Manager/messages.jl")

# Unit Tests
include("Manager/unit_tests/helpers.jl")
include("Manager/unit_tests/filters.jl")
include("Manager/unit_tests/test.jl")

# Functional Tests
include("Manager/functional_tests/test.jl")

end#module
