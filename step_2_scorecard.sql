-- Lumira Cosmetics | Addım 2: Scorecard (SQLite)
-- Asılılıq: step_1_cleaning.sql əvvəlcə işlədildi.
-- Təriflər:
--   Orders      = yalnız order_status='completed' sifarişlər (CRM, last-click, utm_campaign ilə)
--   Net revenue = order_value - discount_amount (completed sifarişlər)
--   CTR         = clicks / impressions (clicks NULL olan sətirlər həm surətdən, həm məxrəcdən çıxarılır)
--   CPC         = spend / clicks (eyni qayda)
--   CPA         = spend / Orders ;  ROAS = net revenue / spend

DROP VIEW IF EXISTS v_spend_q;
CREATE VIEW v_spend_q AS
SELECT
  campaign_id,
  substr(date,1,4)||'-Q'||((CAST(substr(date,6,2) AS INTEGER)+2)/3) AS quarter,
  SUM(spend_azn)                                   AS spend,
  SUM(impressions)                                 AS impressions,
  SUM(CASE WHEN clicks IS NOT NULL THEN clicks END)      AS clicks,
  SUM(CASE WHEN clicks IS NOT NULL THEN impressions END) AS impr_with_clicks,
  SUM(CASE WHEN clicks IS NOT NULL THEN spend_azn END)   AS spend_with_clicks,
  SUM(platform_conversions)                        AS platform_conv,
  SUM(platform_conversion_value_azn)               AS platform_value
FROM ad_spend_clean
GROUP BY 1,2;

DROP VIEW IF EXISTS v_orders_q;
CREATE VIEW v_orders_q AS
SELECT
  campaign_id,
  substr(order_date,1,4)||'-Q'||((CAST(substr(order_date,6,2) AS INTEGER)+2)/3) AS quarter,
  COUNT(*)          AS orders,
  SUM(net_revenue)  AS net_revenue
FROM v_orders_mapped
WHERE order_status='completed' AND campaign_id IS NOT NULL
GROUP BY 1,2;

-- 2.1 Scorecard: kampaniya x rüb
DROP VIEW IF EXISTS v_scorecard;
CREATE VIEW v_scorecard AS
SELECT
  c.campaign_id, c.campaign_name, c.platform, c.objective, s.quarter,
  ROUND(s.spend,2)                                            AS spend,
  s.impressions,
  ROUND(1.0*s.clicks/s.impr_with_clicks*100,2)                AS ctr_pct,
  ROUND(s.spend_with_clicks/s.clicks,3)                       AS cpc,
  COALESCE(o.orders,0)                                        AS orders,
  ROUND(COALESCE(o.net_revenue,0),2)                          AS net_revenue,
  ROUND(s.spend/NULLIF(o.orders,0),2)                         AS cpa,
  ROUND(COALESCE(o.net_revenue,0)/s.spend,2)                  AS roas
FROM v_spend_q s
JOIN campaigns c ON c.campaign_id = s.campaign_id
LEFT JOIN v_orders_q o ON o.campaign_id = s.campaign_id AND o.quarter = s.quarter;

-- 2.2 Platforma vs CRM (platform səviyyəsində)
DROP VIEW IF EXISTS v_platform_vs_crm;
CREATE VIEW v_platform_vs_crm AS
SELECT
  c.platform, s.quarter,
  ROUND(SUM(s.spend),2)                          AS spend,
  SUM(s.platform_conv)                           AS platform_conv,
  SUM(o.orders)                                  AS crm_orders,
  ROUND(SUM(s.platform_conv)*1.0/SUM(o.orders),2) AS conv_inflation_x,
  ROUND(SUM(s.platform_value),2)                 AS platform_value,
  ROUND(SUM(o.net_revenue),2)                    AS crm_revenue,
  ROUND(SUM(s.platform_value)/SUM(o.net_revenue),2) AS value_inflation_x,
  ROUND(SUM(s.platform_value)/SUM(s.spend),2)    AS platform_roas,
  ROUND(SUM(o.net_revenue)/SUM(s.spend),2)       AS crm_roas
FROM v_spend_q s
JOIN campaigns c ON c.campaign_id = s.campaign_id
LEFT JOIN v_orders_q o ON o.campaign_id = s.campaign_id AND o.quarter = s.quarter
WHERE c.platform IN ('google_ads','meta','tiktok')
GROUP BY 1,2;

-- 2.3 MER: bütün xalis gəlir (orqanik daxil) / bütün reklam xərci
DROP VIEW IF EXISTS v_mer;
CREATE VIEW v_mer AS
SELECT r.quarter, ROUND(r.total_net_revenue,2) AS total_net_revenue,
       ROUND(s.total_spend,2) AS total_spend,
       ROUND(r.total_net_revenue/s.total_spend,2) AS mer,
       ROUND(r.paid_revenue,2) AS attributed_revenue
FROM (
  SELECT substr(order_date,1,4)||'-Q'||((CAST(substr(order_date,6,2) AS INTEGER)+2)/3) AS quarter,
         SUM(net_revenue) AS total_net_revenue,
         SUM(CASE WHEN campaign_id IS NOT NULL THEN net_revenue END) AS paid_revenue
  FROM v_orders_mapped GROUP BY 1) r
JOIN (SELECT substr(date,1,4)||'-Q'||((CAST(substr(date,6,2) AS INTEGER)+2)/3) AS quarter,
             SUM(spend_azn) AS total_spend FROM ad_spend_clean GROUP BY 1) s
  ON s.quarter = r.quarter;
  

  