
-- Lumira Cosmetics | Addım 1: Təmizləmə (SQLite)
-- Qayda: xam cədvəllərə yalnız dublikatların tapılıb
-- silinməsi üçün müraciət edirik, o cədvəllərdə başqa 
-- heç bir əməliyyat etməyəcəyik. Təmiz versiyalar *_clean adı ilə yaranacaq.

select * from orders

--orders cedvelindeki dublikatlarin tapilmasi
select order_id, count(*) as dublikat_count
from orders
group by order_id
having count(*) > 1;

--Dublikatlarin silinmesi
DELETE from orders
WHERE rowid not in
(select min(rowid) from orders
GROUP BY order_id)

--Yoxlama
SELECT campaign_id, COUNT(*) FROM ad_spend_daily WHERE spend < 0 GROUP BY 1;
SELECT COUNT(*), SUM(spend) FROM ad_spend_daily;
SELECT COUNT(*), COUNT(DISTINCT order_id) FROM orders;

DROP TABLE IF EXISTS cleaning_log;
CREATE TABLE cleaning_log (
  step INTEGER, table_name TEXT, issue TEXT, rows_affected INTEGER, action TEXT
);

-- 1. ORDERS
DROP TABLE IF EXISTS orders_norm;
CREATE TABLE orders_norm AS
SELECT
  order_id, customer_id,
  -- 'DD.MM.YYYY HH:MM' -> 'YYYY-MM-DD HH:MM:SS'
  CASE WHEN instr(order_datetime,'.') > 0
       THEN substr(order_datetime,7,4)||'-'||substr(order_datetime,4,2)||'-'||substr(order_datetime,1,2)||' '||substr(order_datetime,12,5)||':00'
       ELSE order_datetime END AS order_datetime,
  order_status, order_value, discount_amount, promo_code, device,
  CASE lower(trim(utm_source))
       WHEN 'fb' THEN 'facebook'  WHEN 'ig' THEN 'instagram'
       WHEN 'tt' THEN 'tiktok'    WHEN 'email' THEN 'newsletter'
       ELSE lower(trim(utm_source)) END AS utm_source,
  lower(trim(utm_medium))   AS utm_medium,
  lower(trim(utm_campaign)) AS utm_campaign
FROM orders;

INSERT INTO cleaning_log
SELECT 1,'orders','Tarix formatı qarışıqdır (DD.MM.YYYY HH:MM)', count(*), 'ISO formatına çevrildi'
FROM orders WHERE instr(order_datetime,'.')>0;

INSERT INTO cleaning_log
SELECT 2,'orders','UTM yazılışı (Google/fb/FB/ig/tt/GS_BRAND ...)', count(*), 'lower+trim, qısaltmalar xəritələndi'
FROM orders o WHERE utm_source <> lower(utm_source) OR utm_campaign <> lower(utm_campaign)
   OR utm_source IN ('fb','ig','tt','email');
   
INSERT INTO cleaning_log
SELECT 3,'orders','Dublikat sifarişlər (tam eyni sətir)', count(*)-count(DISTINCT order_id), 'ilk sətir saxlanıldı'
FROM orders;

INSERT INTO cleaning_log
SELECT 4,'orders','Test sifarişləri (order_id TEST%, customer L000000, 0.01 AZN)', count(*), 'xaric edildi'
FROM orders WHERE order_id LIKE 'TEST%' OR customer_id='L000000';

INSERT INTO cleaning_log
SELECT 5,'orders','Anomal yüksək sifariş dəyəri (> 1000 AZN; normal maks ~376)', count(*), 'xaric edildi'
FROM orders WHERE order_value > 1000 AND order_id NOT LIKE 'TEST%';

INSERT INTO cleaning_log
SELECT 6,'orders','Advantage+ kampaniyasına start tarixindən (2026-04-01) əvvəl bağlanmış sifariş', count(*), 'kampaniyası NULL edildi (flag)'
FROM orders_norm WHERE utm_campaign='meta_advplus_broad' AND order_datetime < '2026-04-01';

DROP TABLE IF EXISTS orders_clean;
CREATE TABLE orders_clean AS
WITH ranked AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_datetime) rn
  FROM orders_norm
)
SELECT
  order_id, customer_id, order_datetime, substr(order_datetime,1,10) AS order_date,
  order_status, order_value, discount_amount, promo_code, device,
  utm_source, utm_medium,
  CASE WHEN utm_campaign='meta_advplus_broad' AND order_datetime < '2026-04-01'
       THEN NULL ELSE utm_campaign END AS utm_campaign,
  -- xalis gəlir: yalnız completed; cancelled/refunded gəlirə daxil deyil
  CASE WHEN order_status='completed' THEN order_value - discount_amount ELSE 0 END AS net_revenue
FROM ranked
WHERE rn = 1
  AND order_id NOT LIKE 'TEST%' AND customer_id <> 'L000000'
  AND order_value <= 1000;
  
-- 2. AD_SPEND_DAILY
DROP TABLE IF EXISTS spend_norm;
CREATE TABLE spend_norm AS
SELECT
  CASE WHEN instr(date,'/')>0
       THEN substr(date,7,4)||'-'||substr(date,4,2)||'-'||substr(date,1,2) ELSE date END AS date,
  upper(trim(campaign_id)) AS campaign_id,
  impressions, clicks, spend, upper(trim(currency)) AS currency,
  platform_conversions, platform_conversion_value
FROM ad_spend_daily;

INSERT INTO cleaning_log
SELECT 7,'ad_spend_daily','Tarix formatı qarışıqdır (DD/MM/YYYY)', count(*), 'ISO formatına çevrildi'
FROM ad_spend_daily WHERE instr(date,'/')>0;

INSERT INTO cleaning_log
SELECT 8,'ad_spend_daily','campaign_id kiçik hərflə (c01...)', count(*), 'upper() edildi'
FROM ad_spend_daily WHERE campaign_id <> upper(campaign_id);

INSERT INTO cleaning_log
SELECT 9,'ad_spend_daily','Valyuta USD (C10 TikTok Flight C)', count(*), 'spend və platform_conversion_value x1.70 ilə AZN-ə çevrildi'
FROM ad_spend_daily WHERE upper(currency)='USD';

INSERT INTO cleaning_log
SELECT 10,'ad_spend_daily','Mənfi xərc sətirləri (impressions=0, spend<0)', count(*), 'xaric edildi (düzəliş/kredit sətirləri)'
FROM ad_spend_daily WHERE spend < 0;

INSERT INTO cleaning_log
SELECT 11,'ad_spend_daily','clicks > impressions (clicks = 3 x impressions)', count(*), 'clicks NULL edildi (CTR/CPC-də istifadə olunmur)'
FROM ad_spend_daily WHERE clicks > impressions;

INSERT INTO cleaning_log
SELECT 12,'ad_spend_daily','Dublikat (date+campaign_id), normalizasiyadan sonra', count(*)-count(DISTINCT date||campaign_id), 'ilk sətir saxlanıldı'
FROM spend_norm WHERE spend > 0;

DROP TABLE IF EXISTS ad_spend_clean;
CREATE TABLE ad_spend_clean AS
WITH ranked AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY date, campaign_id ORDER BY impressions DESC) rn
  FROM spend_norm WHERE spend > 0
)
SELECT
  date, campaign_id, impressions,
  CASE WHEN clicks > impressions THEN NULL ELSE clicks END AS clicks,
  CASE WHEN currency='USD' THEN round(spend*1.70,2) ELSE spend END AS spend_azn,
  platform_conversions,
  CASE WHEN currency='USD' THEN round(platform_conversion_value*1.70,2) ELSE platform_conversion_value END AS platform_conversion_value_azn,
  currency AS original_currency
FROM ranked WHERE rn = 1;

-- 3. WEB_TRAFFIC_DAILY
INSERT INTO cleaning_log
SELECT 13,'web_traffic_daily','Tarixi/device-ı olmayan zibil sətirlər', count(*), 'xaric edildi'
FROM web_traffic_daily WHERE date IS NULL;

DROP TABLE IF EXISTS web_traffic_clean;
CREATE TABLE web_traffic_clean AS
WITH norm AS (
  SELECT date,
    CASE lower(trim(utm_source)) WHEN 'fb' THEN 'facebook' WHEN 'ig' THEN 'instagram'
         WHEN 'tt' THEN 'tiktok' WHEN 'email' THEN 'newsletter' ELSE lower(trim(utm_source)) END AS utm_source,
    lower(trim(utm_medium)) AS utm_medium, lower(trim(utm_campaign)) AS utm_campaign,
    device, sessions, bounced_sessions, avg_session_duration_sec
  FROM web_traffic_daily WHERE date IS NOT NULL
), ranked AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY date,utm_source,utm_medium,utm_campaign,device ORDER BY sessions DESC) rn
  FROM norm
)
SELECT date, utm_source, utm_medium, utm_campaign, device, sessions, bounced_sessions, avg_session_duration_sec,
  -- 12-14 may 2026 tt_flight_c mobile: bounce ~2%, müddət ~34 san -> bot şübhəsi (analiz 1.3-də təsdiqlənir)
  CASE WHEN date BETWEEN '2026-05-12' AND '2026-05-14'
        AND utm_campaign='tt_flight_c' AND device='mobile' THEN 1 ELSE 0 END AS is_suspected_bot
FROM ranked WHERE rn = 1;

INSERT INTO cleaning_log
SELECT 14,'web_traffic_daily','Dublikat sətirlər (date+utm+device)', 
  (SELECT count(*) FROM web_traffic_daily 
  WHERE date IS NOT NULL) - (SELECT count(*) 
  FROM web_traffic_clean), 'ilk sətir saxlanıldı (UTM normalizasiyasından sonra)';

INSERT INTO cleaning_log
SELECT 15,'web_traffic_daily','12-14 may 2026 bot trafiki (tt_flight_c, mobile)', count(*), 'is_suspected_bot=1 flag; analizdən xaric'
FROM web_traffic_clean WHERE is_suspected_bot=1;
  
-- 4. CUSTOMERS
DROP TABLE IF EXISTS customers_clean;
CREATE TABLE customers_clean AS
SELECT customer_id, first_order_date, first_channel,
  CASE WHEN lower(city) IN ('baku','bakı') THEN 'Baku' ELSE city END AS city,
  gender, COALESCE(age_group,'unknown') AS age_group, marketing_opt_in
FROM customers;

INSERT INTO cleaning_log
SELECT 16,'customers','Şəhər yazılışı (BAKU/baku/Bakı)', count(*), 'Baku-ya standartlaşdırıldı'
FROM customers WHERE lower(city) IN ('baku','bakı') AND city <> 'Baku';

-- 5. KAMPANIYA XƏRİTƏSİ (utm_campaign -> campaign_id)
DROP VIEW IF EXISTS v_orders_mapped;
CREATE VIEW v_orders_mapped AS
SELECT o.*, c.campaign_id, c.campaign_name, c.channel, c.platform, c.objective,
  CASE WHEN c.campaign_id IS NULL THEN 'unmapped' ELSE 'mapped' END AS map_status
FROM orders_clean o
LEFT JOIN campaigns c ON c.utm_campaign = o.utm_campaign

--SINAQ MƏRHƏLƏSİ
SELECT * FROM cleaning_log 
ORDER BY step;


  
