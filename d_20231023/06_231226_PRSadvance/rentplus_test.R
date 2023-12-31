setwd("~/hmiwa1/storage/hmiwa-lab/06_231226_PRSadvance/testdir")

#rentplus_trees_1700_height_1KG.R

#Goal:  Run rent+ on 1700 height-associated SNPs from 1KG.

library(psych)
library(data.table)
library(ape)

id_file <- "GBR_IDS.txt"
vcf_file <- "temp/test.vcf"
out_pref <- "temp/hap"
rent_file <- "temp/rent_in.txt"
rentplus_fn <- "RentPlus.jar"

height_fn <- "neale.height.best.snp.tsv"

helper_fn <- "helper_functions_coal_sel.R"

source(helper_fn) #read in helper functions and load ape package

mark.dat <- fread(height_fn, head = TRUE)
nmarks <- nrow(mark.dat)

wid <- 100000 #half-window size around focal locus to extract

n_ders <- numeric(0)
thetas <- numeric(0)

trees.all <- list()
trees.anc <- list()
trees.der <- list()

seg.sites <- numeric()
meas.length <- numeric()
n.chrs <- numeric()

snps.fail1 <- rep(0, dim(mark.dat)[1])
snps.miss <- rep(0, dim(mark.dat)[1])
monomorphic_loci <- numeric()

info.sites <- list() # for each snp, ID pos allele0 allele1

system("echo '' > temp/tmp")
system("echo '' > temp/log")

for(i in 1:dim(mark.dat)[1]){
   snp <- mark.dat[i,6]
   pos.snp <- mark.dat[i,2]
   chr <- mark.dat[i,1]
   lb <- pos.snp - wid
   ub <- pos.snp + wid

   rent.tmp <- paste("echo '[", "SNP", as.character(i), "]' `date` >> temp/tmp", sep = "")
   system(rent.tmp)

   #Write a string that will call tabix to extract a vcf from 1000 genomes.
   tabix.str <- paste("tabix -h ~/hmiwa1/rawdata/1KGa/ALL.chr", as.character(chr), ".phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz ", as.character(chr), ":", as.character(lb), "-", as.character(ub), " | ~/homebrew/bin/vcf-subset -c ", id_file, " > ", vcf_file, sep = "")
   system(tabix.str)

   #Write to IMPUTE format, which is easy to change to RENT+ format.
   #vcftools.str <- paste("vcftools --vcf ", vcf_file, " --out ", out_pref, " --IMPUTE", sep = "")
   vcftools.str <- paste("~/homebrew/bin/vcftools --vcf ", vcf_file, " --out ", out_pref, " --IMPUTE 2>> temp/log",sep = "")
   system(vcftools.str)

   #Read in the IMPUTE format haplotypes, keep polymorphic loci, and 
   #rearrange into RENT+ format. We shuffle so that the derived alleles
   #are at the end.

   hap.fn <- paste(out_pref, ".impute.hap",sep = "")
   haps <- try(as.matrix(read.table(hap.fn)))
   if (inherits(haps, 'try-error')){
       print(paste("SNP", as.character(i), "has a problem"))
       snps.fail1[i] <- 1 
       next
   }
   info.fn <- paste(out_pref, ".impute.legend",sep = "")
   info <- read.table(info.fn, head = TRUE)

   loci.poly <- rowMeans(haps) > 0 & rowMeans(haps < 1)
   haps.poly <- haps[loci.poly,]
   info.poly <- info[loci.poly,]
   col.keysnp <- which(info.poly$pos == as.numeric(pos.snp))
   info.sites[[i]] <- info.poly[col.keysnp,]
   if(length(col.keysnp) == 0){
      print(paste("SNP", as.character(i), "missing from 1KG"))
      snps.miss[i] <- 1    
      next 
   }
   n_der <- sum(haps.poly[col.keysnp,])
   haps.poly.der.at.end <- haps.poly[, order(haps.poly[col.keysnp,])]
   haps.charvec <- apply(t(haps.poly.der.at.end), 1, paste, sep = "", collapse = "")
   haps.char <- paste(haps.charvec, sep = "", collapse = "\n")
   pos.char <- paste(as.character(info.poly$pos), sep = "", collapse = " ")
   rentfile.str <- paste(pos.char, haps.char, sep = "\n", collapse = "")
   write(rentfile.str, rent_file)

   seg.sites[i] <- sum(loci.poly)
   n.chrs[i] <- ncol(haps)
   n_ders[i] <- n_der
   meas.length[i] <- max(info.poly$pos) - min(info.poly$pos)
   if(n_der == n.chrs[i] | n_der == 0){
      monomorphic_loci <- c(monomorphic_loci, i)
      print(paste("SNP", as.character(i), "is monomorphic in the sample")) 
      next
   }


   #run rent+
   #rent.string <- paste("java -jar ", rentplus_fn, " -t ",  rent_file, sep = "")
   rent.string <- paste("java -Xmx8g -jar ", rentplus_fn, " -t ", rent_file, " >> temp/tmp",sep = "")
   system(rent.string)

   #read in theta estimate
   rent_theta_fn <- paste(rent_file, ".theta", sep = "")
   thetas[i] <- suppressWarnings(as.numeric(read.table(rent_theta_fn, nrows = 1)$V1))

   #Read in trees at selected site in rent and rent+
   rent_trees_fn <- paste(rent_file, ".trees", sep = "")
   rent_trees <- readLines(rent_trees_fn)

   #which tree is for the focal site?
   rent_tr_ind <- grep(paste(as.character(pos.snp), "\t", sep = ""), rent_trees)

   #get tree at focal site in newick format.
   rent_tree_newick <- sub(paste(as.character(pos.snp), "\t", sep = ""), "", rent_trees[rent_tr_ind])
   rent_tree <- read.tree(text = paste(rent_tree_newick, ";", sep = ""))

   n_chroms <- dim(haps.poly)[2]
   anc_tips <- which(rent_tree$tip.label %in% as.character(1:(n_chroms - n_der))) 
   der_tips <- which(as.numeric(rent_tree$tip.label) %in% (n_chroms - n_der + 1):n_chroms)
   anc_tree <- drop.tip(rent_tree, der_tips)
   der_tree <- drop.tip(rent_tree, anc_tips)

   
   trees.all[[i]] <- rent_tree
   trees.anc[[i]] <- anc_tree
   trees.der[[i]] <- der_tree

   print(paste("round", as.character(i), "complete"))
   print(paste("segsites =", as.character(seg.sites[i])))
   print(paste("measured length =", as.character(meas.length[i])))
}

save.image(file = "rent_1700_trees_1KG_neale_height_071918.RData")


n_ancs <- n_chroms- n_ders

#Checks that SNPS worked.
monomorphic_loci #empty---no loci were monomorphic.
mean(snps.fail1)
mean(snps.miss)


#Check polarization

info.sites.char <- matrix("", nrow = length(info.sites), ncol = 4)
for(i in 1:length(info.sites)){
	info.sites.char[i,1] <- as.character(info.sites[[i]]$ID)
	info.sites.char[i,2] <- as.character(info.sites[[i]]$pos)
	info.sites.char[i,3] <- as.character(info.sites[[i]]$allele0)
	info.sites.char[i,4] <- as.character(info.sites[[i]]$allele1)
}

mean(as.character(mark.dat$A2) == info.sites.char[,4]) #allele1 matches A2 in each case, polarization good.

mean(as.character(mark.dat$rsid) == info.sites.char[,1]) #check that the rsids match



beta <- mark.dat$beta
rsID <- mark.dat$rsid



#Goal: adjust time information using locus-wise thetas.
#fit neutral, waiting-time, and lineages-remaining estimators
#test for selection.


#Rent+ times are computed as t = 2*d/(L*theta)
#where d is a Hamming distance between haplotypes, L is the length of the haplotype
#in base pairs, and theta is estimated value of 4Nu (est. by Watterson).
#We'll multiply by theta estimated per site to get distance-matrix units,
#then rescale so that the mean tmrca is 2.

trees.der.rescale <- trees.der
trees.anc.rescale <- trees.anc
trees.all.rescale <- trees.all


for(i in 1:length(trees.all)){
	trees.der.rescale[[i]]$edge.length <- trees.der[[i]]$edge.length*thetas[i]
	trees.anc.rescale[[i]]$edge.length <- trees.anc[[i]]$edge.length*thetas[i]
	trees.all.rescale[[i]]$edge.length <- trees.all[[i]]$edge.length*thetas[i]
}


tmrcas <- numeric(0)
for(i in 1:length(trees.all)){
	tmrcas[i] <- max(branching.times(trees.all.rescale[[i]]))
}

for(i in 1:length(trees.all)){
	trees.der.rescale[[i]]$edge.length <- trees.der.rescale[[i]]$edge.length*2/mean(tmrcas)
	trees.anc.rescale[[i]]$edge.length <- trees.anc.rescale[[i]]$edge.length*2/mean(tmrcas)
	trees.all.rescale[[i]]$edge.length <- trees.all.rescale[[i]]$edge.length*2/mean(tmrcas)
}

time <- seq(0, 4, by = 0.001)

times.c <- list()
for(i in 1:length(trees.all.rescale)){
	times.c[[i]] <- trees_to_times(trees.all.rescale[[i]], trees.anc.rescale[[i]], trees.der.rescale[[i]], time, sure.alt.is.derived = FALSE)
}

lins.list <- list()
for(i in 1:length(trees.all.rescale)){
	lins.list[[i]] <- times_to_lins(times.c[[i]], time)
}


Va.poly <- add.var(beta, (n_ders/n_chroms))
add.var(beta / sqrt(Va.poly), (n_ders/n_chroms))

beta.r <- beta / sqrt(Va.poly)


#neutral
trajs_neut <- matrix(nrow = length(time), ncol = length(trees.all.rescale))
vars_neut_bin <- matrix(nrow = length(time), ncol = length(trees.all.rescale))
#vars_neut_post <- matrix(nrow = length(time), ncol = length(trees.all.rescale))
for(i in 1:length(trees.all.rescale)){	
	trajs_neut[,i] <- est_af_traj_neut(lins.list[[i]])
	vars_neut_bin[,i] <- est_af_var_neut_bin(lins.list[[i]])
	#vars_neut_post[,i] <- est_af_var_neut_post(lins.list[[i]])
}
trajs_neut[time == 0,] <- (n_ders/n_chroms) #in the present, just use sample allele frequency.
#This is the same as the output of est_af_traj_neut() if no coalescent times get rounded to 0.
vars_neut_bin[time == 0,] <- (n_ders/n_chroms)*(1 - (n_ders/n_chroms))/n_chroms
traj.phen.neut <- 2 * trajs_neut %*%  beta.r
var.phen.neut.bin <- 4 * vars_neut_bin %*% beta.r^2
#var.phen.neut.post <- 4 * vars_neut_post %*% beta^2


#waiting time-based estimates and variance
trajs_est_wt_l1 <- matrix(nrow = length(time), ncol = length(trees.all.rescale))
trajs_var_wt_l1 <- matrix(nrow = length(time), ncol = length(trees.all.rescale))
for(i in 1:length(trees.all.rescale)){
	wt.estvar <- p_ests_wait(times.c[[i]], time, ell.ref = 1, ell.alt = 1)
	trajs_est_wt_l1[,i] <- wt.estvar[,1]	
	trajs_var_wt_l1[,i] <- wt.estvar[,2]	
}
traj.phen.wt_l1 <- 2 * trajs_est_wt_l1 %*%  beta.r 
var.phen.wt_l1 <- 4 * trajs_var_wt_l1 %*%  beta.r^2 
traj.phen.wt_l1[time == 0] <- traj.phen.neut[time == 0]
var.phen.wt_l1[time == 0] <- var.phen.neut.bin[time == 0]



#lineage number based estimates and variance.
trajs_mom_smoothtime <- matrix(nrow = length(time), ncol = length(trees.all.rescale))
trajs_var_mom_smoothtime <- matrix(nrow = length(time), ncol = length(trees.all.rescale))
for(i in 1:length(trees.all.rescale)){		
	trajs_mom_smoothtime[,i] <- est_af_traj_mom.smoothtime(lins.list[[i]], time)
	trajs_var_mom_smoothtime[,i] <- est_af_var_mom.smoothtime_coaltimes(lins.list[[i]], time)
}
traj.phen.mom_smoothtime <- 2 * trajs_mom_smoothtime %*%  beta.r 
traj.phen.mom_smoothtime[time == 0] <- traj.phen.neut[time == 0] 
#trajs_var_mom_smoothtime.nonan <- trajs_var_mom_smoothtime
#trajs_var_mom_smoothtime.nonan[is.nan(trajs_var_mom_smoothtime.nonan)] <- 0
var.phen.mom_smoothtime <- 4 * trajs_var_mom_smoothtime %*%  beta.r^2 
var.phen.mom_smoothtime[time == 0] <- var.phen.neut.bin[time == 0]




allele.freqs <- n_ders/182
plot(allele.freqs, beta.r)
cor(allele.freqs, abs(beta.r))




pal <- c('#1b9e77','#d95f02','#7570b3','#e7298a')
pal <- c(rgb(27/256,158/256,119/256),rgb(217/256,95/256,2/256),rgb(117/256,112/256,179/256),rgb(231/256,41/256,138/256))
pal.int <- c(rgb(27/256,158/256,119/256,1/3),rgb(217/256,95/256,2/256,1/3),rgb(117/256,112/256,179/256,1/3),rgb(231/256,41/256,138/256,1/3))


tiff("height_lr_3ests.tif", units = "in", width = 6, height = 4, res = 300, compression = "lzw")
par(cex = 0.85)
plot(-time, traj.phen.neut, type = "l", xlab = "Time (coalescent units)", ylab = "Estimated mean polygenic height (UK 1000G)", ylim = c(-5, 5), xlim = c(-0.2, 0), xaxt = "n", bty = "n")
axis(1, at = c(0, -.1, -.2))
polygon(c(-time, rev(-time)), c(traj.phen.neut + 1.96*sqrt(var.phen.neut.bin), rev(traj.phen.neut - 1.96*sqrt(var.phen.neut.bin))) , col = pal.int[1], border = NA)
polygon(c(-time, rev(-time)), c(traj.phen.wt_l1 + 1.96*sqrt(var.phen.wt_l1), rev(traj.phen.wt_l1  - 1.96*sqrt(var.phen.wt_l1 ))) , col = pal.int[3], border = NA)
polygon(c(-time[1:1000], rev(-time[1:1000])), c(traj.phen.mom_smoothtime[1:1000] + 1.96*sqrt(var.phen.mom_smoothtime[1:1000]), rev(traj.phen.mom_smoothtime[1:1000]  - 1.96*sqrt(var.phen.mom_smoothtime[1:1000] ))) , col = pal.int[2], border = NA)
lines(-time, traj.phen.wt_l1, col = pal[3], lwd = 2)
lines(-time, traj.phen.mom_smoothtime, col = pal[2], lwd = 2)
lines(-time, traj.phen.neut, col = pal[1], lwd = 2)
legend("topleft", lwd = 1, col = pal[c(1,3,2)], legend = c("Proportion-of-lineages", "Waiting-time", "Lineages-remaining"), bty = "n")
dev.off()


pdf("height_lr_3ests.pdf", width = 6, height = 4, )
par(cex = 0.85)
plot(-time, traj.phen.neut, type = "l", xlab = "Time (coalescent units)", ylab = "Estimated mean polygenic height (UK 1000G)", ylim = c(-5, 5), xlim = c(-0.2, 0), xaxt = "n", bty = "n")
axis(1, at = c(0, -.1, -.2))
polygon(c(-time, rev(-time)), c(traj.phen.neut + 1.96*sqrt(var.phen.neut.bin), rev(traj.phen.neut - 1.96*sqrt(var.phen.neut.bin))) , col = pal.int[1], border = NA)
polygon(c(-time, rev(-time)), c(traj.phen.wt_l1 + 1.96*sqrt(var.phen.wt_l1), rev(traj.phen.wt_l1  - 1.96*sqrt(var.phen.wt_l1 ))) , col = pal.int[3], border = NA)
polygon(c(-time[1:1000], rev(-time[1:1000])), c(traj.phen.mom_smoothtime[1:1000] + 1.96*sqrt(var.phen.mom_smoothtime[1:1000]), rev(traj.phen.mom_smoothtime[1:1000]  - 1.96*sqrt(var.phen.mom_smoothtime[1:1000] ))) , col = pal.int[2], border = NA)
lines(-time, traj.phen.wt_l1, col = pal[3], lwd = 2)
lines(-time, traj.phen.mom_smoothtime, col = pal[2], lwd = 2)
lines(-time, traj.phen.neut, col = pal[1], lwd = 2)
legend("topleft", lwd = 1, col = pal[c(1,3,2)], legend = c("Proportion-of-lineages", "Waiting-time", "Lineages-remaining"), bty = "n")
dev.off()



Qx_test(trajs_neut[time %in% ((0:10)/100),],beta.r, perms = 10000)



save.image(file = "rent_1700_trees_1KG_height_UKB_neale_processed_072318.RData")


######################################################################################3
#Plot GIANT and UKB on one figure
