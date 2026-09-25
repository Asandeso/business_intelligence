# Midwest Airbnb Listings: Data Dictionary

**Dataset:** `listings` table in `midwest_airbnb.db` (SQLite), 14,887 rows and 29 columns
**Source:** Inside Airbnb (https://insideairbnb.com/get-the-data/), the detailed `listings.csv.gz` file for each of three regions: Chicago (snapshot 2026-07-20), Columbus (snapshot 2026-07-23), and Twin Cities MSA (snapshot 2026-07-21). Column meanings follow Inside Airbnb's data dictionary and assumptions (https://insideairbnb.com/data-assumptions/).
**Course:** ISA 401, Miami University

> One row is one listing that showed a nightly price on the snapshot date; listings with no price were dropped. Empty cells are stored as SQL `NULL`.

---

## Field Definitions

| Column | Type | Meaning | Example values |
|---|---|---|---|
| city | TEXT | Metro area the listing is in | Chicago, Columbus, Twin Cities |
| snapshot_date | TEXT (date) | Date Inside Airbnb collected that city's data | 2026-07-20 (Chicago), 2026-07-23 (Columbus), 2026-07-21 (Twin Cities) |
| id | TEXT | Airbnb's unique ID for the listing | 2384, 7126 |
| name | TEXT | Listing title written by the host | Lincoln Park Guest House |
| host_id | TEXT | Airbnb's unique ID for the host; one host can have many listings | 2613, 17928 |
| host_name | TEXT | Host's first name or names | Rebecca, Shar And Robert |
| host_since | TEXT (date) | Date the host joined Airbnb; often missing | YYYY-MM-DD or NULL |
| host_is_superhost | TEXT | Whether the host is an Airbnb Superhost | 't' or 'f' |
| neighbourhood | TEXT | Neighbourhood within the city (Inside Airbnb's neighbourhood_cleansed column) | Hyde Park, West Town, Lincoln Park |
| latitude | REAL | Listing latitude (slightly blurred by Airbnb for privacy) | about 39.9 (Columbus) to 45.1 (Twin Cities) |
| longitude | REAL | Listing longitude (slightly blurred by Airbnb for privacy) | about -93.3 (Twin Cities) to -82.9 (Columbus) |
| property_type | TEXT | Property type the host chose | Entire rental unit, Private room in condo |
| room_type | TEXT | Airbnb's room category | Entire home/apt, Private room, Shared room, Hotel room |
| accommodates | INTEGER | Maximum number of guests | 1 to 16 |
| bedrooms | REAL | Number of bedrooms; NULL for studios or when not listed | 1, 2, NULL |
| beds | REAL | Number of beds | 1, 2 |
| bathrooms_text | TEXT | Bathrooms as written, including shared or private | 1 bath, 1 shared bath, 1 private bath |
| price | REAL | Nightly price in U.S. dollars at the snapshot | 126, 278, 447 |
| minimum_nights | INTEGER | Minimum number of nights per stay | 1, 2, 30 |
| availability_365 | INTEGER | Days the listing is available in the next 365 days | 0 to 365 |
| number_of_reviews | INTEGER | Total reviews the listing has received | 22, 630 |
| number_of_reviews_ltm | INTEGER | Reviews in the last 12 months | 4, 46 |
| first_review | TEXT (date) | Date of the first review; NULL if no reviews | 2009-07-03 |
| last_review | TEXT (date) | Date of the most recent review; NULL if no reviews | 2026-07-05 |
| review_scores_rating | REAL | Average overall guest rating from 0 to 5; NULL if no reviews | 4.74, 4.99 |
| reviews_per_month | REAL | Average reviews per month since the first review | 0.16, 3.04 |
| instant_bookable | TEXT | Whether guests can book without host approval; often missing | 't', 'f', or NULL |
| estimated_revenue_l365d | REAL | Inside Airbnb's estimate of revenue over the last 365 days, in U.S. dollars | 10728, 50130 |
| amenities_count | INTEGER | Number of amenities the listing lists; computed for this course from Inside Airbnb's amenities list | 27, 49 |