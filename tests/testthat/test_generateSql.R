context("Generate SQL")

test_that("genarateSQL works", {
  # plain string column activation
  expect_equal(generateSQL(sqlTemplate = '../../R/exampleSqlTemplate.sql',
                           activate = "naics.NAICS_DESC",
                           tagMap = NULL),
               "--This is used in the @examples in query.R > generateSQL\r\nSELECT\r\nNVL(cust.S_DUNS_NBR, cust.CUST_KEY) CUST_KEY\r\n,naics.NAICS_DESC\r\n--,MAX(prod.ITEM_DESC) ITEM_DESC\r\n\r\n,SUM(pos.SLS_AMT) SLS_AMT\r\n\r\nFROM SALES pos\r\nINNER JOIN CUSTOMER cust\r\n\tON pos.CUST_KEY = NVL(cust.S_DUNS_NBR, cust.CUST_KEY)\r\nINNER JOIN PRODUCT prod\r\n\tON pos.PROD_KEY = prod.PROD_KEY\r\nINNER JOIN N_AM_CLASS naics\r\n\tON cust.NAICS_CODE = naics.NAICS_CODE\r\n\r\nWHERE CAST(pos.SLS_YR || '-' || LPAD(CAST(pos.SLS_MNTH_INT AS CHAR), 2, '0') || '-' || '01' AS DATE) > ADD_MONTHS(DATE, - 14)\r\nAND (cust.S_DUNS_NBR IS NOT NULL OR cust.CUST_CD = 'D')\r\n--<prodFilter>\r\nGROUP BY\r\nNVL(cust.S_DUNS_NBR, cust.CUST_KEY)\r\n\r\n,naics.NAICS_DESC\r\n")

  expect_equal(generateSQL(sqlTemplate = '../../R/exampleSqlTemplate.sql',
                           activate = "MAX(prod.ITEM_DESC) ITEM_DESC",
                           tagMap = NULL),
               "--This is used in the @examples in query.R > generateSQL\r\nSELECT\r\nNVL(cust.S_DUNS_NBR, cust.CUST_KEY) CUST_KEY\r\n--,naics.NAICS_DESC\r\n,MAX(prod.ITEM_DESC) ITEM_DESC\r\n\r\n,SUM(pos.SLS_AMT) SLS_AMT\r\n\r\nFROM SALES pos\r\nINNER JOIN CUSTOMER cust\r\n\tON pos.CUST_KEY = NVL(cust.S_DUNS_NBR, cust.CUST_KEY)\r\nINNER JOIN PRODUCT prod\r\n\tON pos.PROD_KEY = prod.PROD_KEY\r\nINNER JOIN N_AM_CLASS naics\r\n\tON cust.NAICS_CODE = naics.NAICS_CODE\r\n\r\nWHERE CAST(pos.SLS_YR || '-' || LPAD(CAST(pos.SLS_MNTH_INT AS CHAR), 2, '0') || '-' || '01' AS DATE) > ADD_MONTHS(DATE, - 14)\r\nAND (cust.S_DUNS_NBR IS NOT NULL OR cust.CUST_CD = 'D')\r\n--<prodFilter>\r\nGROUP BY\r\nNVL(cust.S_DUNS_NBR, cust.CUST_KEY)\r\n\r\n--,naics.NAICS_DESC\r\n")
})
