### Bloomfield Study Area Figure ====
# Alec L. Robitaille, Juliana Balluffi-Fry


### Packages ----
libs <- c(
	'data.table',
	'ggplot2',
	'sf',
	'ggrepel'
)
lapply(libs, require, character.only = TRUE)


### Data ----
grids <- data.table(SiteName = 'Bloomfield',
										x = 723457,
										y = 5359856)

roads <- st_read('output/terra-nova-roads.gpkg')

nl <- st_read('output/newfoundland-polygons.gpkg')

water <- st_read('output/terra-nova-water.gpkg')

streamLns <- st_read('output/terra-nova-streams-lns.gpkg')

streamPols <- st_read('output/terra-nova-streams-pols.gpkg')


# CRS
utm <- st_crs(nl)

# Bounding Box
# In meters
dist <- 8e3
zoomout <- rep(c(-dist, dist), each = 2)
bb <- st_bbox(st_as_sf(grids, coords = c('x', 'y'))) + zoomout

# Zoomout x2 to ensure no data is clipped within view
streams <- st_crop(streamLns, bb + (zoomout * 2))
highway <- st_crop(roads, bb + (zoomout * 2))
nlcrop <- st_crop(nl, bb + (zoomout * 2))


### Theme ----
# Colors
source('R/00-palette.R')

roadcols <- data.table(highway = c('trunk',  'trunk_link', 'primary', 'secondary', 'tertiary',
																	 'service', 'residential', 'unclassified', 'footway',
																	 'path', 'track'
))
roadcols[, cols := gray.colors(.N, start = 0.1, end = 0.6)]
roadpal <- roadcols[, setNames(cols, highway)]


# Theme
themeMap <- theme(panel.border = element_rect(size = 1, fill = NA),
									panel.background = element_rect(fill = watercol),
									panel.grid = element_line(color = gridcol, size = 0.2),
									axis.text = element_text(size = 11, color = 'black'),
									axis.title = element_blank())

### Plot ----
# TODO: add the NL base plot (see 08-)


# Base bloomfield
(gblm <- ggplot() +
 		geom_sf(fill = islandcol, size = 0.3, color = coastcol, data = nlcrop) +
		geom_sf(fill = watercol, size = 0.2, color = coastcol, data = water) +
		geom_sf(aes(color = highway), data = highway) +
 		geom_sf(fill = streamcol, color = NA, data = streamPols) +
 	 	geom_sf(color = streamcol, size = 0.4, data = streamLns) +
 	 	geom_point(aes(x, y), size = 2, data = grids) +
 	 	geom_label_repel(aes(x, y, label = SiteName), size = 4.5, data = grids) +
 		scale_color_manual(values = roadpal) +
		coord_sf(xlim = c(bb['xmin'], bb['xmax']),
						 ylim = c(bb['ymin'], bb['ymax'])) +
		guides(color = FALSE) +
		themeMap)

# TODO: add patchwork above

# TODO: combine the plots using annotation custom (see 08)


### Output ----
ggsave(
	'graphics/09-bloomfield.png',
	gblm,
	width = 10,
	height = 10,
	dpi = 320
)
