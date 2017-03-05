function run_server()
    # Start health check - necessary for AWS
    @async begin
        http = HttpHandler() do req::Request, res::Response
            Response(string(JSON.json({
                "status" =>1,
                "env" => env,
                "hello" => "world",
            })))
        end
        http.events["listen"] = (port) -> Logging.info("Health check listening on port $port")

        server = Server(http)
        run(server, config["port"])
    end

    Logging.info("Starting server")
    while true
        task = get_task()
        if task != nothing
            run_task(task)
            mark_task_done(task)
        else
            Logging.debug("No task. Sleeping.")
            sleep(config["sleep"])
        end
    end
end
