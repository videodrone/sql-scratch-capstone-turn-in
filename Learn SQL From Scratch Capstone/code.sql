
-- #1  
 SELECT *
 FROM survey
 LIMIT 10;
 --question, user_id, response
 
 -- #2
 SELECT question, COUNT(DISTINCT user_id) as 'count'
 FROM survey
 GROUP BY 1;
-- question	                        count
-- 1. What are you looking for?	    500
-- 2. What's your fit?	            475
-- 3. Which shapes do you like?	    380
-- 4. Which colors do you like?	    361
-- 5. When was your last eye exam?	270
 
 -- #3
 --  The last three questions have significantly lower completion rates (25% less than question 1). This may be due to shoppers not knowing or ever considering:
 -- The color they want
 -- The shape they want
 -- When their last eye exam was
 
-- Since they didn't know the answers, they left to consider them and never finshed the quiz.
 
-- The shoppers may also have only been on the site to shop for pricing vs. other competitors, most specifically their current insurance carriers options. Because of they were only interested in reviewing the first two questions.
 
-- #4 
SELECT *
FROM quiz
LIMIT 5;
-- user_id, style, fit, shape, color

SELECT *
FROM home_try_on
LIMIT 5;
-- user_id, number_of_pairs, address, 

SELECT *
FROM purchase
LIMIT 5;
-- user_id, product_id, style, model_name, color, price

-- #5
SELECT DISTINCT(quiz.user_id),
	CASE WHEN
  	home_try_on.user_id IS NOT NULL THEN "True" ELSE "False"
  	END AS 'is_home_try_on',
  home_try_on.number_of_pairs,
  CASE WHEN
  	purchase.user_id IS NOT NULL THEN "True" ELSE "False"
    END AS 'is_purchase'
FROM quiz
LEFT JOIN home_try_on
	ON quiz.user_id = home_try_on.user_id
LEFT JOIN purchase
	ON home_try_on.user_id = purchase.user_id
LIMIT 10;

-- #6 
-- Compare conversion from quiz home_try_on and home_try_on purchase.
WITH funnels AS(
SELECT DISTINCT(quiz.user_id),
home_try_on.user_id IS NOT NULL AS 'is_home_try_on',
home_try_on.number_of_pairs,
purchase.user_id IS NOT NULL AS 'is_purchase'
FROM quiz
LEFT JOIN home_try_on
	ON quiz.user_id = home_try_on.user_id
LEFT JOIN purchase
	ON home_try_on.user_id = purchase.user_id)
SELECT COUNT(*) AS 'num_quiz',
	SUM(is_home_try_on) AS 'num_try_on',
  SUM(is_purchase) AS 'num_purchase',
  1.0 * SUM(is_home_try_on) / COUNT(user_id) AS 'quiz_to_try_on',
  1.0 * SUM(is_purchase) / SUM(is_home_try_on) AS 'try_on_to_purchase'
FROM funnels;

-- Calculate the difference in purchase rates between customers who had 3 number_of_pairs with ones who had 5.
WITH funnels AS(
SELECT DISTINCT(quiz.user_id),
home_try_on.user_id IS NOT NULL AS 'is_home_try_on',
home_try_on.number_of_pairs AS 'num_of_pairs',
purchase.user_id IS NOT NULL AS 'is_purchase'
FROM quiz
LEFT JOIN home_try_on
	ON quiz.user_id = home_try_on.user_id
LEFT JOIN purchase
	ON home_try_on.user_id = purchase.user_id)
SELECT num_of_pairs,
	COUNT(*) AS 'num_quiz',
	SUM(is_home_try_on) AS 'num_try_on',
  SUM(is_purchase) AS 'num_purchase',
  1.0 * SUM(is_home_try_on) / COUNT(user_id) AS 'quiz_to_try_on',
  1.0 * SUM(is_purchase) / SUM(is_home_try_on) AS 'try_on_to_purchase'
FROM funnels
GROUP BY 1
ORDER BY 1;

-- ADDITIONAL QUERIES
-- The most common results of the style quiz
SELECT style AS 'Style',
	COUNT(*) AS 'Count'
FROM quiz
GROUP BY 1
ORDER BY 2 DESC;

-- The most common types of purchase made by style, color, model
SELECT style,
	model_name,
  color,
  COUNT(*) AS 'Count'
FROM purchase
GROUP BY 1, 2, 3;