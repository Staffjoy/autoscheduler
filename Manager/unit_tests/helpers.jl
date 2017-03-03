function test_helpers()
    test_build_uri()
    test_days()
end

function test_build_uri()
    test_config = {
        "protocol" => "http",
        "host" => "dev.staffjoy.com",
        "api_key" => "staffjoydev", # This should be from a sudo user
        "pagerduty" => false, # Alert on issues?
        "pagerduty_key" => "", # API key for triggering an alert
        "sleep" => 10, # Seconds between fetching
    }

    path = "/home"
    expected = "http://staffjoydev:@dev.staffjoy.com/home"
    actual = build_uri(test_config, path)
    @test actual == expected
end

function test_days()
    # Given a start day, get days in the correct order
    input = {"day_week_starts" => "tuesday"}
    expected = [
        "tuesday",
        "wednesday",
        "thursday",
        "friday",
        "saturday",
        "sunday",
        "monday",
    ]

    actual = days(input)
    @test expected == actual
end
