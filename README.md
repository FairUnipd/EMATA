# EMATA

The full documentation will be loaded soon.


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

For disabling the motion correction step by adding the specific flag:
```matlab
emata(...,'MoCo',0)
```



