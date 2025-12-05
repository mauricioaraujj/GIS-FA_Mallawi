
library(readr)
library(raster)
library(sf)
library(ggplot2)
library(dplyr)
library(ggspatial)
library(patchwork)
library(viridis)
library(ggnewscale)
library(ggrepel)
library(rnaturalearth) 

# Elevevation -------------------------------------------------------------
data <- read.csv("malawi_data.csv", sep = ";")

dem_path <- "C:/Users/mauri/OneDrive/Documentos/Enviromics2.0/raster/elevation.tif"
r_dem <- raster(dem_path)
proj_crs <- crs(r_dem)

Lim <- ne_countries(country = "Malawi", returnclass = "sf") %>%
  st_transform(proj_crs)

Limit <- ne_countries(continent = "Africa", returnclass = "sf") %>%
  st_transform(proj_crs)

codenv <- data %>%
  group_by(location) %>%
  summarise(n_env = n_distinct(env), .groups = 'drop')

loc <- data %>%
  dplyr::distinct(location, .keep_all = TRUE) %>%
  left_join(codenv, by = "location") %>%
  sf::st_as_sf(coords = c("lon", "lat"), crs = 4326) %>%
  sf::st_transform(proj_crs)

r_malawi_dem <- crop(r_dem, Lim)
r_malawi_dem <- mask(r_malawi_dem, Lim)
r_df_dem <- as.data.frame(r_malawi_dem, xy = TRUE)
names(r_df_dem)[3] <- "Elevation"

line_color <- "darkgreen"
point_fill <- "#FF7F00" 
Limit_fill <- "lightgrey"
Limit_color <- "darkgrey"


mapa_malawi <- ggplot() +
  geom_raster(data = r_df_dem,
              aes(x = x, y = y, fill = Elevation)) +
  scale_fill_viridis_c(
    option = "magma",
    direction = -1,
    name = "Elevation (m)",
    na.value = "transparent",
    guide = guide_colorbar(order = 1)
  ) +
  
  ggnewscale::new_scale_fill() + 
    geom_sf(data = Lim, fill = NA, color = "black", linewidth = 0.6) +
  geom_sf(data = loc, 
          aes(fill = factor(n_env),
      size = factor(n_env)),
    color = "black", shape = 21,
    alpha = 0.9) +  scale_fill_manual(
    name = "No. of Trials",
    values = c(
      "1" = "#2c7bb6",
      "2" = "#abd9e9",
      "4" = "#fdae61",
      "8" = "#d7191c",
      "16" = "#2c7bb6" 
    ),
    breaks = c("1","2","4","8","16")
  ) +
  
  scale_size_manual(
    name = "No. of Trials",
    values = c(
      "1" = 2.5,
      "2" = 3.5,
      "4" = 5,
      "8" = 7,
      "16" = 9
    ),
    breaks = c("1","2","4","8","16")
  ) +
  
  geom_label_repel(
    data = as.data.frame(st_coordinates(loc)) %>%
      rename(lon = X, lat = Y) %>%
      bind_cols(st_drop_geometry(loc)),
    aes(x = lon, y = lat, label = location),
    color = "black",
    size = 3.5,
    fontface = "bold",
    box.padding = unit(0.35, "lines"),
    point.padding = unit(0.5, "lines"),
    segment.color = "grey50",
    fill = "white",
    min.segment.length = 0
  ) +
  
  guides(
    fill = guide_legend(title = "No. of Trials", order = 2),
    size = guide_legend(title = "No. of Trials", order = 2)
  ) +
  
  annotation_north_arrow(
    locationation = "bl",
    which_north = "true",
    style = north_arrow_fancy_orienteering()
  ) +
  annotation_scale(locationation = "br") +
  
  coord_sf(crs = proj_crs) +
  theme_minimal() +
  labs(
    title = "",
    subtitle = "",
    x = "Longitude",
    y = "Latitude"
  ) +
  theme(
    legend.position = "right",
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 11),
    legend.box.spacing = unit(0.5, "cm")
  )


inset_map_africa <- ggplot() +
  geom_sf(data = Limit,
          fill = Limit_fill,
          color = Limit_color,
          linewidth = 0.2) +

    geom_sf(data = Lim,
          fill = "red",
          color = "red",
          linewidth = 0.3) +
  theme_void() +
  theme(
    panel.background = element_rect(fill = "white", color = "black"),
    plot.margin = margin(1, 1, 1, 1, "mm")
  )

comb <- mapa_malawi +
  inset_element(
    inset_map_africa,
    left = 0.85, 
    right = 0.99, 
    bottom = 0.01, 
    top = 0.15, 
    align_to = 'plot'
  )

print(comb)





library(readr)
library(raster)
library(sf)
library(ggplot2)
library(dplyr)
library(ggspatial)
library(patchwork)
library(viridis)
library(ggnewscale)
library(rnaturalearth)
library(gridExtra)
library(grid)
library(gtable)

# -------------------------------------------------------------------------
# Dados básicos
data <- read.csv("malawi_data.csv", sep = ";")

dem_path <- "C:/Users/mauri/OneDrive/Documentos/Enviromics2.0/raster/elevation.tif"
r_dem   <- raster(dem_path)
proj_crs <- crs(r_dem)

Lim <- ne_countries(country = "Malawi", returnclass = "sf") |>
  st_transform(proj_crs)

Limit <- ne_countries(continent = "Africa", returnclass = "sf") |>
  st_transform(proj_crs)

# nº de ensaios por local
codenv <- data |>
  group_by(location) |>
  summarise(n_env = n_distinct(env), .groups = "drop")

# pontos dos locais (1 linha por location) + sigla (code)
loc <- data |>
  distinct(location, .keep_all = TRUE) |>
  left_join(codenv, by = "location") |>
  mutate(
    code = toupper(substr(location, 1, 4))   # <<< SIGLA AQUI
  ) |>
  st_as_sf(coords = c("lon", "lat"), crs = 4326) |>
  st_transform(proj_crs)

# DEM recortado para Malawi
r_malawi_dem <- crop(r_dem, Lim)
r_malawi_dem <- mask(r_malawi_dem, Lim)
r_df_dem     <- as.data.frame(r_malawi_dem, xy = TRUE)
names(r_df_dem)[3] <- "Elevation"

Limit_fill  <- "lightgrey"
Limit_color <- "darkgrey"

# Paleta para nº de ensaios (usada no mapa e na tabela)
map_colors <- c(
  "1"  = "#2c7bb6",
  "2"  = "#abd9e9",
  "4"  = "#fdae61",
  "8"  = "#d7191c",
  "16" = "#2c7bb6"
)

# -------------------------------------------------------------------------
# Data frame para rótulos (siglas) no mapa
lab_df <- as.data.frame(st_coordinates(loc)) |>
  rename(x = X, y = Y) |>
  bind_cols(st_drop_geometry(loc))

# -------------------------------------------------------------------------
# Mapa principal (com bolinha e sigla dentro do mapa)
mapa_malawi <- ggplot() +
  geom_raster(data = r_df_dem,
              aes(x = x, y = y, fill = Elevation)) +
  scale_fill_viridis_c(
    option = "magma",
    direction = -1,
    name = "Elevation (m)",
    na.value = "transparent",
    guide = guide_colorbar(order = 1)
  ) +
  ggnewscale::new_scale_fill() +
  geom_sf(data = Lim, fill = NA, color = "black", linewidth = 0.6) +
  
  # bolinha por location, cor pela paleta (mesma da tabela)
  geom_sf(
    data  = loc,
    aes(fill = factor(n_env)),
    color = "black",
    shape = 21,
    size  = 3,
    alpha = 0.9
  ) +
  scale_fill_manual(
    values = map_colors,
    breaks = names(map_colors)
  ) +
  guides(fill = "none") +  
  
  # sigla dentro do mapa (curtinha, pouco poluída)
  geom_text(
    data = lab_df,
    aes(x = x, y = y, label = code),
    size = 2.7,
    fontface = "bold",
    vjust = -0.8,
    color = "black"
  ) +
  
  annotation_north_arrow(
    location   = "bl",
    which_north = "true",
    style       = north_arrow_fancy_orienteering()
  ) +
  annotation_scale(location = "br") +
  coord_sf(crs = proj_crs) +
  labs(x = "Longitude", y = "Latitude") +
  theme_minimal() +
  theme(
    legend.position    = "right",
    plot.title         = element_text(hjust = 0.5, face = "bold", size = 18),
    plot.subtitle      = element_text(hjust = 0.5, size = 11),
    legend.box.spacing = unit(0.5, "cm")
  )

# -------------------------------------------------------------------------
# Mapa inset da África
inset_map_africa <- ggplot() +
  geom_sf(data = Limit,
          fill  = Limit_fill,
          color = Limit_color,
          linewidth = 0.2) +
  geom_sf(data = Lim,
          fill  = "red",
          color = "red",
          linewidth = 0.3) +
  theme_void() +
  theme(
    panel.background = element_rect(fill = "white", color = "black"),
    plot.margin      = margin(1, 1, 1, 1, "mm")
  )

mapa_malawi_inset <- mapa_malawi +
  inset_element(
    inset_map_africa,
    left   = 0.78,
    right  = 0.98,
    bottom = 0.02,
    top    = 0.20,
    align_to = "plot"
  )

# -------------------------------------------------------------------------
# Tabela de locais x nº de ensaios x sigla (com cor de fundo por linha)
tab_df <- codenv |>
  left_join(
    loc |>
      st_drop_geometry() |>
      select(location, code),
    by = "location"
  ) |>
  arrange(desc(n_env)) |>
  mutate(
    col = map_colors[as.character(n_env)]
  ) |>
  rename(
    Code            = code,
    Location        = location,
    `No. of Trials` = n_env
  )

tab_plain <- tab_df |>
  select(-col)

tab_grob <- tableGrob(tab_plain, rows = NULL)

# aplica cor de fundo linha a linha (mesma cor das bolinhas)
for (i in seq_len(nrow(tab_plain))) {
  shade <- rectGrob(
    gp = gpar(fill = tab_df$col[i], col = NA, alpha = 0.45)
  )
  tab_grob <- gtable_add_grob(
    tab_grob,
    shade,
    t = i + 1, l = 1, r = ncol(tab_grob)
  )
}

tab_plot <- wrap_elements(tab_grob)

# -------------------------------------------------------------------------
# Mapa + tabela lado a lado
final_plot <- mapa_malawi_inset + tab_plot +
  plot_layout(widths = c(3, 1))

print(final_plot)

