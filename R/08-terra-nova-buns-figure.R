### Terra Nova Buns Grid Study Area Figure ====
# Alec L. Robitaille, Isabella Richmond


### Packages ----
libs <- c(
	'data.table',
	'ggplot2',
	'ggrepel',
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

water <- st_read('output/terra-nova-water.gpkg')

# CRS
utm <- st_crs('+proj=utm +zone=21 ellps=WGS84')

# Only main highway and primary
selroads <- c('trunk', 'primary')
highway <- roads[roads$highway %in% selroads,]


### Theme ----
# Colors
watercol <- '#c3e2ec'
islandcol <- '#d0c2a9'
coastcol <- '#82796a'
roadcol <- '#666666'
gridcol <- '#323232'

parkcol <- '#9fb5a0'
parkboundcol <- '#4c5d3a'

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
bb <- st_bbox(tn) + rep(c(-5e3, 5e3), each = 2)
bbadjust <- bb #+ c(-1e3, 0, 0, 0)


### Plot ----
# Crop NL
nlcrop <- st_crop(nl, bbadjust + rep(c(-5e4, 5e4), each = 2))


# Base NL with red box indicating TN
(gnl <- ggplot() +
		geom_sf(fill = islandcol, size = 0.3, color = coastcol, data = nl) +
		geom_sf(fill = parkcol, size = 0.3, color = coastcol, data = tn) +
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
					plot.margin = grid::unit(c(-1,-1,-1,-1), "mm")))

# Base terra-nova
(gtn <- ggplot() +
		geom_sf(fill = islandcol, size = 0.3, color = coastcol, data = nlcrop) +
		geom_sf(fill = parkcol, size = 0.3, color = parkboundcol, data = tn) +
		geom_sf(fill = watercol, size = 0.2, color = coastcol, data = water) +
		geom_sf(aes(color = highway), data = highway) +
		scale_color_manual(values = roadpal) +
		geom_point(aes(x, y), data = grids) +
		geom_sf_label(aes(label = 'Terra Nova National Park'), size = 6, fontface = 'bold', data = tn) +
		geom_label_repel(aes(x, y, label = SiteName), data = grids) +
		coord_sf(xlim = c(bbadjust['xmin'], bbadjust['xmax']),
						 ylim = c(bbadjust['ymin'], bbadjust['ymax'])) +
		guides(color = FALSE) +
		themeMap)

# Use annotation custom to drop the NL inset on Fogo
# Numbers here taken from mapview(tn), just reading off the map
annotateSf <- st_sfc(st_multipoint(matrix(c(-53.8, -53.65,
																						48.35, 48.45),
																					nrow = 2)))
st_crs(annotateSf) <- 4326
annotateBB <- st_bbox(st_transform(annotateSf, utm))

(g <- gtn +
		annotation_custom(
			ggplotGrob(gnl),
			xmin = annotateBB['xmin'],
			xmax = annotateBB['xmax'],
			ymin = annotateBB['ymin'],
			ymax = annotateBB['ymax']
		)
)



### Output ----
ggsave(
	'graphics/08-terra-nova-buns.png',
	g,
	width = 10,
	height = 10,
	dpi = 320
)
