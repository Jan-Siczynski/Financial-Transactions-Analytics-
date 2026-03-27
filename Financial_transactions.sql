-- ============================================================
-- PROJECT: Financial Transactions Analytics
-- Source: Kaggle - Financial Transactions Dataset (CaixaBank)
-- ============================================================

-- Q1: Which month of the year generates the highest transaction volume?
--     Supports workforce planning and short-term staffing decisions
--     during peak banking periods.

-- Q2: Which merchant categories generate the highest total revenue?
--     Identifies key customer spending sectors to support
--     product portfolio decisions and business partnerships.

-- Q3: Does a lower credit score correlate with a higher fraud rate?
--     Evaluates the effectiveness of credit score as a transaction
--     risk indicator in the credit scoring process.

-- Q4: Does credit score influence the credit limit assigned to a customer?
--     Analyzes the bank's credit policy in the context of
--     portfolio risk management.

-- Q5: Which customers have the highest debt-to-income ratio?
--     Identifies the TOP 100 high-risk customers for
--     debt restructuring or collection actions.

-- Q6: What is the share of each payment method
--     (chip, swipe, online) in total transaction count and volume?
--     Supports infrastructure investment decisions
--     based on customer payment preferences.

-- Q7: What is the total credit limit distributed by card brand
--     and card type (credit/debit)?
--     Analyzes card portfolio structure to assess
--     risk exposure per brand.

-- Q8: How is customer debt distributed across
--     4 geographic regions of the United States?
--     Identifies regional debt concentration
--     for targeted risk management strategies.

-- Q9: Does the number of years until retirement influence
--     a customer's average transaction amount?
--     Behavioral segmentation by life stage supports
--     personalized product offerings.

-- Q10: What percentage of annual income did customers spend
--      on transactions in 2010?
--      Analyzes customer spending propensity as a baseline
--      for financial health assessment.



----------------------------------------------------------------------
----------------------------------------------------------------------

-- Q1: Which month of the year generates the highest transaction volume?
--     Supports workforce planning and short-term staffing decisions
--     during peak banking periods.

SELECT COUNT(amount) AS volume,
       EXTRACT(MONTH FROM date::date) AS month
FROM transactions_data
GROUP BY EXTRACT(MONTH FROM date::date)
ORDER BY COUNT(amount) DESC;

-- Q2: Which merchant categories generate the highest total revenue? TOP 50
--     Identifies key customer spending sectors to support
--     product portfolio decisions and business partnerships.

SELECT mcc_codes.c1,
       SUM(REPLACE(amount, '$', '')::numeric) AS volume
FROM transactions_data
INNER JOIN mcc_codes ON transactions_data.mcc = mcc_codes.c0::text
GROUP BY mcc_codes.c1
ORDER BY volume DESC;

-- Q3: Does a lower credit score correlate with a higher fraud rate?
--     Evaluates the effectiveness of credit score as a transaction
--     risk indicator in the credit scoring process.

SELECT
    CASE
        WHEN u.credit_score::integer < 500 THEN 'Poor'
        WHEN u.credit_score::integer BETWEEN 500 AND 650 THEN 'Fair'
        WHEN u.credit_score::integer BETWEEN 651 AND 750 THEN 'Good'
        ELSE 'Excellent'
    END AS credit_segment,
    COUNT(*) AS fraud_count
FROM transactions_data AS t
    INNER JOIN fraud_labels AS f ON t.id = f.transaction_id
    INNER JOIN users_data AS u ON u.id = t.client_id

WHERE fraud = 'Yes'
GROUP BY credit_segment
ORDER BY fraud_count DESC;

-- Q4: Does credit score influence the credit limit assigned to a customer?
--     Analyzes the bank's credit policy in the context of
--     portfolio risk management.

SELECT
    CASE
        WHEN credit_score::integer < 500 THEN 'Poor (< 500)'
        WHEN credit_score::integer BETWEEN 500 AND 650 THEN 'Fair (500-650)'
        WHEN credit_score::integer BETWEEN 651 AND 750 THEN 'Good (651-750)'
        ELSE 'Excellent (> 750)'
    END AS credit_score_segment,
    ROUND(AVG(REPLACE(credit_limit, '$', '')::numeric), 2) AS avg_credit_limit,
    COUNT(*) AS total_clients
FROM users_data
JOIN cards_data ON users_data.id = cards_data.client_id
GROUP BY credit_score_segment
HAVING COUNT(*) > 10
ORDER BY avg_credit_limit DESC;

-- Q5: Which customers have the highest debt-to-income ratio?
--     Identifies the TOP 100 high-risk customers for
--     debt restructuring or collection actions.

WITH debt_ratio AS (
    SELECT
        id,
        REPLACE(yearly_income, '$', '')::numeric AS income,
        REPLACE(total_debt, '$', '')::numeric AS debt,
        ROUND((REPLACE(total_debt, '$', '')::numeric /
        NULLIF(REPLACE(yearly_income, '$', '')::numeric, 0)) * 100, 2) AS dti_ratio
    FROM users_data
)
SELECT *
FROM debt_ratio
ORDER BY dti_ratio DESC
LIMIT 100;

-- Q6: What is the share of each payment method
--     (chip, swipe, online) in total transaction count and volume?
--     Supports infrastructure investment decisions
--     based on customer payment preferences.

SELECT
    CASE
        WHEN use_chip = 'Swipe Transaction' THEN 'Swipe'
        WHEN use_chip = 'Chip Transaction' THEN 'Chip'
        ELSE 'Online'
    END AS payment_method,
    COUNT(*) AS transaction_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage,
    ROUND(SUM(REPLACE(amount, '$', '')::numeric), 2) AS total_volume
FROM transactions_data
GROUP BY payment_method
ORDER BY total_volume DESC;

-- Q7: What is the total credit limit distributed by card brand
--     and card type (credit/debit)?
--     Analyzes card portfolio structure to assess
--     risk exposure per brand.
SELECT
    card_brand,
    card_type,
    ROUND(SUM(REPLACE(credit_limit, '$', '')::numeric), 2) AS total_credit_limit,
    COUNT(*) AS total_cards
FROM cards_data
GROUP BY card_brand, card_type
ORDER BY total_credit_limit DESC;

-- Q8: How is customer debt distributed across
--     4 geographic regions of the United States?
--     Identifies regional debt concentration
--     for targeted risk management strategies.

WITH client_location AS (
    SELECT DISTINCT
        u.id,
        REPLACE(u.total_debt, '$', '')::numeric AS total_debt,
        u.latitude AS lat,
        u.longitude AS lon
    FROM users_data u
    JOIN transactions_data t ON u.id = t.client_id
)
SELECT
    CASE
        WHEN lat >= 37 AND lon >= -100 THEN 'NE (North-East)'
        WHEN lat >= 37 AND lon < -100 THEN 'NW (North-West)'
        WHEN lat < 37 AND lon >= -100 THEN 'SE (South-East)'
        ELSE 'SW (South-West)'
    END AS geographic_quadrant,
    ROUND(SUM(total_debt), 2) AS total_debt,
    COUNT(DISTINCT id) AS total_clients
FROM client_location
GROUP BY geographic_quadrant
ORDER BY total_debt DESC;

-- Q9: Does the number of years until retirement influence
--     a customer's average transaction amount?
--     Behavioral segmentation by life stage supports
--     personalized product offerings.

WITH retirement_segments AS (
    SELECT
        id,
        (retirement_age - current_age) AS years_to_retirement,
        CASE
            WHEN (retirement_age - current_age) <= 5 THEN 'Near retirement (≤ 5 lat)'
            WHEN (retirement_age - current_age) BETWEEN 6 AND 15 THEN 'Mid career (6-15 lat)'
            WHEN (retirement_age - current_age) BETWEEN 16 AND 30 THEN 'Early career (16-30 lat)'
            ELSE 'Young (> 30 lat)'
        END AS career_stage
    FROM users_data
)
SELECT
    r.career_stage,
    ROUND(AVG(REPLACE(t.amount, '$', '')::numeric), 2) AS avg_transaction,
    COUNT(*) AS total_transactions
FROM retirement_segments r
JOIN transactions_data t ON r.id = t.client_id
GROUP BY r.career_stage
ORDER BY avg_transaction DESC;

-- Q10: What percentage of annual income did customers spend
--      on transactions in 2010?
--      Analyzes customer spending propensity as a baseline
--      for financial health assessment.

WITH spending_2010 AS (
    SELECT
        client_id,
        SUM(REPLACE(amount, '$', '')::numeric) AS total_spent
    FROM transactions_data
    WHERE EXTRACT(YEAR FROM date::date) = 2010
    GROUP BY client_id
),
income_ratio AS (
    SELECT
        u.id,
        REPLACE(u.yearly_income, '$', '')::numeric AS yearly_income,
        s.total_spent,
        ROUND((s.total_spent / NULLIF(REPLACE(u.yearly_income, '$', '')::numeric, 0)) * 100, 2) AS spending_ratio
    FROM users_data u
    JOIN spending_2010 s ON u.id = s.client_id
)
SELECT
    *,
    RANK() OVER (ORDER BY spending_ratio DESC) AS spending_rank
FROM income_ratio
ORDER BY spending_rank;
