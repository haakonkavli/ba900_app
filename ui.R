
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)


shinyUI(fluidPage(
    tags$head(tags$script(src = "message-handler.js")),

  # Application title
  titlePanel("Plot & Export BA900 Data"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
        dateInput('dates_start', 'Start Date:',
                  value = as.Date('2000-01-04'),
                  min = as.Date('2000-01-04'),
                  max = Sys.Date()-1
        ),
        dateInput('dates_end', 'End Date:',
                  value = Sys.Date(),
                  min = as.Date('2000-01-05'),
                  max = Sys.Date()
        ),

        uiOutput('select_bank_ui'),
        uiOutput('select_ratio_check_ui'),
        uiOutput('select_ratio_ui'),
        uiOutput('select_item_ui')

    ),

    # Show a plot of the generated distribution
    mainPanel(
        fluidRow(downloadButton('downloadData', 'Download')),
        fluidRow(
      plotOutput("baplot",height = "800px"))
    )
  )
))
