/* ============================================================================
   PROJECT: StreamFlow SaaS - Q3 Customer Churn & Onboarding Analysis
   DIALECT: PostgreSQL
   ============================================================================ */

-- 1. EXECUTIVE KPI OVERVIEW
SELECT 
    COUNT(user_id) AS total_signups,
    ROUND(100.0 * AVG(is_activated), 2) AS overall_activation_rate_pct,
    ROUND(100.0 * AVG(churned_60d), 2) AS overall_60d_churn_rate_pct,
    ROUND(AVG(tasks_completed_7d), 2) AS avg_tasks_first_7d
FROM user_onboarding_metrics;

-- 2. IMPACT OF DAY-7 ACTIVATION ON CHURN
WITH activation_summary AS (
    SELECT 
        CASE 
            WHEN is_activated = 1 THEN 'Activated (>= 3 Tasks)'
            ELSE 'Non-Activated (< 3 Tasks)'
        END AS activation_segment,
        COUNT(user_id) AS user_count,
        SUM(churned_60d) AS churned_users,
        ROUND(100.0 * AVG(churned_60d), 2) AS churn_rate_pct
    FROM user_onboarding_metrics
    GROUP BY 1
)
SELECT 
    activation_segment,
    user_count,
    ROUND(100.0 * user_count / SUM(user_count) OVER(), 2) AS pct_of_total_users,
    churned_users,
    churn_rate_pct
FROM activation_summary
ORDER BY churn_rate_pct DESC;

-- 3. ROOT CAUSE ANALYSIS: DEVICE & PLAN SEGMENTATION
SELECT 
    device,
    plan_type,
    COUNT(user_id) AS total_users,
    ROUND(AVG(tasks_completed_7d), 2) AS avg_tasks_7d,
    ROUND(100.0 * AVG(is_activated), 2) AS activation_rate_pct,
    ROUND(100.0 * AVG(churned_60d), 2) AS churn_rate_pct
FROM user_onboarding_metrics
GROUP BY 1, 2
ORDER BY device ASC, churn_rate_pct DESC;
