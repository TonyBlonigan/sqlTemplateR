--This is used in the @examples in query.R > generateSQL
SELECT
NVL(cust.S_DUNS_NBR, cust.CUST_KEY) CUST_KEY
--,naics.NAICS_DESC
--,MAX(prod.ITEM_DESC) ITEM_DESC

,SUM(sls.SLS_AMT) SLS_AMT

FROM SALES sls
INNER JOIN CUSTOMER cust
	ON sls.CUST_KEY = NVL(cust.S_DUNS_NBR, cust.CUST_KEY)
INNER JOIN PRODUCT prod
	ON sls.PROD_KEY = prod.PROD_KEY
INNER JOIN N_AM_CLASSIFICATION naics
	ON cust.NAICS_CODE = naics.NAICS_CODE

WHERE CAST(sls.SLS_YR || '-' || LPAD(CAST(sls.SLS_MNTH_INT AS CHAR), 2, '0') || '-' || '01' AS DATE) > ADD_MONTHS(DATE, - 14)
AND (cust.S_DUNS_NBR IS NOT NULL OR cust.CUST_CD = 'D')
--<prodFilter>
GROUP BY
NVL(cust.S_DUNS_NBR, cust.CUST_KEY)

--,naics.NAICS_DESC
