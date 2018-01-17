# Guideline for FreeSurfer Preprocessing  
## Table of Contents  
1. [T1 Ordering & Quality Check](#step:-t1-ordering-&-quality-check)  
1. [FreeSurfer Enviroment Configuration](#step-2:-freesurfer-enviroment-configuration)  
1. [Finally Running FreeSurfer](#step-3:-finally-running-freesurfer)  
1. [Quality Check of the FreeSurfer Output](#step-4:-quality-check-of-the-freesurfer-output)  
1. [Time for Analysis](#step-5:-time-for-analysis)  
  
  
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
  
## Step 2: FreeSurfer Enviroment Configuration  
### 2.1. FreeSurfer_HOME  
Once FreeSurfer is installed you should check if the variable `FREESURFER_HOME` is declared in the global enviroment. You can check if it's declared by writing on the terminal:  
```{bash}
     env | grep FREESURFER_HOME  
```  
or  
```{bash}
     echo $FREESURFER_HOME  
```  
  
### 2.2. FreeSurfer Configuration  
Check the FreeSurfer configuration typing on the terminal:  
```{bash}
	source $FREESURFER_HOME/SetUpFreeSurfer.sh
```  

### 2.3 Subject's Directory  
Now it's time to declare the directory where all the processed T1 are located as a local variable named `SUBJECTS_DIR`. We have two options to achieve this.  
  
**OPTION 1**  
   1. Open the file `~/.bashrc` with your favorite text editor (nano, vim, gedit etc).
   2. At the end of the file add the next lines:  
```{bash}
# Freesurfer Subjects Directory
export SUBJECTS_DIR=<path>/T1_processed  
```
   3. Save the changes and open a new terminal or update the bash by typing `bash` on the terminal.  
  
**OPTION 2**  
This one is described on the FreeSurfer webpage. if you are using a C-shell (csh), type this on the terminal:  
```{bash}
   setenv SUBJECTS_DIR <path>/FS_timing/input  
```  
  
  
## Step 3: Finally Running FreeSurfer  
### 3.1. Running `recon_all`
`recon-all` is the fully automated command from FreeSurfer for structural processing. It takes a while for each subject (from few to 10 hours or more depending on your computer), so it's highly recommended to use a job control system such as SGE (fsl_sub).   
**a.** Change your directory to $SUBJECTS_DIR  
```{bash}
cd $SUBJECTS_DIR
```  
**b.** To run the structural FreeSurfer processing for the file `T1_001.nii.gz` you should type on the terminal:  
```{bash}
recon-all –i T1_001.nii.gz –s T1_001 –all
```  
> hint: type `recon-all` on the terminal and press `Enter key` to see more detailes about this command.  
**c.** If you have more than one subject try a `for` loop over each T1 image.
```{bash}
for subject in *.nii.gz; do
	recon-all –i $subject –s ${subject/.nii.gz/} –all
done
```  
**c.** If you have access to a SGE cluster you can use the next code instead of the latter.
```{bash}
for subject in *.nii.gz; do
	fsl_sub -l <path_to_logfiles> -R 6 recon-all –i $subject –s ${subject/.nii.gz/} –all
done
```  
**d.** When all processing is done you will have all the NIFTIS and the FreeSurfer outputs on the same directory, you might want to change the NIFTIS to somewhere else but is up to you.  
  
> NOTE: For further information check the [FreeSurfer official webpage](http://surfer.nmr.mgh.harvard.edu/fswiki/RecommendedReconstruction)  
  
## Step 4: Quality Check of the FreeSurfer Output  
### 4.1 Directory outputs
Once all the processing is done, first check the log files for errors. You can also list each output directory, they should contain the folowing directories:  
> `./bem  ./label  ./mri  ./scripts  ./src  ./stats  ./surf  ./tmp  ./touch  ./trash`  
  
If you list all the contents of a particular subjects (`ls T1_001/*`) you should obtain something like this:
![files](https://farm5.staticflickr.com/4659/27878923639_5878be0ec1_b.jpg)  
If something is missing check the log file for that subject, try to figure out what the error is.  
If you figure out what was the ERROR, erase the output directory for that subject and run `recon-all` again for him.  
  
### 4.1 Visual Quality Check
This is an extremely important step and maybe the most tedious!  
1. Individual visualization of each FS output must be performed in order to check for correct segmentation. You can try the script [`FSview`](https://github.com/rcruces/MRI_analytic_tools/blob/master/Freesurfer_preprocessing/FSview) to visualize the FS surfaces.
```{bash}
	FSview ${SUBJECTS_DIR}/T1_001
```  
2. Watch this [FreeSurfer Troubleshooting Video](https://www.youtube.com/watch?v=gf0BC0xs0tM&feature=youtu.be) to learn more about finding and fixing errors.  
3. After visual QC and fixing all troubleshooting from your sample, and only then you can go to step 5.  
![freeview](https://farm5.staticflickr.com/4711/39658495511_df8b10f1c0_o.png)
  
## Step 5: Time for Analysis  
Pick your favorite method to analyse your data, for example:  
1. ROI volume analysis  
1. Cortical thickness  
1. Surface analysis ([SurfStat](http://www.math.mcgill.ca/keith/surfstat/))  
1. White matter yuxtacortical analysis.  

  
# Thanks for reading & success!


