### Terra Nova Study Area Figure ====
# Alec L. Robitaille, Isabella Richmond


### Packages ----
libs <- c(
	'data.table',
	'ggplot2',
	'sf'
)
lapply(libs, require, character.only = TRUE)


### Data ----
tn <- st_read('output/terra-nova-polygons.gpkg')
roads <- st_read('output/terra-nova-roads.gpkg')

nl <- st_read('output/newfoundland-polygons.gpkg')

water <- st_read('output/terra-nova-water.gpkg')
streamLns <- st_read('output/terra-nova-streams-lns.gpkg')
streamPols <- st_read('output/terra-nova-streams-pols.gpkg')

# CRS
utm <- st_crs('+proj=utm +zone=21 ellps=WGS84')

# Only main highway and primary
selroads <- c('trunk', 'primary')
highway <- roads[roads$highway %in% selroads,]


### Theme ----
# Colors
source('R/00-palette.R')

roadcols <- data.table(highway = selroads)
roadcols[, cols := gray.colors(.N, start = 0.1, end = 0.4)]
roadpal <- roadcols[, setNames(cols, highway)]


# Theme
themeMap <- theme(panel.border = element_rect(size = 1, fill = NA),
									panel.background = element_rect(fill = watercol),
									panel.grid = element_line(color = gridcol, size = 0.2),
									axis.text = element_text(size = 11, color = 'black'),
									axis.title = element_blank())

# x/y limits
bb <- st_bbox(tn) - rep(c(1e3, -1e3), each = 2)


### Plot ----
# Crop NL
nlcrop <- st_crop(nl, bb + rep(c(-5e4, 5e4), each = 2))

# Base terra-nova
(gtn <- ggplot() +
 	geom_sf(fill = islandcol, size = 0.3, color = coastcol, data = nlcrop) +
 	geom_sf(fill = parkcol, size = 0.3, color = parkboundcol, data = tn) +
 	geom_sf(fill = watercol, size = 0.2, color = coastcol, data = water) +
 	geom_sf(fill = streampolcol, color = NA, data = streamPols) +
 	geom_sf(color = streamcol, size = 0.4, data = streamLns) +
 	geom_sf(aes(color = highway), data = highway) +
 	geom_sf_label(aes(label = 'Terra Nova National Park'), size = 5, fontface = 'bold', data = tn) +
 	scale_color_manual(values = roadpal) +
 	coord_sf(xlim = c(bb['xmin'], bb['xmax']),
 					 ylim = c(bb['ymin'], bb['ymax'])) +
 	guides(color = FALSE) +
 	themeMap)


### Output ----
ggsave(
	'graphics/07-terra-nova.png',
	gtn,
	width = 10,
	height = 10,
	dpi = 320
)
