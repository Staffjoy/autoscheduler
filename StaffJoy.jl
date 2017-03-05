module StaffJoy


# module dependencies
importall JuMP
using Base.Test: @test
importall JSON
import Logging

# Functions available elsewhere
export schedule, unit_test, functional_test, is_unassigned_shift, anneal_availability

if "ENV" in keys(ENV) && (
    ENV["ENV"] == "stage" || ENV["ENV"] == "prod"
    )

    env = ENV["ENV"]
    Logging.configure(level=Logging.INFO)
else
    env = "dev"
    Logging.configure(level=Logging.DEBUG)
end

if "Gurobi" in keys(Pkg.installed())
    Logging.info("Gurobi detected")
    using Gurobi
    GUROBI = true
else
    GUROBI = false
    using Cbc
    Logging.info("Using CBC solver")
end

UNASSIGNED_PREFIX = "unassigned_shift_" # Just basically substring matching for when we generate unassigned shifts
UNASSIGNED_ID = 0 # user id for sending back to scheduler

# what's available elsewhere

LYFT_THROTTLE = .999
MIN_LYFT = 1.1 # If it's less than this, don't even try

# 0 generates all fixed shifts at min_shift_length
# 1 generates all fixed shifts at max_shift_length
# lower means: more shifts, easier feasibility, lower theoretical optimality
UNASSIGNED_RATIO = .4
BIFURCATE_THRESHOLD = 350 # labor sum per week


# Amount of time to search for at least one feasible solutions before adding unassigned
if "ITERATION_TIMEOUT" in keys(ENV)
    ITERATION_TIMEOUT = env["ITERATION_TIMEOUT"]
else
    ITERATION_TIMEOUT = 6 * 60 # 6 minutes
end

# Max amount of time to search for feasible solutions in a given lift
# IF AND ONLY IF at least one existing solution has been found. 
# This is like "We have one solution, let's find lots for optimality"
if "SEARCH_TIMEOUT" in keys(ENV)
    SEARCH_TIMEOUT = env["SEARCH_TIMEOUT"]
else
    # Should be longer than ITERATION_TIMEOUT
    SEARCH_TIMEOUT = 20 * 60 # 20 minutes
end

# Longest time to run an individual calculation
if "CALCULATION_TIMEOUT" in keys(ENV)
    CALCULATION_TIMEOUT = env["ITERATION_TIMEOUT"]
else
    CALCULATION_TIMEOUT = 3 * 60 # 3 minutes
end

#
# Includes
#

# Module
include("StaffJoy/serial_schedulers.jl")
include("StaffJoy/unassigned.jl")
include("StaffJoy/week.jl")
include("StaffJoy/day.jl")
include("StaffJoy/helpers.jl")
include("StaffJoy/windowing.jl")
include("StaffJoy/bifurcate.jl")

# Unit Tests
include("StaffJoy/unit_tests/test.jl")
include("StaffJoy/unit_tests/helpers_test.jl")
include("StaffJoy/unit_tests/windowing_test.jl")
include("StaffJoy/unit_tests/unassigned_test.jl")
include("StaffJoy/unit_tests/week_test.jl")

# Functional Tests
TEST_THRESHOLD = 1.08  # Minimum efficiency
include("StaffJoy/functional_tests/test.jl")
include("StaffJoy/functional_tests/day_test.jl")
include("StaffJoy/functional_tests/windowing_test.jl")
include("StaffJoy/functional_tests/week_test.jl")
include("StaffJoy/functional_tests/unassigned_test.jl")
include("StaffJoy/functional_tests/bifurcate_test.jl")

# Source data for tests
include("StaffJoy/test_data/courier-bike-1.jl")
include("StaffJoy/test_data/courier-car-1.jl")
include("StaffJoy/test_data/courier-bike-monday.jl")
include("StaffJoy/test_data/courier-incorrect-availability-length.jl")
include("StaffJoy/test_data/day-prior-failure.jl")
include("StaffJoy/test_data/consecutive-week.jl")
include("StaffJoy/test_data/consecutive-week-with-preceding.jl")
include("StaffJoy/test_data/week-with-day-off.jl")
include("StaffJoy/test_data/delivery-unassigned.jl")

end#module
