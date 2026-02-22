library(shiny)
library(gentelellaShiny)
library(shinyWidgets)
library(tidyverse)
library(lubridate)


heart_rate_df <- read_rds(here("Data/heart_rate.rds"))

ui <- gentelellaPageCustom(
  title = HTML("<center>My Apple Watch heart rate data</center>"),
  shinyWidgets::setBackgroundColor(color = "black", gradient = "radial"),
  
  sidebar = gentelellaSidebar(
    sidebarDate(),
    sidebarMenu(
      sidebarItem(
        "",
        tabName = "tab1",
        dateRangeInput("date_range", "Date range: ",
                       format = "mm-dd-yyyy",
                       min = min(as.Date(heart_rate_df$date_only)),
                       max = max(as.Date(heart_rate_df$date_only)),
                       start = max(as.Date(heart_rate_df$date_only)) - days(1),
                       end = max(as.Date(heart_rate_df$date_only))
        )
      )
    )
    #,
    # shiny::sliderInput("date2",
    #                    label = h3("Date Slider:"),
    #                    min = min(as.Date(heart_rate_df$date_only)),
    #                    max = max(as.Date(heart_rate_df$date_only)),
    #                    start = max(as.Date(heart_rate_df$date_only)) - days(1),
    #                    end = max(as.Date(heart_rate_df$date_only)),
    #                    timeFormat = "%b %d, %Y")
  ),
  body = gentelellaBody(
    plotOutput("heart_rate_plot"),
    tableOutput("heart_rate_table")
  ),
  footer = gentelellaFooter(leftText = "Duncan Gates", rightText = "2021")
)

server <- shinyServer(function(input, output) {
  heart_rate_ranged <- reactive({
    date_ranges <- input$date_range[1:2] %>% as.Date()
    date_start <- min(date_ranges)
    date_end <- max(date_ranges)

    heart_rate_df %>%
      filter(date_only >= date_start & date_only <= date_end)
  })

  output$heart_rate_plot <- renderPlot({
    g <- ggplot(heart_rate_ranged(), aes(x = ts, y = rate)) +
      geom_line(color = "red", alpha = 0.9) +
      scale_y_continuous(breaks = scales::pretty_breaks(n = 8)) +
      labs(
        x = "",
        y = "Heart rate (bpm)",
        title = paste0("From ", input$date_range[1], " to ", input$date_range[2])
      ) +
      theme(text = element_text(family = "Montserrat"),
            plot.background = element_rect(fill = "black"),
            panel.background = element_rect(fill = "black"),
            # panel.grid.major.y = element_line(),
            # panel.grid.minor.y = element_line(),
            panel.grid.major.x = element_blank(),
            panel.grid.minor.x = element_blank(),
            plot.title = element_text(color = "white", hjust = 0.5))
    g
  })

  output$heart_rate_table <- renderTable({
    heart_rate_ranged() %>%
      summarize(
        earliest_record = as.character(min(ts)),
        latest_record = as.character(max(ts)),
        highest_heart_rate = max(rate),
        lowest_heart_rate = min(rate),
        measurements = prettyNum(n(), big.mark = ",")
      )
  })
  
})

shinyApp(ui = ui, server = server)
