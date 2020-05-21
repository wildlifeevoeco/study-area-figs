# === Riding Mountain National Park - Inset Figure ------------------------------
# Alec L. Robitaille


# Packages ----------------------------------------------------------------
libs <- c(
	'data.table',
	'ggplot2',
	'sf'
)
lapply(libs, require, character.only = TRUE)



# Source MB and RMNP figures ----------------------------------------------
# Source MB figure script, provides ggplot "gmb"
source('R/13-manitoba-figure.R')

# Source RMNP figure, provides ggplot
source('R/11-riding-mountain-figure.R')



# Adjust plots ------------------------------------------------------------
gmb <- gmb +
	geom_point(aes(x, y), data = data.table(x = 415472, y = 5631636),
						 size = 10) +
	theme(axis.text = element_blank(),
				axis.ticks = element_blank(),
				plot.margin = grid::unit(c(-1,-1,-1,-1), "mm"))



# Combine -----------------------------------------------------------------
# used the ggannotate package to make finding these numbers easier
g <- grmnp +
 	annotation_custom(
 		ggplotGrob(gmb),
 		xmin = 340770,
 		ymin = 5584909,
 		xmax = 377059,
 		ymax = 5612715)




# Output ------------------------------------------------------------------
ggsave(
	'graphics/14-riding-mountain-inset.png',
	g,
	width = 10,
	height = 10,
	dpi = 320
)
