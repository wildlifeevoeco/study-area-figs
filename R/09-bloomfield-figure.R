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
minmax <- st_sfc(st_multipoint(matrix(
	c(-54.03,-53.93,
		48.358, 48.424),
	nrow = 2
)))
st_crs(minmax) <- 4326
adjust <- rep(c(-5e3, 5e3), each = 2)

bb <- st_bbox(st_transform(minmax, utm)) + adjust

streams <- st_crop(streamLns, bb + (adjust * 2))

highway <- st_crop(roads, bb + (adjust * 2))

nlcrop <- st_crop(nl, bb + (adjust * 2))


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
# Base bloomfield

# TODO: what else to add?
# TODO: add it to the readme
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

### Output ----
ggsave(
	'graphics/09-bloomfield.png',
	gblm,
	width = 10,
	height = 10,
	dpi = 320
)
