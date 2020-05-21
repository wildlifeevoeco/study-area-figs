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
	theme(axis.text = element_blank())



# Combine -----------------------------------------------------------------

g <- grmnp +
 	annotation_custom(
 		ggplotGrob(gmb))#,
 	# 	xmin = utmBB$x[2] - 0.9e4,
 	# 	xmax = utmBB$x[2] + 0.1e4,
 	# 	ymin = utmBB$y[1],
 	# 	ymax = utmBB$y[1] + 1e4
 	# )






# Output ------------------------------------------------------------------
ggsave(
	'graphics/14-riding-mountain-inset.png',
	g,
	width = 10,
	height = 10,
	dpi = 320
)
