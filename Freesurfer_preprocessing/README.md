![intro](https://farm5.staticflickr.com/4674/24783541397_0aaf0dcf80_z.jpg)  
 

# Guideline for FreeSurfer Preprocessing  
## Step 1: T1 Ordering & Quality Check  
### 1.1. T1 Management  
   1. Each T1 image should have an identifier, for example; `T1_001.nii.gz`.  
   1. Create a new directory on your local computer where all the images will be placed.  
>	NOTE: replace `<path>` for your local path.  
```{bash}
	mkdir <path>/T1_niftis
```  
  
### 1.2. T1 Quality Check (T1-QC)  
Visual inspection must be carry out in order to exclude T1-weighted volumes with artifacts such as:  
   1. Motion  
   1. Magnetic suceptibility  
   1. RF overflow (clipping)  
   1. RF spike  
   1. Bad encoding  
   1. Incomplete or croped volumes.  
  
On the following figure you can see the most common T1-artifacts:  
![T1 artifacts](https://farm5.staticflickr.com/4710/24784057227_2d716a04b9_z.jpg)  
  
After identifying the images with artifacts they must be excluded or repaired. If this step is not done properly, extremely poor segmentation or failure is expected from FreeSurfer.
   
> Further reading of MRI artifacts:  
> Morelli, J. N., Runge, V. M., Ai, F., Attenberger, U., Vu, L., Schmeets, S. H., ... & Kirsch, J. E. (2011). An image-based approach to understanding the physics of MR artifacts. Radiographics, 31(3), 849-866. [https://doi.org/10.1148/rg.313105115](https://doi.org/10.1148/rg.313105115)  
  
### 1.4. T1 Denoise and Bias Field Correction (N4) 
   1. For a better output of the FreeSurfer algorithm it is highly recomended to perform *denoising* and *bias field correction* of each T1. This step will aid to increase the contrast between gray and white matter and reduce the signal to noise ratio, thus improving and facilitating the FS segmentation.  
   1. Figure with a sagital and axial view of a T1 with and without denoise and bias field correction.
![T1 denoised](https://farm5.staticflickr.com/4761/24785957987_27c9f2c548_z.jpg)  
   1. The script [`T1_denoiseN4`](https://github.com/rcruces/MRI_analytic_tools/blob/master/Freesurfer_preprocessing/T1_denoiseN4) can be use to asses this point, further information is detailled inside it. It uses minc-toolkit, FS and ANTs.  
> You need to save the script `T1_denoiseN4` to your computer and [make it executable](https://askubuntu.com/questions/229589/how-to-make-a-file-e-g-a-sh-script-executable-so-it-can-be-run-from-termina#229592).  
  
   3a. Create a new directory where all the processed T1 will be placed:
```{bash}
		 mkdir <path>/T1_processed
```  

   3b. Run the denoise and N4 for each T1:  
```{bash}
		 T1_denoiseN4 T1_001.nii.gz <path>/T1_processed
```  

   3c. You can do a `for` loop like in the next example:
```{bash}
		 for subject in  <path>/T1_niftis/*; do
			 T1_denoiseN4 $subject <path>/T1_processed;
		 done
```  
  
## Step 2: FreeSurfer enviroment configuration  
### 2.1. FreeSurfer_HOME  
Once FreeSurfer is installed you should check if the variable `FREESURFER_HOME` is declared in the global enviroment. You can check if it's declared writing on the terminal:  
> `env | grep FREESURFER_HOME`  
	or  
> `echo $FREESURFER_HOME`.  
  
### 2.2. FreeSurfer Configuration  
Check the FreeSurfer configuration typing on the terminal:  
> ```{bash}
source $FREESURFER_HOME/SetUpFreeSurfer.sh
```  

### 2.3 Subject's Directory  
Se debe de declarar el directorio de entrada en el ambiente global como `SUBJECTS_DIR`. Hay dos opciones para esto, escribirla en `~/.bashrc` o declararla antes del análisis:  
> `setenv SUBJECTS_DIR <path>/FS_timing/input`  
o en el archivo ~/.bashrc:  
> `export SUBJECTS_DIR=/misc/ernst/rcruces/FS_ejemplo`
  
## Step 3: Running recon_all  
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

## Step 4: Visual Quality Check of the freesurfer output  
1. Individual QC
  
  


