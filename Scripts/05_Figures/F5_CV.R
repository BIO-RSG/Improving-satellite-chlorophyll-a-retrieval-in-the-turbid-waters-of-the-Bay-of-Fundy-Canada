yesspm = read.csv("Data/CrossValidateStats/cvyesSPM/cvresults.csv")
nospm = read.csv("Data/CrossValidateStats/cvyesSPM/cvresults.csv")

MAE =	c(2.06,	1.38,	1.40,	1.30,	1.49)
RMSLE =c(0.58,	0.52,	0.52,	0.38,	0.47)
r2 = c(0.01,	0.01,	0.03,	0.28,	0.14)
st = cbind(MAE, RMSLE,r2)
rownames(st)= c("oc3m","ocxall","ocxcv","ocxspmall","ocxspmcv")

MAE =	c(NA,	NA,	sd(nospm$MAE),NA,	sd(yesspm$Rsquared))
RMSLE =c(NA,NA,	sd(nospm$RMSLE),	NA,	sd(yesspm$Rsquared))
r2 = c(NA,	NA,	sd(nospm$Rsquared),	NA,	sd(yesspm$Rsquared))
sd = cbind(MAE, RMSLE,r2)
rownames(sd)= c("oc3m","ocxall","ocxcv","ocxspmall","ocxspmcv")

png("./Figures//Figure5.png", width=6.5 ,height=3.5,res=300,unit="in", pointsize = 12)
par(mar=c(5,3,0.5,0.5),mgp=c(2,1,0),mfrow=c(1,3),family="serif")
a = st[,1]
a = sort(a, decreasing = T ,index.return=T)$ix
b = sd[a,1]
a = st[a,1]
barplot(a,las=3,ylim=c(0,2.1),xaxt = "n",ylab=c("MAE"),
        col=pals::stepped(23)[c(23,18,14,16,20)])
arrows(c(3.15,1.95), a+b, c(3.15,1.95), a,code=1,angle=90,length=0.1)
box(which = "plot", lty = "solid")
text(x=seq(0.75,6,1.2),y=0,labels=c("OC3M (All)",
                                    expression('OC'[X-SPMCor]*' (CV)'),
                                    expression('OC'[X-BoF]*' (CV)'),
                                    expression('OC'[X-BoF]*' (All)'),
                                    expression('OC'[X-SPMCor]*' (All)')),srt = 45, adj = c(1.1,1.1), xpd = TRUE)
legend("topright","(a)",bty="n")
a = st[,2]
a = sort(a, decreasing = T ,index.return=T)$ix
b = sd[a,2]
a = st[a,2]
barplot(a,las=3,ylim=c(0,0.65),xaxt = "n",ylab=c("RMSLE"), col=pals::stepped(23)[c(23,16,14,18,20)])
box(which = "plot", lty = "solid")
text(x=seq(0.75,6,1.2),y=0,labels=c( "OC3M (All)",
                                    expression('OC'[X-BoF]*' (All)'),
                                    expression('OC'[X-BoF]*' (CV)'),
                                    expression('OC'[X-SPMCor]*' (CV)'),
                                    expression('OC'[X-SPMCor]*' (All)')),
     srt = 45, adj = c(1.1,1.1), xpd = TRUE)
arrows(c(3.15,4.35), a+b, c(3.15,4.35), a,code=1,angle=90,length=0.1)
legend("topright","(b)",bty="n")
a = st[,3]
a = sort(a, decreasing = F ,index.return=T)$ix
b = sd[a,3]
a = st[a,3]
barplot(a,las=3,ylim=c(0,0.32),xaxt = "n",ylab=expression('R'^2), col=pals::stepped(23)[c(23,16,14,18,20)])
box(which = "plot", lty = "solid")
arrows(c(3.15,4.35), a+b, c(3.15,4.35), a,code=1,angle=90,length=0.1)
text(x=seq(0.75,6,1.2),y=0,labels = c( "OC3M (All)",
                                       expression('OC'[X-BoF]*' (All)'),
                                       expression('OC'[X-BoF]*' (CV)'),
                                       expression('OC'[X-SPMCor]*' (CV)'),
                                       expression('OC'[X-SPMCor]*' (All)')), 
     srt = 45, adj = c(1.1,1.1), xpd = TRUE) 
legend("topright","(c)",bty="n")
dev.off()