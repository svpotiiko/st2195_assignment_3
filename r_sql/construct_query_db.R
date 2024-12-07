# enter library 
library(RSQLite)
library(dplyr)
library(data.table)

# create data base
conn <- dbConnect(RSQLite::SQLite(), "airline2.db")
dbListTables(conn)

# assign variables to table
airports <- read.csv("/Users/veranikapotiiko/Desktop/airports.csv", header = TRUE)
carriers <- read.csv("/Users/veranikapotiiko/Desktop/carriers.csv", header = TRUE)
planes <- read.csv("/Users/veranikapotiiko/Desktop/plane-data.csv", header = TRUE)

# ontime table must have data from multiple csv files
file_path <- "/Users/veranikapotiiko/Desktop"
csv_files <- list.files(file_path, pattern = "200[0-5]\\.csv$", full.names = TRUE)
ontime <- do.call(rbind, lapply(csv_files, read.csv, header = TRUE))

# add variables to db
dbWriteTable(conn, "airports", airports)
dbWriteTable(conn, "carriers", carriers)
dbWriteTable(conn, "planes", planes)
dbWriteTable(conn, "ontime", ontime)

# Quiz Q1 : Which of the following airplanes has the lowest associated 
# average departure delay (excluding cancelled and diverted flights)?

## Using dplyr
lowest_dep_delay <- planes %>%
  inner_join(ontime, by = c("tailnum" = "TailNum")) %>%
  filter(Cancelled == 0, Diverted == 0, DepDelay > 0) %>%
  group_by(model) %>%
  summarize(avg_delay = mean(DepDelay, na.rm = TRUE)) %>%
  arrange(avg_delay)
print(lowest_dep_delay %>% head(1))

## Using DBI 
dep_delay <- dbGetQuery(conn,
        "SELECT model AS model, 
            AVG(ontime.DepDelay) AS avg_delay
        FROM planes 
        JOIN ontime USING(tailnum)
        WHERE ontime.Cancelled = 0 
            AND ontime.Diverted = 0 
            AND ontime.DepDelay > 0
        GROUP BY model
        ORDER BY avg_delay
        LIMIT 1")
dep_delay

# Quiz Q2 : Which of the following cities has the highest number of 
# inbound flights (excluding cancelled flights)?

## Using dplyr
## doesn't work 
inbound_city <- airports %>% 
  inner_join(ontime, by = c("iata" = "Dest")) %>%
  filter(Cancelled == 0) %>%
  group_by(city) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
print(inbound_city %>% head(1))

## Using DBI
city_inbound <- dbGetQuery(conn , 
        "SELECT airports.city AS city, 
		        COUNT(*) AS total
        FROM airports 
        JOIN ontime ON ontime.dest = airports.iata
        WHERE ontime.Cancelled = 0
        GROUP BY airports.city
        ORDER BY total DESC
        LIMIT 1")
city_inbound

# Quiz Q3 : Which of the following companies has the highest number of 
# cancelled flights?

## Using dplyr
canc_num <- carriers %>%
  inner_join(ontime, by = c("Code" = "UniqueCarrier"))
  filter(Cancelled IS NOT NULL, Description = 'United Air Lines Inc.', 
         'American Airlines Inc.', 'Pinnacle Airlines Inc.', 
         'Delta Air Lines Inc.') %>%
  group_by(Description) %>%
  summarise(total = n()) %>%
  arrange(count)
print(canc_num %>% head(1))

## Using DBI
cancelled_num <- dbGetQuery(conn, 
        "SELECT carriers.Description AS carrier, 
            COUNT(*) AS total
        FROM carriers 
        JOIN ontime ON ontime.UniqueCarrier = carriers.Code
        WHERE ontime.Cancelled = 1
            AND carriers.Description IN ('United Air Lines Inc.', 
            'American Airlines Inc.', 'Pinnacle Airlines Inc.', 
            'Delta Air Lines Inc.')
        GROUP BY carriers.Description
        ORDER BY total DESC
        LIMIT 1")
cancelled_num

# Quiz Q4 : Which of the following companies has the highest number of 
# cancelled flights, relative to their number of total flights?

## Using dplyr
# convert data.frames to data.tables for efficincy 
# (vector memory exhaust error)
setDT(carriers)
setDT(ontime)

# calculating numerator
numerator <- ontime[Cancelled == 1][
  carriers, on = .(UniqueCarrier = Code)][
    Description %in% carriers, .(numerator = .N), by = Description]

# calculate denominator
denominator <- ontime[
  carriers, on = .(UniqueCarrier = Code)][
    Description %in% carriers, .(denominator = .N), by = Description]

# calculate the ratio
result <- numerator[denominator, on = "Description"][
  , .(carrier = Description, ratio = numerator / denominator)][
    order(-ratio)][
      .SD[1]]
result

## Using DBI
rel_cancelled_num <- dbGetQuery(conn, 
        "SELECT q1.carrier AS carrier, 
	      (CAST(q1.numerator AS FLOAT)/ CAST(q2.denominator AS FLOAT)) AS ratio
        FROM
          (SELECT carriers.Description AS carrier, 
			        COUNT(*) AS numerator
			     FROM carriers 
	         JOIN ontime ON ontime.UniqueCarrier = carriers.Code
           WHERE ontime.Cancelled = 1 
		          AND carriers.Description IN ('United Air Lines Inc.', 
		          'American Airlines Inc.', 'Pinnacle Airlines Inc.', 
		          'Delta Air Lines Inc.')
		       GROUP BY carriers.Description
          ) AS q1 JOIN
          (SELECT carriers.Description AS carrier, 
		          COUNT(*) AS denominator
          FROM carriers 
	        JOIN ontime ON ontime.UniqueCarrier = carriers.Code
          WHERE carriers.Description IN ('United Air Lines Inc.', 
              'American Airlines Inc.', 'Pinnacle Airlines Inc.', 
              'Delta Air Lines Inc.')
          GROUP BY carriers.Description
          ) AS q2 USING(carrier)
      ORDER BY ratio DESC
      LIMIT 1")


