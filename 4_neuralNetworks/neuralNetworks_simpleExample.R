##############################
##############################
##############################
set.seed(1)
p = 5
n = 25
X = matrix(rnorm(n*p),nrow=n)
b = p:1
Y = sin(X%*%b) + rnorm(n)

nTest = 100
Xtest = matrix(rnorm(nTest*p),nrow=nTest)
Ytest = sin(Xtest%*%b) + rnorm(nTest)

#Stochastic Gradient Descent Batch Parm
miniBatchParm = 5

# Utility functions
fF = function(Z,b){
  return( Z %*% b)
}
gam_kF = function(X,alpha){
  return(X %*% alpha)
}
sigF = function(gam_k){
  return(1/(1+exp(-gam_k)))
}
d_sigF = function(gam_k){
  return(sigF(gam_k)*(1-sigF(gam_k)))
}
ellF = function(Y,f){
  return((Y - f)**2)
}
rF = function(ell){
  return( mean( ell ))
}

# NN parms:
K             = 4
nIter         = 20000
learnRate     = .02


#Step 0: Initialize
bHat          = rnorm(K)
alphaHat      = matrix(rnorm(p*K),nrow=p,ncol=K)

bHatIter      = matrix(0,nrow=nIter,ncol=K)
alphaHatIter  = array(0,c(nIter,p,K))
#Step 1
for(iter in 1:nIter){
  batch = sample(1:n,miniBatchParm,replace=FALSE)
  Z     = sigF(X[batch,] %*% alphaHat)  
  for(j in 1:p){
    for(k in 1:K){
      #Step 2a: Forward
      gam_k = gam_kF(X[batch,],alphaHat[,k])
      Z[,k] = sigF(gam_k)
      f     = fF(Z,bHat)
      ell   = ellF(Y[batch],f)
      r     = rF(ell)
      #Step 2b: Backward
      ## beta
      dell_df = -2*(Y[batch] - f)
      df_dbk  = Z[,k]
      dR_dbk   = rF( dell_df*df_dbk )
      ## alpha
      df_dZk  = bHat[k]
      dZk_dgk  = d_sigF(gam_k)
      dgk_dakj = X[batch,j]
      dR_dakj  = rF(dgk_dakj * dZk_dgk * df_dZk * dell_df )
      #Step 3a: Update beta
      bHat[k]  = bHat[k] - learnRate * dR_dbk
    }
    #Step 3b: Update alpha
    alphaHat[j,k]  = alphaHat[j,k] - learnRate * dR_dakj
  }
  bHatIter[iter,]      = bHat
  alphaHatIter[iter,,] = alphaHat
}



bHat_LS = lm(Y~X-1)$coef

Yhat_LS = Xtest %*% bHat_LS
Yhat_NN = sigF(Xtest  %*% alphaHat) %*% bHat
rF( ellF(Ytest,Yhat_LS))
rF( ellF(Ytest,Yhat_NN))

#Get a plot of the first and second hidden unit on all of the training data

Z_train_k = drop(sigF(gam_kF(X,alphaHat[,1:2])))
plot(Z_train_k)

#Which hidden unit has the largest value for the first test observations?
which.max(drop(sigF(gam_kF(Xtest[1,],alphaHat))))

