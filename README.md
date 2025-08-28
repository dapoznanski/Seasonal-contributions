[![DOI](https://zenodo.org/badge/265254045.svg)](https://zenodo.org/doi/10.5281/zenodo.10442485)


# Apoznanski-etal_2025_earthsfuture

**Seasonal drivers of storm tides and flood impacts along the US Atlantic Coast (once published, include a link to the text)**

Diana K. Apoznanski<sup>1\*</sup>, Hannah Baranes<sup>4</sup>,  Robert E. Kopp<sup>2, 3</sup>, and Anthony J. Broccoli<sup>1, 3</sup>

<sup>1 </sup>Department of Environmental Sciences, Rutgers University, New Brunswick, NJ

<sup>2 </sup>Department of Earth and Planetary Sciences, Rutgers University, New Brunswick, NJ

<sup>3 </sup>Rutgers Climate and Energy Institute, Rutgers University, New Brunswick, NJ

<sup>4 </sup>Gulf of Maine Research Institute, Portland, ME

\* corresponding author:  diana.apoznanski@rutgers.edu

## Abstract
Densely populated coastal areas face increasing flood risk as rising sea levels combine with storm surges and high tides. Parts of the U.S. East Coast experience extratropical cyclones (ETCs) more frequently than tropical cyclones (TCs), yet many studies on extreme flood risk focus primarily on TCs or exclude ETCs altogether. ETCs occur primarily during November to April (henceforth, the cool season), while TCs occur primarily during May to October (hence-forth, the warm season). This study performs a quasi-nonstationary skew surge joint probability analysis of storm tide exceedance distributions for cool and warm season from 23 tide gauges along the U.S. east coast to assess seasonal contributions to extreme water levels. From Boston northward, cool-season extreme storm tides predominate, while south of Wilmington, warm-season storm tides predominate. In the mid-Atlantic, both seasons contribute substantially, with cool-season storms producing most short return-period events and warm-season storms producing most high-impact, long-return-period events. At The Battery location, cool season and warm season events contribute about equally to the average annual loss (AAL), but cool season events are responsible for the most common extreme floods, which are still very costly, while warm season events are responsible for the most extreme floods. These findings highlight the importance of treating cool and warm season storms as statistically separate to improve flood risk analysis and coastal protection.

## Journal reference
_your journal reference_


## Contributing modeling software
| Model | Repository Link |
|-------|-----------------|
| qn-SSJPM | (https://zenodo.org/records/3898657) | 
| damage curve | https://github.com/dmr2/damage_allowance/blob/master/README.md |

## Reproduce my experiment
The following script and data are in MATLAB language. A sample qn-SSJPM dataset from The Battery tide gauge is provided. For other locations, perform qn-SSJPM from Baranes et al. (2020) analysis prior to running the contribution script. The damage curve for Manhattan uses the methods and data from Rasmussen et al. (2020), which is copied here. 

1. Install MATLAB
2. Download and install the supporting [input data](#input-data) required to conduct the experiment
3. Run the following scripts to re-create this experiment:

| Script Name | Description |
| --- | --- |
| `seasonal_contribution.m` | Script to calculate seasonal contribution of ETCs to total year storm tides. | 
| `battery_damage.m` | Script to calculate AALs and contribution of ETCs to total year property damage. | 


## Reproduce my figures
Use the scripts found in the `figures` directory to reproduce the figures used in this publication.

| Figure Number(s) | Script Name | Description | 
| --- | --- | --- |
| 1 | `plot_qnssjpm.m` | qn-SSJPM plot with cool and warm seasons, total year, and uncertainty. | 
| 3 | `plot_battery_damage.m` | Plots associated with damage curve at The Battery site | 

