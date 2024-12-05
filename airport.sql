-- Which of the following airplanes has the lowest associated average departure delay (excluding cancelled and diverted flights)?
SELECT model AS model, 
		AVG(ontime.DepDelay) AS avg_delay
FROM planes 

JOIN ontime USING(tailnum)

WHERE ontime.Cancelled = 0 
		AND ontime.Diverted = 0 
		AND ontime.DepDelay > 0

GROUP BY model

ORDER BY avg_delay

-- Which of the following cities has the highest number of inbound flights (excluding cancelled flights)?
SELECT airports.city AS city, 
		COUNT(*) AS total

FROM airports 

JOIN ontime ON ontime.dest = airports.iata

WHERE ontime.Cancelled = 0

GROUP BY airports.city

ORDER BY total DESC

-- Which of the following companies has the highest number of cancelled flights?
SELECT carriers.Description AS carrier, COUNT(*) AS total

FROM carriers 

JOIN ontime ON ontime.UniqueCarrier = carriers.Code

WHERE ontime.Cancelled = 1
		AND carriers.Description IN ('United Air Lines Inc.', 'American Airlines Inc.', 'Pinnacle Airlines Inc.', 'Delta Air Lines Inc.')

GROUP BY carriers.Description

ORDER BY total DESC

-- Which of the following companies has the highest number of cancelled flights, relative to their number of total flights?
SELECT
	q1.carrier AS carrier, 
	(CAST(q1.numerator AS FLOAT)/ CAST(q2.denominator AS FLOAT)) AS ratio

FROM
(
	SELECT carriers.Description AS carrier, 
			COUNT(*) AS numerator

    FROM carriers 
	
	JOIN ontime ON ontime.UniqueCarrier = carriers.Code

    WHERE ontime.Cancelled = 1 
		AND carriers.Description IN ('United Air Lines Inc.', 'American Airlines Inc.', 'Pinnacle Airlines Inc.', 'Delta Air Lines Inc.')

    GROUP BY carriers.Description

) AS q1 JOIN

(
	SELECT carriers.Description AS carrier, 
		COUNT(*) AS denominator

    FROM carriers 
	
	JOIN ontime ON ontime.UniqueCarrier = carriers.Code

    WHERE carriers.Description IN ('United Air Lines Inc.', 'American Airlines Inc.', 'Pinnacle Airlines Inc.', 'Delta Air Lines Inc.')

    GROUP BY carriers.Description

) AS q2 USING(carrier)

ORDER BY ratio DESC