env_config = {
    "dev" => {
        "protocol" => "http",
        "host" => "dev.staffjoy.com",
        "api_key" => "staffjoydev", # This should be from a sudo user
        "sleep" => 10, # Seconds between fetching
        "port" => 8080,
    },
    "stage" => {
        "protocol" => "https",
        "host" => "stage.staffjoy.com",
        "api_key" => get(ENV, "API_KEY", ""),
        "sleep" => get(ENV, "SLEEP", 60),
        "port" => 80,
    },
    "prod" => {
        "protocol" => "https",
        "host" => "www.staffjoy.com",
        "api_key" => get(ENV, "API_KEY", ""),
        "sleep" => get(ENV, "SLEEP", 60),
        "port" => 80,
    },
}
