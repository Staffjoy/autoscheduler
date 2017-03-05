#=
This file handles fetching data from the StaffJoy API, parsing it, running a calculation, and sending it back to StaffJoy.
=#
import StaffJoy

function get_task()
    results = Requests.post(build_uri(config, "/api/v1/tasking/"))
    if results.status == 404
        return nothing
    elseif results.status != 200
        # Bad request? Internal error? This is a pageable offense!
        code = results.status
        Logging.warn("Tasking API Down - code $code")
        return nothing
    end

    # Return task
    task = JSON.parse(Requests.text(results))
    Logging.info("Task Received - $task")
    # Task Fields: schedule_id, role_id, location_id, organization_id
    return task
end

function mark_task_done(task)
    path = string("/api/v1/tasking/", task["schedule_id"])
    results = Requests.delete(build_uri(config, path))
    if results.status != 204  # 204 is "success / empty response"
        # Bad request? Internal error? This is a pageable offense!
        code = results.status
        schedule = task["schedule_id"]
        Logging.err( "Failed to mark schedule $schedule as done. Code $code")
        error()
    end

    Logging.info( "Task Completed - $task")
end
