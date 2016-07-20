###############################################################
### RUN OUTSIDE OF RADIANT
###############################################################
# installing and loading packages
# repos <- "https://cloud.r-project.org"
repos <- c("https://radiant-rstats.github.io/minicran/", "https://cloud.r-project.org")
options(repos = c(CRAN = repos))

#install.packages("devtools")
library(devtools)
#install.packages("miniCRAN")
library(miniCRAN)

pth <- "~/gh/minicran"
pkgs = c("DiagrammeR")

# building minicran for source packages
pkgList <- pkgDep(pkgs, repos = repos, type = "source", suggests = FALSE)
makeRepo(pkgList, path = pth, type = "source")

# building minicran for windows binaries
pkgList <- pkgDep(pkgs, repos = repos, type = "win.binary", suggests = FALSE)
makeRepo(pkgList, path = pth, type = "win.binary")

# building minicran for mac mavericks binaries
pkgList <- pkgDep(pkgs, repos = repos, type = "mac.binary.mavericks", suggests = FALSE)
makeRepo(pkgList, path = pth, type = "mac.binary.mavericks")

library(dplyr)
library(magrittr)

pdirs <- c("src/contrib", "bin/windows/contrib/3.3", "bin/macosx/mavericks/contrib/3.3")

for(pdir in pdirs) {
  list.files(file.path(pth, pdir)) %>%
    data.frame(fn = ., stringsAsFactors=FALSE) %>%
    mutate(pkg_file = fn, pkg_name = strsplit(fn, "_") %>% sapply("[",1),
    			 pkg_version = strsplit(fn, "_") %>% sapply("[",2) %>% gsub("(.zip)|(.tar.gz)|(.tgz)","",.)) %>%
    group_by(pkg_name) %>%
    arrange(desc(pkg_version)) %>%
    summarise(old = n(), pkg_file_new = first(pkg_file), pkg_file_old = last(pkg_file)) %>%
    filter(old > 1) %T>% print -> old

  if(nrow(old) > 0) {
    for(pf in old$pkg_file_old) {
    	unlink(file.path(pth, pdir, pf))
    }
  }
}

## needed to update PACKAGES after deleting old versions
tools::write_PACKAGES(file.path(pth, "bin/windows/contrib/3.3/"), type = "win.binary")
tools::write_PACKAGES(file.path(pth, "bin/macosx/mavericks/contrib/3.3/"), type = "mac.binary")
tools::write_PACKAGES(file.path(pth, "src/contrib/"), type = "source")
