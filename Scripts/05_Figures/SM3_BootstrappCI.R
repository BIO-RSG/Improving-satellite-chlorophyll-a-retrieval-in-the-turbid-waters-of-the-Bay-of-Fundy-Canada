setwd("")

library(plotrix)
options(scipen=5)

nospm = read.csv("./Scripts/Revisions/Out/1to1noSPM_bootresultsCI.csv")
noall = readRDS("./Scripts/Revisions/Out/1to1noSPM_bootresults.rds")
attributes(noall)
print(noall)
yesspm = read.csv("./Scripts/Revisions/Out/1to1YESSPM_bootresultsCI.csv")
yesall = readRDS("./Scripts/Revisions/Out/1to1YESSPM_bootresults.rds")
yeslow = readRDS("./Scripts/Revisions/Out/1to1YesSPMtestlow_bootresults.rds")
yeshigh = readRDS("./Scripts/Revisions/Out/1to1YesSPMtesthigh_bootresults.rds")
print(yesall)

nospm$dif = abs(nospm$lower - nospm$upper)
yesspm$dif = abs(yesspm$lower - yesspm$upper)
plot.dat = cbind(c(nospm$dif,NA),yesspm$dif)
rownames(plot.dat) = paste0("a",c(0:4, "spm"))
colnames(plot.dat) = c("No SPM", "Yes SPM")
plot.dat = t(plot.dat)


png("./Figures//BootCVv3.png", width=6.5 ,height=6.5,res=300,unit="in", pointsize = 12)
layout(matrix(c(1,1,6,6,11,
                2,2,7,7,12,
                3,3,8,8,13,
                4,4,9,9,14,
                5,5,10,10,15), nrow=5,byrow=T))
par(mgp=c(2,1,0),mar=c(2,2,0.1,1),oma=c(1.5,1,0,0),xpd=NA,family="serif")
ind = c(0.01,0.1,1,2,1)
pnl = c("(a)", "(b)","(c)","(d)","(e)")
for(i in 1:5){hist(noall$t[,i],breaks=seq(min(noall$t[,i]),max(noall$t[,i])+ind[i],ind[i]),main="",xlab="",
                   xaxs="i",yaxs="i",col=pals::stepped(23)[c(14)])
legend("topright",legend=pnl[i],bty="n")}
text(x=20,y=-575,expression('Coefficient OC'[X-BoF]*''))
ind = c(0.01,0.05,0.1,0.1,0.1)
pnl = c("(f)", "(g)","(h)","(i)","(j)")
for(i in 1:5){hist(yesall$t[,i],breaks=seq(min(yesall$t[,i]),max(yesall$t[,i])+ind[i],ind[i]),main="",
                   xlab="",xaxs="i",yaxs="i",ylab="",col=pals::stepped(23)[c(18)])
  legend("topright",legend=pnl[i],bty="n")}
text(x=4,y=-100,expression('Coefficient OC'[X-SPMCor]*''))
pnl = c("(k)", "(l)","(m)","(n)","(o)")
for(i in 1:5){
in.dat = rbind(nospm[i,],yesspm[i,])
plotCI(y=in.dat[,2],x=1:2,ui = in.dat[,4], li=in.dat[,3],xlim=c(0.5,2.5),xlab="",ylab="Coefficient",xaxt="n",pch=19,
       col=pals::stepped(23)[c(14,18)])
legend("topright",legend=pnl[i],bty="n")}
text(x=seq(1,2),y=0,labels = c(expression('OC'[X-BoF]*''),expression('OC'[X-SPMCor]*'')), 
     srt = 45, adj = c(1.1,1.1), xpd = NA) 
dev.off()

for(i in 1:5){hist(yeslow$t[,i],breaks=seq(min(yeslow$t[,i]),max(yeslow$t[,i])+ind[i],ind[i]),main="",
                   xlab="",xaxs="i",yaxs="i",ylab="")
  legend("topright",legend=pnl[i],bty="n")}
for(i in 1:5){hist(yeshigh$t[,i],breaks=seq(min(yeshigh$t[,i]),max(yeshigh$t[,i])+ind[i],ind[i]),main="",
                   xlab="",xaxs="i",yaxs="i",ylab="")
  legend("topright",legend=pnl[i],bty="n")}

