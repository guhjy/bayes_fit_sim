library(blavaan)

install.packages("blavaan", repos="http://faculty.missouri.edu/~merklee", type="source")


# three simulated dataset
# 1. no growth
# 2. linear growth
# 3. quadratic growth

# vary sample size simulated

mod.noGrowth <-"
i =~ 1*t1 + 1*t2 + 1*t3 + 1*t4
s =~ 0*t1 + 0*t2 + 0*t3 + 0*t4
i~0*1
s~0*1
s~~1*s
i~~1*i
t1~~1*t1
t2~~1*t2
t3~~1*t3
t4~~1*t4
i~~0*s
"

mod.linearGrowth <-"
i =~ 1*t1 + 1*t2 + 1*t3 + 1*t4
s =~ 0*t1 + 1*t2 + 2*t3 + 3*t4
i~5*1
s~0*1
s~~1*s
i~~1*i
t1~~1*t1
t2~~1*t2
t3~~1*t3
t4~~1*t4
i~~0*s
"

mod.quadGrowth <-"
i =~ 1*t1 + 1*t2 + 1*t3 + 1*t4
s =~ 0*t1 + 1*t2 + 2*t3 + 3*t4
s2 =~ 0*t1 + 1*t2 + 4*t3 + 9*t4
i~5*1
s~0*1
s2~0*1
s~~1*s
i~~1*i
s2~~1*s2
t1~~1*t1
t2~~1*t2
t3~~1*t3
t4~~1*t4
i~~0*s
i~~0*s2
s~~0*s2
"



count= 0
#samps = c(100,300,1000)
samps = 1000
iters=1
mods = list(mod.noGrowth,mod.linearGrowth,mod.quadGrowth)
#mods = mod.noGrowth

fit.ret = data.frame(matrix(NA,iters*length(samps)*length(mods),38))
colnames(fit.ret) = c("samp.size","mod",
                      "conv1","iters1","logl1","bic1","dic1","waic1","looic1","margloglik1","jags_dic1",
                      "conv2","iters2","logl2","bic2","dic2","waic2","looic2","margloglik2","jags_dic2",
                      "conv3","iters3","logl3","bic3","dic3","waic3","looic3","margloglik3","jags_dic3",
                      "conv4","iters4","logl4","bic4","dic4","waic4","looic4","margloglik4","jags_dic4")

system.time(
for(i in 1:iters){
  for(j in 1:length(samps)){
    for(k in 1:length(mods)){
      count = count + 1
      
      set.seed(count)
      
      fit.ret[count,"samp.size"] = samps[[j]]
      fit.ret[count,"mod"] = k
      
      #dat1 <- simulateData(mod.noGrowth,sample.nobs=100,model.type="lavaan")
      #dat2 <- simulateData(mod.linearGrowth,sample.nobs=100,model.type="lavaan")
      #dat3 <- simulateData(mod.quadGrowth,sample.nobs=100,model.type="lavaan")
      dat <- simulateData(mods[[k]],sample.nobs=samps[[j]],model.type="lavaan")
      
      
      if(samps[[j]]==100){
        time="3m"
      }else if(samps[[j]]==300){
        time="10m"
      }else if(samps[[j]]==1000){
        time="30m"
      }
      
      
      
      mod1 <- ' i =~ 1*t1 + 1*t2 + 1*t3 + 1*t4
                s =~ 0*t1 + 0*t2 + 0*t3 + 0*t4 '
                #t1~~r1*t1; t2~~r1*t2; t3~~r1*t3; t4~~r1*t4'
      fit1 = try(bgrowth(mod1, data=dat,convergence="auto",dp=dpriors(alpha="dnorm(0,10)"),
                         jagcontrol=list(method="rjparallel",max.time=time,psrf.target=1.05)))
      if(inherits(fit1, "try-error")){
        fit.ret[count,"conv1"] = -9999
        fit.ret[count,"iters1"] <- fit1@external$runjags$summary$end
        fit.ret[count,"logl1"] = -9999
        fit.ret[count,"bic1"] = -9999
        fit.ret[count,"dic1"] = -9999
        fit.ret[count,"waic1"] = -9999
        fit.ret[count,"looic1"] = -9999
        fit.ret[count,"margloglik1"] = -9999
        fit.ret[count,"jags_dic1"] = -9999
      }else{
        fit.ret[count,"conv1"] = all(fit1@external$runjags$psrf$psrf[,1] < 1.05)
        fit.ret[count,"iters1"] <- fit1@external$runjags$summary$end
        fits1 = fitmeasures(fit1)
        fit.ret[count,"logl1"] = fits1["logl"]
        fit.ret[count,"bic1"] = fits1["bic"]
        fit.ret[count,"dic1"] = fits1["dic"]
        fit.ret[count,"waic1"] = fits1["waic"]
        fit.ret[count,"looic1"] = fits1["looic"]
        fit.ret[count,"margloglik1"] = fits1["margloglik"]
        dic11 = extract(fit1@external$runjags,"dic",method="parallel")
        fit.ret[count,"jags_dic1"] = sum(dic11$deviance) + sum(dic11$penalty)
      }
      
      
      mod2 <- ' i =~ 1*t1 + 1*t2 + 1*t3 + 1*t4
      s =~ 0*t1 + 1*t2 + 2*t3 + 3*t4 '
      fit2 = try(bgrowth(mod2, data=dat,convergence="auto",
                         jagcontrol=list(method="rjparallel",max.time=time,psrf.target=1.05)))
      if(inherits(fit2, "try-error")){
        fit.ret[count,"conv2"] = -9999
        fit.ret[count,"iters2"] <- fit2@external$runjags$summary$end
        fit.ret[count,"logl2"] = -9999
        fit.ret[count,"bic2"] = -9999
        fit.ret[count,"dic2"] = -9999
        fit.ret[count,"waic2"] = -9999
        fit.ret[count,"looic2"] = -9999
        fit.ret[count,"margloglik2"] = -9999
        fit.ret[count,"jags_dic2"] = -9999
      }else{
        fit.ret[count,"conv2"] = all(fit2@external$runjags$psrf$psrf[,1] < 1.05)
        fit.ret[count,"iters2"] <- fit2@external$runjags$summary$end
        fits2 = fitmeasures(fit2)
        fit.ret[count,"logl2"] = fits2["logl"]
        fit.ret[count,"bic2"] = fits2["bic"]
        fit.ret[count,"dic2"] = fits2["dic"]
        fit.ret[count,"waic2"] = fits2["waic"]
        fit.ret[count,"looic2"] = fits2["looic"]
        fit.ret[count,"margloglik2"] = fits2["margloglik"]
        dic22 = extract(fit2@external$runjags,"dic",method="parallel")
        fit.ret[count,"jags_dic2"] = sum(dic22$deviance) + sum(dic22$penalty)
      }
      
      
      mod3 <- ' i =~ 1*t1 + 1*t2 + 1*t3 + 1*t4
      s =~ 0*t1 + 1*t2 + 2*t3 + 3*t4
      s2 =~ 0*t1 + 1*t2 + 4*t3 + 9*t4'
      
      fit3 = try(bgrowth(mod3, data=dat,convergence="auto",
                         jagcontrol=list(method="rjparallel",max.time=time,psrf.target=1.05)))
      if(inherits(fit3, "try-error")){
        fit.ret[count,"conv3"] = -9999
        fit.ret[count,"iters3"] <- fit3@external$runjags$summary$end
        fit.ret[count,"logl3"] = -9999
        fit.ret[count,"bic3"] = -9999
        fit.ret[count,"dic3"] = -9999
        fit.ret[count,"waic3"] = -9999
        fit.ret[count,"looic3"] = -9999
        fit.ret[count,"margloglik3"] = -9999
        fit.ret[count,"jags_dic3"] = -9999
      }else{
        fit.ret[count,"conv3"] = all(fit3@external$runjags$psrf$psrf[,1] < 1.05)
        fit.ret[count,"iters3"] <- fit3@external$runjags$summary$end
        fits3 = fitmeasures(fit3)
        fit.ret[count,"logl3"] = fits3["logl"]
        fit.ret[count,"bic3"] = fits3["bic"]
        fit.ret[count,"dic3"] = fits3["dic"]
        fit.ret[count,"waic3"] = fits3["waic"]
        fit.ret[count,"looic3"] = fits3["looic"]
        fit.ret[count,"margloglik3"] = fits3["margloglik"]
        dic33 = extract(fit3@external$runjags,"dic",method="parallel")
        fit.ret[count,"jags_dic3"] = sum(dic33$deviance) + sum(dic33$penalty)
      }
      
      
      mod4 <- ' i =~ 1*t1 + 1*t2 + 1*t3 + 1*t4
      s =~ 0*t1 + l1*t2 + l2*t3 + 1*t4'
      fit4 = try(bgrowth(mod4, data=dat,convergence="auto",
                         jagcontrol=list(method="rjparallel",max.time=time,psrf.target=1.05)))
      if(inherits(fit4, "try-error")){
        fit.ret[count,"conv4"] = -9999
        fit.ret[count,"iters4"] <- fit4@external$runjags$summary$end
        fit.ret[count,"logl4"] = -9999
        fit.ret[count,"bic4"] = -9999
        fit.ret[count,"dic4"] = -9999
        fit.ret[count,"waic4"] = -9999
        fit.ret[count,"looic4"] = -9999
        fit.ret[count,"margloglik4"] = -9999
        fit.ret[count,"jags_dic4"] = -9999
      }else{
        fit.ret[count,"conv4"] = all(fit4@external$runjags$psrf$psrf[,1] < 1.05)
        fit.ret[count,"iters4"] <- fit4@external$runjags$summary$end
        fits4 = fitmeasures(fit4)
        fit.ret[count,"logl4"] = fits4["logl"]
        fit.ret[count,"bic4"] = fits4["bic"]
        fit.ret[count,"dic4"] = fits4["dic"]
        fit.ret[count,"waic4"] = fits4["waic"]
        fit.ret[count,"looic4"] = fits4["looic"]
        fit.ret[count,"margloglik4"] = fits4["margloglik"]
        dic44 = extract(fit4@external$runjags,"dic",method="parallel")
        fit.ret[count,"jags_dic4"] = sum(dic44$deviance) + sum(dic44$penalty)
      }
      
      print(count)
    }
  }
}
)




#min = matrix(NA,12,5)
#for(i in 1:12){
#  min[i,1] = which(fit.ret[i,c(3,8,13,18)] == min(fit.ret[i,c(3,8,13,18)]))
#  min[i,2] = which(fit.ret[i,c(4,9,14,19)] == min(fit.ret[i,c(4,9,14,19)]))
#  min[i,3] = which(fit.ret[i,c(5,10,15,20)] == min(fit.ret[i,c(5,10,15,20)]))
#  min[i,4] = which(fit.ret[i,c(6,11,16,21)] == min(fit.ret[i,c(6,11,16,21)]))
#  min[i,5] = which(fit.ret[i,c(7,12,17,22)] == min(fit.ret[i,c(7,12,17,22)]))
#}


