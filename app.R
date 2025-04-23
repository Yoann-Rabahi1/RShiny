library(shiny)
library(shinythemes)
library(dplyr)
library(ggplot2)
library(maps)
library(DT)
library(stringi)
library(stringr)


# Chargement et préparation des données
data <- read.csv("consoelecgaz2024.csv", sep = "\t")
data$`Conso totale (MWh)` <- as.numeric(gsub(",", ".", data$`Conso.totale..MWh.`))
data$`Conso moyenne (MWh)` <- as.numeric(gsub(",", ".", data$`Conso.moyenne..MWh.`))
data$Nom.Département <- stri_trans_general(data$Nom.Département, "Latin-ASCII") %>%
  str_replace_all("Cote-d'Or", "Cote-Dor") %>%
  str_replace_all("Cotes-d'Armor", "Cotes-Darmor") %>%
  str_replace_all("Corse-du-Sud", "Corse du Sud") %>%
  str_replace_all("Val-d'Oise", "Val-Doise")

datamap <- map_data("france")
annee <- unique(data$Année)
secteur <- unique(data$CODE.GRAND.SECTEUR)
departement <- unique(data$Nom.Département)

# Interface utilisateur
ui <- fluidPage(
  tags$style(HTML(".title-panel { text-align: center; }")),
  div(class = "title-panel", titlePanel("Étude sur les consommations en Élec/Gaz en France")),
  theme = shinytheme("flatly"),
  navbarPage("",
             tabPanel("Carte/tableau",
                      sidebarLayout(
                        sidebarPanel(
                          selectInput("annee", "Sélectionnez une ou plusieurs années", choices = c("Toutes", annee)),
                          selectInput("secteur", "Choisissez un secteur d'activités", choices = secteur),
                          selectInput("departement", "Sélectionnez un département", choices = c("Tous", departement)),
                          radioButtons("mesure", "Choisissez une mesure en MWh", choices = c("Conso totale", "Conso moyenne")),
                          actionButton("reset", "Réinitialiser la carte")
                        ),
                        mainPanel(
                          tabsetPanel(
                            tabPanel("Carte", plotOutput("cartePlot", click = "plot_click")),
                            tabPanel("Tableau", DTOutput("table")),
                            tags$div(style = "padding-top: 20px;", textOutput("nb_sites"))
                          )
                        )
                      )
             ),
             tabPanel("Visualisation de tendance",
                      sidebarLayout(
                        sidebarPanel(
                          selectInput("secteur_trend", "Choisissez un secteur d'activités", choices =c("Tous",secteur)),
                          selectInput("departement_trend", "Sélectionnez un département", choices = c("Tous", departement)),
                          radioButtons("mesure_trend", "Choisissez une mesure en MWh", choices = c("Conso totale", "Conso moyenne"))
                          
                        ),
                        mainPanel(plotOutput("barplot"))
                      )
             )
  )
)

# Serveur
server <- function(input, output, session) {
  filtered_data_ <- reactive({
    data_filtered <- data
    if (input$secteur != "Tous") data_filtered <- data_filtered[data_filtered$CODE.GRAND.SECTEUR == input$secteur, ]
    if (input$departement != "Tous") data_filtered <- data_filtered[data_filtered$Nom.Département == input$departement, ]
    if (input$annee != "Toutes") data_filtered <- data_filtered %>% filter(Année == input$annee)
    return(data_filtered)
  })
  
  output$cartePlot <- renderPlot({
    df <- filtered_data_()
    df$Valeur <- if (input$mesure == "Conso totale") df$`Conso totale (MWh)` else df$`Conso moyenne (MWh)`
    df <- df %>% group_by(Code.Département, Nom.Département) %>%
      summarize(Valeur = sum(Valeur, na.rm = TRUE))
    full_data_r <- left_join(datamap, df, by = c("region" = "Nom.Département"))
    ggplot(full_data_r, aes(x = long, y = lat, group = group, fill = Valeur)) +
      geom_polygon(color = "white") +
      scale_fill_gradient(low = "lightblue", high = "darkblue", na.value = "grey") +
      labs(title = "Consommation d'Électricité/Gaz par Département", fill = "Consommation (MWh)") +
      theme_minimal()
  })
  
  output$table <- renderDT({
    req(input$departement != "Tous")
    df <- filtered_data_()
    datatable(df %>% select(OPERATEUR, FILIERE,Nb.sites, `Conso totale (MWh)`, `Conso moyenne (MWh)`),
              options = list(pageLength = 10))
  })
  
  output$barplot <- renderPlot({
    df <- data
    if (input$secteur_trend != "Tous") {
      df <- df %>% filter(CODE.GRAND.SECTEUR == input$secteur_trend)
    }
    if (input$departement_trend != "Tous") {
      df <- df %>% filter(Nom.Département == input$departement_trend)
    }
    conso <- if (input$mesure_trend == "Conso totale") "Conso totale (MWh)" else "Conso moyenne (MWh)"
    if (input$secteur_trend == "Tous") {
      df <- df %>% group_by(Année) %>% summarize(Consommation = sum(.data[[conso]], na.rm = TRUE))
      y_label <- "Consommation totale (MWh)"
      title <- "Évolution de la consommation totale (tous secteurs)"
    } else {
      df$Consommation <- df[[conso]]
      y_label <- input$mesure_trend
      title <- "Évolution de la consommation"
    }
    ggplot(df, aes(x = Année, y = Consommation)) +
      geom_bar(stat = "identity", show.legend = FALSE, fill = "lightblue", color = "lightblue") +
      labs(title = title, x = "Année", y = y_label) +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5))
  })
  
  output$nb_sites <- renderText({
    df <- filtered_data_()
    nb_sites <- sum(df$Nb.sites, na.rm = TRUE)
    paste("Nombre total de sites :", nb_sites)
  })
  
  observeEvent(input$plot_click, {
    click <- input$plot_click
    if (!is.null(click)) {
      clicked_dep <- datamap %>%
        filter(long >= click$x - 0.5 & long <= click$x + 0.5, lat >= click$y - 0.5 & lat <= click$y + 0.5) %>%
        pull(region) %>%
        unique()
      if (length(clicked_dep) > 0) updateSelectInput(session, "departement", selected = clicked_dep[1])
    }
  })
  
  observeEvent(input$reset, { updateSelectInput(session, "departement", selected = "Tous") })
}

# Exécuter l'application
shinyApp(ui = ui, server = server)   