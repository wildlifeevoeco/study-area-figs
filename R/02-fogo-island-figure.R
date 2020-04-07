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
fogo <- readRDS('output/fogo-island-polygons.Rds')

# CRS
utm <- st_crs('+proj=utm +zone=21 ellps=WGS84')


### Theme ----
# Colors
watercol <- '#c3e2ec'
islandcol <- '#d0c2a9'
coastcol <- '#bbae98'
roadcol <- '#666666'

# Theme
themeMap <- theme(panel.border = element_rect(size = 1, fill = NA),
									panel.background = element_rect(fill = watercol),
									panel.grid = element_line(color = 'black', size = 0.2),
									axis.text = element_text(size = 11, color = 'black'),
									axis.title = element_blank())

### Plot ----
# Base fogo
(gfogo <- ggplot(fogo) +
		geom_sf(fill = islandcol) +
		themeMap)


### Output ----
ggsave(
	'graphics/02-fogo-island.png',
	gfogo,
	width = 5,
	height = 5,
	dpi = 320
)
