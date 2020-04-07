### Fogo Inset in NL Study Area Figure ====
# Alec L. Robitaille


### Packages ----
libs <- c(
	'data.table',
	'ggplot2',
	'sf',
	'rgdal'
)
lapply(libs, require, character.only = TRUE)


### Data ----
fogo <- readRDS('output/fogo-island-polygons.Rds')
nl <- readRDS('output/newfoundland-polygons.Rds')

# CRS
utm <- st_crs('+proj=utm +zone=21 ellps=WGS84')

# Bbox from 01-fogo-island-prep.R
bb <- data.table(
	xmin = -54.3533,
	ymin = 49.5194,
	xmax = -53.954220,
	ymax = 49.763834
)

### Theme ----
# Colors
watercol <- '#c3e2ec'
islandcol <- '#d0c2a9'

# Theme
themeMap <- theme(panel.border = element_rect(size = 1, fill = NA),
									panel.background = element_rect(fill = watercol),
									panel.grid = element_line(color = 'black', size = 0.2),
									axis.text = element_text(size = 11, color = 'black'),
									axis.title = element_blank())

### Plot ----
# Base islands
(gfogo <- ggplot(fogo) +
 	geom_sf(fill = islandcol) +
 	themeMap)

# Base NL
(gnl <- ggplot(nl) +
	geom_sf(fill = islandcol) +
	themeMap +
	geom_rect(aes(xmin = xmin, xmax = xmax,
								ymin = ymin, ymax = ymax),
						data = bb))

# TODO: need to project
### Output ----
# ggsave(
# 	'graphics/01-fogo-island.png',
# 	width = 5,
# 	height = 5,
# 	dpi = 320
# )
