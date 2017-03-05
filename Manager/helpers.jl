function build_uri(config, path)
    # API basic
    # http://username:password@dev.staffjoy.com/path
    # Note that our api keys are username and there is no password, so
    # http://apikey:@dev.staffjoy.com/path

    return string(config["protocol"], "://", config["api_key"], ":@", config["host"], path)
end

function days(organization)
    DAYS = [
        "monday",
        "tuesday",
        "wednesday",
        "thursday",
        "friday",
        "saturday",
        "sunday",
    ]

    start_day = organization["day_week_starts"]
    start_index = findfirst(DAYS, start_day)

    if start_index == 0
        Logging.err( "Unable to match organization start day")
        error()
    end

    output = Any[]
    for i in start_index:(start_index + length(DAYS) - 1)
        push!(
            output,
            # Stupid 1-indexing
            DAYS[(i - 1) % length(DAYS)+ 1]
        )
    end
    return output
end
