# Staffjoy Autoscheduler

[![Build Status](https://travis-ci.org/Staffjoy/autoscheduler.svg?branch=master)](https://travis-ci.org/Staffjoy/autoscheduler) [![Moonlight contractors](https://www.moonlightwork.com/shields/julia.svg)](https://www.moonlightwork.com/?referredByUserID=1&referralProgram=maintainer&referrerName=Staffjoy)

[Staffjoy is shutting down](https://blog.staffjoy.com/staffjoy-is-shutting-down-39f7b5d66ef6#.ldsdqb1kp), so we are open-sourcing our code. This repo was the original scheduling algorithm. The repo predates Staffjoy as a company by about a year, and it underwent constant rewrites and improvements. Along the way, we mixed integer programming libraries with techniques like dynamic programming. We used the [Julia Programming Language](http://julialang.org/), and Staffjoy is eternally grateful to the [Julia JuMP project](https://github.com/JuliaOpt/JuMP.jl) for making such a great library that it rekindled an interested in scheduling optimization algorithms that became Staffjoy.

This scheduler started serving paying customers via spreadsheets over email starting in January 2015, then eventually integrated with a web application that we launched at the end of that year. It served production traffic until it was replaced by [Chomp decomposition](https://github.com/chomp-decomposition) and [Mobius assignment](https://blog.staffjoy.com/introducing-mobius-giving-employees-the-shifts-they-want-5eadfdf6de71) in 2016.

In production, we used a proprietary third party solving package that provided significant speed gains. If that library is not present, the library falls back to a slower, open-source library. As such, some tests must be disabled for the public CI system.

## Credit

The architect primary author of this repo was [@philipithomas](https://github.com/philipithomas). This is a fork of the internal repository. 

## General Approach

This approach uses a variety of dynamic programming techniques and heuristics to create workers then assign them to shifts. It assumes that businesses are not open 24/7 (or, if they are, that all shifts turn over at one particular time.) It has two basic optimization models:

1. **Week Model** - Assigns workers to days of the week to work, while maximizing `lift` - basically, a ratio of (worker availability)/(hours of work to do). A ratio of less than one is impossible to solve. We found that, the higher the ratio, the more likely a day model is to converge.
2. **Day Model** - Given workers, and demand for a day, it generates assigned shifts, each with a start and end time, while minimizing the total number of hour scheduled.

It combines these two models with **Serial Scheduling**, where we start with one day of the week, run the Day Model, then schedule the following day - with its model being modified for how the previous day's schedule affects the following day, and continue this until the end of the week.

If a worker work slate on Monday, they can't open on Tuesday. If they have a limit of 40 hours per week and are scheduled for 34 hours, they cannot work more than 6 hours on any remaining day. Due to these changes, the model must be run serially. 

In practice, we start the serial scheduling on each of the seven days of the week, and run the seven different serial scheduling models in parallel. Every Day Model is cached, so in practice - seeding the serial scheduler with all start days only adds additional computation time if the results change.

Overall, the algorithm basically functions like this:

1. Minimize `lift` in the Week Model
2. Run Serial Scheduling, starting with each day of the week. If we hit perfect optimality, return. Otherwise, keep the best solution.
3. Re-run the Week Model, where the `lift` must be lower than the previous one, and repeat until we time out.

## Dev

Run `vagrant up` to build the development environment. Enter it with `vagrant ssh`. Code is synced to the `/vagrant` folder. You can run tests and the server inside this development environment. 

To rebuild the development environment, run `vagrant destroy -f && vagrant up` *outside* the VM.

## Tests

* `make test`: runs unit tests and functional test for both the StaffJoy module and the Manager module. (`make scheduler-test && make manager-test`)
* `make test-unit`: runs unit tests for the StaffJoy module and the Manager module. Skips the (very slow, resource-intensive) functional tests. (`make scheduler-test-light && make manager-test`)
* `make test-functional`: runs unit tests for the StaffJoy module and the Manager module.
* `make test-scheduler-unit`: runs unit tests for the StaffJoy module
* `make test-manager-unit`: runs unit tests for the Manager module
* `make test-scheduler-functional`: runs functional tests for the StaffJoy module. Very slow - probably requires four cores and 45 min to pass. 
* `make test-manager-functional`: runs unit tests for the Manager module.

##  Modules

### StaffJoy Module

The StaffJoy module includes the core logic for the day scheduler and the week scheduler. Consider this application "Dumb" - it should not be aware of environment, continuous time, task queue, etc.

### Manager Module

The Manager module translates requests from the App for calculation using the StaffJoy module. This includes:

* Environment (dev / stage / prod) awareness
* Tasking - retrieving data from the App server
* Server - set up a service that runs on a server, and perhaps in a Docker container.
* Response - send back completed schedules to the App

## Request format

This is what the JSON for the Manager should look like when it does a POST request to the API:

```
POST
{
    "schedule_id": 1,
    "role_id": 1,
    "location_id": 1,
    "organization_id": 1,
    "api_token": "abc123"
}
```

## Org Options

These org options are consumed by scheduler Others are disregarded.

```
{
    data: {
        "no_shifts_after": 17, // Optional - stop shifts after time 17 (exclusive) only in pure unassigned shift mode
        "min_shifts_per_week": 4,
        "max_hours_per_week": 29,
        "max_shift_length": 8,
        "max_shifts_per_week": 5,
        "min_hours_per_week": 20,
        "id": 3,
        "hours_between_shifts": 12,
        "day_week_starts": "monday",
        "min_shift_length": 4,
    }
}
```

## Response Format
This is what the JSON callback from the Manager to the App API looks like:

```
DELETE
{
    "solver_hash": "12lfls3lf" // Git hash of solver version used.
}
```

## Environment Variables

The system defaults to a development environment where no environment variables are necessary. 

* `ENV` - either 'dev', 'stage', or 'prod'
* `API_KEY` - a persistent api key associated with a Sudo-level user on [Staffjoy Suite](https://github.com/staffjoy/suite).
* (optional) `SLEEP` - seconds between fetches to the tasking api. Defaults to 60 seconds in stage/prod.
