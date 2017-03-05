# Files for fetching stuff from the StaffJoy API

function fetch_organization(task)
    path = string("/api/v1/organizations/", task["organization_id"])
    results = Requests.get(build_uri(config, path))
    if results.status != 200
        code = results.status
        err("Organization API Down - code $code")
    end
    organization = JSON.parse(Requests.text(results))
    Logging.info( "Organization Info Received")
    return organization["data"]
end

function fetch_schedule(task)
    path = string(
        "/api/v1/organizations/",
        task["organization_id"],
        "/locations/",
        task["location_id"],
        "/roles/",
        task["role_id"],
        "/schedules/",
        task["schedule_id"],
    )
    results = Requests.get(build_uri(config, path))

    if results.status != 200
        code = results.status
        Logging.err( "schedule API down - code $code")
        error()
    end
    schedule = JSON.parse(Requests.text(results))
    Logging.info("Schedule Info Received")
    return schedule["data"]
end

function fetch_workers(task)
    path = string(
        "/api/v1/organizations/",
        task["organization_id"],
        "/locations/",
        task["location_id"],
        "/roles/",
        task["role_id"],
        "/users/",
    )
    results = Requests.get(build_uri(config, path))

    if results.status != 200
        code = results.status
        Logging.err("workers API down - code $code")
        error()
    end
    workers = JSON.parse(Requests.text(results))["data"]
    Logging.info( "workers Info Received")
    Logging.debug( "workers Info: $workers")
    for worker in workers
        if worker["name"] == nothing
            worker["name"] = worker["email"]
        end
    end
    return workers
end

function fetch_availability(task)
    path = string(
        "/api/v1/organizations/",
        task["organization_id"],
        "/locations/",
        task["location_id"],
        "/roles/",
        task["role_id"],
        "/schedules/",
        task["schedule_id"],
        "/availabilities/",
    )
    results = Requests.get(build_uri(config, path))

    if results.status != 200
        code = results.status
        Logging.err( "availabilities API down - code $code")
        error()
    end
    availabilities = JSON.parse(Requests.text(results))
    Logging.info( "availabilities Info Received")
    return availabilities["data"]
end
