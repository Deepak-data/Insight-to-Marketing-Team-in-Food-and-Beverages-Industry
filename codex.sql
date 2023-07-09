CREATE DATABASE CODEX;

USE CODEX;

CREATE TABLE dimcities (
	cityid VARCHAR(6) PRIMARY KEY,
	city VARCHAR(255),
	tier VARCHAR(10)
    );

CREATE TABLE dim_respondents(
resp_id VARCHAR(20) PRIMARY KEY,
name VARCHAR(255),
age VARCHAR(100),
gender VARCHAR(10),
cityid VARCHAR(10)
);

alter table dim_respondents modify column resp_id int;

create table factsurvey(
	response_id int primary key,
	respondent_id int,
	consume_frequency varchar(255),
	consume_time varchar(255),
	consume_reason varchar(255),
	heard_before varchar(255),
	brand_perception varchar(255),
	general_perception varchar(255),
	tried_before varchar(255),
	taste_experience tinyint,
	reasons_preventing_trying varchar(255),
	current_brands varchar(255),
	reasons_for_choosing_brands varchar(255),
	improvements_desired varchar(255),
	ingredients_expected varchar(255),
	health_concerns varchar(255),
	interest_in_natural_or_organic varchar(255),
	marketing_channels varchar(255),
	packaging_preference varchar(255),
	limited_edition_packaging varchar(255),
	price_range varchar(255),
	purchase_location varchar(255),
	tpical_consumption_situations varchar(255)
);

LOAD DATA INFILE 'fact_survey_responses.csv' 
INTO TABLE factsurvey 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 LINES;

ALTER TABLE factsurvey ADD FOREIGN KEY(Respondent_ID) REFERENCES dim_respondents(Resp_ID);

ALTER TABLE dim_respondents ADD FOREIGN KEY (CityID) REFERENCES dimcities(CityID);

CREATE VIEW respondent AS 
	SELECT * 
    FROM factsurvey 
    INNER JOIN dim_respondents 
    ON factsurvey.Respondent_ID = dim_respondents.Resp_ID;

CREATE VIEW factcities AS 
SELECT * 
FROM factsurvey F 
INNER JOIN dim_respondents R 
ON F.Respondent_ID = R.Resp_ID 
INNER JOIN dimcities AS D 
USING (cityid);

SELECT Consume_reason,count(Consume_reason) count 
FROM factsurvey 
GROUP BY Consume_reason 
ORDER BY count;

#Q1A Who prefers energy drink more?
SELECT gender,count(Consume_frequency) AS Respondent 
FROM respondent 
GROUP BY gender 
ORDER BY RESPONDENT DESC;

#Q1B Which age group prefers energy drinks more?
SELECT AGE,COUNT(Consume_frequency) AS Respondent 
FROM respondent 
GROUP BY AGE 
ORDER BY Respondent DESC;

#Q1C Which type of marketing reaches the most Youth (15-30)?
SELECT Marketing_channels,COUNT(Marketing_channels) AS Respondent 
FROM respondent 
WHERE AGE IN ('15-18','19-30') 
GROUP BY Marketing_channels 
ORDER BY Respondent DESC;

#Q2A What are the preferred ingredients of energy drinks among respondents?
SELECT Ingredients_expected,COUNT(Ingredients_expected) AS Respondent 
FROM respondent
GROUP BY Ingredients_expected
ORDER BY Respondent DESC;

#Q2B What packaging preferences do respondents have for energy drinks?
SELECT Packaging_preference,COUNT(Packaging_preference) AS Respondent 
FROM respondent 
group by Packaging_preference
ORDER BY Respondent DESC;

#Q3A Who are the current market leaders?
SELECT Current_brands,count(Current_brands) AS Respondent 
FROM respondent 
GROUP BY Current_brands
ORDER BY Respondent DESC;

#Q3B What are the primary reasons consumers prefer those brands over ours
SELECT Reasons_preventing_trying, COUNT(*) AS Respondent 
FROM factsurvey 
GROUP BY Reasons_preventing_trying 
ORDER BY Respondent DESC;

#Q4A Which marketing channel can be used to reach more customers?
SELECT Marketing_channels,COUNT(Marketing_channels) AS Respondent 
FROM respondent 
GROUP BY Marketing_channels 
ORDER BY Respondent DESC;

#Q4B  How effective are different marketing strategies and channels in reaching our customers?
SELECT DISTINCT COUNT(Marketing_channels),Marketing_channels 
FROM respondent 
GROUP BY Marketing_channels ;

#Q5A What do people think about our brand? (overall rating)
SELECT AVG(Taste_experience) AS Respondent 
FROM factsurvey ;

#Q5B Which cities do we need to focus more oN?
SELECT CITY,COUNT(Health_concerns) AS Respondent 
FROM factcities 
WHERE Health_concerns = 'YES' 
GROUP BY CITY 
ORDER BY Respondent DESC ;
 
 #Q6A Where do respondents prefer to purchase energy drinks?
SELECT Purchase_location,COUNT(Purchase_location) AS Respondent 
FROM respondent 
GROUP BY Purchase_location 
ORDER BY Respondent;

#Q6B What are the typical consumption situations for energy drinks among respondents?
SELECT Typical_consumption_situations,COUNT(Typical_consumption_situations) AS Respondent 
FROM factsurvey 
GROUP BY Typical_consumption_situations 
ORDER BY Respondent DESC;

#Q6C What factors influence respondents' purchase decisions, such as price range and limited edition packaging?
SELECT Price_range,Limited_edition_packaging,Brand_perception,Ingredients_expected, COUNT(*) OVER (partition by Price_range,Limited_edition_packaging,Brand_perception,Ingredients_expected) AS COUNT
FROM factsurvey
ORDER BY COUNT DESC;

SELECT Price_range, COUNT(*) AS COUNT
FROM factsurvey
GROUP BY price_range
ORDER BY COUNT DESC;

SELECT Limited_edition_packaging, COUNT(*) AS COUNT
FROM factsurvey
GROUP BY Limited_edition_packaging
ORDER BY COUNT DESC;

SELECT Reasons_for_choosing_brands, COUNT(*) AS COUNT
FROM factsurvey
group by Reasons_for_choosing_brands
ORDER BY COUNT DESC;


#Q7A Which area of business should we focus more on our product development? (Branding/taste/availability)
SELECT Taste_experience,COUNT(Taste_experience) AS Respondent 
FROM factsurvey 
WHERE Tried_before = 'YES'
GROUP BY Taste_experience
ORDER BY Respondent DESC;

SELECT Reasons_for_choosing_brands,COUNT(Reasons_for_choosing_brands) AS COUNT
FROM factsurvey 
GROUP BY Reasons_for_choosing_brands
ORDER BY COUNT DESC;


SELECT Brand_perception,COUNT(Brand_perception) AS COUNT 
FROM factsurvey
GROUP BY Brand_perception
ORDER BY COUNT DESC;

#recommendation
SELECT Reasons_preventing_trying,COUNT(Reasons_preventing_trying) AS respondent 
FROM factsurvey 
GROUP BY Reasons_preventing_trying 
ORDER BY respondent;

SELECT Improvements_desired,COUNT(Improvements_desired) AS respondent 
FROM factsurvey 
GROUP BY Improvements_desired
ORDER BY respondent;

SELECT Interest_in_natural_or_organic,COUNT(Interest_in_natural_or_organic) AS respondent 
FROM factsurvey 
GROUP BY Interest_in_natural_or_organic 
ORDER BY respondent;

SELECT Price_range,COUNT(Price_range) AS respondent 
FROM factsurvey 
GROUP BY Price_range 
ORDER BY respondent;
