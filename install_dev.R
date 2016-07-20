## install script for R(adiant) @ Rady School of Management (MBA)
cdir <- getwd()
tmp <- tempdir()
setwd(tmp)

repos <- c("https://radiant-rstats.github.io/minicran/", "https://cran.rstudio.com")
options(repos = c(CRAN = repos))

build <- function() {
	suppressWarnings(update.packages(ask = FALSE, repos = "https://radiant-rstats.github.io/minicran/", type = "binary"))
	install <- function(x) {
		if (!x %in% installed.packages())
			install.packages(x, type = 'binary')
	}

	resp <- sapply(
		c("radiant", "devtools", "roxygen2", "testthat", "gitgadget", "lintr", "haven", "readxl", "miniUI"),
		install
	)
}

readliner <- function(text, inp = "", resp = "[yYnN]") {
	while (!grepl(resp, inp))
		inp <- readline(text)

	return(inp)
}

rv <- R.Version()

if (as.numeric(rv$major) < 3 || as.numeric(rv$minor) < 3) {
	cat("Radiant requires R-3.3.0 or later. Please install the latest\nversion of R from https://cloud.r-project.org/")
} else {

	os <- Sys.info()["sysname"]
	if (os == "Windows") {
		lp <- .libPaths()[grepl("Documents",.libPaths())]
		if (grepl("(Prog)|(PROG)", Sys.getenv("R_HOME"))) {
			rv <- paste(rv$major, rv$minor, sep = ".")
			cat(paste0("It seems you installed R in the Program Files directory.\nPlease uninstall R and re-install into C:\\R\\R-",rv),"\n\n")
		} else if (length(lp) > 0) {

			cat("Installing R-packages in the directory printed below often causes\nproblems on Windows. Please remove the 'Documents/R' directory,\nclose and restart R, and run the script again.\n\n")
			cat(paste0(lp, collapse = "\n"),"\n\n")
		} else {

			build()

			if (!require("installr")) {
			  install.packages("installr")
			  library("installr")
			}

			installr::install.Rtools()
			installr::install.git()

			## get rstudio - preview
			page <- readLines("https://www.rstudio.com/products/rstudio/download/preview/", warn = FALSE)
			pat <- "//s3.amazonaws.com/rstudio-dailybuilds/RStudio-[0-9.]+.exe"
			URL <- paste0("https:",regmatches(page,regexpr(pat,page))[1])
			# installr::install.URL(URL, installer_option = "/S")
			installr::install.URL(URL)

			## get putty for ssh
			page <- readLines("http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html", warn = FALSE)
			pat <- "//the.earth.li/~sgtatham/putty/latest/x86/putty-[0-9.]+-installer.msi"
			URL <- paste0("http:",regmatches(page,regexpr(pat,page))[1])
			installr::install.URL(URL)

			cat("\n\nInstallation on Windows complete. Close R and start Rstudio\n\n")
		}
	} else if (os == "Darwin") {

		## from http://unix.stackexchange.com/a/712
		resp <- system("sw_vers -productVersion", intern = TRUE)

    if (as.integer(strsplit(resp, "\\.")[[1]][2]) < 9) {
			cat("The version of OSX on your mac is no longer supported by R. You will need to upgrade the OS before proceeding\n\n")
    } else {

			build()

			## get rstudio
			##  based on https://github.com/talgalili/installr/blob/82bf5b542ce6d2ef4ebc6359a4772e0c87427b64/R/install.R#L805-L813
			# page <- readLines("https://www.rstudio.com/ide/download/desktop", warn = FALSE)
			# pat <- "//download1.rstudio.org/RStudio-[0-9.]+.dmg";
			## get rstudio - preview

		  # download.file("https://developer.apple.com/services-account/download?path=/Developer_Tools/Xcode_7.3.1/Xcode_7.3.1.dmg","Xcode.dmg")
		  # system("open 'https://developer.apple.com/services-account/download?path=/Developer_Tools/Xcode_7.2.1/Xcode_7.2.1.dmg'")
			# cat("Install Xcode. You may need to provide login information for your Apple account to get\nXcode. Download the file to a location of your choice and install it. When the install\nis complete open Xcode, go to Preferences > Downloads, and install the Command Line Tools")
			# cat("Install Xcode. You will need to provide login information for your Apple account to get\nXcode. Download the file to a location of your choice and install it. When the install\nis complete open Xcode, go to Preferences > Downloads, and install the Command Line Tools")

			# xc <- try(suppressWarnings(suppressMessages(system("xcode-select --install", intern = TRUE))), silent = TRUE)
			xc <- system("xcode-select --install", ignore.stderr = TRUE)
			if (xc == 1) {
				cat("\n\nXcode command line tools are already installed\n\n")
			} else {
				cat("\n\nXcode command line tools were successfully installed\n\n")
			}

			hb <- suppressWarnings(system("which brew", intern = TRUE))
			if (length(hb) == 0) {
			  cat("If you are going to use Mac OS for scientific computing we recommend that you install homebrew")
			  inp <- readliner("Type y to install homebrew or n to stop the process: ")
			  if (grepl("[yY]", inp)) {
			    hb_string <- "tell application \"Terminal\"\n\tactivate\n\tdo script \"/usr/bin/ruby -e \\\"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\\\"\"\nend tell"
			    cat(hb_string, file="homebrew.scpt",sep="\n")
			    system("osascript homebrew.scpt", wait = TRUE)
		    }
			}

			inp <- readliner("Type y to install Rstudio preview or n to stop the process: ")
			if (grepl("[yY]", inp)) {
				page <- readLines("https://www.rstudio.com/products/rstudio/download/preview/", warn = FALSE)
				pat <- "//s3.amazonaws.com/rstudio-dailybuilds/RStudio-[0-9.]+.dmg"
				URL <- paste0("https:",regmatches(page,regexpr(pat,page))[1])
				download.file(URL,"Rstudio.dmg")
				cat("\nDrag Rstudio.app to the applications folder\n")
				system("open RStudio.dmg", wait = TRUE)
				# system("sudo cp -R /Volumes/Rstudio/Rstudio.app /Applications", wait = TRUE)
				# cp /Volumes/Rstudio /Applications and then close?
				# path <- list.files("/Volumes", pattern = "RStudio*", full.names = TRUE)
				# system(paste0("hdiutil unmount ", path))
			}
			cat("\n\nInstallation on Mac complete. Close R and start Rstudio\n\n")
		}
	} else {
		cat("\n\nThe install script is not currently supported on your OS")
	}
}

setwd(cdir)
