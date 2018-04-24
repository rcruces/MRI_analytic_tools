# Contenido: Procesamiento Imágenes Pesadas a Difusión  
1. [`dwi_vec`]() Paso Inicial, concatena las DWIs y arregla los vectores (Philips) para uno o más shells. 
1. [`dwi_dn4`](https://github.com/rcruces/epilepsia_processing/blob/master/code/dwi_dn4) Paso 1 de 2 para el pre procesamiento de imágenes pesadas a difusión, denoise y bias field correction con dos opciones LPCA y mrtrix.  
1. [`dwi_corr`](https://github.com/rcruces/epilepsia_processing/blob/master/code/dwi_corr) Paso final del procesamiento de DWI. Incluye corrección geométricas y de movimiento (EDDY y TOPUP). Finalmente corrige los vectores de acuerdo a los `eddy_parameters` y crea un archivo `mif` corregido y con vectores codificados dentro de él.
  
  
### Paso 0 - Concatenacion y correccion de vectores (dependiente de la adquisión)  
Este paso es particular para los datos adquiridos del resonador *Philips Achieva 3.0T* en formato NIFTI o DICOM. En caso de que se hallan adquirido de NIFTI requiere los archivos `omat` para corregir los vectores.  
Recomiendo crear un directorio por sujeto donde se guarden los archivos que corresponden al preprocesamiento de difusión (por ejemplo aqui hago uno llamado *DWI* con `mkdir DWI`).
```{bash}
for i in *; do cd $i; echo -e "\033[48;5;125m $i  \033[0m"; 
  mkdir DWI
  dwi_vec -in "DWI_1k.nii.gz DWI_2k.nii.gz" -out DWI/DWI_2shell
cd ..; done
```
### Paso 1 - Eliminación de rudio y correccion de campo  
El prefijo de salida es automático, y dependerá del algoritmo utilizado:  
> `_dn4.nii.gz` es para el algorithmo de LPCA de Pierric Coupé.  
> `_dn4_mrtrix.nii.gz` es para el algorithmo de Tournier de `mrtrix`.
```{bash}
for i in *; do cd $i/DWI; echo -e "\033[48;5;125m $i  \033[0m"; 
  dwi_dn4 DWI_2shell.nii.gz . mrtrix
cd ../..; done
```
### Paso 2 - Corrección de movimiento y geométrica  
Este script va a generar **CUATRO** archivos de salida, todos con las DWI y los vectore ya corregidos.  
En el siguiente ejemplo `DWI_corregido` corresponderia al identificador de salida `-out`:  
1. `DWI_corregido.nii.gz` NIFTI con los volumenes y todas las direcciones.  
1. `DWI_corregido.eddy_parameters` Archivo de texto con los parametros de corrección que se aplican a cada volumen de difusión (filas).  
1. `DWI_corregido.b` Archivo de texto con la matriz de vectores CORREGIDOS, los BVECS son las primeras 3 columnas y el BVAL la cuarta..  
1. `DWI_corregido.mif` MIF con los volumenes, las direcciones y los vectores codificados.  
```{bash}
for i in *; do cd $i/DWI; echo -e "\033[48;5;125m $i  \033[0m"; 
  dwi_corr -dwi2fix DWI_2shell_dn4_mrtrix.nii.gz -dwiPA DWI_PA.nii.gz -out DWI_corregido -bvecs DWI_2shell.bvecs -bvals DWI_2shell.bvals
cd ../..; done
```
  
### Extras de DWI  
[`dwi_getPA`]() Obtiene las imágenes B0 de de la adquisición posterioanterior (DWI-PA) para facilitar el paso 3 con `dwi_corr`.
  
