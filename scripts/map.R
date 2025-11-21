

# Elevevation -------------------------------------------------------------

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



# Zones -------------------------------------------------------------------
data <- read.csv("malawi_data.csv", sep = ";")
aez_path <- "C:/Users/mauri/OneDrive/Documentos/GIS-FA_Mallawi/mis/raster/aez_v9v2.tif"
r_aez <- raster(aez_path)
proj_crs <- crs(r_aez)

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

r_malawi_aez <- crop(r_aez, Lim)
r_malawi_aez <- mask(r_malawi_aez, Lim)
r_df_aez <- as.data.frame(r_malawi_aez, xy = TRUE)
names(r_df_aez)[3] <- "AEZ_ID"

r_df_aez <- r_df_aez %>% filter(!is.na(AEZ_ID))
r_df_aez$AEZ_ID_f <- factor(r_df_aez$AEZ_ID)

aez_labels_short <- c(
  "1" = "T-LL:SA/n", "2" = "T-LL:SA/y", "3" = "T-LL:SH/n", "4" = "T-LL:SH/y",
  "5" = "T-LL:H/n", "6" = "T-LL:H/y", "7" = "T-HL:SA/n", "8" = "T-HL:SA/y",
  "9" = "T-HL:SH/n", "10" = "T-HL:SH/y", "11" = "T-HL:H/n", "12" = "T-HL:H/y",
  "13" = "ST-W:SA/n", "14" = "ST-W:SA/y", "15" = "ST-W:SH/n", "16" = "ST-W:SH/y",
  "17" = "ST-W:H/n", "18" = "ST-W:H/y", "19" = "ST-MC:SA/n", "20" = "ST-MC:SA/y",
  "21" = "ST-MC:SH/n", "22" = "ST-MC:SH/y", "23" = "ST-MC:H/n", "24" = "ST-MC:H/y",
  "25" = "ST-C:SA/n", "26" = "ST-C:SA/y", "27" = "ST-C:SH/n", "28" = "ST-C:SH/y",
  "29" = "ST-C:H/n", "30" = "ST-C:H/y", "31" = "T-M:Dry/n", "32" = "T-M:Dry/y",
  "33" = "T-M:Moist/n", "34" = "T-M:Moist/y", "35" = "T-M:Wet/n", "36" = "T-M:Wet/y",
  "37" = "T-C:Dry/n", "38" = "T-C:Dry/y", "39" = "T-C:Moist/n", "40" = "T-C:Moist/y",
  "41" = "T-C:Wet/n", "42" = "T-C:Wet/y", "43" = "C-NF:Dry/n", "44" = "C-NF:Dry/y",
  "45" = "C-NF:Moist/n", "46" = "C-NF:Moist/y", "47" = "C-NF:Wet/n", "48" = "C-NF:Wet/y",
  "49" = "V-Steep", "50" = "Sev-Lim", "51" = "Irrig-Soil", "52" = "Hydro-Soil",
  "53" = "Desert-C", "54" = "Boreal-C", "55" = "Arctic-C", "56" = "Built-Up",
  "57" = "Water"
)

aez_palette <- colorRampPalette(brewer.pal(12, "Set3"))(length(aez_labels_short))

Limit_fill <- "lightgrey"
Limit_color <- "darkgrey"

mapa_malawi <- ggplot() +
  geom_raster(data = r_df_aez,
              aes(x = x, y = y, fill = AEZ_ID_f)) +
  scale_fill_manual(
    values = aez_palette,
    labels = aez_labels_short,
    name = "Agro-Ecological Zones",
    na.value = "transparent",
    guide = guide_legend(
      order = 1,
      ncol = 1, 
      title.position = "top",
      override.aes = list(alpha = 1, size = 3)
    )
  ) +
  
  ggnewscale::new_scale_fill() +
  geom_sf(data = Lim, fill = NA, color = "black", linewidth = 0.6) +
  geom_sf(data = loc,
          aes(fill = factor(n_env),
              size = factor(n_env)),
          color = "black", shape = 21,
          alpha = 0.9) +
  scale_fill_manual(
    name = "No. of Trials",
    values = c(
      "1" = "#2c7bb6", "2" = "#abd9e9", 
      "4" = "#fdae61", "8" = "#d7191c", 
      "16" = "purple"
    ),
    breaks = c("1","2","4","8") 
  ) +
  
  scale_size_manual(
    name = "No. of Trials",
    values = c(
      "1" = 3.5, "2" = 4.5, "4" = 5.5, "8" = 6.5, "16" = 7.5 
    ),
    breaks = c("1","2","4","8") 
  ) +
  
  geom_label_repel(
    data = as.data.frame(st_coordinates(loc)) %>%
      rename(lon = X, lat = Y) %>%
      bind_cols(st_drop_geometry(loc)),
    aes(x = lon, y = lat, label = location),
    color = "black",
    size = 3.5,
    fontface = "bold",
    box.padding = unit(0.3, "lines"),
    point.padding = unit(0.3, "lines"),
    segment.color = "grey50",
    fill = "white",
    min.segment.length = 0,
    nudge_x = 0.1,
    nudge_y = 0.1,
    max.overlaps = Inf, 
    direction = "both"
  ) +
  
  guides(
    fill = guide_legend(title = "No. of Trials", order = 2, override.aes = list(alpha = 1, size = 5)),
    size = guide_legend(title = "No. of Trials", order = 2)
  ) +
  
  annotation_north_arrow(
    location = "bl", which_north = "true", style = north_arrow_fancy_orienteering()
  ) +
  annotation_scale(location = "br", style = "bar") +
  
  coord_sf(crs = proj_crs) +
  theme_minimal() +
  labs(
    x = "Longitude",
    y = "Latitude"
  ) +
  theme(
    legend.position = "right",
    legend.box.spacing = unit(0.5, "cm")
  )

inset_map_africa <- ggplot() +
  geom_sf(data = Limit, fill = Limit_fill, color = Limit_color, linewidth = 0.2) +
  geom_sf(data = Lim, fill = "red", color = "red", linewidth = 0.3) +
  theme_void() +
  theme(
    panel.background = element_rect(fill = "white", color = "black"),
    plot.margin = margin(1, 1, 1, 1, "mm")
  )

comb <- mapa_malawi +
  inset_element(
    inset_map_africa,
    left = 0.85, right = 0.99, bottom = 0.01, top = 0.15, align_to = 'plot'
  )

print(comb)

