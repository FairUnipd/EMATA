# EMATA #

## INSTALLATION ##
The toolbox is compatible with Unix (including MacOS) and Windows systems and can be used in MATLAB. An initial set-up may be required due to dependencies on external MATLAB packages and FSL:
* The external MATLAB packages, i.e. the NIfTI toolbox (https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image) and the Jerman Enhancement Filter (https://github.com/timjerman/JermanEnhancementFilter), are already provided. However, to use the Jerman Enhancement Filter, the c-code file needs to be compiled with 'mex eig3volume.c' (as detailed here: https://www.mathworks.com/matlabcentral/fileexchange/63171-jerman-enhancement-filter). 
* FSL needs to be manually installed by the user, regardless of the operating system, to perform image registration. If running on Windows, Windows Subsystem for Linux (WSL) needs to be installed so that FSL can be used. Once FSL is installed, the file /UTILITY_GENERAL/SETTINGS/fsl_settings.txt is to be updated with the FSL installation path.

## BASIC USAGE ##

Default call: 
```matlab
emata(PET_dyn_path,t_PET_delta,out_path) 
```

corresponds to

```matlab
emata(PET_dyn_path, t_PET_delta, out_path, 'InputFun', 'IDIF', 'extractionSite', 'ICA', 'Feng', 1, 'Patlak', 1)
```

To extract IDIF from the CCA (when the FOV allows it…):  

```matlab
emata(PET_dyn_path, t_PET_delta, out_path,…,'extractionSite', 'CCA', …)
```

To perform Chen Correction with NLMEM: 

```matlab

emata(PET_dyn_path, t_PET_delta, out_path, 'Chen', 'NLMEM', covariates)

covariates = [Sex Height Weight Age Dose];    
%Sex --> 1: female, 0: male    
%Height [cm]   
%Weight [Kg]    
%Age [years]   
%Dose[MBq]

```

Otherwise, if venous samples are available:
```matlab
 emata(PET_dyn_path, t_PET_delta, out_path, 'Chen', 'samples', venous_samples)

 %venous_samples =    
	
	%--> venous_samples.c %[Bq/ml]    
	%--> venous_samples.t %[sec]
  
```

For disabling the motion correction step:
```matlab
emata(…,'MoCo',0)
```
## OUTPUTS ##
	
IDIF curve is stored in a MATLAB struct, which is named after the extraction site of choice, and contains the final curve and time-grid together.
After running Patlak’s Graphical Analysis, the original voxel-wise map and the map of the corresponding precisions (coefficients of variation, CVs, of parameter estimates) are stored in NIfTI files, together with a smoothed voxel-wise K<sub>i</sub> map (Gaussian filter, variance σ = ½ of the image voxel size). 
All intermediate steps of the extraction algorithm are stored and can be used for quality check purposes. These are represented by: 
* the parameters used for motion correction and the resulting motion-corrected images, provided as a .txt file and NIfTI images, respectively.
* pseudo-angiographies and masks for carotid or siphons segmentation provided as NIfTI images.
* the position of the selected hot voxels and the relative peak amplitude, provided both as a mask in NIfTI format and through a MATLAB graphics. 
* parameter estimates for denoising and recalibration (included in the MATLAB struct by which the final IDIF is provided)
* venous model prediction by NonLinear Mixed Effect Model (included in the MATLAB struct by which the final IDIF is provided)
* the tissue mask for spillover correction (in a NIfTI format) and the corresponding TACs (in a MATLAB struct).

## DEFAULT SETTINGS ##
The toolbox comes with a JSON configuration file (/UTILITY_GENERAL/SETTINGS/options.json) which can be used to adapt the algorithm to specific dataset characteristics. The main options and the default values are listed below:
* **Reference volume for motion correction** [min]: 20 by default, the reference PET volume is the one acquired 20 minutes post-injection.
* **Static PET time-threshold** [min]: 30 by default, the static PET is calculated by summing the dynamic frames acquired from 30 minutes post-injection. 
* **Initial Pseudo-Angiography threshold** [seconds]: 60 by default, the pseudo-Angiography is obtained summing all dynamic PET frames up to 60 seconds.
* **Optimized Arterial Pseudo-Angiography threshold** [number of volumes]: once venous peak time has been estimated, optimized arterial pseudo-angiography is obtained by summing a number of frames which is determined as function of venous peak time. By default, Pseudo-angiography is calculated by summing frames up to the venous peak time itself for ICA and one frame before for CCA. This is done because CCA peak time is expected to be anticipated for physiological reasons. However, depending on the reconstruction grid employed, no distinction in peak timing may be detected, and thus the two thresholds can be set to be equal.
* **ICA/CCA size** [mm<sup>3</sup>]:  These are used to binarize the masks obtained by the vesselness probability map resulting from the Jerman Filter. Default values are 300 mm3 for ICA and 640 mm3 for CCA – corresponding respectively to 19 and 40 voxels for a 2.8 mm x 2.8 mm x 2.0 mm PET reconstruction voxel size.
* **Tissue Spill-over masks** [ratio]: The two concentric masks (spill-in and background) used for tissue TAC derivation and spillover correction have an internal radius equal to twice the voxel size by default. 
* **Patlak’s t-star** [min]: the equilibrium time between plasma and the reversible compartment needs to be identified for applying Patlak’s graphical method: the default value is 25 minutes after injection.

You can edit the file directly or copy it and pass it externally to the toolbox:

```matlab
emata(…,'options',<options_path>)
```






