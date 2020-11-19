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

setwd("C:/Users/recal/Desktop/MINISTERIO DE HACIENDA/PYTYVO - Datos de Consumo/NUEVOS DATOS/NEW EDITION")

# GENERAL SETUP: MAPA - MONTO CONSUMIDO

# POR DEPARTAMENTOS

# Load data
CONS_DPTO <- read_excel("DEPARTAMENTOS_CONSUMO.xlsx")

CONS_DPTO <- as.data.frame(CONS_DPTO)

# Clean and prepare data
CONS_DPTO <- CONS_DPTO %>%
  group_by(DPTO) %>%
  summarise(MONTO = sum(USD)) %>%
  mutate(MONTO = round(MONTO/1000)) %>%
  ungroup()

# Load shapefile (Departamentos de Paraguay)
deptos_cons <- readOGR("Departamentos_Paraguay.shp", encoding = "UTF-8")

# Cleaning

deptos_cons$DPTO <- as.numeric(deptos_cons$DPTO)

# Merge data with shapefile

merged_dpto_cons <- merge(deptos_cons, CONS_DPTO, by = "DPTO")


# save shapefile
writeOGR(merged_dpto_cons, ".", "merged_dpto_cons2", 
         driver = "ESRI Shapefile", layer_options = "ENCODING=UTF-8")

testshape <- readOGR("merged_dpto_cons2.shp", encoding = "UTF-8")

merged_dpto_consumo <- rmapshaper::ms_simplify(testshape, 
                                              keep = 0.05, keep_shapes = TRUE)

writeOGR(merged_dpto_consumo, ".", "merged_dpto_consumo", 
         driver = "ESRI Shapefile", layer_options = "ENCODING=UTF-8")

testtest <- readOGR("merged_dpto_consumo.shp", use_iconv = T, encoding = "UTF-8")

TEST <- as.data.frame(testtest)


