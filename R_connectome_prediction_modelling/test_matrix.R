#### TEST CORRELATION ####
# Obtains all the control matrices
ctrl.mean <- Mtxs[,,which(cases$GR=="ctrl")]
# Obtains the mean of Wij of the control matrices
ctrl.mean <-apply(ctrl.mean,1:2,sum)
corrplot(ctrl.mean,is.corr = F,tl.col="black",method="color",cl.pos = "r")

# Number of columns-rows of the matrix
N<-ncol(ctrl.mean)
# Creates an array based on the mean of control with noise injected
mtx.test <- array(NA,c(N,N,55))
for (k in 1:55) {
  mtx.test[,,k] <- jitter(ctrl.mean,factor = 100,amount = 2)
}
mtx.test<-apply(mtx.test,1:3,function(x) x=round(x,digits = 0)+2)
corrplot(apply(mtx.test,1:2,sum),is.corr = F,tl.col="black",method="color",cl.pos = "r")


# Creates a fake high correlation with behavior
x<-50:104
plot(x[match(B,B[order(B)])],B)
X<-x[match(B,B[order(B)])]


for ( k in 51:80) {
  for (l in 11:40)
    #mtx.test[l,k,] <-  mtx.test[k,l,] <- mtx.test[k,l,] * -1
    mtx.test[l,k,] <-  mtx.test[k,l,] <- round(jitter(X,amount = 5),0)
}
rm(ctrl.mean, N, k, l, x, X)
corrplot(apply(mtx.test,1:2,sum),is.corr = F,tl.col="black",method="color",cl.pos = "r")


corrplot(r.mat,is.corr = F,tl.col="black",method="color",cl.pos = "r")

