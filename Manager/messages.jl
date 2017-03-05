# Send message to API
function send_message(message, task)
    path = string(
        "/api/v1/organizations/",
        task["organization_id"],
        "/locations/",
        task["location_id"],
        "/roles/",
        task["role_id"],
        "/schedules/",
        task["schedule_id"],
        "/messages/",
    )
    results = Requests.post(
        build_uri(config, path),
        json={"message" => message}
    )

    if results.status != 201
        code = results.status
        reason = results.data
        Logging.err( "Unable to create message $message - status %code - response $reason")
        error()
    end
    Logging.info( "Sent message - $message")
end
