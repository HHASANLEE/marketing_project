# Lumira Cosmetics | Marketing Analytics & Budget Optimization

**Marketing Performance Analysis · SQL · SQLite · Power BI · Data Cleaning · Attribution**

## Layihə haqqında

Bu layihənin məqsədi Lumira Cosmetics şirkətinin rəqəmsal marketinq fəaliyyətini kompleks şəkildə təhlil etmək, reklam büdcəsinin effektivliyini qiymətləndirmək və növbəti rüb üçün data əsaslı büdcə optimallaşdırma strategiyası hazırlamaqdır.

Layihə çərçivəsində reklam platformalarından, web analitika sistemindən və CRM sifariş bazasından əldə olunan məlumatlar vahid və etibarlı analitik bazada birləşdirilir.

Əsas diqqət reklam xərclərinin gəlirə təsirinə, kampaniya performansına, atribusiya fərqlərinə, inkrementallığa və reklam büdcəsinin optimallaşdırılmasına yönəldilib.

## Biznes problemi

Şirkətin CFO-su və marketinq komandası aşağıdakı suallara cavab axtarır:

- Q2-də reklam xərcləri artdığı halda gəlir niyə eyni səviyyədə qalıb?
- Hansı reklam kanalları və kampaniyalar daha effektivdir?
- Reklam platformalarının bildirdiyi konversiyalar CRM nəticələrindən nə qədər fərqlənir?
- Brand kampaniyası həqiqətən əlavə satış yaradır, yoxsa mövcud müştərilərin atribusiyasını öz üzərinə götürür?
- TikTok və Meta kampaniyalarında reklam doyma və kreativ yorğunluğu müşahidə olunurmu?
- Q3 reklam büdcəsi 25% azaldılarsa, gəlirə mümkün təsir nə olacaq?

## Layihənin məqsədləri

1. Müxtəlif mənbələrdən gələn məlumatları təmizləyərək vahid analitik baza yaratmaq.
2. Kampaniya və platforma səviyyəsində marketinq performansını ölçmək.
3. Q1 və Q2 nəticələrini müqayisə edərək büdcə dəyişikliklərinin təsirini müəyyənləşdirmək.
4. Brand kampaniyasının inkremental təsirini qiymətləndirmək.
5. Reklam doyma və kreativ yorğunluq əlamətlərini araşdırmaq.
6. Q3 üçün optimallaşdırılmış reklam büdcəsi və gəlir proqnozu hazırlamaq.

## İstifadə olunan texnologiyalar

| Texnologiya | İstifadə məqsədi |
|---|---|
| SQL | Məlumatların təmizlənməsi və analizi |
| SQLite | Vahid analitik verilənlər bazası |
| Power BI | Dashboard və vizuallaşdırma |
| Excel / CSV | İlkin məlumat mənbələri |
| Marketing Analytics | Kampaniya performansının qiymətləndirilməsi |

## Layihənin mərhələləri

### 1. Data Cleaning & Data Integration

İlkin məlumatlar reklam platformalarından, web analitika sistemindən və CRM-dən əldə olunub.

SQL vasitəsilə aşağıdakı əməliyyatlar həyata keçirilib:

- Tarix formatlarının standartlaşdırılması.
- UTM parametrlərinin normallaşdırılması.
- Kampaniya ID-lərinin vahid formata gətirilməsi.
- Dublikat sifariş və reklam xərclərinin təmizlənməsi.
- Test sifarişlərinin çıxarılması.
- Anomal sifarişlərin müəyyənləşdirilməsi və xaric edilməsi.
- USD valyutasında olan reklam xərclərinin AZN-ə çevrilməsi.
- Mənfi xərc qeydlərinin ayrılması.
- Anomal klik göstəricilərinin təmizlənməsi.
- Trafik cədvəlindəki etibarsız qeydlərin çıxarılması.
- Şəhər adlarının standartlaşdırılması.
- Bot trafikinin müəyyənləşdirilməsi və işarələnməsi.

**Təmizləmə nəticələri:**

| Problem | Təsirlənmiş sətir sayı |
|---|---:|
| Sifariş tarixlərinin standartlaşdırılması | 952 |
| Reklam xərci tarixlərinin standartlaşdırılması | 146 |
| UTM normallaşdırılması | 2,562 |
| Campaign ID düzəlişləri | 32 |
| Dublikat sifarişlər | 95 |
| Dublikat reklam xərcləri | 14 |
| Dublikat trafik qeydləri | 3 |
| Test sifarişləri | 14 |
| Anomal sifarişlər | 6 |
| USD-dən AZN-ə çevrilən xərc qeydləri | 122 |
| Mənfi xərc qeydləri | 6 |
| Anomal klik qeydləri | 9 |
| Etibarsız trafik qeydləri | 6 |
| Şəhər adlarının standartlaşdırılması | 919 |
| Bot trafik kimi işarələnən qeydlər | 3 |

Xam məlumatlar dəyişdirilməyib. Təmizlənmiş məlumatlar ayrıca cədvəllərdə saxlanılıb.

Yaradılmış əsas cədvəllər:

- `orders_clean`
- `ad_spend_clean`
- `web_traffic_clean`
- `customers_clean`
- `cleaning_log`

### 2. Campaign Mapping & Attribution

Sifarişlər `utm_campaign` əsasında reklam kampaniyaları ilə əlaqələndirilib.

**Əsas nəticələr:**

- Təmizləmədən sonra CRM-də 46,812 sifariş mövcuddur.
- 23,992 sifariş kampaniya ilə əlaqələndirilməyib.
- Kampaniyaya bağlanmayan sifarişlərin payı 51.3%-dir.
- Kampaniya adı mövcud olub, kampaniya xəritəsində tapılmayan sifariş qeydə alınmayıb.

Kampaniyaya bağlanmayan sifarişlər əsasən Organic Search, Referral və Direct kanallarından gəldiyi üçün onların hamısını atribusiya xətası hesab etmək düzgün deyil.

### 3. Traffic Anomaly Analysis

12–14 may tarixlərində müşahidə olunan trafik artımı araşdırılıb.

Təhlil zamanı müəyyən edilib ki:

- Trafik artımı əsasən `tt_flight_c` kampaniyasının mobil trafikindən qaynaqlanıb.
- Gündəlik sessiya sayı təxminən 6,500-ə yüksəlib.
- Normal gündəlik sessiya sayı təxminən 360 olub.
- Bounce rate 2%-ə düşüb (normal göstərici təxminən 38%).
- Sessiya müddəti 34 saniyə olub (normal göstərici təxminən 81 saniyə).
- Trafik artımına baxmayaraq, gündəlik sifariş sayı 80–105 intervalında qalıb.

**Qərar:** Bu trafik real müştəri davranışına uyğun gəlmədiyi üçün bot və ya etibarsız trafik kimi qiymətləndirilib. Müvafiq qeydlər silinmək əvəzinə işarələnib.

### 4. Campaign Performance Scorecard

Kampaniyaların performansı 2026-cı ilin Q1 və Q2 rübləri üzrə qiymətləndirilir.

Hesablanan KPI-lar:

| KPI | Formula |
|---|---|
| CTR | Clicks / Impressions × 100 |
| CPC | Ad Spend / Clicks |
| CPA | Ad Spend / CRM Orders |
| ROAS | CRM Net Revenue / Ad Spend |
| MER | Total Net Revenue / Total Ad Spend |

Gəlir hesablamalarında CRM-in last-click atribusiya modeli əsas götürülür.

Əlavə olaraq hər platformanın bildirdiyi konversiyalar CRM sifarişləri ilə müqayisə edilir.

### 5. Marketing Budget Effectiveness (Q1 → Q2)

Q1-dən Q2-yə reklam xərclərindəki dəyişiklik kampaniya səviyyəsində araşdırılır.

Analizin əsas istiqamətləri:

- Kampaniyalar üzrə xərc artımı və azalması.
- Əlavə reklam xərcinin gəlirə təsiri.
- Marjinal ROAS hesablanması.
- Meta Advantage+ Broad kampaniyasının digər prospecting kampaniyalarına təsiri.
- Potensial kampaniya kanibalizasiyasının qiymətləndirilməsi.

Marjinal ROAS aşağıdakı formula ilə hesablanır:

`Marginal ROAS = Incremental Revenue / Incremental Ad Spend`

### 6. Incrementality Analysis – Brand Campaign

Brand kampaniyasının həqiqətən əlavə satış yaradıb-yaratmadığını qiymətləndirmək üçün kampaniyanın üç həftəlik dayanma dövrü təbii eksperiment kimi istifadə edilir.

Üç dövr müqayisə olunur:

1. Kampaniyanın dayanmasından əvvəlki 3 həftə.
2. Kampaniyanın dayandığı 3 həftə.
3. Kampaniyanın yenidən aktivləşməsindən sonrakı 3 həftə.

Analiz zamanı:

- Brand reklamından gələn sifarişlər.
- Organic Google Search sifarişləri.
- Digər kanallardan gələn sifarişlər.
- Mövsümi dəyişikliklər.

nəzərə alınır.

Əsas məqsəd brand reklamı dayandıqda itirilən sifarişlərin nə qədərinin digər kanallara keçdiyini müəyyənləşdirmək və inkremental ROAS (iROAS) hesablamaqdır.

### 7. Ad Fatigue & Diminishing Returns

Reklam performansında doyma və kreativ yorğunluğu araşdırılır.

**TikTok:**
- Kreativlərin aktiv olduğu flight dövrü müəyyənləşdirilir.
- Kreativin yaşına görə CTR dəyişməsi təhlil edilir.
- CTR-in azalması əsasında kreativ yenilənməsi üçün tövsiyələr hazırlanır.

**Meta Prospecting:**
- Aylıq reklam xərcləri və CPA müqayisə edilir.
- Büdcə artımının əldə edilən sifarişlərə təsiri araşdırılır.
- Azalan marjinal effektivlik əlamətləri qiymətləndirilir.

### 8. Q3 Budget Optimization – 25% Budget Cut

Q3 reklam büdcəsi Q2 reklam xərclərinin 75%-i həcmində planlaşdırılır.

Kampaniya səviyyəsində:

- Q2 faktiki reklam xərci.
- Q3 üçün təklif olunan büdcə.
- Gözlənilən gəlir təsiri.
- Büdcə bölgüsünün əsaslandırılması.

hazırlanır.

Üç fərqli proqnoz ssenarisi nəzərdə tutulur:

| Ssenari | Yanaşma |
|---|---|
| Optimist | Effektiv kampaniyaların qorunması və büdcənin optimallaşdırılması |
| Baza | Mövcud performansın müəyyən qədər qorunması |
| Pessimist | Büdcə azalmasının satışlara daha güclü təsiri |

Q3 üçün əlavə olaraq aşağıdakı testlər tövsiyə edilir:

- Geo-holdout test.
- Brand-off experiment.
- Kreativ rotasiyası.
- Meta prospecting auditoriyalarının ayrılıqda yoxlanılması.

## Əsas biznes nəticələri

İlkin data təmizlənməsi nəticəsində aşağıdakı vacib məqamlar müəyyən edilib:

1. Reklam, CRM və web analitika məlumatları arasında vahid metodologiyanın tətbiqi zəruridir.
2. Sifarişlərin 51.3%-i kampaniya səviyyəsində last-click atribusiyasına bağlanmır.
3. 12–14 may tarixlərindəki trafik artımı real müştəri davranışını əks etdirmir.
4. Reklam xərclərinin vahid valyutada — AZN ilə hesablanması təmin edilib.
5. Q1–Q2 müqayisəsi, inkrementallıq və büdcə optimallaşdırması üçün təmiz analitik baza yaradılıb.

## Data & Methodology Assumptions

Hesabatda aşağıdakı fərziyyələr tətbiq edilib:

**1. USD → AZN məzənnəsi**

USD ilə qeydə alınmış reklam xərclərinin AZN-ə çevrilməsi üçün 1 USD = 1.70 AZN məzənnəsi qəbul edilib.

**2. Mənfi reklam xərcləri**

Mənfi xərc qeydləri mümkün platforma kreditləri və düzəlişləri ola biləcəyi üçün əsas xərc hesablamasından xaric edilib. Bu qeydlərin ümumi təsiri təxminən 400 AZN-dir.

**3. Attribution**

Kampaniya gəlirlərinin hesablanmasında CRM last-click atribusiyası əsas götürülüb.

**4. Bot traffic**

12–14 may tarixlərində şübhəli trafik qeydləri müştəri trafiki kimi qəbul edilməyib.

## Repository Structure

```text
Lumira-Cosmetics-Marketing-Analytics/
│
├── data/
│   ├── raw/
│   └── cleaned/
│
├── sql/
│   └── 01_cleaning.sql
│
├── powerbi/
│   └── marketing_dashboard.pbix
│
├── reports/
│   ├── cleaning_log
│   ├── campaign_scorecard
│   ├── budget_analysis
│   └── q3_budget_plan
│
└── README.md
```

*Qeyd: Bu struktur layihənin tövsiyə olunan təşkilati quruluşudur.*

## Nəticə

Lumira Cosmetics Marketing Analytics layihəsi marketinq fəaliyyətinin sadəcə reklam platformalarının hesabatları əsasında deyil, CRM-də qeydə alınmış real sifariş və xalis gəlir əsasında qiymətləndirilməsinə yönəlib.

Layihənin əsas məqsədi marketinq və maliyyə komandalarına daha şəffaf performans ölçümü, düzgün büdcə bölgüsü və data əsaslı qərarvermə imkanı yaratmaqdır.

---

**Project Focus:** Marketing Analytics | Performance Marketing | Budget Optimization | Attribution | SQL | Power BI

**Industry:** Beauty & Cosmetics
