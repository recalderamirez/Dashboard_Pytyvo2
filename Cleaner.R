rm(list=ls())

library(tidyverse)
library(tidycensus)
library(sf)
library(ggthemes)
library(readxl)
library(foreign)
library(leaflet)
library(maps)
library(sp)
library(rgdal)
library(htmlwidgets)
library(shiny)
library(flexdashboard)

setwd("C:/Users/recal/Desktop/MINISTERIO DE HACIENDA/PYTYVO - Datos de Consumo")

# DATA <- read.csv("DATOS_PYTYVO_2_1.csv", encoding = "Latin1")

# DATA <- read_excel("DATOS_PYTYVO_2_1 CONSOLIDADO.xlsx")

# PYTYVO <- DATA %>%
#  group_by(DEPARTAMENTO_COMERCIO, DISTRITO_COMERCIO) %>%
#  summarise(MONTO = sum(MONTO))

# write_excel_csv(PYTYVO, "AGRUPADOS.csv")

# CONSUMO EN MILES DE USD 
######################################################

DATA <- read_excel("TODOS_DISTRITOS_GROUPED.xlsx")

PYTYVO <- DATA %>%
  filter(!is.na(CLAVE)) %>%
  group_by(DEPARTAMENTO_COMERCIO, DIST_DESC, CLAVE) %>%
  summarise(MONTO = sum(MONTO),
            USD = sum(USD)) %>%
  mutate(TOTAL = round(USD / 1000))

write_excel_csv(PYTYVO, "FINAL_DISTRITOS.csv")

###################### GIS ##################

distritos <- readOGR("Distritos_Paraguay.shp")

distritos$CLAVE <- as.numeric(distritos$CLAVE)

merged <- merge(distritos, PYTYVO, by = "CLAVE")

#bins <- c(0, 15, 35, 65, 160, 500, 4500)

bins <- c(0, 50, 300, 800, 1500, 4500)

pal <- colorBin(palette = "Blues",
                domain = merged$TOTAL, bins = bins, reverse = F)


pal2 <- colorBin(palette = "YlOrBr",
                domain = merged$TOTAL, bins = bins, reverse = F)

labels <- sprintf(
  "<strong>Distrito:</strong> %s <br><strong>Consumo total en miles de USD:</strong> %g",
  merged$DIST_DESC.y, merged$TOTAL) %>%
  lapply(htmltools::HTML)

# graph 1

azul <- leaflet(merged) %>%
  addProviderTiles(provider = "CartoDB.Positron") %>%
  addPolygons(
    fillColor = ~ pal(TOTAL),
    weight = 0.5,
    opacity = 1,
    color = "#3b3e45",
    dashArray = "",
    fillOpacity = 0.9,
    highlight = highlightOptions(
      weight = 2,
      color = "#666",
      dashArray = "",
      fillOpacity = 0.5,
      bringToFront = T),
    label = labels,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "12px",
      direction = "auto"))%>%
  addLegend("bottomright", 
          pal = pal, 
          values = ~ TOTAL,
          title = "Consumo en miles de USD",
          opacity = 0.7) %>%
  addScaleBar("bottomleft", options = 
                scaleBarOptions(imperial = T, updateWhenIdle = T))

###################### beneficiarios ##################

benef <- readOGR("Distritos_Beneficiarios.shp")

TEST <- as.data.frame(merged_benef)

benef$CLAVE <- as.numeric(benef$CLAVE)

merged_benef <- merge(benef, PYTYVO, by = "CLAVE")


#bins <- c(0, 15, 35, 65, 160, 500, 4500)

bins <- c(0, 500, 1000, 5000, 20000, 80000, 120000)

pal <- colorBin(palette = "Purples",
                domain = merged$TOTAL, bins = bins, reverse = F)

labels <- sprintf(
  "<strong>Distrito:</strong> %s <br><strong>Beneficiarios:</strong> %g",
  benef$DIST_DESC, benef$cantidad) %>%
  lapply(htmltools::HTML)

# graph 1

leaflet(benef) %>%
  addProviderTiles(provider = "CartoDB.Positron") %>%
  addPolygons(
    fillColor = ~ pal(cantidad),
    weight = 0.5,
    opacity = 1,
    color = "#3b3e45",
    dashArray = "",
    fillOpacity = 0.9,
    highlight = highlightOptions(
      weight = 2,
      color = "#666",
      dashArray = "",
      fillOpacity = 0.5,
      bringToFront = T),
    label = labels,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "12px",
      direction = "auto"))%>%
  addLegend("bottomright", 
            pal = pal, 
            values = ~ cantidad,
            title = "Consumo en miles de USD",
            opacity = 0.7) %>%
  addScaleBar("bottomleft", options = 
                scaleBarOptions(imperial = T, updateWhenIdle = T))
