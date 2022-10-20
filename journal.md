# Giant sequoia, wildfire and vegetation and other climate factors


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

