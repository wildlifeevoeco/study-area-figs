# === Fogo Island Figure --------------------------------------------------
# Alec L. Robitaille


# Packages ----------------------------------------------------------------
libs <- c(
	'data.table',
	'ggplot2',
	'sf', 'adehabitatHR'
)
lapply(libs, require, character.only = TRUE)


# Data --------------------------------------------------------------------
fogo <- st_read('output/fogo-island-polygons.gpkg')
roads <- st_read('output/fogo-roads.gpkg')

# CRS
utm <- st_crs('+proj=utm +zone=21 ellps=WGS84')


# Theme -------------------------------------------------------------------
# Colors
source('R/00-palette.R')

roadcols <- data.table(highway = c("primary", "secondary", "residential",
																	 "service", "unclassified", "footway"))
roadcols[, cols := gray.colors(.N, start = 0.1, end = 0.4)]
roadpal <- roadcols[, setNames(cols, highway)]


# Theme
themeMap <- theme(panel.border = element_rect(size = 1, fill = NA),
									panel.background = element_rect(fill = watercol),
									panel.grid = element_line(color = gridcol, size = 0.2),
									axis.text = element_text(size = 11, color = 'black'),
									axis.title = element_blank())


# Plot --------------------------------------------------------------------
# Base fogo
(gfogo <- ggplot() +
 	geom_sf(fill = islandcol, size = 0.3, color = coastcol, data = fogo) +
	geom_sf(aes(color = highway), data = roads) +
 	scale_color_manual(values = roadpal) +
 	guides(color = FALSE) +
 	themeMap)



# Output ------------------------------------------------------------------
ggsave(
	'graphics/02-fogo-island.png',
	gfogo,
	width = 10,
	height = 10,
	dpi = 320
)
