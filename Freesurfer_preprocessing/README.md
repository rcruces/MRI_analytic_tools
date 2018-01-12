![intro](https://farm5.staticflickr.com/4674/24783541397_0aaf0dcf80_z.jpg)  
 

# Guideline for FreSurfer Preprocessing  
## Step 1... T1 weighted volume Quality Check & ordering
**1.** Visual inspection must be carry out in order to exclude T1-weighted volumes with artifacts such as:
	- Motion  
	- Magnetic suceptibility  
	- RF overflow (clipping)  
	- RF spike  
	- Bad encoding  
	- Incomplete or croped volumes.  
![T1 artifacts](https://farm5.staticflickr.com/4710/24784057227_2d716a04b9_z.jpg)  
After identifying the images with artifacts they must be excluded or repaired. If this step is not done properly, extremely poor segmentation or failure is expeted from FreeSurfer.
   
> Further reading of MRI artifacts:  
> Morelli, J. N., Runge, V. M., Ai, F., Attenberger, U., Vu, L., Schmeets, S. H., ... & Kirsch, J. E. (2011). An image-based approach to understanding the physics of MR artifacts. Radiographics, 31(3), 849-866. [https://doi.org/10.1148/rg.313105115](https://doi.org/10.1148/rg.313105115)  
  
**2.** Once T1-QC is done, you should create a directory where all the images will be placed.  
```{bash}
	mkdir <path>/FS_timing
```  
**3.** Each T1 image should have an identifier for example; `FS_000.nii.gz`.   
  
**4.** For a better output of the freesurfer algorithm it is highly recomended to perform *denoising* and *bias field correction* of each T1.  
 >The script [`denoiseN4`]() can be use to asses this point, further information is detailled inside it.  
```{bash}
	mkdir <path>/FS_timing/input <path>/FS_timing/output
```  

  
## Step 2... FreeSurfer enviroment configuration  
1. FREESURFER_HOME debe ser una variable declarada en el `env`. Se puede revisar con `env | grep FREESURFER_HOME` o `echo $FREESURFER_HOME`.  
2. El script de freesurfer debe estar configurado.  
```{bash}
source $FREESURFER_HOME/SetUpFreeSurfer.csh
```  
3. Se debe de declarar el directorio de entrada en el ambiente global como `SUBJECTS_DIR`. Hay dos opciones para esto, escribirla en `~/.bashrc` o declararla antes del análisis:  
> `setenv SUBJECTS_DIR <path>/FS_timing/input`  
o en el archivo ~/.bashrc:  
> `export SUBJECTS_DIR=/misc/ernst/rcruces/FS_ejemplo`
  
## Step 3... Running recon_all  
1. Para todos los sujetos (identificación, ej. `FS_000`) hay que correr el mismo comando dentro de $SUBJECTS_DIR:  
```{bash}
recon-all –i FS_000.nii.gz –s FS_000 –all;  
mv FS_000 <path>/FS_timing/output`
```  
quizá sea posible hacer esto también:  
```{bash}
recon-all –i FS_000.nii.gz –s <path>/FS_timing/output/FS_000 –all;  
```  
For further information che the [FreeSurfer official webpage](http://surfer.nmr.mgh.harvard.edu/fswiki/RecommendedReconstruction)  

## Step 4... Visual Quality Check of the freesurfer output  
1. Compra una chela  
2. Espera varios días.  
3. Hay que hacer control de calidad de la segmentación.
  
  


