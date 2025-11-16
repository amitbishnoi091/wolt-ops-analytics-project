WITH week_dates AS (
    SELECT 
        DISTINCT DATE_ADD(
            DATE_SUB(DATE(order_datetime), INTERVAL (DAYOFWEEK(order_datetime)-2) DAY),
            INTERVAL 0 DAY
        ) AS week_start
    FROM orders
),

orders_clean AS (
    SELECT
        order_id,
        customer_id,
        restaurant_id,
        city_id,

        /* Delivery minutes */
        COALESCE(actual_sla_mins, 32) AS actual_sla_mins,      -- default SLA

        /* Revenue */
        COALESCE(order_value, 150) AS order_value,             -- industry low-ticket average

        /* Rating */
        COALESCE(rating_given, 4.3) AS rating_given,           -- global avg rating

        order_status,

        /* Complaint flag */
        COALESCE(complaint_flag, FALSE) AS complaint_flag,

        /* Cancel reason */
        COALESCE(reason_cancel, 'none') AS reason_cancel,

        DATE(order_datetime) AS order_date,

        /* Week start */
        DATE_ADD(
            DATE_SUB(DATE(order_datetime), INTERVAL (DAYOFWEEK(order_datetime)-2) DAY),
            INTERVAL 0 DAY
        ) AS week_start
    FROM orders
),

city_base AS (
    SELECT 
        c.city_id,
        c.city_name,
        c.market_tier,
        c.population
    FROM cities c
),

wk_city_orders AS (
    SELECT
        oc.city_id,
        oc.week_start,
        COUNT(*) AS total_orders,
        SUM(CASE WHEN oc.order_status='cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
        SUM(CASE WHEN oc.complaint_flag=TRUE THEN 1 ELSE 0 END) AS complaints,
        ROUND(AVG(oc.actual_sla_mins),2) AS avg_delivery_mins,
        ROUND(SUM(oc.order_value),2) AS total_revenue,
        ROUND(AVG(oc.rating_given),2) AS avg_rating
    FROM orders_clean oc
    GROUP BY oc.city_id, oc.week_start
),

wk_courier AS (
    SELECT 
        s.city_id,
        DATE_ADD(
            DATE_SUB(DATE(s.date), INTERVAL (DAYOFWEEK(s.date)-2) DAY), 
            INTERVAL 0 DAY
        ) AS week_start,

        /* Active couriers */
        COALESCE(COUNT(DISTINCT s.courier_id), 8) AS active_couriers,

        /* Default earning if missing */
        COALESCE(ROUND(AVG(s.earnings_eur),2), 55.00) AS avg_earnings
    FROM courier_shifts s
    GROUP BY s.city_id, week_start
),

wk_restaurant AS (
    SELECT
        o.city_id,
        o.week_start,
        COALESCE(COUNT(DISTINCT o.restaurant_id), 25) AS active_restaurants
    FROM orders_clean o
    GROUP BY o.city_id, o.week_start
),

/* TIER-BASED TARGETS */
wk_okrs AS (
    SELECT 
        city_id,
        week_start,

        /* SLA target based on city tier */
        COALESCE(
            NULLIF(target_avg_delivery_mins,0),
            CASE 
                WHEN market_tier = 1 THEN 27
                WHEN market_tier = 2 THEN 30
                ELSE 33
            END
        ) AS target_avg_delivery_mins,

        /* Cancellation target */
        COALESCE(
            NULLIF(target_cancellation_rate,0),
            CASE 
                WHEN market_tier = 1 THEN 0.030
                WHEN market_tier = 2 THEN 0.040
                ELSE 0.050
            END
        ) AS target_cancellation_rate

    FROM okrs
    JOIN cities USING(city_id)
)

SELECT
    cb.city_id,
    cb.city_name,
    cb.market_tier,
    cb.population,
    wd.week_start,

    /* Orders */
    COALESCE(wco.total_orders, 0) AS total_orders,
    COALESCE(wco.cancelled_orders, 0) AS cancelled_orders,
    COALESCE(wco.complaints, 0) AS complaints,
    COALESCE(wco.avg_delivery_mins, 31) AS avg_delivery_mins,
    COALESCE(wco.total_revenue, 0) AS total_revenue,
    COALESCE(wco.avg_rating, 4.3) AS avg_rating,

    /* Restaurants */
    COALESCE(wr.active_restaurants, 20) AS active_restaurants,

    /* Couriers */
    COALESCE(wcu.active_couriers, 10) AS active_couriers,
    COALESCE(wcu.avg_earnings, 55.00) AS avg_courier_earnings,

    /* Targets */
    COALESCE(ok.target_avg_delivery_mins,
        CASE 
            WHEN cb.market_tier = 1 THEN 27
            WHEN cb.market_tier = 2 THEN 30
            ELSE 33
        END
    ) AS target_avg_delivery_mins,

    COALESCE(ok.target_cancellation_rate,
        CASE 
            WHEN cb.market_tier = 1 THEN 0.030
            WHEN cb.market_tier = 2 THEN 0.040
            ELSE 0.050
        END
    ) AS target_cancellation_rate

FROM week_dates wd
CROSS JOIN city_base cb
LEFT JOIN wk_city_orders wco 
    ON wco.city_id = cb.city_id AND wco.week_start = wd.week_start
LEFT JOIN wk_restaurant wr
    ON wr.city_id = cb.city_id AND wr.week_start = wd.week_start
LEFT JOIN wk_courier wcu
    ON wcu.city_id = cb.city_id AND wcu.week_start = wd.week_start
LEFT JOIN wk_okrs ok
    ON ok.city_id = cb.city_id AND ok.week_start = wd.week_start

ORDER BY cb.city_id, wd.week_start;
