### Fogo Study Area Figure ====
# Alec L. Robitaille


### Packages ----
libs <- c(
	'data.table',
	'ggplot2',
	'sf'
)
lapply(libs, require, character.only = TRUE)


### Data ----
islands <- readRDS('output/fogo-island-polygons.Rds')

# CRS
utm <- st_crs('+proj=utm +zone=21 ellps=WGS84')


### Theme ----
# Colors
watercol <- '#afd8e6'
islandcol <- '#d0c2a9'

# Theme
themeMap <- theme(panel.border = element_rect(size = 1, fill = NA),
									panel.background = element_rect(fill = watercol),
									panel.grid = element_line(color = 'black', size = 0.2),
									axis.text = element_text(size = 11, color = 'black'),
									axis.title = element_blank())

### Plot ----
# Base islands
(gfogo <- ggplot(islands) +
		geom_sf(fill = islandcol) +
		themeMap)


### Output ----
ggsave(
	'graphics/01-fogo-island.png',
	width = 5,
	height = 5,
	dpi = 320
)
