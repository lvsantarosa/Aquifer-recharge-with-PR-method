# Aquifer recharge with PR method

The first step to applying the SCS method is the Curve Number (CN) calculation. In this example, the Land Cover Classification project (https://mapbiomas.org/) and the Soil Grid (250 m) (see how to download here: https://github.com/lvsantarosa/Soil-Grid-on-Google-Earth-Engine) soil texture maps were used to generate a spatial CN using the `terra` package. The complete SCS Method is available in the documents of USDA (https://nationalstormwater.com/urban-hydrology-for-small-watersheds-tr-55/)

With the CN the daily riunoff is calculated to produce a water budgest (PR = P - (ETP + Roff)). The precipitation is from GPM and the evapotranpiration is from GLDAS 2.1, both from NASA dataset disponible in GES DISC (see how to download here: https://github.com/lvsantarosa/NASA-data-download). 

An exemple of processing with data for 2023 is disponible here: 

To apply the SCS method, the first step involves calculating the Curve Number (CN). In this example, the Land Cover Classification project ([available at MapBiomas](https://mapbiomas.org/)) and the Soil Grid (250 m) (download instructions here) were used to generate a spatial CN utilizing the terra package. Detailed documentation of the SCS Method can be found in the USDA's Urban Hydrology for Small Watersheds.

With the CN calculated, the daily runoff is computed to produce a water budget (PR = P - (ETP + Roff)). Precipitation data is sourced from GPM, while evapotranspiration data is from GLDAS 2.1, both available in NASA's GES DISC (download instructions here).

An example of processing data for 2023 is available here.

### The following paper was written using this method:

Santarosa, L. V., Pinto, G. V. F., Blandón Luengas, J. S., & Gastmans, D. (2024). Remote sensing to quantify potential aquifer recharge as a complementary tool for groundwater monitoring. Hydrological Sciences Journal. https://doi.org/10.1080/02626667.2024.2412741
