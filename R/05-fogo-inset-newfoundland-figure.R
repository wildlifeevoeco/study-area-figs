### Fogo Inset in NL Study Area Figure ====
# Alec L. Robitaille


### Packages ----
libs <- c(
	'data.table',
	'ggplot2',
	'sf',
	'rgdal'
)
lapply(libs, require, character.only = TRUE)


### Data ----
fogo <- st_read('output/fogo-island-polygons.gpkg')
roads <- st_read('output/fogo-roads.gpkg')

nl <- st_read('output/newfoundland-polygons.gpkg')


# CRS
utm <- st_crs('+proj=utm +zone=21 ellps=WGS84')

# Bbox from 01-fogo-island-prep.R
bb <- c(
	xmin = -54.3533,
	ymin = 49.5194,
	xmax = -53.954220,
	ymax = 49.763834
)
dtbb <- data.table(x = c(bb[['xmin']], bb[['xmax']]),
									 y = c(bb[['ymin']], bb[['ymax']]))

# Project and buffer out for clarity
buf <- 3e4
utmBB <- data.table(dtbb[, project(cbind(x, y), utm$proj4string)])



### Theme ----
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

### Plot ----
# Base Fogo
gfogo <- ggplot(fogo) +
	geom_sf(fill = islandcol, size = 0.3, color = coastcol) +
	geom_sf(aes(color = highway), data = roads) +
	scale_color_manual(values = roadpal) +
	guides(color = FALSE) +
	themeMap

# Base NL with red box indicating Fogo
gnl <- ggplot(nl) +
 	geom_sf(fill = islandcol, size = 0.3, color = coastcol) +
 	themeMap +
 	geom_sf(fill = islandcol, , size = 0.3, color = coastcol, data = fogo) +
 	geom_rect(
 		aes(
 			xmin = x[1],
 			xmax = x[2],
 			ymin = y[1],
 			ymax = y[2]
 		),
 		data = utmBB + c(-buf, buf),
 		fill = NA,
 		size = 1.5,
 		color = 'red'
 	) +
		theme(axis.text = element_blank(),
					axis.ticks = element_blank(),
					plot.margin = grid::unit(c(-1,-1,-1,-1), "mm"))


# Use annotation custom to drop the NL inset on Fogo
# Numbers here taken from the bbox but adjusted to be placed in the bottom left
(g <- gfogo +
	annotation_custom(
		ggplotGrob(gnl),
		xmin = utmBB$x[2] - 0.9e4,
		xmax = utmBB$x[2] + 0.1e4,
		ymin = utmBB$y[1],
		ymax = utmBB$y[1] + 1e4
	)
)


### Output ----
ggsave(
	'graphics/05-fogo-inset-nl.png',
	g,
	width = 7,
	height = 7,
	dpi = 320
)



### Alternative options ----
# Fogo with NL coastline visible
# (gnl <- ggplot(nl) +
#  	geom_sf(fill = islandcol) +
#  	themeMap +
#  	geom_sf(fill = islandcol, data = fogo) +
#  	coord_sf(
#  		xlim = c(691276 - 10000, 719709),
#  		ylim = c(5488671 - 10000, 5515541)
#  	) +
#  	geom_rect(
#  		aes(
#  			xmin = x[1],
#  			xmax = x[2],
#  			ymin = y[1],
#  			ymax = y[2]
#  		),
#  		data = utmBB,
#  		fill = NA,
#  		size = 1.5,
#  		color = 'red'
#  	))
