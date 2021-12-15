# AppEEARS Point Sample Extraction Readme  

## Table of Contents  

1. Request Parameters  
2. Request File Listing  
3. Point Sample Extraction Process  
4. Data Quality  
    4.1. Moderate Resolution Imaging Spectroradiometer (MODIS)  
    4.2. NASA MEaSUREs Shuttle Radar Topography Mission (SRTM) Version 3 (v3)  
    4.3. Gridded Population of the World (GPW) Version 4 (v4)  
    4.4. Suomi National Polar-orbiting Partnership (S-NPP) NASA Visible Infrared Imaging Radiometer Suite (VIIRS)  
    4.5. Soil Moisture Active Passive (SMAP)  
    4.6. MODIS Simplified Surface Energy Balance (SSEBop) Actual Evapotranspiration (ETa)  
    4.7. eMODIS Smoothed Normalized Difference Vegetation Index (NDVI)  
    4.8. Daymet  
    4.9. U.S. Landsat Analysis Ready Data (ARD)  
    4.10. Ecosystem Spaceborne Thermal Radiometer Experiment on Space Station (ECOSTRESS)  
    4.11. Advanced Spaceborne Thermal Emission and Reflection Radiometer (ASTER) Global Digital Elevation Model (GDEM) Version 3 (v3) and Global Water Bodies Database (WBD) Version 1 (v1)  
    4.12. NASA MEaSUREs NASA Digital Elevation Model (DEM) Version 1 (v1)  
5. Data Caveats  
6. Documentation  
7. Sample Request Retention  
8. Data Product Citations  
9. Software Citation  
10. Feedback  

## 1. Request Parameters  

    Name: Aqua_P05600_P05966  

    Date Completed:** 2021-09-21T17:32:09.627319  

    Id: 4ef73da1-a38b-496c-9c15-17c6e7d7d227  

    Details:  

        Start Date: 12-01-2020  

        End Date: 08-31-2021
    
        Layers:  

            LST_Day_1km (MYD11A1.006)  
            LST_Night_1km (MYD11A1.006)  
            QC_Day (MYD11A1.006)  
            QC_Night (MYD11A1.006)  
    
        Coordinates:  

            P05600, 42.30608262, 2.695582078  
            P05602, 42.30586189, 2.707667595  
            P05603, 42.30644419, 2.756452096  
            P05609, 42.29646889, 2.538020207  
            P05610, 42.29663195, 2.549580041  
            P05611, 42.29691272, 2.573549388  
            P05612, 42.29701716, 2.584830766  
            P05615, 42.2975101, 2.609793885  
            P05619, 42.2968984, 2.646106509  
            P05621, 42.29664921, 2.671316562  
            P05628, 42.29714139, 2.744308105  
            P05630, 42.29709531, 2.756233366  
            P05634, 42.28746274, 2.514057619  
            P05637, 42.28796954, 2.549969255  
            P05640, 42.28748533, 2.574110287  
            P05641, 42.28772896, 2.586541373  
            P05642, 42.28810514, 2.598632087  
            P05647, 42.28805809, 2.659243794  
            P05651, 42.28807367, 2.707276803  
            P05654, 42.28843119, 2.731946838  
            P05655, 42.28841311, 2.743736925  
            P05660, 42.28792162, 2.805235728  
            P05666, 42.27857729, 2.550278647  
            P05668, 42.27801941, 2.562046409  
            P05675, 42.27873095, 2.62288648  
            P05678, 42.27911577, 2.647600733  
            P05679, 42.27929234, 2.658332924  
            P05683, 42.27904151, 2.707694574  
            P05689, 42.27918886, 2.768248349  
            P05692, 42.2794098, 2.804679802  
            P05696, 42.26970732, 2.513066302  
            P05703, 42.27003952, 2.598867981  
            P05709, 42.27018223, 2.647808139  
            P05714, 42.27038483, 2.683312451  
            P05715, 42.26981423, 2.695429249  
            P05718, 42.27039876, 2.719812188  
            P05719, 42.27010216, 2.731357574  
            P05720, 42.27029344, 2.744113488  
            P05721, 42.27010381, 2.756288889  
            P05729, 42.26053337, 2.501279365  
            P05735, 42.26074595, 2.623017918  
            P05738, 42.26086812, 2.647265884  
            P05740, 42.2614981, 2.671365822  
            P05743, 42.26014696, 2.7079031  
            P05749, 42.26142486, 2.780086272  
            P05750, 42.25934131, 2.792932903  
            P05752, 42.25180744, 2.48924977  
            P05755, 42.250804, 2.526146328  
            P05757, 42.25146279, 2.562763567  
            P05760, 42.25152349, 2.599094429  
            P05762, 42.25167042, 2.623859934  
            P05766, 42.25169131, 2.659366877  
            P05771, 42.25181922, 2.719955047  
            P05772, 42.25189383, 2.732344054  
            P05776, 42.25181997, 2.768784983  
            P05779, 42.25182947, 2.792593796  
            P05781, 42.24217854, 2.488975936  
            P05786, 42.24181294, 2.538710034  
            P05789, 42.24293348, 2.586955184  
            P05790, 42.24263856, 2.610786701  
            P05792, 42.24245015, 2.708093828  
            P05793, 42.2428403, 2.720091725  
            P05796, 42.24263586, 2.744394967  
            P05797, 42.24295132, 2.756938855  
            P05798, 42.24241666, 2.76840721  
            P05802, 42.2339103, 2.501137569  
            P05810, 42.23387682, 2.671690945  
            P05815, 42.23383518, 2.72056781  
            P05817, 42.23369297, 2.756986502  
            P05818, 42.23364634, 2.769299737  
            P05821, 42.23375692, 2.804590365  
            P05826, 42.22429292, 2.514033422  
            P05828, 42.22457977, 2.551280066  
            P05829, 42.22462602, 2.563263846  
            P05834, 42.22486768, 2.696832892  
            P05835, 42.22478933, 2.708296374  
            P05839, 42.22483775, 2.792657931  
            P05840, 42.22458841, 2.804533819  
            P05844, 42.21584384, 2.683669901  
            P05846, 42.21584961, 2.720574417  
            P05854, 42.20630228, 2.502348178  
            P05855, 42.20747697, 2.513750451  
            P05858, 42.20645885, 2.562880216  
            P05860, 42.2064673, 2.587035336  
            P05862, 42.20609886, 2.599975341  
            P05863, 42.20597466, 2.61099972  
            P05869, 42.20667738, 2.781015207  
            P05873, 42.19748936, 2.551423323  
            P05881, 42.197755, 2.598828855  
            P05885, 42.19770317, 2.623392849  
            P05887, 42.19766986, 2.635384182  
            P05892, 42.19728499, 2.671977314  
            P05894, 42.19769239, 2.720387952  
            P05897, 42.19772089, 2.756591433  
            P05902, 42.18811681, 2.538567774  
            P05905, 42.18813948, 2.574729346  
            P05906, 42.18850817, 2.586897929  
            P05908, 42.18885942, 2.59959963  
            P05911, 42.18839591, 2.647741739  
            P05914, 42.1883609, 2.67239888  
            P05918, 42.18841266, 2.708257798  
            P05920, 42.1890113, 2.756382637  
            P05921, 42.18867388, 2.781113688  
            P05925, 42.17905165, 2.550984552  
            P05928, 42.17947616, 2.562957126  
            P05930, 42.17932856, 2.586303811  
            P05935, 42.17940501, 2.624227974  
            P05937, 42.1796312, 2.6357179  
            P05938, 42.17961516, 2.647887349  
            P05940, 42.17939925, 2.672287728  
            P05943, 42.17985202, 2.696079307  
            P05945, 42.17980669, 2.720769486  
            P05946, 42.17967274, 2.732588297  
            P05950, 42.17043418, 2.575053786  
            P05951, 42.16976746, 2.587322564  
            P05958, 42.17058331, 2.67274488  
            P05959, 42.16885095, 2.684485264  
            P05961, 42.1708638, 2.696134446  
            P05962, 42.17114752, 2.708288723  
            P05966, 42.33301614, 2.840625207  
    
    Version: This request was processed by AppEEARS version 2.66  

## 2. Request File Listing  

- Comma-separated values file with data extracted for a specific product
  - Aqua-P05600-P05966-MYD11A1-006-results.csv
- Text file with data pool URLs for all source granules used in the extraction
  - Aqua-P05600-P05966-granule-list.txt
- JSON request file which can be used in AppEEARS to create a new request
  - Aqua-P05600-P05966-request.json
- xml file
  - Aqua-P05600-P05966-MYD11A1-006-metadata.xml  

## 3. Point Sample Extraction Process  

Datasets available in AppEEARS are served via OPeNDAP (Open-source Project for a Network Data Access Protocol) services. OPeNDAP services allow users to concisely pull pixel values from datasets via HTTPS requests. A middleware layer has been developed to interact with the OPeNDAP services. The middleware make it possible to extract scaled data values, with associated information, for pixels corresponding to a given coordinate and date range.

**NOTE:**  

- Requested date ranges may not match the reference date for multi-day products. AppEEARS takes an inclusive approach when extracting data for sample requests, often returning data that extends beyond the requested date range. This approach ensures that the returned data includes records for the entire requested date range.  
- For multi-day (8-day, 16-day, Monthly, Yearly) MODIS and S-NPP NASA VIIRS datasets, the date field in the data tables reflects the first day of the composite period.  
- If selected, the SRTM v3, ASTER GDEM v3 and Global Water Bodies Database v1, and NASADEM v1 product will be extracted regardless of the time period specified in AppEEARS because it is a static dataset. The date field in the data tables reflects the nominal SRTM date of February 11, 2000.  
- If the visualizations indicate that there are no data to display, proceed to downloading the .csv output file. Data products that have both categorical and continuous data values (e.g. MOD15A2H) are not able to be displayed within the visualizations within AppEEARS.  

## 4. Data Quality  

When available, AppEEARS extracts and returns quality assurance (QA) data for each data file returned regardless of whether the user requests it. This is done to ensure that the user possesses the information needed to determine the usability and usefulness of the data they get from AppEEARS. Most data products available through AppEEARS have an associated QA data layer. Some products have more than one QA data layer to consult. See below for more information regarding data collections/products and their associated QA data layers.  

### 4.1. MODIS (Terra, Aqua, & Combined)

All MODIS land products, as well as the MODIS Snow Cover Daily product, include quality assurance (QA) information designed to help users understand and make best use of the data that comprise each product. Results downloaded from AppEEARS and/or data directly requested via middleware services contain not only the requested pixel/data values but also the decoded QA information associated with each pixel/data value extracted.  

- See the MODIS Land Products QA Tutorials: <https://lpdaac.usgs.gov/resources/e-learning/> for more QA information regarding each MODIS land product suite.  
- See the MODIS Snow Cover Daily product user guide for information regarding QA utilization and interpretation.  

### 4.2. NASA MEaSUREs SRTM v3 (30m & 90m)  

SRTM v3 products are accompanied by an ancillary "NUM" file in place of the QA/QC files. The "NUM" files indicate the source of each SRTM pixel, as well as the number of input data scenes used to generate the SRTM v3 data for that pixel.  

- See the user guide: <https://lpdaac.usgs.gov/documents/179/SRTM_User_Guide_V3.pdf> for additional information regarding the SRTM "NUM" file.  

### 4.3. GPW v4  

The GPW Population Count and Population Density data layers are accompanied by two Data Quality Indicators datasets. The Data Quality Indicators were created to provide context for the population count and density grids, and to provide explicit information on the spatial precision of the input boundary data. The data context grid (data-context1) explains pixels with "0" population estimate in the population count and density grids, based on information included in the census documents. The mean administrative unit area grid (mean-admin-area2) measures the mean input unit size in square kilometers. It provides a quantitative surface that indicates the size of the input unit(s) from which the population count and density grids were created.  

### 4.4. S-NPP NASA VIIRS

All S-NPP NASA VIIRS land products include quality information designed to help users understand and make best use of the data that comprise each product. For product-specific information, see the link to the S-NPP VIIRS products table provided in section 5.  

**NOTE:**  

- The S-NPP NASA VIIRS Surface Reflectance data products VNP09A1 and VNP09H1 contain two quality layers: `SurfReflect_State` and `SurfReflect_QC`. Both quality layers are provided to the user with the request results. Due to changes implemented on August 21, 2017 for forward processed data, there are differences in values for the `SurfReflect_QC` layer in VNP09A1 and `SurfReflect_QC_500` in VNP09H1.  
- Refer to the S-NPP NASA VIIRS Surface Reflectance User's Guide Version 1.1: <https://lpdaac.usgs.gov/documents/123/VNP09_User_Guide_V1.1.pdf> for information on how to decode the `SurfReflect_QC` quality layer for data processed before August 21, 2017. For data processed on or after August 21, 2017, refer to the S-NPP NASA VIIRS Surface Reflectance User's guide Version 1.6: <https://lpdaac.usgs.gov/documents/124/VNP09_User_Guide_V1.6.pdf>  

### 4.5. SMAP  

SMAP products provide multiple means to assess quality. Each data product contains bit flags, uncertainty measures, and file-level metadata that provide quality information. Results downloaded from AppEEARS and/or data directly requested via middleware services contain not only the requested pixel/data values, but also the decoded bit flag information associated with each pixel/data value extracted. For additional information regarding the specific bit flags, uncertainty measures, and file-level metadata contained in this product, refer to the Quality Assessment section of the user guide for the specific SMAP data product in your request: <https://nsidc.org/data/smap/smap-data.html>  

### 4.6. SSEBop Actual Evapotranspiration (ETa)  

The SSEBop evapotranspiration monthly product does not have associated quality indicators or data layers. The data are considered to satisfy the quality standards relative to the purpose for which the data were collected.

### 4.7. eMODIS Smoothed Normalized Difference Vegetation Index (NDVI)  

The smoothed eMODIS NDVI product does not have associated quality indicators or data layers. The data are considered to satisfy the quality standards relative to the purpose for which the data were collected.  

### 4.8. Daymet  

Daymet station-level daily weather observation data and the corresponding Daymet model predicted data for three Daymet model parameters: minimum temperature (tmin), maximum temperature (tmax), and daily total precipitation (prcp) are available. These data provide information into the regional accuracy of the Daymet model for the three station-level input parameters. Corresponding comma separated value (.csv) files that contain metadata for every surface weather station for the variable-year combinations are also available. <https://doi.org/10.3334/ORNLDAAC/1850>

### 4.9. U.S. Landsat ARD  

Quality assessment bands for the U.S. Landsat ARD data products are produced from Level 1 inputs with additional calculations derived from higher-level processing. A pixel quality assessment band describing the general state of each pixel is supplied with each AppEEARS request. In addition to the pixel quality assessment band, Landsat ARD data products also have additional bands that can be used to evaluate the usability and usefulness of the data. These include bands that characterize radiometric saturation, as well as parameters specific to atmospheric correction. Refer to the U.S. Landsat ARD Data Format Control Book (DFCB): <https://www.usgs.gov/media/files/landsat-analysis-ready-data-ard-data-format-control-book-dfcb> for a full description of the quality assessment bands for each product (L4-L8) as well as guidance on interpreting each band’s bit-packed data values.

### 4.10. ECOSTRESS  

Quality information varies by product for the ECOSTRESS product suite. Quality information for ECO2LSTE.001, including the bit definition index for the quality layer, is provided in section 2.4 of the User Guide: <https://lpdaac.usgs.gov/documents/423/ECO2_User_Guide_V1.pdf>. Results downloaded from AppEEARS contain the requested pixel/data values and also the decoded QA information associated with each pixel/data value extracted. No quality flags are produced for the ECO3ETPTJPL.001, ECO4WUE.001, or ECO4ESIPTJPL.001 products. Instead, the quality flags of the source data are available in the ECO3ANCQA.001 data product and a cloud mask is available in the ECO2CLD.001 product. The `ETinst` layer in the ECO3ETPTJPL.001 product does include an associated uncertainty layer that is provided with each request for ‘ETinst’ in AppEEARS. Each radiance layer in the ECO1BMAPRAD.001 product has a linked quality layer (Data Quality Indicators). ECO2CLD.001 and ECO3ANCQA.001 are separate quality products that are also available for download in AppEEARS.  

### 4.11. ASTER GDEM v3 and Global Water Bodies Database v1  

ASTER GDEM v3 data are accompanied by an ancillary "NUM" file in place of the QA/QC files. The "NUM" files refer to the count of ASTER Level-1A scenes that were processed for each pixel or the source of reference data used to replace anomalies. The ASTER Global Water Bodies Database v1 products do not contain QA/QC files.  

- See Section 7 of the ASTER GDEM user guide: <https://lpdaac.usgs.gov/documents/434/ASTGTM_User_Guide_V3.pdf> for additional information regarding the GDEM "NUM" file.  
- See Section 7 of the ASTER Global Water Bodies Database user guide: <https://lpdaac.usgs.gov/documents/436/ASTWBD_User_Guide_V1.pdf> for a comparison with the SRTM Water Body Dataset.  

### 4.12. NASA MEaSUREs NASADEM v1 (30m)  

NASADEM v1 products are accompanied by an ancillary "NUM" file in place of the QA/QC files. The "NUM" files indicate the source of each NASADEM pixel, as well as the number of input data scenes used to generate the NASADEM v1 data for that pixel.  

- See the NASADEM user guide: <https://lpdaac.usgs.gov/documents/592/NASADEM_User_Guide_V1.pdf> for additional information regarding the NASADEM "NUM" file.  

## 5. Data Caveats  

### 5.1. SSEBop Actual Evapotranspiration (ETa)  

- A list of granule files is not provided for the SSEBop ETa data product. The source data for this product can be obtained by using the download interface at: <https://earlywarning.usgs.gov/fews/datadownloads/Continental%20Africa/Monthly%20ET%20Anomaly>.  

### 5.2. eMODIS Smoothed Normalized Difference Vegetation Index (NDVI)  

- The raw data values within the smoothed eMODIS NDVI product represent scaled byte data with values between 0 and 200. To convert the scaled raw data to smoothed NDVI (smNDVI) data values, the user must apply the following conversion equation:  

      smNDVI = (0.01 * Raw_Data_Value) - 1

- A list of granule files is not provided for the SSEBop ETa data product. The source data for this product can be obtained by using the download interface at: <https://phenology.cr.usgs.gov/get_data_smNDVI.php>.  

### 5.3. ECOSTRESS  

- ECOSTRESS data products are natively stored in swath format. To fulfill AppEEARS requests for ECOSTRESS products, the data are first from the native swath format to a georeferenced output. This requires the use of the requested ECOSTRESS product files and the corresponding ECO1BGEO: <https://doi.org/10.5067/ECOSTRESS/ECO1BGEO.001> files for all products except for ECO1BMAPRAD.001. ECO1BMAPRAD.001 contains latitude and longitude arrays within each file that are then used in the resampling process.  
The conversion leverages the pyresample package’s: <https://pyresample.readthedocs.io/en/stable/> kd_tree algorithm: <https://pyresample.readthedocs.io/en/latest/swath.html#pyresample-kd-tree> using nearest neighbor resampling. The conversion resamples to a Geographic (lat/lon) coordinate reference system (EPSG: 4326), which is defined as the ‘native projection’ option for ECOSTRESS products in AppEEARS.  

### 5.4 S-NPP VIIRS Land Surface Phenology Product (VNP22Q2.001)

- A subset of the science datasets/variables for VNP22Q2.001 are returned in their raw, unscaled form. That is, these variables are returned without having their scale factor and offset applied. AppEEARS visualizations and output summary files are derived using the raw data value, and consequently do not characterize the intended information ("day of year") for the impacted variables. The variables returned in this state include:  

    1. Date_Mid_Greenup_Phase (Cycle 1 and Cycle 2)  
    2. Date_Mid_Senescence_Phase (Cycle 1 and Cycle 2)  
    3. Onset_Greenness_Increase (Cycle 1 and Cycle 2)  
    4. Onset_Greenness_Decrease (Cycle 1 and Cycle 2)  
    5. Onset_Greenness_Maximum (Cycle 1 and Cycle 2)  
    6. Onset_Greenness_Minimum (Cycle 1 and Cycle 2)  

- To convert the raw data to "day of year" (doy) for the above variables, use the following equation:  

      doy = Raw_Data_Value * 1 – (Given_Year - 2000) * 366  

## 6. Documentation

Documentation for data products available through AppEEARS are listed below.

### 6.1. MODIS Land Products(Terra, Aqua, & Combined)

- <https://lpdaac.usgs.gov/product_search/?collections=Combined+MODIS&collections=Terra+MODIS&collections=Aqua+MODIS&view=list>

### 6.2. MODIS Snow Products (Terra and Aqua)  

- <https://nsidc.org/data/modis/data_summaries>

### 6.3. NASA MEaSUREs SRTM v3

- <https://lpdaac.usgs.gov/product_search/?collections=MEaSUREs+SRTM&view=list>

### 6.4. GPW v4  

- <http://sedac.ciesin.columbia.edu/binaries/web/sedac/collections/gpw-v4/gpw-v4-documentation.pdf>

### 6.5. S-NPP NASA VIIRS Land Products  

- <https://lpdaac.usgs.gov/product_search/?collections=S-NPP+VIIRS&view=list>

### 6.6. SMAP Products  

- <http://nsidc.org/data/smap/smap-data.html>

### 6.7. SSEBop Actual Evapotranspiration (ETa)  

- <https://earlywarning.usgs.gov/fews/product/66#documentation>

### 6.8. eMODIS Smoothed Normalized Difference Vegetation Index (NDVI)  

- <https://phenology.cr.usgs.gov/get_data_smNDVI.php>

### 6.9. Daymet  

- <https://doi.org/10.3334/ORNLDAAC/1840>
- <https://daymet.ornl.gov/>

### 6.10. U.S. Landsat ARD  

- <https://www.usgs.gov/land-resources/nli/landsat/us-landsat-analysis-ready-data?qt-science_support_page_related_con=0#qt-science_support_page_related_con>

### 6.11. ECOSTRESS  

- <https://lpdaac.usgs.gov/product_search/?collections=ECOSTRESS&view=list>

### 6.12. ASTER GDEM v3 and Global Water Bodies Database v1  

- <https://doi.org/10.5067/ASTER/ASTGTM.003>
- <https://doi.org/10.5067/ASTER/ASTWBD.001>

### 6.13. NASADEM  

- <https://doi.org/10.5067/MEaSUREs/NASADEM/NASADEM_NC.001>  
- <https://doi.org/10.5067/MEaSUREs/NASADEM/NASADEM_NUMNC.001>

## 7. Sample Request Retention  

AppEEARS sample request outputs are available to download for a limited amount of time after completion. Please visit <https://lpdaacsvc.cr.usgs.gov/appeears/help?section=sample-retention> for details.  

## 8. Data Product Citations  

- Wan, Z., Hook, S., Hulley, G. (2015). MYD11A1 MODIS/Aqua Land Surface Temperature/Emissivity Daily L3 Global 1km SIN Grid V006. NASA EOSDIS Land Processes DAAC. Accessed 2021-09-21 from https://doi.org/10.5067/MODIS/MYD11A1.006. Accessed September 21, 2021.

## 9. Software Citation  

AppEEARS Team. (2021). Application for Extracting and Exploring Analysis Ready Samples (AppEEARS). Ver. 2.66. NASA EOSDIS Land Processes Distributed Active Archive Center (LP DAAC), USGS/Earth Resources Observation and Science (EROS) Center, Sioux Falls, South Dakota, USA. Accessed September 21, 2021. https://lpdaacsvc.cr.usgs.gov/appeears

## 10. Feedback  

We value your opinion. Please help us identify what works, what doesn't, and anything we can do to make AppEEARS better by submitting your feedback at https://lpdaacsvc.cr.usgs.gov/appeears/feedback or to LP DAAC User Services at <https://lpdaac.usgs.gov/lpdaac-contact-us/>  
