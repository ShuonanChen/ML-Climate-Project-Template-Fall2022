
# Giant sequoia, wildfire and vegetation and other climate factors
# 12/03 update and changes. 
1. for $Y$, log and normalization for the input data
2. change the model so we can incorporate the feature vector. Currently just doing 3 dimensional GP. 
3. edit the preprocessing. Because of limitation with the datasets, making the following assumptions. 
    - when $Y$ is available for the particular grid, it is considered to be observed and 



## Next todo
1. probably need to validate the model by holdingh 10% of the train data.     



# 11/28 preprocess the geospatial data 

## the original questions:
- use multiple fire severity images (diff fires in different years)
- train a 2D GP model to predict the fire severity based on the environmental factors, including the sequoia density and humidity etc. 
- is there associations with the sequoia density and the fire severity? (this is to test the assumption made in the paper)
- so our $X$ would be $X \in \mathbb{R}^{D+2}$. For instance, $D=1$ and its the vector of density of sequoia, at these coordinates. 
- then our prediction $y$ is a vector of fire severity -- the problem is how to get this data, if only considering castle fire then its a very small region (i think)
- in the castle fire report, they used RAVG:
> **Fire severity maps.** Spatially explicit Castle Fire severity was estimated using the satellite-derived **RAVG CBI4 composite burn index** (RAVG website), from Landsat prefire imagery acquired on August 9, 2020 and postfire imagery acquired on October 10, 2020. These data provide an initial, un-ground-truthed fire severity estimate; more refined estimates typically become available from other sources more than one year post-fire.
- but honestly the exact source is unclear (RAVG or CBI? from RAVG could not find the castle fire data. Windy and KNP complex fire were found though)
- $y$ hence in my case will be the burned area (available from RAVG). the coordinate will be the centroid of the 
- however teh descriptors are hard to obtain - sequoia grove too sparse, and not enough info to infer the number of trees. 



# 11/26 Stan + 2D GP
- learning how to use Stan, pystan and cmdstan.
- wrote 1D GP model following two examples 
    - [betancourt](https://betanalpha.github.io/assets/case_studies/gaussian_processes.html#23_Fitting_A_General_Gaussian_Process_Posterior)
    - [aki](https://avehtari.github.io/casestudies/Motorcycle/motorcycle_gpcourse.html#4_Heteroskedastic_GP_with_Hilbert_basis_functions)
- need to expand to multi-dimensional case (found stan discussion [from this link](https://discourse.mc-stan.org/t/speeding-up-gaussian-process-model-for-spatial-prediction/16316/4)) -- leads to this following paper. 
- found some example stan code from [paper on Hilbert space approx GP](https://arxiv.org/abs/2004.11408). 
- Used some random iris dataset to test. 
- the notebook uploaded (named `cmdstan_test.ipynb`) 
- seems the model is doing correct thing at least. note now is only using exact GP model, no HS is used (and i have no idea how it workds!)

## next steps
1. preprocess our data to get the data points. only consider 2d case for now. 
2. fit the current exact GP 2D model
3. expand the data - can we use vector inputs in each location, how would the model change? write new stan code. 
4. maybe explore the speed up (HSGP)




# 11/23 Fitting the models? 
there are a few candidates packages
- pystan
- GPy
- PcMC
-- update: pystan keeps getting some weird errors. switching to Cmdstan. 


# 11/21 castle fire paper notes
**"primary estimates of sequoia mortality in the 2020 castle fire. "**
## main questions asked in the paper
1. fire severity index (from sattelite) --> estimate how much $\frac{A_b^i}{A_{all}}$ where $A_b^i$ is the burned grove area with severity $i$, $A_{all}$ is all the grove areas.  -- table 1 and fig1. 
2. relationships between $A_b^i$ and $S_b^i$ where the latter is teh large sequoias that burned at the severity $i$. 
3. $S_b^i$ for each $i$ within the castle fire. 
4. From 1 and 3, estimate proportion killed in the sierra nevada, due to the castle fire. 
5. From 4, estimate the total number that were killed in castle fire. (previous estimate is 10-14%, which is like 7.5k = 10.6k large sequoias)


## Assumptions made
Especially to answer question 2, (the answer is that they can assume one-to-one correspindence between burned grove area, $A_b^i$, vs bunred sequoia proportion, $S_b^u$ for each severity $i$.), they made a few assumptions. SOme of these are made based on some preliminary analysis, some of them are purely presumptions made by the authors. But all of them should be subjec to the test. 
1. within castle fire, random fine-scale density var does not afffect broad scale conclusios. 
2. within castle, fire severity did not vary systematically with sequoia densitites. 
3.  sequoia within castle, grow in environmentally similar conditions within sierra nevada. 
4. effects of past sequoia logging on range-wide estimates. (think this is indeed harder to estimate than the others)

-- so which can be resolved by ML approaches? 
- if we have multiple fire severity images (diff fires in different years), we can train a model to predict the fire severity based on the environmental factors, including the sequoia density and humidity etc. is there associations with the sequoia density and the fire severity? (does not have to be the causal associations) - GP spatial regression (Or CNN type of thing)
- (maybe too diff for now) reinforcement learning to decide where to put the prescribed fire. 

---
maybe GP spatial regression is better for the following reasons 
- we have limited number of data points and featurees. training a RL or CNN is probably not feasible. 
- GP integrates nicely with the spatial data which is my main resource of the data. 
- easier to compare with some easier image processing methods usch as linear interpolations. 
- wel.. is the problem non-linear? who knows! but yeah probably. 
- [PyMC](https://www.pymc-labs.io/blog-posts/spatial-gaussian-process-01/) - GP for geospatial data, tutorials. 

-----



# 11/10 understanding the data sturcture
## name conventions and layers
1. vegetation `ds0984`
    - only one layer ds0984
    - (only within kings kayon and sequoia park so might not be that useful?)
2. prescribed fire burns `ds0397`
    - only one layer ds0397
3. fire perimeter through 2021 `fire21_1`/`fire21_2`
    - `['firep21_2', 'rxburn21_2', 'Non_RXFire_Legacy13_2']`
    - these are the size of (21688, 20), (8027, 17), (864, 17).
    -  corresponds to `wildfire history, prescribed burns, and other fuel modification projects` -- we porbably are only interested in the frist two 
    - it turns out... the second layer (prescribed fire) is basically the same thing but sliglhtly updated from above ds397. so we will be using fire21_2 only. 
4. post-fire soil erosion `perod04_1` (this file seems to be currupted, abandoned)
    - `['perod04_1', 'VAT_perod04_1', 'fras_aux_perod04_1', 'fras_blk_perod04_1', 'fras_bnd_perod04_1', 'fras_ras_perod04_1']`
5. sequoia groves `CA_Sierra_groves`
    - only one layer `CA_Sierra_groves`



## some data want to add
1. fire severuty
2. humidity/water content
3. found something new: [**burn severity portal**](https://burnseverity.cr.usgs.gov/) - want to extract more data


## the actual available data i have:
1. fire each year
2. prescribed fire each year. 

## other questions/challenges
1. **sequoia grove daata do not have the time-series data** -- we cannot really make prediction if the data point is just one... modify the project? Some ideas relevant:
    - fire burn severity, impacted by? (we have prescribed fire data on diff years)
    - predict the future fire locations (this sounds too magical)
    - or based on what affects the burn severity, what can we do to protect sequoia? 
    - can also focus on the castle fire 2020 since there is a previous analysis on this. 
2. spatial GP 
3. how to include the features (at each coordinate, we want to know the vegetation, severity of fire, etc)
4. how to save the data


# 11/08 finalizing the GIS data we will be using. 
- vegetation: https://map.dfg.ca.gov/metadata/ds0984.html
- prescribed fire bunrs: https://map.dfg.ca.gov/metadata/ds0397.html
- fire perimeter through 2021: https://frap.fire.ca.gov/mapping/gis-data/
- Post-fire Soil Erosion: https://frap.fire.ca.gov/mapping/gis-data/
- sequoia groves: https://irma.nps.gov/DataStore/Reference/Profile/2259632 (2017)



# 10/31 update
- currently availble data
    - ds984 vegetation GDB vector image data (for sequoia)
    - ds397 prescribed fire data
    - csv of above two 



# 10/14 update
- what type of data might be helpful 
    - tree inventory, or tree maps. (before and after the burn?)
    - vegetation condition (is this redundant?) (before and after the burn?)
    - burn images (before and after the burn?)
    - prescribed fire (when and where) and the impact to the vegetation:
        https://apps.wildlife.ca.gov/bios/?al=ds397
        this have the prescribed fire database. where they are and when they are done (burned area etc info seems to be availeble) - see the description here: https://map.dfg.ca.gov/metadata/ds0397.html
- NYVS name: sequoiadendron giganteum
- BIOS 
    - ds984. Vegetation - sequoia and kings canyon national parks vegetation mapping project
    - ds397. Prescribed fire burns. 
    - (uploaded 125 rows csv files, showing where the sequoias are located.)
    - GIS data (GDB file) available (vector image), need to install python library which can handle these. 



# data sources (updated 10/05)
- (main)  sequoia inventory or the tree maps at different times.
    - this is the hard part - we can get the grove map, but cannot find the inventory of the trees. 
    - 
- **Rapid Assessment of Vegetation Condition after Wildfire (RAVG)**
    - what time point can we get these, at which locations? 
    - what images are available? 
    - how is CBI estimated?
- Burned Area Emergency Response (BAER) Imagery Support program 
- tree mortalitly: 
    - tree stem maps + fire severity map 
    - NPS sequoia Tree inventory (not available///?)
    




# 10/04 what data sources will be used? 
wildfire impact is large from 2015 to 2021. 
- How are they impacted,    
    - the mortality rate of each fire can be obtained. 
- what are the factors that make the impact larger?
    - moisture
    - vegetation (CBI from RAVG)
    - prescribed fire in the year. 
    - 
- future trends on the trees (simulate some fire????)
- what can we do to reduce the impact? (based on the analysis results, what can we intefere)



# 10/03 Narrow down the questions
1. Aim: Focus on finding the dataset, make sure it can be used for the methods (reduce uncertainty). 
2. some questions that can be asked. 
    - impact of wildfire, prescribed fire, and the other factors to the forests
    - can we predict the mortality rate of the trees based on the fire information. sounds like they are doing it (e.g., after KNP complex and windy fire on 2021) - how are they estimatting this, are they accurate and is there room for improvement? 
    - can we predict whats the best design for the prescribed fires? 
    - can we somehow predict the regeneration impact by the wildfires? 




# 09/28 plan. 
updated Plan (subject to change)

1. understand what might be the more direct impact to the Sequoia habitat.
2. Find recent papers that study the same subjects - what are their conclusion, what are their methods and limitaiton? 
3. Find the data that might be relevant. 
    - vegetation in each year can be obtained from RAVG images
    - wild fire data can be obtained from Cal fire and Landset image gallery?
    - moisture data from LFMC of radiant MLHub
4. Prediction using the wildefire real time tracking? 


# data / resources: 
- [RAVG data](https://burnseverity.cr.usgs.gov/ravg/) - **Rapid Assessment of Vegetation Condition after Wildfire (RAVG) program**. this looks to be a fairly nice resource to obtain the recent wildfire data. -- how the vegetation before/after the wildfire affect the sequoia population? 
- [2021 fire season and impact on the giant sequpia](https://www.nps.gov/articles/000/2021-fire-season-impacts-to-giant-sequoias.htm) - from NPS. 
- relatedly [impact of wildefire (2015-2020) for the sequoia](https://www.nps.gov/articles/000/wildfires-kill-unprecedented-numbers-of-large-sequoia-trees.htm#:~:text=The%20Castle%20Fire%20killed%20an,%2Cor%20%3E1.2%20meters).)
- [Western US live fuel moisture: used to assess the wildfire risks](https://mlhub.earth/data/su_sar_moisture_content_main), from 'radiant MLHub'. 
    - 'Live fuel moisture content (LFMC)' - the mass of wataer per unit dry biomass in vegetation
- [Kaggle nature disaster data](https://www.kaggle.com/datasets/dataenergy/natural-disaster-data?resource=download) 1900-2018, with several missing values. 
- [awesome forest](https://github.com/blutjens/awesome-forests#tree-species-classification) - does not have wildfire related data. but might be relevant. 
- [wildfire real time tracking (this is cool)](https://terrafuse.ai/fire/) by terrafuse AI
- [Landsat image gallary](https://landsat.visibleearth.nasa.gov/search.php?cx=002358070019171462865%3Ajkcajjtgk4q&cof=FORID%3A9&q=california&sa=search)

