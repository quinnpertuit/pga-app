library(tidyverse)
library(shiny)
library(shinyWidgets)
library(esquisse)
library(shinythemes)
library(DT)
library(shinydashboard)

HistLeaderboard    = read_csv('HistLeaderboard.csv')
CurrentLeaderboard = read_csv('CurrentLeaderboard.csv')
WorldRank          = read_csv('WorldRank.csv')

players = sort(unique(c(HistLeaderboard$player, Leaderboard$player, WorldRank$player)))
seasons = sort(unique(c(HistLeaderboard$season, Leaderboard$season, WorldRank$season)), decreasing = TRUE)
tours   = sort(unique(c(HistLeaderboard$tour,   Leaderboard$tour,   WorldRank$tour)))

server <- function(input,output, session){
  
  data_r <- reactiveValues(data = CurrentLeaderboard, name = "Leaderboard Current")
  
  observeEvent(input$data, {
    if (input$data == "Leaderboard Current") {
      data_r$data <- CurrentLeaderboard
      data_r$name <- "Leaderboard Current"
    } else {
      if (input$data == "Leaderboard History") {
        data_r$data <- HistLeaderboard
        data_r$name <- "Leaderboard History"
      }else{
      data_r$data <- WorldRank
      data_r$name <- "WorldRank"
    }
  }
})
  
  observe (
    updateSelectInput(session, 
                      inputId = 'seasons', 
                      choices = c(sort(unique(data_r$data$season))),
                      selected = c(sort(unique(data_r$data$season)))
    )
  )
  
  observe (
    updateSelectInput(session, 
                      inputId = 'tours', 
                      choices = c(sort(unique(data_r$data$tour))),
                      selected = c(sort(unique(data_r$data$tour)))
    )
  )
  
  
  callModule(module = esquisserServer, id = "esquisse", data = data_r)
  
}