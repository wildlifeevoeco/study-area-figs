# === Middle Ridge - Figure -----------------------------------------------
# Alec Robitaille


# Packages ----------------------------------------------------------------
libs <- c(
	'data.table',
	'ggplot2',
	'sf',
	'ggrepel'
)
lapply(libs, require, character.only = TRUE)


# Data --------------------------------------------------------------------
roads <- st_read('output/mr-roads.gpkg')
areas <- st_read('output/mr-protected-areas.gpkg')
nl <- st_read('output/newfoundland-polygons.gpkg')


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
bb <- st_bbox(st_buffer(areas, 4e4))

areas$labx <- st_coordinates(st_centroid(areas))[, 'X']
areas$laby <- st_coordinates(st_centroid(areas))[, 'Y']

gmr <- ggplot() +
	geom_sf(fill = landcol, color = coastcol, data = nl) +
	geom_sf(fill = parkcol, color = parkcol, data = areas) +
	geom_sf(aes(color = highway), alpha = 0.8, data = roads, size = 0.5) +
	scale_color_manual(values = roadpal) +
	# geom_label_repel(aes(labx, laby, label = NAME_E), size = 5, fontface = 'bold', data = areas) +
	guides(color = FALSE, fill = FALSE) +
	coord_sf(xlim = c(bb['xmin'], bb['xmax']),
					 ylim = c(bb['ymin'], bb['ymax'])) +
	themeMap



# Output ------------------------------------------------------------------
ggsave(
	'graphics/16-middle-ridge.png',
	gmr,
	width = 10,
	height = 10,
	dpi = 320
)

