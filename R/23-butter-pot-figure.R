# === Butter Pot Figure ---------------------------------------------------
# Emily Monk, Alec L. Robitaille


# Packages ----------------------------------------------------------------
libs <- c('sf', 'sfheaders', 'ggplot2', 'data.table')
lapply(libs, require, character.only = TRUE)



# Data --------------------------------------------------------------------
crs_latlon <- st_crs(4326)
crs_proj <- st_crs(32621)

butter_pot <- st_read(file.path('output', 'butter-pot-protected-areas.gpkg'))
roads <- st_read(file.path('output', 'butter-pot-roads.gpkg'))
water <- st_read(file.path('output', 'butter-pot-water.gpkg'))
streams_lns <- st_read(file.path('output', 'butter-pot-streams-lns.gpkg'))
streams_pols <- st_read(file.path('output', 'butter-pot-streams-pols.gpkg'))
nl <- st_read(file.path('output', 'newfoundland-polygons.gpkg'))


# Select road types to display
# - service: roads include campground roads and fire road in Butter Pot
# - motorway: TCH
# - primary: context of other major roads in area
selroads <- c('primary',  'motorway', 'service')
highway <- roads[roads$highway %in% selroads,]


# Add trapping grids
old_grid <- sf_polygon(matrix(
	c(-53.06592, -53.06749, -53.0738, -53.07224,
		47.39021, 47.39421, 47.39313, 47.38913),
	ncol = 2)
)
st_crs(old_grid) <- crs_latlon
old_grid <- st_transform(st_as_sfc(old_grid), crs_proj)

new_grid <- sf_polygon(matrix(
	c(-53.06253, -53.05724, -53.06068, -53.06596,
		47.41072, 47.41287, 47.41674, 47.41459),
	ncol = 2)
)
st_crs(new_grid) <- crs_latlon
new_grid <- st_transform(st_as_sfc(new_grid), crs_proj)



# Theme -------------------------------------------------------------------
# Colors
source('R/00-palette.R')

roadcols <- data.table(highway = selroads)
roadcols[, cols := gray.colors(.N, start = 0.1, end = 0.4)]
roadpal <- roadcols[, setNames(cols, highway)]


# Theme
themeMap <- theme(panel.border = element_rect(linewidth = 1, fill = NA),
									panel.background = element_rect(fill = watercol),
									panel.grid = element_line(color = gridcol, size = 0.2),
									axis.text = element_text(size = 11, color = 'black'),
									axis.title = element_blank())

# x/y limits (in meters)
bb <- st_bbox(butter_pot) - rep(c(1e3, -1e3), each = 2)



# Plot --------------------------------------------------------------------
# Crop NL
nlcrop <- st_crop(nl, bb + rep(c(-5e4, 5e4), each = 2))

# Butterpot map with rectangles on grids
(gbp <- ggplot() +
		geom_sf(fill = islandcol, size = 0.3, color = coastcol, data = nlcrop) +
		geom_sf(fill = parkcol, size = 0.3, color = parkboundcol, data = butter_pot) +
		geom_sf(fill = watercol, size = 0.2, color = coastcol, data = water) +
		geom_sf(fill = streampolcol, color = NA, data = streams_pols) +
		geom_sf(color = streamcol, size = 0.4, data = streams_lns) +
		geom_sf(aes(color = highway), data = highway) +
		# geom_sf_label(aes(label = 'Butter Pot Provincial Park'), size = 4, fontface = 'bold',
		# 							data = butter_pot, nudge_x = -600, nudge_y = -1000) +
		geom_sf(fill = 'red', data = old_grid) +
		geom_sf(fill = 'red', data = new_grid) +
		scale_color_manual(values = roadpal) +
		coord_sf(xlim = c(bb['xmin'], bb['xmax']),
						 ylim = c(bb['ymin'], bb['ymax'])) +
		guides(color = 'none') +
		themeMap)

# Base NL with red box indicating Butter Pot
gnl <- ggplot() +
		geom_sf(fill = islandcol, linewidth = 0.3, color = coastcol, data = nl) +
		geom_sf(fill = parkcol, linewidth = 0.3, color = coastcol, data = butter_pot) +
		geom_rect(
			aes(
				xmin = bb['xmin'],
				xmax = bb['xmax'],
				ymin = bb['ymin'],
				ymax = bb['ymax']
			),
			fill = NA,
			linewidth = 1.5,
			color = 'red'
		) +
		themeMap +
		theme(axis.text = element_blank(),
					axis.ticks = element_blank(),
					plot.margin = grid::unit(c(-1,-1,-1,-1), 'mm'))


# Overlay NL map onto butterpot map
annotateSf <- st_sfc(st_multipoint(matrix(
	c(-53.055,-53.01, 47.319, 47.38),
	nrow = 2))
)
st_crs(annotateSf) <- crs_latlon
annotateBB <- st_bbox(st_transform(annotateSf, crs_proj))

(g <- gbp +
		annotation_custom(
			ggplotGrob(gnl),
			xmin = annotateBB['xmin'],
			xmax = annotateBB['xmax'],
			ymin = annotateBB['ymin'],
			ymax = annotateBB['ymax']
		)
)


# Output ------------------------------------------------------------------
ggsave(
	'graphics/23-butter-pot.png',
	gbp,
	width = 10,
	height = 8,
	dpi = 320
)
