### Newfoundland Study Area Figure ====
# Alec L. Robitaille


### Packages ----
libs <- c(
	'data.table',
	'ggplot2',
	'sf'
)
lapply(libs, require, character.only = TRUE)


### Data ----
nl <- st_read('output/newfoundland-polygons.gpkg')

# CRS
utm <- st_crs('+proj=utm +zone=21 ellps=WGS84')


### Theme ----
# Colors
source('R/00-palette.R')

# Theme
themeMap <- theme(panel.border = element_rect(size = 1, fill = NA),
									panel.background = element_rect(fill = watercol),
									panel.grid = element_line(color = 'black', size = 0.2),
									axis.text = element_text(size = 11, color = 'black'),
									axis.title = element_blank())

### Plot ----
# NOTE: this figure only has the main island's coastline (eg missing Fogo)
# Base NL
(gnl <- ggplot(nl) +
 	geom_sf(fill = islandcol, color = coastcol, size = 0.3) +
 	themeMap)


### Output ----
ggsave(
	'graphics/04-newfoundland.png',
	gnl,
	width = 7,
	height = 7,
	dpi = 320
)
