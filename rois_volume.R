# ######################################################## #
#               Cuenta voxeles de ROIs
# ######################################################## #

#### FUNCION: CUENTA VOXELES X ROI ####
rois.volume <- function(Nifti) {
  # Nifti   Es la dirección con nombre del archivo (character)
  # escala  Es la escala de los voxeles (x10 x1 etc), tu tienes x10 Karen!
  # Carga la libreria que lee niftis
  require(oro.nifti)
  # Carga el archivo con las etiquetas
  nii <- readNIfTI(Nifti,reorient = FALSE)
  # Cuenta los voxeles de cada etiqueta única
  total <- table(c(nii@.Data))
  # Resolución de los pixeles
  pix.res <- nii@pixdim[2:4]
  # Volumen real de cada voxel en mm³
  voxvol <- prod(pix.res)
  # Crea un vector con el ID y las dimensiones de voxel
  out <- as.data.frame(cbind(strsplit(Nifti, split='.', fixed=TRUE)[[1]][1],t(pix.res),voxvol,sum(total)))
  # Combina todo en un data.frame (df) de 1xN
  out <- cbind(out,t(matrix(total)))
  # Agrega lis nombres al df
  colnames(out) <- c("ID", "vox.x", "vox.y", "vox.z", "vox.vol","vox.n", names(total))
  # Salida
  return(out)  
}

# -------------------------------------------------------------------- #
# Uso:
rois.volume("mi_nifti.nii.gz")
