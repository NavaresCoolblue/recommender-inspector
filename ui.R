library(shiny)
library(shinydashboard)
library(shinyjs)


library(shiny)
library(shinydashboard)
library(shinyjs)

ui <- dashboardPage( 
  skin="blue",
  dashboardHeader(
    title="Recommender System Inspector",
    titleWidth = 450
  ),
  dashboardSidebar(
    # selectInput("sessionId", "Session Id: ", c(1,2,3))
    uiOutput("session_drill_down")
  ),
  dashboardBody(
    fluidRow(
      h4('Sequences')
    ),
    
    fluidRow(
      htmlOutput('sequence')
    ), 
    fluidRow(
      h4('Recommendations')
    ),
    
    fluidRow(
      htmlOutput('recommendation')
    )
  )
)
