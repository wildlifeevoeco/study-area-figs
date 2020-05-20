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
									panel.background = element_rect(fill = islandcol),
									panel.grid = element_line(color = gridcol, size = 0.2),
									axis.text = element_text(size = 11, color = 'black'),
									axis.title = element_blank())


# Plot --------------------------------------------------------------------
roads$geometry <- st_geometry(roads)

# Base rmnp
bb <- st_bbox(st_buffer(st_centroid(rmnp), 4e4))

grmnp <- ggplot() +
		geom_sf(fill = forestcol, color = forestcol, size = 0.1, data = forest) +
		geom_sf(fill = watercol, color = streamcol, size = 0.1, data = water) +
		geom_sf(aes(color = highway), data = roads, size = 0.2) +
		geom_sf(fill = NA, size = 0.5, color = 'black', data = rmnp) +
		scale_color_manual(values = roadpal) +
	 	guides(color = FALSE, fill = FALSE) +
		coord_sf(xlim = c(bb['xmin'], bb['xmax']),
						 ylim = c(bb['ymin'] + 1e3, bb['ymax']) - 1e3) +
	 	themeMap



# Output ------------------------------------------------------------------
ggsave(
	'graphics/11-riding-mountain.png',
	grmnp,
	width = 10,
	height = 10,
	dpi = 320
)
