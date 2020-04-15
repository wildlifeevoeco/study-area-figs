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

# CRS
utm <- st_crs('+proj=utm +zone=21 ellps=WGS84')

# Only main highway
highway <- roads[roads$highway == 'trunk',]


### Theme ----
# Colors
watercol <- '#c3e2ec'
islandcol <- '#d0c2a9'
coastcol <- '#82796a'
roadcol <- '#666666'
gridcol <- '#323232'
roadcol <- '#191919'

parkcol <- '#7F9B62'
parkboundcol <- '#4c5d3a'


# Theme
themeMap <- theme(panel.border = element_rect(size = 1, fill = NA),
									panel.background = element_rect(fill = watercol),
									panel.grid = element_line(color = gridcol, size = 0.2),
									axis.text = element_text(size = 11, color = 'black'),
									axis.title = element_blank())

# x/y limits
bb <- st_bbox(tn) - rep(c(1e3, -1e3), each = 2)


### Plot ----
# Base terra-nova
(gtn <- ggplot() +
 	geom_sf(fill = islandcol, size = 0.3, color = coastcol, data = nl) +
 	geom_sf(fill = parkcol, size = 0.3, color = parkboundcol, data = tn) +
 	geom_sf(color = roadcol, data = highway) +
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
