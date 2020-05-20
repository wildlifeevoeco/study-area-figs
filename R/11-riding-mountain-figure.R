# === Riding Mountain National Park - Figure ------------------------------
# Alec L. Robitaille



# Packages ----------------------------------------------------------------
libs <- c(
	'data.table',
	'ggplot2',
	'sf'
)
lapply(libs, require, character.only = TRUE)



# Data --------------------------------------------------------------------
rmnp <- st_read('output/rmnp-bounds.gpkg')
roads <- st_read('output/rmnp-roads.gpkg')
water <- st_read('output/rmnp-water.gpkg')
forest <- st_read('output/rmnp-forest.gpkg')


# CRS
utm <- st_crs(32614)


# Theme -------------------------------------------------------------------
## Colors
source('R/00-palette.R')

# Road colors
roads$highway <- factor(roads$highway, levels = levels(roadlevels))
roadcols <- data.table(highway = c('trunk',  'trunk_link', 'primary', 'primary_link',
																	 'secondary', 'secondary_link', 'tertiary',
																	 'tertiary_link',
																	 'service', 'residential', 'construction' ,
																	 'unclassified', 'cycleway', 'footway', 'bridleway',
																	 'path', 'track', 'steps'
))
roadcols[, cols := gray.colors(.N, start = 0.1, end = 0.6)]
roadpal <- roadcols[, setNames(cols, highway)]

## Theme
themeMap <- theme(panel.border = element_rect(size = 1, fill = NA),
									panel.background = element_rect(fill = coastcol),
									panel.grid = element_line(color = gridcol, size = 0.2),
									axis.text = element_text(size = 11, color = 'black'),
									axis.title = element_blank())


# Plot --------------------------------------------------------------------
roads$geometry <- st_geometry(roads)

gplot(water, maxpixels = 1e3) +
	geom_tile(aes(fill = factor(value))) +
	scale_fill_manual(values = c("NA" = NULL, "1" = watercol)) +
	geom_sf(aes(color = highway), data = roads) +
	# scale_color_manual(values = roadpal) +
	guides(color = FALSE, fill = FALSE) +
	coord_sf() +
	themeMap

# Base rmnp
(grmnp <- ggplot() +
 	# geom_sf(fill = islandcol, size = 0.3, color = coastcol, data = rmnp) +
 	geom_sf(aes(color = highway), data = roads) +
 	scale_color_manual(values = roadpal) +
 	guides(color = FALSE, fill = FALSE) +
 	themeMap)



# Output ------------------------------------------------------------------
ggsave(
	'graphics/11-riding-mountain.png',
	grmnp,
	width = 10,
	height = 10,
	dpi = 320
)
