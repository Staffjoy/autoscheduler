function test_filters()
    test_fill_missing_availability()
    test_downgrade_availability_noop()
    test_downgrade_shifts()
    test_downgrade_hours()
    test_downgrade_hours_and_shifts()
    test_only_available_when_business_closed_downgrade()
end

function test_fill_missing_availability()
    schedule = {
        "demand" => {
            "sunday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "monday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "tuesday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "wednesday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "thursday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "friday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "saturday" => [1, 2, 3, 3, 2, 1, 1, 1],
        },
    }

    organization = {
        "day_week_starts" => "sunday",
    }

    workers = Any[
        {
            "id" => 1,
            "name" => "Nikola Tesla",
            "max_shifts_per_week" => 2,
        },
        {
            "id" => 2,
            "name" => "Richard Feynman",
            "max_shifts_per_week" => 2,
        },
        {
            "id" => 3,
            "name" => "Dean Quatrano",
            "max_shifts_per_week" => 0,
        },
    ]

    availability = Any[
        {
            "user_id" => 2,
            "availability" => {
                "sunday" => [1, 0, 1, 1, 0, 1, 1, 1],
                "monday" => [1, 0, 1, 1, 0, 1, 1, 1],
                "tuesday" => [1, 0, 1, 1, 0, 1, 1, 1],
                "wednesday" => [1, 0, 1, 1, 0, 1, 1, 1],
                "thursday" => [1, 0, 1, 1, 0, 1, 1, 1],
                "friday" => [1, 0, 1, 1, 0, 1, 1, 1],
                "saturday" => [1, 0, 1, 1, 0, 1, 1, 1],
            },
        }
        {
            "user_id" => 3,
            "availability" => {
                "sunday" => [1, 0, 0, 0, 0, 0, 1, 1],
                "monday" => [1, 0, 1, 1, 0, 1, 1, 1],
                "tuesday" => [1, 0, 1, 1, 0, 1, 1, 1],
                "wednesday" => [1, 0, 1, 1, 0, 1, 1, 1],
                "thursday" => [1, 0, 1, 1, 0, 1, 1, 1],
                "friday" => [1, 0, 1, 1, 0, 1, 1, 1],
                "saturday" => [1, 0, 1, 1, 0, 1, 1, 1],
            },
        }
    ]

    expected = Any[
        {
            "id" => 1,
            "name" => "Nikola Tesla",
            "max_shifts_per_week" => 2,
            "availability" => {
                "sunday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "monday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "tuesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "wednesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "thursday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "friday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
        {
            "id" => 2,
            "name" => "Richard Feynman",
            "max_shifts_per_week" => 2,
            "availability" => {
                "sunday" => [1, 0, 1, 1, 0, 1, 1, 1],
                "monday" => [1, 0, 1, 1, 0, 1, 1, 1],
                "tuesday" => [1, 0, 1, 1, 0, 1, 1, 1],
                "wednesday" => [1, 0, 1, 1, 0, 1, 1, 1],
                "thursday" => [1, 0, 1, 1, 0, 1, 1, 1],
                "friday" => [1, 0, 1, 1, 0, 1, 1, 1],
                "saturday" => [1, 0, 1, 1, 0, 1, 1, 1],
            },
        },
    ]

    actual = fill_missing_availability(schedule, availability, workers, organization, Dict(), false)

    @test expected == actual
end


# Everybody meets constraints - don't touch them
function test_downgrade_availability_noop()
    schedule = {
        "demand" => {
            "sunday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "monday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "tuesday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "wednesday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "thursday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "friday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "saturday" => [1, 2, 3, 3, 2, 1, 1, 1],
        },
    }

    organization = {
        "day_week_starts" => "sunday",
    }

    workers = Any[
        {
            "id" => 1,
            "name" => "Nikola Tesla",
            "min_shift_length" => 1,
            "max_shift_length" => 9,
            "min_shifts_per_week" => 1,
            "max_shifts_per_week" => 2,
            "min_hours_per_week" => 1,
            "max_hours_per_week" => 20,
            "availability" => {
                "sunday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "monday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "tuesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "wednesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "thursday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "friday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
        {
            "id" => 2,
            "name" => "Richard Feynman",
            "min_shift_length" => 1,
            "max_shift_length" => 9,
            "min_shifts_per_week" => 1,
            "max_shifts_per_week" => 2,
            "min_hours_per_week" => 1,
            "max_hours_per_week" => 20,
            "availability" => {
                "sunday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "monday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "tuesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "wednesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "thursday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "friday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
    ]

    actual = downgrade_availability(schedule, workers, organization, Dict(), false)

    @test workers == actual
end

function test_downgrade_shifts()
    schedule = {
        "demand" => {
            "sunday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "monday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "tuesday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "wednesday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "thursday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "friday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "saturday" => [1, 2, 3, 3, 2, 1, 1, 1],
        },
    }

    organization = {
        "day_week_starts" => "sunday",
    }

    workers = Any[
        # Adjust this guy's shift max
        {
            "id" => 1,
            "name" => "Nikola Tesla",
            "min_shift_length" => 2,
            "max_shift_length" => 9,
            "min_shifts_per_week" => 1,
            "max_shifts_per_week" => 7,
            "min_hours_per_week" => 1,
            "max_hours_per_week" => 20,
            "availability" => {
                "sunday" => [0, 1, 0, 0, 0, 0, 0, 0],
                "monday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "tuesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "wednesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "thursday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "friday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
        {   # Adjust this guy's shift min and max
            "id" => 2,
            "name" => "Richard Feynman",
            "min_shift_length" => 1,
            "max_shift_length" => 9,
            "min_shifts_per_week" => 5,
            "max_shifts_per_week" => 7,
            "min_hours_per_week" => 1,
            "max_hours_per_week" => 20,
            "availability" => {
                "sunday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "monday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "tuesday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "wednesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "thursday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "friday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
    ]

    expected = Any[
        # Adjust this guy's shift max
        {
            "id" => 1,
            "name" => "Nikola Tesla",
            "min_shift_length" => 2,
            "max_shift_length" => 9,
            "min_shifts_per_week" => 1,
            "max_shifts_per_week" => 6,
            "min_hours_per_week" => 2,
            "max_hours_per_week" => 20,
            "availability" => {
                # Annealed
                "sunday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "monday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "tuesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "wednesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "thursday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "friday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
        {   # Adjust this guy's shift min and max
            "id" => 2,
            "name" => "Richard Feynman",
            "min_shift_length" => 1,
            "max_shift_length" => 9,
            "min_shifts_per_week" => 4,
            "max_shifts_per_week" => 4,
            "min_hours_per_week" => 4,
            "max_hours_per_week" => 20,
            "availability" => {
                "sunday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "monday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "tuesday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "wednesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "thursday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "friday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
    ]


    actual = downgrade_availability(schedule, workers, organization, Dict(), false)

    @test expected == actual
end

function test_downgrade_hours()
    schedule = {
        "demand" => {
            "sunday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "monday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "tuesday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "wednesday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "thursday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "friday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "saturday" => [1, 2, 3, 3, 2, 1, 1, 1],
        },
    }

    organization = {
        "day_week_starts" => "sunday",
    }

    workers = Any[
        # Adjust this guy's shift max
        {
            "id" => 1,
            "name" => "Nikola Tesla",
            "min_shift_length" => 2,
            "max_shift_length" => 3,
            "min_shifts_per_week" => 1,
            "max_shifts_per_week" => 7,
            "min_hours_per_week" => 1,
            "max_hours_per_week" => 80,
            "availability" => {
                "sunday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "monday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "tuesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "wednesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "thursday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "friday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
        {   # Adjust this guy's shift min and max
            "id" => 2,
            "name" => "Richard Feynman",
            "min_shift_length" => 5,
            "max_shift_length" => 5,
            "min_shifts_per_week" => 1,
            "max_shifts_per_week" => 1,
            "min_hours_per_week" => 6,
            "max_hours_per_week" => 20,
            "availability" => {
                "sunday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "monday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "tuesday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "wednesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "thursday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "friday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
    ]

    expected = Any[
        # Adjust this guy's shift max
        {
            "id" => 1,
            "name" => "Nikola Tesla",
            "min_shift_length" => 2,
            "max_shift_length" => 3,
            "min_shifts_per_week" => 1,
            "max_shifts_per_week" => 7,
            "min_hours_per_week" => 2,
            "max_hours_per_week" => 21,
            "availability" => {
                # Annealed
                "sunday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "monday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "tuesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "wednesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "thursday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "friday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
        {   # Adjust this guy's shift min and max
            "id" => 2,
            "name" => "Richard Feynman",
            "min_shift_length" => 5,
            "max_shift_length" => 5,
            "min_shifts_per_week" => 1,
            "max_shifts_per_week" => 1,
            "min_hours_per_week" => 5,
            "max_hours_per_week" => 5,
            "availability" => {
                "sunday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "monday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "tuesday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "wednesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "thursday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "friday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
    ]


    actual = downgrade_availability(schedule, workers, organization, Dict(), false)

    @test expected == actual
end

function test_downgrade_hours_and_shifts()
    schedule = {
        "demand" => {
            "sunday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "monday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "tuesday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "wednesday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "thursday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "friday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "saturday" => [1, 2, 3, 3, 2, 1, 1, 1],
        },
    }

    organization = {
        "day_week_starts" => "sunday",
    }

    workers = Any[
        {
            "id" => 1,
            "name" => "Nikola Tesla",
            "min_shift_length" => 2,
            "max_shift_length" => 3,
            "min_shifts_per_week" => 1,
            "max_shifts_per_week" => 7,
            "min_hours_per_week" => 1,
            "max_hours_per_week" => 80,
            "availability" => {
                "sunday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "monday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "tuesday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "wednesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "thursday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "friday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
        {
            "id" => 2,
            "name" => "Richard Feynman",
            "min_shift_length" => 4,
            "max_shift_length" => 5,
            "min_shifts_per_week" => 1,
            "max_shifts_per_week" => 2,
            "min_hours_per_week" => 3,
            "max_hours_per_week" => 20,
            "availability" => {
                "sunday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "monday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "tuesday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "wednesday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "thursday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "friday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
        {
            "id" => 3,
            "name" => "That weird guy who smells like onions",
            "min_shift_length" => 5,
            "max_shift_length" => 8,
            "min_shifts_per_week" => 1,
            "max_shifts_per_week" => 4,
            "min_hours_per_week" => 16,
            "max_hours_per_week" => 32,
            "availability" => {
                "sunday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "monday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "tuesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "wednesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "thursday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "friday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
    ]

    expected = Any[
        # Adjust this guy's shift max
        {
            "id" => 1,
            "name" => "Nikola Tesla",
            "min_shift_length" => 2,
            "max_shift_length" => 3,
            "min_shifts_per_week" => 1,
            "max_shifts_per_week" => 4,
            "min_hours_per_week" => 2,
            "max_hours_per_week" => 12,
            "availability" => {
                "sunday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "monday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "tuesday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "wednesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "thursday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "friday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
        {   # Adjust this guy's shift min and max
            "id" => 2,
            "name" => "Richard Feynman",
            "min_shift_length" => 4,
            "max_shift_length" => 5,
            "min_shifts_per_week" => 1,
            "max_shifts_per_week" => 1,
            "min_hours_per_week" => 4,
            "max_hours_per_week" => 5,
            "availability" => {
                "sunday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "monday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "tuesday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "wednesday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "thursday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "friday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
        {
            "id" => 3,
            "name" => "That weird guy who smells like onions",
            "min_shift_length" => 5,
            "max_shift_length" => 8,
            "min_shifts_per_week" => 2,
            "max_shifts_per_week" => 4,
            "min_hours_per_week" => 16,
            "max_hours_per_week" => 32,
            "availability" => {
                "sunday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "monday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "tuesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "wednesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "thursday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "friday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
    ]


    actual = downgrade_availability(schedule, workers, organization, Dict(), false)
    @test expected == actual
end

function test_only_available_when_business_closed_downgrade()
    # Basically same as last test, but some unavailability comes from
    # the business being closed and the worker not having enough hours
    # on the day to have it count.

    schedule = {
        "demand" => {
            "sunday" => [0, 0, 0, 0, 2, 1, 1, 1],
            "monday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "tuesday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "wednesday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "thursday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "friday" => [1, 2, 3, 3, 2, 1, 1, 1],
            "saturday" => [1, 2, 3, 3, 2, 1, 1, 1],
        },
    }

    organization = {
        "day_week_starts" => "sunday",
    }

    workers = Any[
        {
            "id" => 1,
            "name" => "Nikola Tesla",
            "min_shift_length" => 2,
            "max_shift_length" => 3,
            "min_shifts_per_week" => 1,
            "max_shifts_per_week" => 7,
            "min_hours_per_week" => 1,
            "max_hours_per_week" => 80,
            "availability" => {
                "sunday" => [1, 1, 1, 1, 0, 0, 0, 0],
                "monday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "tuesday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "wednesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "thursday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "friday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
        {
            "id" => 2,
            "name" => "Richard Feynman",
            "min_shift_length" => 4,
            "max_shift_length" => 5,
            "min_shifts_per_week" => 1,
            "max_shifts_per_week" => 2,
            "min_hours_per_week" => 3,
            "max_hours_per_week" => 20,
            "availability" => {
                "sunday" => [1, 1, 1, 0, 0, 0, 0, 0],
                "monday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "tuesday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "wednesday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "thursday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "friday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
    ]

    expected = Any[
        # Adjust this guy's shift max
        {
            "id" => 1,
            "name" => "Nikola Tesla",
            "min_shift_length" => 2,
            "max_shift_length" => 3,
            "min_shifts_per_week" => 1,
            "max_shifts_per_week" => 4,
            "min_hours_per_week" => 2,
            "max_hours_per_week" => 12,
            "availability" => {
                "sunday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "monday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "tuesday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "wednesday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "thursday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "friday" => [1, 1, 1, 1, 1, 1, 1, 1],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
        {   # Adjust this guy's shift min and max
            "id" => 2,
            "name" => "Richard Feynman",
            "min_shift_length" => 4,
            "max_shift_length" => 5,
            "min_shifts_per_week" => 1,
            "max_shifts_per_week" => 1,
            "min_hours_per_week" => 4,
            "max_hours_per_week" => 5,
            "availability" => {
                "sunday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "monday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "tuesday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "wednesday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "thursday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "friday" => [0, 0, 0, 0, 0, 0, 0, 0],
                "saturday" => [1, 1, 1, 1, 1, 1, 1, 1],
            },
        },
    ]


    actual = downgrade_availability(schedule, workers, organization, Dict(), false)
    @test expected == actual
end
