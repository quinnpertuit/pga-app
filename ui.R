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

players = sort(unique(c(HistLeaderboard$player, CurrentLeaderboard$player, WorldRank$player)))
seasons = sort(unique(c(HistLeaderboard$season, CurrentLeaderboard$season, WorldRank$season)), decreasing = TRUE)
tours   = sort(unique(c(HistLeaderboard$tour,   CurrentLeaderboard$tour,   WorldRank$tour)))

# ssh -i qdp.pem ubuntu@ec2-54-89-158-111.compute-1.amazonaws.com
# sudo apt-get install libcurl4-openssl-dev libssl-dev

# sudo R
# install.packages(c("later","promises","rlang"))
# install.packages("dplyr", dependencies = TRUE, INSTALL_opts = '--no-lock')
# install.packages("tidyverse", dependencies = TRUE, INSTALL_opts = '--no-lock')
# install.packages("Rcpp", dependencies = TRUE, INSTALL_opts = '--no-lock')
# install.packages("httpuv", dependencies = TRUE, INSTALL_opts = '--no-lock')
# install.packages("shiny", dependencies = TRUE, INSTALL_opts = '--no-lock')
# install.packages("shinythemes", dependencies = TRUE, INSTALL_opts = '--no-lock')
# install.packages("shinyWidgets", dependencies = TRUE, INSTALL_opts = '--no-lock')
# install.packages("shinydashboard", dependencies = TRUE, INSTALL_opts = '--no-lock')
# install.packages("shinyjs", dependencies = TRUE, INSTALL_opts = '--no-lock')
# install.packages("DT", dependencies = TRUE, INSTALL_opts = '--no-lock')
# install.packages("rmarkdown", dependencies = TRUE, INSTALL_opts = '--no-lock')
# install.packages("esquisse", dependencies = TRUE, INSTALL_opts = '--no-lock')


#sudo su - -c "R -e \"install.packages(c('tidyverse', 'shiny', 'shinythemes', 'DT', 'shinyWidgets', 'rmarkdown', 'shinydashboard', 'shinyjs', 'esquisse'), repos='http://cran.rstudio.com/')\""

# sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=3072
# sudo /sbin/mkswap /var/swap.1
# sudo /sbin/swapon /var/swap.1
# sudo sh -c 'echo "/var/swap.1 swap swap defaults 0 0 " >> /etc/fstab'
# sudo su - -c "R -e \"install.packages(c('tidyverse', 'shiny', 'shinythemes'), repos='http://cran.rstudio.com/')\""
# sudo su - -c "R -e \"install.packages(c('DT', 'shinyWidgets', 'rmarkdown'), repos='http://cran.rstudio.com/')\""
# sudo su - -c "R -e \"install.packages(c('shinydashboard', 'shinyjs', 'esquisse'), repos='http://cran.rstudio.com/')\""

#sudo su - -c "R -e \"install.packages(c('shiny'))\""


ui <- shinyUI(dashboardPage( 
  # Header and Skin #####
  skin = "green",
  dashboardHeader(tags$li(class = "dropdown",
    HTML(
      "
          <script>
          var socket_timeout_interval
          var n = 0
          $(document).on('shiny:connected', function(event) {
          socket_timeout_interval = setInterval(function(){
          Shiny.onInputChange('count', n++)
          }, 15000)
          });
          $(document).on('shiny:disconnected', function(event) {
          clearInterval(socket_timeout_interval)
          });
          </script>
          "
    )
  ),
    title = 'PGA Statistics Dashboard',
    tags$li(class = "dropdown",
            tags$a(href="https://www.fantasygolfbag.com/", 
                   tags$img(height = "40px", alt="Fantasy Golf Bag Logo", src="https://res.cloudinary.com/dreamlinefgb/image/upload/v1567867211/fantasygolfbag.com/FGBPrimaryLogo.png")
            )
    )),
  # SidebarMenu #####
  dashboardSidebar(
    radioButtons(
      inputId = "data",
      label = "Data",
      choices = c("Leaderboard Current", "Leadboard History", "World Rank"),
      inline = TRUE
    ),
    sidebarMenu(id='tabs',
                menuItem("Filters", tabName = "dstat", icon = shiny::icon("fa fa-fas fa-globe", lib = "font-awesome"))),
    pickerInput(inputId = 'seasons', label = 'Season(s)', choices=seasons, options = list(`actions-box` = TRUE), multiple = TRUE, selected=seasons),
    pickerInput(inputId = 'tours', label = 'Tournaments(s)', choices=tours, options = list(`actions-box` = TRUE), multiple = TRUE, selected=tours[1]),
    pickerInput(inputId = 'players', label = 'Player(s)', choices=players, options = list(`actions-box` = TRUE), multiple = TRUE, selected=players)
    ),
  # Body #####
  dashboardBody(
    tabItems(
      tabItem("dstat",
              titlePanel(title=h4("Drag-and-Drop", align="center")),
              esquisserUI(
                id = "esquisse",
                header = FALSE, # dont display gadget title
                choose_data = FALSE # dont display button to change data
              ),
              fluidRow(
                column(width = 12,
                       height = "600px",
                       DT::dataTableOutput("CurrentLeaderboard", 
                                           width = "100%",
                                           height = "auto"))
                
              ))
    )),textOutput("keepAlive")))
