# === Middle Ridge - Figure -----------------------------------------------
# Alec Robitaille


# Packages ----------------------------------------------------------------
libs <- c(
	'data.table',
	'ggplot2',
	'sf'
)
lapply(libs, require, character.only = TRUE)


# Data --------------------------------------------------------------------
# mr <- st_read('output/mr-bounds.gpkg')
roads <- st_read('output/mr-roads.gpkg')
# water <- st_read('output/mr-water.gpkg')
# forest <- st_read('output/mr-forest.gpkg')
areas <- st_read('output/mr-protected-areas.gpkg')
nl <- st_read('output/newfoundland-polygons.gpkg')

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
									panel.background = element_rect(fill = watercol),
									panel.grid = element_line(color = gridcol, size = 0.3),
									axis.text = element_text(size = 11, color = 'black'),
									axis.title = element_blank())


# Plot --------------------------------------------------------------------
roads$geometry <- st_geometry(roads)

# Base mr
bb <- st_bbox(st_buffer(st_centroid(mr), 6e4))

gmr <- ggplot() +
	# geom_sf(fill = landcol, data = nl) +
	# geom_sf(fill = landcol, data = mr) +
	geom_sf(fill = forestcol, color = forestcol, size = 0.1, data = forest) +
	geom_sf(fill = watercol, color = streamcol, size = 0.2, data = water) +
	geom_sf(aes(color = highway), alpha = 0.8, data = roads, size = 0.5) +
	# geom_sf(fill = NA, size = 0.5, color = 'black', data = mr) +
	scale_color_manual(values = roadpal) +
	guides(color = FALSE, fill = FALSE) +
	# coord_sf(xlim = c(bb['xmin'] - 1e4, bb['xmax']),
	# 				 ylim = c(bb['ymin'] + 4.5e4, bb['ymax']) - 3e4) +
	themeMap



# Output ------------------------------------------------------------------
ggsave(
	'graphics/16-middle-ridge.png',
	gmr,
	width = 10,
	height = 10,
	dpi = 320
)


