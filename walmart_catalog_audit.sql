
CREATE TABLE IF NOT EXISTS public.raw_catalog (
    "Uniq Id" TEXT,
    "Crawl Timestamp" TEXT,
    "Product Url" TEXT,
    "Product Name" TEXT,
    "Description" TEXT,
    "List Price" TEXT,
    "Sale Price" TEXT,
    "Brand" TEXT,
    "Item Number" TEXT,
    "Gtin" TEXT,
    "Package Size" TEXT,
    "Category" TEXT,
    "Postal Code" TEXT,
    "Available" TEXT
);

CREATE OR REPLACE VIEW public.walmart_cleaned AS
SELECT
    "Uniq Id" AS listing_id,
    "Product Name" AS product_name,
    "Product Url" AS product_url,
    "Category" AS category_path,
    COALESCE(NULLIF(TRIM(SPLIT_PART("Category", '|', 1)), ''), 'Unknown')
        AS department,
    NULLIF(TRIM("List Price"), '')::numeric AS list_price,
    NULLIF(TRIM("Sale Price"), '')::numeric AS sale_price,
    CASE UPPER(TRIM("Available"))
        WHEN 'TRUE' THEN TRUE
        WHEN 'FALSE' THEN FALSE
    END AS available
FROM public.raw_catalog;

-- Import check: 30,000 rows and 30,000 distinct listing IDs.
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT listing_id) AS distinct_listings
FROM public.walmart_cleaned;

-- Overall availability: 2,072 unavailable (6.91%).
SELECT COUNT(*) AS total_listings,
       COUNT(*) FILTER (WHERE available IS FALSE) AS unavailable_listings,
       ROUND(100.0 * COUNT(*) FILTER (WHERE available IS FALSE)
             / NULLIF(COUNT(available), 0), 2) AS unavailable_rate_pct
FROM public.walmart_cleaned;

-- Pricing audit: 1,551 markdowns (5.24%), 396 zero prices, 2 above list.
WITH pricing AS (
    SELECT
        COUNT(*) FILTER (WHERE list_price > 0 AND sale_price > 0)
            AS comparable_listings,
        COUNT(*) FILTER (WHERE sale_price > 0 AND sale_price < list_price)
            AS markdown_listings,
        COUNT(*) FILTER (WHERE list_price = 0 OR sale_price = 0)
            AS zero_price_listings,
        COUNT(*) FILTER (WHERE list_price > 0 AND sale_price > list_price)
            AS above_list_price_listings
    FROM public.walmart_cleaned
)
SELECT *,
       ROUND(100.0 * markdown_listings / NULLIF(comparable_listings, 0), 2)
           AS markdown_rate_pct
FROM pricing;

-- Department ranking by unavailable listing count.
SELECT department,
       COUNT(*) AS total_listings,
       COUNT(*) FILTER (WHERE available IS FALSE) AS unavailable_listings,
       ROUND(100.0 * COUNT(*) FILTER (WHERE available IS FALSE)
             / NULLIF(COUNT(available), 0), 2) AS unavailable_rate_pct
FROM public.walmart_cleaned
GROUP BY department
ORDER BY unavailable_listings DESC, department;

-- Food spotlight: the three category paths with the most unavailable listings.
SELECT category_path,
       COUNT(*) AS total_listings,
       COUNT(*) FILTER (WHERE available IS FALSE) AS unavailable_listings,
       ROUND(100.0 * COUNT(*) FILTER (WHERE available IS FALSE)
             / NULLIF(COUNT(available), 0), 2) AS unavailable_rate_pct
FROM public.walmart_cleaned
WHERE department = 'Food'
GROUP BY category_path
ORDER BY unavailable_listings DESC, category_path
LIMIT 3;
