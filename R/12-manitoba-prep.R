# === Manitoba - Prep -----------------------------------------------------
# Alec Robitaille



# Packages ----------------------------------------------------------------
libs <- c('sf', 'osmdata', 'rnaturalearth')
lapply(libs, require, character.only = TRUE)


# Download OSM data -------------------------------------------------------
bounds <- ne_download(
	scale = 'large',
	type = 'states',
	category = 'cultural',
	returnclass = 'sf'
)

admin only

zz <- opq(getbb('Newfoundland')) %>%
	add_osm_feature(key = 'place', value = 'island') %>%
	osmdata_sf()

get borders of all provinces and usa

# Prep geometries ---------------------------------------------------------


# Output ------------------------------------------------------------------



