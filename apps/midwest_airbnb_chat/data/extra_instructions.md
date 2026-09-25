# Extra Instructions

Rules the LLM follows when it writes SQL for `listings`.

- `price` is the nightly price in U.S. dollars. When the user asks what something costs, use `price` and round money to whole dollars in the answer.

<!-- Add more rules below (Assignment 05 asks for at least three). Good candidates:
     `host_is_superhost` and `instant_bookable` are the text values 't' and 'f',
     not booleans; how to match a city name the user types; how to search `name`
     case-insensitively; and whether to ignore rows whose `review_scores_rating`
     is NULL when averaging ratings. -->
- host_is_superhost and instant_bookable are text values 't' or 'f', not booleans; filter with = 't'.
- When comparing groups, report the number of listings in each group next to the average.
- Leave out listings with a missing price when computing price statistics, and say how many were excluded.
- If a question does not name a city, break the result out by city.
- Use a bar chart for comparisons across categories.