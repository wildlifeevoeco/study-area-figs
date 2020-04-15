### Terra Nova Buns Grid Study Area Figure ====
# Alec L. Robitaille, Isabella Richmond


### Packages ----
libs <- c(
	'data.table',
	'ggplot2',
	'sf'
)
lapply(libs, require, character.only = TRUE)


### Data ----
grids <- data.table(
	SiteName = c("Bloomfield",
							 "Dumphy's Pond", "TNNP North", "Unicorn"),
	AgeClass = c("> 20 - 40 yrs", "> 40 - 60 yrs",
							 "> 60 - 80 yrs", "> 80 -100 yrs"),
	x = c(
		723457,
		712397,
		723063,
		720037
	),
	y = c(
		5359856,
		5368213,
		5390372,
		5391103
	)
)


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
 	geom_point(aes(x, y), data = grids) +
 	coord_sf(xlim = c(bb['xmin'], bb['xmax']),
 					 ylim = c(bb['ymin'], bb['ymax'])) +
 	guides(color = FALSE) +
 	themeMap)


### Output ----
ggsave(
	'graphics/08-terra-nova-buns.png',
	gtn,
	width = 10,
	height = 10,
	dpi = 320
)
