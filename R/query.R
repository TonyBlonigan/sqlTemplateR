# Run SQL Querries --------------------------------------------------------
#' Return the results of running SQL file
#'
#' \code{sqlFileExecute} returns the results of an SQL query, as a data frame
#'
#' This function makes it convenient to develop your SQL in whatever IDE you
#' choose, without copy/pasting code to your R script--which would make
#' maintenance tedious.
#'
#' @param sqlFile String. The path to your .sql file
#' @param stringsAsFactors Boolean. Will strings be converted to factors?
#' @param connectVar RODBC Connection. Name of the object holding your ODBC connection.
#' @return Data frame containing the results of your SQL query executed agaist
#' the named channel.
#' @examples
#' df = sqlFileExecute(sqlFile = 'file/path/exampleQuery.sql', stringsAsFactors = FALSE)
#' @export

sqlFileExecute = function(sqlFile, stringsAsFactors = TRUE, connectVar) {

  sql = readFile(filePath = sqlFile)

  return(RODBC::sqlQuery(connectVar, sql, stringsAsFactors = stringsAsFactors))
}



#' Build and run a sqlTemplate file
#'
#' @inheritParams generateSQL
#' @inheritParams sqlFileExecute
#' @param debug Boolean: Default False, weather to print query for debug
#'
#' @return Data frame of sql query results
#' @export
#'
sqlTemplateExecute = function(sqlTemplate, activate = NULL, tagMap = NULL,
                              stringsAsFactors = TRUE, connectVar,
                              debug = FALSE) {

  # add special security tags defined in data-raw folder
  if (!exists('tagMap')) {
    tagMap = list()
  }

  # add security tags
  tagMap$security_header = sqlTemplateR::security_header

  tagMap$security_filter = sqlTemplateR::security_filter

  # generate sql
  sql = generateSQL(sqlTemplate = sqlTemplate,
                    activate = activate,
                    tagMap = tagMap)

  # populate the tag in the security header
  if (!is.null(tagMap[['user_id']])) {
    sql = sub('--<user_id>|<user_id>', tagMap$user_id, sql)
  }

  # print for debug
  if (debug) {
    print(sql)
  }

  return(RODBC::sqlQuery(channel = connectVar,
                         query = sql,
                         stringsAsFactors = stringsAsFactors))
}





# Generate SQL Querries ---------------------------------------------------
#' Read a text file
#'
#' @param filePath path to file to read
#'
#' @return string representation of text file
#' @export
#'
#' @examples readFile(filePath = 'example.sql')
readFile = function(filePath = '') {
  # parse the sqlFile
  sqlLength = file.info(filePath)$size

  sql = readChar(con = filePath, nchars = sqlLength)

  return(sql)
}




#' Generate query from an SQL template file
#'
#' @param sqlTemplate String: path to SQL Template File
#' @param tagMap List: Tags and the string they should be replaced with
#' @param activate String: Vector of column names that should be uncommented.
#' If using alias, include the alias: c('prod.CORP_DIV_CD','cust.ADDRESS')
#'
#' @return string
#' @export
#' @seealso \code{vignette(“sqlTemplateR”)}
#'
#' @examples generateSQL(sqlTemplate = 'exampleQuery.sql', 'MARKET', "CORP_DIV_CD = 'DIV_A'")
generateSQL = function(sqlTemplate, activate = NULL, tagMap = NULL) {
  # read the sql template file
  sql = readFile(filePath = sqlTemplate)


  # escape metacharacters

  # activate: remove comment characters for lines of SQL in the activate vector
  for (val in activate) {
    # escape regex meta-characters
    escapedVal = Hmisc::escapeRegex(val)
    pattern = paste0('--(?=,?', escapedVal, ')')
    sql = gsub(pattern, '', sql, perl = TRUE)
  }

  # tag
  for (tag in names(tagMap)) {
    pattern = paste0('<', tag, '>')
    # when precedded by a --, we have to also replace the --
    sql = gsub(paste0('--', pattern), tagMap[tag], sql)
    # otherwise just do a simple replacement
    sql = gsub(pattern, tagMap[tag], sql)
  }

  return(sql)
}


#' Add equal sign to begining of paramenter
#'
#' @param x string
#'
#' @return string
#' @export
#'
#' @examples addEqualSign('EP')
addEqualSign = function(x) {
  if (length(x) == 1) {
    return(paste0(" = ", x))
  } else {
    stop("addEqualSign is only for strings of length 1")
  }
}


#' Add single quotes around x
#'
#' @param x string
#'
#' @return string
#' @export
#'
#' @examples singleQuote("EP")
singleQuote = function(x) {
  return(paste0("'", x, "'"))
}


#' Generate a where in clause
#'
#' @param inputVals list of values to put after "WHERE IN"
#' @param filterCol SQL database column name to put before "WHERE IN"
#' @param dropIfIncludes Optional value
#'
#' @return string
#' @export
#'
#' @examples whereIn(input$divFilter)
whereIn = function(inputVals, filterCol, dropIfIncludes = NULL) {
  # exclude filter if dropIfIncludes value is in inputVals
  if (!is.null(dropIfIncludes)) {
    if (dropIfIncludes %in% inputVals) {
      return('')
    }
  }

  # make where in clause
  return(
    paste0(filterCol, " IN ('",
           paste0(inputVals, collapse = "','"),
           "')")
  )
}

