# === Butter Pot Figure ---------------------------------------------------
# Emily Monk, Alec L. Robitaille


# Packages ----------------------------------------------------------------
libs <- c('sf', 'ggplot2', 'data.table')
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
#service roads include campground roads and fire road in butterpot
#motorway includes TCH
#primary provides context of other major roads in area
selroads <- c('primary',  'motorway', 'service')
highway <- roads[roads$highway %in% selroads,]



#Add trapping grids
old_grid <- data.frame(
	x = c(-53.06592, -53.06749, -53.07224, -53.0738),
	y = c(47.39021, 47.39421, 47.38913, 47.39313)
)

new_grid <- data.frame(
	x = c(-53.06253, -53.05724, -53.06596, -53.06068),
	y = c(47.41072, 47.41287, 47.41459, 47.41674)
)


old_unprojected = st_as_sf(old_grid, coords = c('x', 'y'), crs = 4326)
old_projected = st_transform(old_unprojected, 32621)
old_poly <- old_projected %>%
	dplyr::summarise() %>%
	st_cast("POLYGON") %>%
	st_convex_hull()

new_unprojected = st_as_sf(new_grid, coords = c('x', 'y'), crs = 4326)
new_projected = st_transform(new_unprojected, 32621)
new_poly <- new_projected %>%
	dplyr::summarise() %>%
	st_cast("POLYGON") %>%
	st_convex_hull()


# Theme -------------------------------------------------------------------
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
		geom_sf_label(aes(label = 'Butter Pot Provincial Park'), size = 4, fontface = 'bold',
									data = butter_pot, nudge_x = -600, nudge_y = -1000) +
		geom_sf(color = "red", data = old_poly) +
		geom_sf(color = "red", data = new_poly) +
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
					plot.margin = grid::unit(c(-1,-1,-1,-1), "mm"))


# Overlay NL map onto butterpot map
annotateSf <- st_sfc(st_multipoint(matrix(c(-53.055, -53.01,
																						47.319, 47.38),
																					nrow = 2)))
st_crs(annotateSf) <- 4326
utm <- st_crs(32621)
annotateBB <- st_bbox(st_transform(annotateSf, utm))

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
	height = 10,
	dpi = 320
)
