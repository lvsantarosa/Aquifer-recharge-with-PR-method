# Aquifer recharge with PR method

To apply the SCS method, the first step involves calculating the Curve Number (CN). In this example, the Land Cover Classification project ([MapBiomas](https://mapbiomas.org/)) and the Soil Grid (250 m) ([download instructions here](https://github.com/lvsantarosa/Soil-Grid-on-Google-Earth-Engine)) were used to generate a spatial CN utilizing the terra package. Detailed documentation of the SCS Method can be found in the USDA's Urban Hydrology for Small Watersheds.

With the CN calculated, the daily runoff is computed to produce a water budget (PR = P - (ETP + Roff)). Precipitation data is sourced from GPM, while evapotranspiration data is from GLDAS 2.1, both available in NASA's GES DISC ([download instructions here](https://github.com/lvsantarosa/NASA-data-download)).

An example of processing data for 2023 is available [here](https://drive.google.com/drive/folders/1gQTgBNakUZKlkHiiFL14R_Fw8En824Qe?usp=drive_link).

### The following paper was written using this method:

Santarosa, L. V., Pinto, G. V. F., Blandón Luengas, J. S., & Gastmans, D. (2024). Remote sensing to quantify potential aquifer recharge as a complementary tool for groundwater monitoring. Hydrological Sciences Journal. https://doi.org/10.1080/02626667.2024.2412741
