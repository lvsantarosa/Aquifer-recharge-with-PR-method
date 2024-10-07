
# libraries ---------------------------------------------------------------
library(dplyr); library(purrr); library(glue)
library(terra)


# WORK DIRECTORY ----------------------------------------------------------

setwd('C:/Users/lucas/Documents/02_ARTIGOS/00_RECARGA_SP/00_PR_METHOD/')

# temp directory ----------------------------------------------------------
dir.create(path = 'temp', showWarnings = FALSE) #To create a temp directory to exclude in the final
terraOptions(tempdir = 'temp')


# SOIL INFORMATION --------------------------------------------------------
# SCS Soil group from SCS method	A = (1)	B = (2)	C = (3)	D = (4)
# Layers from Soil Grid
# See my script to download in Google Earth Engine
# https://github.com/lvsantarosa/Soil-Grid-on-Google-Earth-Engine

soil = c(
   terra::rast('01_DADOS/00_SOIL/clay.tif') %>% mean()
  ,terra::rast('01_DADOS/00_SOIL/sand.tif') %>% mean()
  ,terra::rast('01_DADOS/00_SOIL/silt.tif') %>% mean()
) / 1000

names(soil) = c('clay', 'sand', 'silt')
soil
plot(soil)


sum(soil) %>% plot()

soil_types_table =
  soiltexture::TT.classes.tbl(class.sys = "USDA.TT") %>%
  as_tibble() %>%
  mutate(
    Class = case_when(
      abbr %in% c('Si', 'SiLo', 'Lo') ~ 2
      ,abbr %in% c('SaLo', 'LoSa', 'Sa') ~ 1
      ,abbr %in% c('SaClLo') ~ 3
      ,TRUE ~ 4
    )) %>%
  select(Abbreviation = abbr, Name = name, Class)

soil_types_table

soiltexture::TT.plot(
  class.sys = "USDA.TT",
  main = "Soil texture data"
)

# calculate_textural_triangle = function(clay, sand, silt) {
#
#   soil_matrix = data.frame(CLAY = clay, SILT = silt, SAND = sand)
#
#   TT.points.in.classes(
#     tri.data = soil_matrix,
#     class.sys = "USDA.TT",
#     PiC.type = "t"
#     ,tri.sum.tst = FALSE
#   )
# }

# see https://www.biologysimulations.com/post/how-to-use-the-soil-texture-triangle

calculate_textural_triangle = function(clay, sand, silt) {
  case_when(

    clay <= 0.05 & sand <= 0.05 & silt <= 0.05 ~ 0

    ,clay >= 0.35 ~ 4
    ,clay >= 0.25 & sand <= 0.45 ~ 4

    ,clay >= 0.2 & silt <= 0.275 ~ 3

    ,silt <= 0.5 ~ 2

    ,clay <= 0.075 ~ 1

    ,sand <= 0.575 ~ 2

    ,TRUE ~ 1
  )
}

soil_classified = terra::app(soil, fun = function(x) calculate_textural_triangle(clay = x[, 1], sand = x[,2], silt = x[,3]))
soil_classified %>% plot()

grid <- terra::rast(xmin = -53.1, xmax = -47, ymin = -23.5, ymax = -19.7, resolution = c(0.0025, .0025))
soil_final = project(soil_classified, grid) %>% terra::as.int()
soil_final %>% plot()


# LULC --------------------------------------------------------------------
# MAPBIOMAS LULC to Brazil, change the year to download diferentes LULC:  
# https://storage.googleapis.com/mapbiomas-public/initiatives/brasil/collection_9/lclu/coverage/brasil_coverage_2023.tif

list <- list.files('01_DADOS/01_LULC/', full.names = TRUE, pattern = '.tif$')

uses <- list()
for(i in 1:length(list)) {
  uses[[i]] <- terra::rast(list[i]) %>% 
               terra::resample(soil_final, method = 'mode') %>% 
               terra::as.int()
  print(uses[[i]])
}

mapbio_resample = terra::rast(uses)
mapbio_resample[mapbio_resample <= 0] = NA
terra::plot(mapbio_resample[[1]])

#writeRaster(mapbio_resample, '01_DADOS/01_LULC/brasil_coverage_2023.tif', overwrite = T)


# MAPBIOMAS reclassified as SCS method --------------
# There are different classes depending on the MAPBIOMAS collection. 

#10	Urban (24)
#20	Agriculture (14, 18, 19, 20, 21, 36, 39, 40, 41, 46, 47, 48, 62)
#30	Forest (1, 3, 4, 5, 49)
#40	Silviculture (9)
#50	Grassland  (12, 13, 32, 50)
#60	Uncover (23,25, 29, 30)
#70	Pasture (15)
#100 Water (10, 27,31,33)


# Multiple replacements
class_map_scs <- rbind(c(24,  10), 
                       c(14,  20), c(18, 20), c(19, 20), c(20, 20), c(21, 20), c(36, 20), c(39, 20), c(40, 20), c(41, 20), c(46, 20), c(47, 20), c(48, 20), c(62, 20), 
                       c(1 ,  30), c(3 , 30), c(4 , 30), c(5 , 30), c(49, 30), 
                       c(9 ,  40), 
                       c(12,  50), c(13, 50), c(32, 50), c(50, 50), 
                       c(23,  60), c(25, 60), c(29, 60), c(30, 60),
                       c(15,  70),
                       c(11, 100), c(27, 100), c(31, 100), c(33, 100))


#Reclassify uses based in the matrix
rc_map_scs = classify(mapbio_resample, class_map_scs)
rc_map_scs[rc_map_scs < 10] = NA

terra::plot(rc_map_scs[[1]])

# CN ----------------------------------------------------------------------

# Values based in the method => https://www.nrcs.usda.gov/Internet/FSE_DOCUMENTS/stelprdb1044171.pdf

#	Sum Soil and Land Use -> to reclassify using the SCS values above				
#	Uses/Soil	    A	  B	  C	  D
#	Urban	        11	12	13	14
#	Crops	        21	22	23	24
#	Florest	      31	32	33	34
#	Silviculture	41	42	43	44
#	Herbaceus	    51	52	53	54
#	Baresoil	    61	62	63	64
#	Pasture	      71	72	73	74
#	No Data	      101	102	103	104

#	SCS method values 				
#	Uses/Soil     A	  B	  C	  D
#	Urban	        89	92	94	95
#	Crops	        64	75	82	85
#	Florest	      30	55	70	77
#	Silviculture	45	66	77	86
#	Herbaceus	    48	62	71	85
#	Bare Soil	    77	86	91	94
#	Pasture	      39	61	74	80
#	No Data	      0	  0	  0	  0


class_cn <- rbind(c(11,89), c(12,92), c(13,94), c(14,95), 
                  c(21,64), c(22,75), c(23,82), c(24,85), 
                  c(31,30), c(32,55), c(33,70), c(34,77), 
                  c(41,45), c(42,66), c(43,77), c(44,86), 
                  c(51,48), c(52,62), c(53,71), c(54,85),
                  c(61,77), c(62,86), c(63,91), c(64,94), 
                  c(71,39), c(72,61), c(73,74), c(74,80), 
                  c(101,0), c(102,0), c(103,0), c(104,0), 
                  c(10,0 ), c(20,0 ), c(30,0 ), c(40,0 ), 
                  c(50,0 ), c(60,0 ), c(70,0 ), c(100,0))

#Reclassify
sum_soil_uses = soil_final + rc_map_scs
cn_final = classify(sum_soil_uses, class_cn)


#Use year as names for each CN
#Nomes = seq(from = 2000, to = 2021)
#names(cn_final) = Nomes
Nomes = 2023
names(cn_final) = Nomes

cn_final[cn_final < 30] = NA
terra::plot(cn_final[[1]])

library(glue)
library(dplyr)


# EXPORT ------------------------------------------------------------------

#Export CN
filename = glue("02_RESULTADOS/00_CN/CN_{Nomes}.tif")
cn_final %>% writeRaster(filename = filename, overwrite = TRUE)

#Export soil layer
Soil_Hidro_exp <- mask(soil_final, cn_final[[1]])
terra::plot(Soil_Hidro_exp)
terra::writeRaster(Soil_Hidro_exp, "02_RESULTADOS/00_CN/00_SOIL_HIDRO/Soil_Hidro.tif", overwrite = TRUE)

# CLEAN TEMP FILE ---------------------------------------------------------
unlink(x = list.files('temp', full.names = TRUE)) #Delete the temp archives
