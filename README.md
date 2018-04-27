---
title: "SQLTemplateR"
author: "Tony Blonigan"
date: "`r Sys.Date()`"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{sqlTemplateR}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---

```{r globalOptions, include=FALSE}
knitr::opts_chunk$set(warning=FALSE, message=FALSE, eval=FALSE)
```

# sqlTemplateR
R interface to programmatically edit sqlTemplate files

## Motivation

SQL Templates and the `sqlTemplateExecute()` function work together to provide a simple interface for writing flexible queries that can be defined at run-time. There are two features that allow for flexible SQL, and prevent you from having to write tedious code to parse and edit your query:

* Column Activation, which lets you add fields to your query; and
* Tags, which let you add arbitrary SQL to your template (e.g., an additional WHERE clause)

But before we can get to those, we have to define the SQL Template format.

## SQL Template Format

### Standard SQL
Normally, you would write a query like this:

```{sql stdSQL}
SELECT cust.CUST_KEY,
prod.GLBL_BSIC_COMM_DESC,
SUM(pos.SLS_AMT) SLS_AMT
FROM DBSAAD31.POS_FACT pos
INNER JOIN DBSAAD31.CUST_DIM cust
    ON pos.CUST_KEY = NVL(cust.S_DUNS_NBR, cust.CUST_KEY)
INNER JOIN DBSAAD31.PROD_DIM prod
    ON pos.PROD_KEY = prod.PROD_KEY
WHERE CAST(pos.SLS_YR || '-' || LPAD(CAST(pos.SLS_MNTH_INT AS CHAR), 2, '0') || '-' || '01' AS DATE) > ADD_MONTHS(DATE, - 14)  
GROUP BY cust.CUST_KEY,
prod.GLBL_BSIC_COMM_DESC,
HAVING SUM(pos.SLS_AMT) > 0
```

But what if you wanted to be able to run the same analysis at different levels of the product hierarchy? You could create several versions of the same query, or hack out some text parsing that would update the columns and grouping. Or you could make some minor changes to the .sql file and use activation options.

### Column Activation

Here is the simple query above could be transformed into a query template that could be run at any level(s) of the product hierarchy:

```{sql activationSQL}
SELECT cust.CUST_KEY
--,prod.GLBL_BSIC_COMM_DESC
--,prod.COMM_CLASS_DESC
--,prod.GLBL_SLS_DESC
--,prod.MMM_ID_NBR
--,prod.ITEM_DESC
,SUM(pos.SLS_AMT) SLS_AMT
FROM DBSAAD31.POS_FACT pos
INNER JOIN DBSAAD31.CUST_DIM cust
    ON pos.CUST_KEY = NVL(cust.S_DUNS_NBR, cust.CUST_KEY)
INNER JOIN DBSAAD31.PROD_DIM prod
    ON pos.PROD_KEY = prod.PROD_KEY
WHERE CAST(pos.SLS_YR || '-' || LPAD(CAST(pos.SLS_MNTH_INT AS CHAR), 2, '0') || '-' || '01' AS DATE) > ADD_MONTHS(DATE, - 14)  
GROUP BY cust.CUST_KEY
--,prod.GLBL_BSIC_COMM_DESC
--,prod.COMM_CLASS_DESC
--,prod.GLBL_SLS_DESC
--,prod.MMM_ID_NBR
--,prod.ITEM_DESC
,prod.GLBL_BSIC_COMM_DESC
HAVING SUM(pos.SLS_AMT) > 0
```

Notice the changes:

1. Commented out column names have been added has been added to the SELECT and GROUP BY sections, for each level of the product hierarchy
2. Commas used to separate column names have been moved to the start of each line (SQL doesn’t care about lines or spaces, just that fileds are comma separated)

Now, we can activate any of the commeneted out fields from an SQL template file, like this:

```{r activateRun}
# setup odbc connection
mmmConnect()

# setup vector with name(s) of column(s) to activate
colsToActivate = c('prod.GLBL_BSIC_COMM_DESC','prod.ITEM_DESC')

# build and execute the qurey
sqlTemplateExecute(sqlTemplate = 'path/to/your/sqlTemplate.sql', activate = colsToActivate)
# NOTE: this executes the query against the variable containing your odbc connection.
# The default connection is .mmmConnection, which we created by running mmmConnect()

```

Before executing the query, sqlTemplateExecute removes '- –,' any time it is found infront of one of the columns listed under the activate parameter. So the query that would be executed would look like this:

```{sql activateResult}
SELECT cust.CUST_KEY
,prod.GLBL_BSIC_COMM_DESC
--,prod.COMM_CLASS_DESC
--,prod.GLBL_SLS_DESC
--,prod.MMM_ID_NBR
,prod.ITEM_DESC
,SUM(pos.SLS_AMT) SLS_AMT
FROM DBSAAD31.POS_FACT pos
INNER JOIN DBSAAD31.CUST_DIM cust
    ON pos.CUST_KEY = NVL(cust.S_DUNS_NBR, cust.CUST_KEY)
INNER JOIN DBSAAD31.PROD_DIM prod
    ON pos.PROD_KEY = prod.PROD_KEY
WHERE CAST(pos.SLS_YR || '-' || LPAD(CAST(pos.SLS_MNTH_INT AS CHAR), 2, '0') || '-' || '01' AS DATE) > ADD_MONTHS(DATE, - 14)  
GROUP BY cust.CUST_KEY
,prod.GLBL_BSIC_COMM_DESC
--,prod.COMM_CLASS_DESC
--,prod.GLBL_SLS_DESC
--,prod.MMM_ID_NBR
,prod.ITEM_DESC
,prod.GLBL_BSIC_COMM_DESC
HAVING SUM(pos.SLS_AMT) > 0
```

Tip: If there are columns that should not be used together, build some sort of validation process into the step where you define the columns to activate to make sure they are not included in the same query.

### Tags

While column activation is simple, there are other common changes that are better accomplished with tags. A tag is any string between these guys: “<>.” Here are a few examples: 

* \<duns_nbr\> 
* \<corpDivCd\> 
* \<additionalWhereClauses\>

If you wanted to run the query above, but compare outcomes at several minimum SLS_AMT threasholds, you could change your SQL template to this:

```{sql tagExample}
SELECT cust.CUST_KEY
--,prod.GLBL_BSIC_COMM_DESC
--,prod.COMM_CLASS_DESC
--,prod.GLBL_SLS_DESC
--,prod.MMM_ID_NBR
--,prod.ITEM_DESC
,SUM(pos.SLS_AMT) SLS_AMT
FROM DBSAAD31.POS_FACT pos
INNER JOIN DBSAAD31.CUST_DIM cust
    ON pos.CUST_KEY = NVL(cust.S_DUNS_NBR, cust.CUST_KEY)
INNER JOIN DBSAAD31.PROD_DIM prod
    ON pos.PROD_KEY = prod.PROD_KEY
WHERE CAST(pos.SLS_YR || '-' || LPAD(CAST(pos.SLS_MNTH_INT AS CHAR), 2, '0') || '-' || '01' AS DATE) > ADD_MONTHS(DATE, - 14)  
GROUP BY cust.CUST_KEY
--,prod.GLBL_BSIC_COMM_DESC
--,prod.COMM_CLASS_DESC
--,prod.GLBL_SLS_DESC
--,prod.MMM_ID_NBR
--,prod.ITEM_DESC
,prod.GLBL_BSIC_COMM_DESC
HAVING SUM(pos.SLS_AMT) > <min_SLS_AMT>
```

Now, you could use this code to set the minimum sales threasholds:

```{r tagRun}
# setup list with tag(s) and replacement values
tags = list(min_SLS_AMT = 900)

# execute the query
sqlTemplateExecute(sqlTemplate = 'path/to/your/sqlTemplate.sql', 
                   activate = colsToActivate,
                   tagMap = tags)
```

Each tag is replaced with the value associated with its name in the tagMap arg list. The tags are case sensitive, so be careful.

Also, if a tag is after a "- –" comment, the "- –" is removed before replacing the tag with its tagMap value. Here is the query that gets executed for the example above:

```{sql tagResults}
SELECT cust.CUST_KEY
,prod.GLBL_BSIC_COMM_DESC
--,prod.COMM_CLASS_DESC
--,prod.GLBL_SLS_DESC
--,prod.MMM_ID_NBR
,prod.ITEM_DESC
,SUM(pos.SLS_AMT) SLS_AMT
FROM DBSAAD31.POS_FACT pos
INNER JOIN DBSAAD31.CUST_DIM cust
    ON pos.CUST_KEY = NVL(cust.S_DUNS_NBR, cust.CUST_KEY)
INNER JOIN DBSAAD31.PROD_DIM prod
    ON pos.PROD_KEY = prod.PROD_KEY
WHERE CAST(pos.SLS_YR || '-' || LPAD(CAST(pos.SLS_MNTH_INT AS CHAR), 2, '0') || '-' || '01' AS DATE) > ADD_MONTHS(DATE, - 14)  
GROUP BY cust.CUST_KEY
,prod.GLBL_BSIC_COMM_DESC
--,prod.COMM_CLASS_DESC
--,prod.GLBL_SLS_DESC
--,prod.MMM_ID_NBR
,prod.ITEM_DESC
,prod.GLBL_BSIC_COMM_DESC
HAVING SUM(pos.SLS_AMT) > 900
```

## Parting Thoughts
These functions can be especially usefull if you need to run the same report for different segments of the company, or testing how applying a range of values to a set of parameters affect outcomes. In either case, loop through the set of variables you want to test and re-run the code with each combination.
