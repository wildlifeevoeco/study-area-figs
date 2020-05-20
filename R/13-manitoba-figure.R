# === Manitoba - Figure ------------------------------
# Alec L. Robitaille


# Packages ----------------------------------------------------------------
libs <- c(
	'data.table',
	'ggplot2',
	'sf'
)
lapply(libs, require, character.only = TRUE)



# Data --------------------------------------------------------------------
bounds <- st_read('output/manitoba-bounds.gpkg')
lakes <- st_read('output/manitoba-lakes.gpkg')


# CRS
utm <- st_crs(4326)


# Theme -------------------------------------------------------------------
## Colors
source('R/00-palette.R')

## Theme
themeMap <- theme(panel.border = element_rect(size = 1, fill = NA),
									panel.background = element_rect(fill = landcol),
									panel.grid = element_line(color = gridcol, size = 0.3),
									axis.text = element_text(size = 11, color = 'black'),
									axis.title = element_blank())


# Plot --------------------------------------------------------------------
# Base rmnp
mb <- bounds[bounds$name_en == 'Manitoba',]

bb <- st_bbox(st_buffer(st_centroid(mb), 1))

gmb <- ggplot() +
	geom_sf(fill = islandcol, data = mb) +
	geom_sf(fill = watercol, color = streamcol, size = 0.1, data = lakes) +
	geom_sf(fill = NA, size = 0.5, color = 'black', data = bounds) +
	guides(color = FALSE, fill = FALSE) +
	# coord_sf(xlim = c(bb['xmin'], bb['xmax']),
	# 				 ylim = c(bb['ymin'], bb['ymax'])) +
	themeMap



# Output ------------------------------------------------------------------
ggsave(
	'graphics/13-manitoba.png',
	gmb,
	width = 10,
	height = 10,
	dpi = 320
)
