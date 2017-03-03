# Send shifts to API
function set_shifts(shifts, task, organization)
    path = string(
        "/api/v1/organizations/",
        task["organization_id"],
        "/locations/",
        task["location_id"],
        "/roles/",
        task["role_id"],
        "/schedules/",
        task["schedule_id"],
        "/shifts/",
    )
    for e in keys(shifts)
        for shift in shifts[e]
            if StaffJoy.is_unassigned_shift(e)
                data = {
                    "user_id" => 0, # This line could be omitted
                    "day" => shift["day"],
                    "start" => shift["start"] + TIME_OFFSET,
                    "length" => shift["length"],
                }
            else
                data = {
                    "user_id" => e, # Flask can convert strings to int
                    "day" => shift["day"],
                    "start" => shift["start"] + TIME_OFFSET,
                    "length" => shift["length"],
                }
            end
            results = Requests.post(build_uri(config, path), json=data)
            if results.status != 201
                code = results.status
                message = results.data
                Logging.err("Unable to create shift $data - status %code - message $message")
                error()
            end
            Logging.info("Created shift - $data")
        end
    end
end

