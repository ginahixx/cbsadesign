


#install.packages("RMySQL")
#install.packages("DT")
library(shiny)
library(RMySQL)
library(DT)

# Define the fields we want to save from the form
fields <- c("ID", "Parameter1", "Savings", "Parameter2","Parameter3")

 options(mysql = list(
  "host" = "sbwdb.cpbjzli7i42z.us-west-2.rds.amazonaws.com",
  "port" = 3306,
  "user" = "gina",
  "password" = "CBSA4Funtimes!"
))
databaseName <- "shiny"
table <- "sampleframe"
frame<- "tempdata"
#file<-"P:/Projects/NEEA22 (CBSA Phase 1 Planning)/_04 Assessment of Alternative Designs/Tool/sampledevelopment/mock_pnw_bulding_list.csv"
file<-"mock_pnw_bulding_list.csv"
#sampledata<-read.csv(file,nrows = 100)

saveData <- function(data) {
  # Connect to the database
  db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host,
                  port = options()$mysql$port, user = options()$mysql$user,
                  password = options()$mysql$password)
  # Construct the update query by looping over the data fields
  query <- sprintf(
    "INSERT INTO %s (%s) VALUES ('%s')",
    table,
    paste(names(data), collapse = ", "),
    paste(data, collapse = "', '")
  )
  # Submit the update query and disconnect
  dbGetQuery(db, query)
  dbDisconnect(db)
}

loadData <- function() {
  # Connect to the database
  db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host,
                  port = options()$mysql$port, user = options()$mysql$user,
                  password = options()$mysql$password)
  # Construct the insert query
  query <- sprintf("SELECT * FROM %s", table)
  # Submit the fetch query and disconnect
  data <- dbGetQuery(db, query)
  dbDisconnect(db)
  data
}

uploadData <- function() {
  # Connect to the database
  db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host,
                  port = options()$mysql$port, user = options()$mysql$user,
                  password = options()$mysql$password)
  #delete any old data
  query <- sprintf("DELETE FROM %s", frame)
  #dbGetQuery(db, query)
  # Construct the update query by looping over the data fields
  query <- sprintf("LOAD DATA LOCAL INFILE '%s' INTO TABLE %s FIELDS TERMINATED BY ','  LINES TERMINATED BY '\n' IGNORE 1 ROWS;", 
                   file, frame)
  # Submit the update query and disconnect
  dbGetQuery(db, query)
  dbDisconnect(db)
}

loadFrame <- function() {
  # Connect to the database
  db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host,
                  port = options()$mysql$port, user = options()$mysql$user,
                  password = options()$mysql$password)
  # Construct the insert query
  query <- sprintf("SELECT * FROM %s", frame)
  # Submit the fetch query and disconnect
  data <- dbGetQuery(db, query)
  dbDisconnect(db)
  data
}
# Shiny app
shinyApp(
  ui = fluidPage(
    DT::dataTableOutput("responses", width = 300), tags$hr(),
    textInput("ID", "Unique int ID (Leave blank to auto create)",value =  ""),
    textInput("Parameter1", "Parameter1", value = ""),
    textInput("Savings", "Savings",  value ="" ),
    textInput("Parameter2", "Parameter2", value ="" ),
    textInput("Parameter3", "Parameter3", value = ""),
    #sliderInput("r_num_years", "Number of years using R", 0, 25, 2, ticks = FALSE),
    actionButton("submit", "Submit"),
    #textInput("filename", "Table Name", value = ""),
    actionButton("upload", "Load Data"),
    DT::dataTableOutput("frame", width = 600), tags$hr()
  ),
  server = function(input, output, session) {

    # Whenever a field is filled, aggregate all form data
    formData <- reactive({
      data <- sapply(fields, function(x) input[[x]])
      data
    })

    # When the Submit button is clicked, save the form data
    observeEvent(input$submit, {
      saveData(formData())
    })

    # When the upload button is clicked, load the frame data
    observeEvent(input$upload, {
      #uploadData(formData())
      uploadData()
    })
    
    # Show the previous responses
    # (update with current response when Submit is clicked)
    output$responses <- DT::renderDataTable({
      input$submit
      loadData()
    })
    
    output$frame <- DT::renderDataTable({
      input$submit
      loadFrame()
    })
  }
)


#

