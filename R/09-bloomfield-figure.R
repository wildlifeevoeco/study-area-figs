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
dist <- 4e4
zoomout <- rep(c(-dist, dist), each = 2)
bb <- st_bbox(st_as_sf(grids, coords = c('x', 'y'))) + zoomout

# Zoomout x2 to ensure no data is clipped within view
streams <- st_crop(streamLns, bb + (zoomout * 2))
highway <- st_crop(roads, bb + (zoomout * 2))
nlcrop <- st_crop(nl, bb + (zoomout * 2))


### Theme ----
# Colors
source('R/00-palette.R')

roadcols <- data.table(highway = c('trunk',  'trunk_link', 'primary', 'primary_link',
																	 'secondary', 'secondary_link', 'tertiary',
																	 'tertiary_link',
																	 'service', 'residential', 'construction' ,
																	 'unclassified', 'cycleway', 'footway', 'bridleway',
																	 'path', 'track', 'steps'
))
roadcols[, cols := gray.colors(.N, start = 0.1, end = 0.6)]
roadpal <- roadcols[, setNames(cols, highway)]


# Theme
themeMap <- theme(panel.border = element_rect(size = 1, fill = NA),
									panel.background = element_rect(fill = watercol),
									panel.grid = element_line(color = gridcol, size = 0.6),
									axis.text = element_text(size = 11, color = 'black'),
									axis.title = element_blank())

### Plot ----

#NL plot
(gnl <- ggplot() +
 	geom_sf(fill = islandcol, size = 0.3, color = coastcol, data = nl) +
 	geom_rect(
 		aes(
 			xmin = bb['xmin'],
 			xmax = bb['xmax'],
 			ymin = bb['ymin'],
 			ymax = bb['ymax']
 		),
 		fill = NA,
 		size = 1.5,
 		color = 'red'
 	) +
 	themeMap +
 	theme(axis.text = element_blank(),
 				axis.ticks = element_blank(),
 				plot.margin = grid::unit(c(-1,-1,-1,-1), 'mm')))


# Base bloomfield
(gblm <- ggplot() +
 	geom_sf(fill = islandcol, size = 0.3, color = coastcol, data = nlcrop) +
	geom_sf(fill = watercol, size = 0.2, color = coastcol, data = water) +
 	geom_sf(fill = streampolcol, color = NA, data = streamPols) +
	geom_sf(color = streamcol, size = 0.4, data = streamLns) +
 	geom_sf(aes(color = highway), size = 1, data = highway) +
	geom_point(aes(x, y), size = 2, data = grids) +
	geom_label_repel(aes(x, y, label = SiteName), size = 4.5, data = grids) +
 	scale_color_manual(values = roadpal) +
	coord_sf(xlim = c(bb['xmin'], bb['xmax']),
					 ylim = c(bb['ymin'], bb['ymax'])) +
	guides(color = FALSE) +
	themeMap)



#add NL map to bloomfield map
annoBB <- st_sfc(st_point(c(-54.4, 48.1)))
st_crs(annoBB) <- 4326
annotateBB <- st_bbox(st_buffer(st_transform(annoBB, utm), 1e3))

g <- gblm +
		annotation_custom(
			ggplotGrob(gnl),
			xmin = annotateBB['xmin'],
			xmax = annotateBB['xmax'],
			ymin = annotateBB['ymin'],
			ymax = annotateBB['ymax']
		)


### Output ----
ggsave(
	'graphics/09-bloomfield.png',
	g,
	width = 10,
	height = 10,
	dpi = 320
)
