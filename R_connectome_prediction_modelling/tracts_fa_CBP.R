# Behavioral variable Nx1 vector
for (i in 11:20) {
  B<-as.matrix(cases[i])
  corr<-corr_mtx(Mtxs,B,"pearson")
  r.mat<-corr$rho
  p.mat<-corr$p.val
  print(paste(colnames(cases[i]),"max:",max(r.mat),"min:",min(r.mat)))
  par(mfrow=c(1,2))
  hist(r.mat[p.mat<0.05],breaks = 100,main=colnames(cases[i]))
  hist(p.mat[p.mat!=1],breaks = 100,main=colnames(cases[i]))
  abline(v=0.05,col="red",lwd=3)
  }


WM<- read.csv("/home/rr//Dropbox/linuxook/oma/cluster_multi/WM.csv")
WM<-merge(cases,WM,by="urm")


B<-as.matrix(WM[11])
mtx.wm<-WM[22:63]

corr_vec <- function(M,V,Method){ 
  # M= array of matrices 1xMxN, # V=Nx1
  # Function that obtains a list of p-values and r-values 
  # from correlating an array of matrices with a vector of behavioral data
  n <- ncol(M)
  Subj<-length(V)
  p.mat <- r.mat <- array(NA,c(1,n))
  
  for (i in 1:n) {
      tmp <- cor.test(M[,i],V,exact = FALSE,method = Method)
      p.mat[i] <- tmp$p.value
      r.mat[i] <- tmp$estimate
  }

  # assigns value of 0 if there is no values in the correlation
  r.mat[is.na(r.mat) | r.mat=="NaN"]<-0
  p.mat[is.na(p.mat) | p.mat=="NaN"]<-1
  
  return(list("rho"=r.mat, "p.val"=p.mat))
}
corr_vec(mtx.wm,B,"pearson")
# Behavioral variable Nx1 vector
for (i in 11:20) {
  B<-as.matrix(WM[WM$SIDE!="ctrl",][i])
  corr<-corr_vec(mtx.wm[WM$SIDE!="ctrl",],B,"pearson")
  r.mat<-corr$rho
  p.mat<-corr$p.val
  print(paste(colnames(cases[i]),"max:",max(r.mat),"min:",min(r.mat)))
  par(mfrow=c(1,2))
  hist(r.mat,breaks = 10,main=colnames(cases[i]))
  hist(p.mat,breaks = 10,main=colnames(cases[i]))
  abline(v=0.05,col="red",lwd=3)
}





