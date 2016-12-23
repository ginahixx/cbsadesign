


#install.packages("RMySQL")
#install.packages("DT")
library(shiny)
library(RMySQL)
library(DT)

# Define the fields we want to save from the form
fields <- c("ID", "Parameter1", "Savings", "Parameter2","Parameter3")
#these setting are for bluehost database
#  options(mysql = list(
#   "host" = "69.195.124.106",
#   "port" = 3306,
#   "user" = "sbwconsu_shiny",
#   "password" = "shinyuser"
# ))
# databaseName <- "sbwconsu_shiny"
# table <- "sampleframe"

 options(mysql = list(
  "host" = "sbwdb.cpbjzli7i42z.us-west-2.rds.amazonaws.com",
  "port" = 3306,
  "user" = "gina",
  "password" = "highway99."
))
databaseName <- "shiny"
table <- "sampleframe"

# saveData <- function(data) {
#   data <- as.data.frame(t(data))
#   if (exists("responses")) {
#     responses <<- rbind(responses, data)
#   } else {
#     responses <<- data
#   }
# }
# 
# loadData <- function() {
#   if (exists("responses")) {
#     responses
#   }
# }

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
  # Construct the fetching query
  query <- sprintf("SELECT * FROM %s", table)
  # Submit the fetch query and disconnect
  data <- dbGetQuery(db, query)
  dbDisconnect(db)
  data
}

# Shiny app with 3 fields that the user can submit data for
shinyApp(
  ui = fluidPage(
    DT::dataTableOutput("responses", width = 300), tags$hr(),
    textInput("ID", "Unique int ID (Leave blank to auto create)",value =  ""),
    textInput("Parameter1", "Parameter1", value = ""),
    textInput("Savings", "Savings",  value ="" ),
    textInput("Parameter2", "Parameter2", value ="" ),
    textInput("Parameter3", "Parameter3", value = ""),
    #sliderInput("r_num_years", "Number of years using R", 0, 25, 2, ticks = FALSE),
    actionButton("submit", "Submit")
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

    # Show the previous responses
    # (update with current response when Submit is clicked)
    output$responses <- DT::renderDataTable({
      input$submit
      loadData()
    })
  }
)


#

