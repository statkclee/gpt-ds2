library(shiny)
library(tidyverse)
library(shinydashboard)
library(tidymodels)

ui <- fluidPage(
  titlePanel("펭귄 성별 예측 앱"),
  sidebarLayout(
    sidebarPanel(
      sliderInput('bill_length_mm', '부리 길이 (mm)',
                  min=32, max=50, value=43, step=1),
      sliderInput('bill_depth_mm', '부리 깊이 (mm)',
                  min=13, max=22, value=17, step=1),
      sliderInput('flipper_length_mm', '물갈퀴 길이 (mm)',
                  min=170, max=235, value=200, step=1),
      sliderInput('body_mass_g', '체중 (g)',
                  min=2700, max=6300, value=4200, step=100)
    ),
    mainPanel(
      h3("펭귄 성별 예측 결과"),
      h4("성별"),
      verbatimTextOutput("pred_sex"),
      h4("성별 확률"),
      textOutput("prob_sex"),
      h4("입력값"),
      textOutput("bill_length"),
      textOutput("bill_depth"),
      textOutput("flipper_length"),
      textOutput("body_mass")
    )
  )
)

server <- function(input, output, session) {

  penguin_predictvie_model <- read_rds(str_glue("{here::here()}/code/penguin_app/penguin_predictvie_model.rds"))

  penguin_df <- reactive({
    tibble(
      "species" = "Adelie",
      "bill_length_mm" = input$bill_length_mm,
      "bill_depth_mm" = input$bill_depth_mm,
      "flipper_length_mm" = input$flipper_length_mm,
      "body_mass_g" = input$body_mass_g
    )
  })

  pred_sex <- reactive({
    predict(penguin_predictvie_model, penguin_df()) %>%
      unlist() %>%
      as.character()
  })

  prob_sex <- reactive({
    predict(penguin_predictvie_model, penguin_df(), type="prob")[,1]
  })

  output$pred_sex <- renderPrint({ pred_sex() })

  output$prob_sex <- renderText({
    paste0("성별 확률: ", round(prob_sex()*100, 2), "%")
  })

  output$bill_length <- renderText({
    paste0("부리 길이 (mm): ", input$bill_length_mm)
  })

  output$bill_depth <- renderText({
    paste0("부리 깊이 (mm): ", input$bill_depth_mm)
  })

  output$flipper_length <- renderText({
    paste0("물칼퀴 길이 (mm): ", input$flipper_length_mm)
  })

  output$body_mass <- renderText({
    paste0("체중 (g): ", input$body_mass_g)
  })

}

shinyApp(ui, server)
