if(!require('filesstrings')) {install.packages('filesstrings'); library('filesstrings')}
datum <- format (Sys.Date(),"%d_%b_%Y")
file.move("/home/pi/R/projects/20min.png","/home/pi/R/projects/plots/")
file.rename("/home/pi/R/projects/plots/20min.png", paste0("/home/pi/R/projects/plots/20min_", datum,".png"))
file.move("/home/pi/R/projects/srf.png","/home/pi/R/projects/plots/")
file.rename("/home/pi/R/projects/plots/srf.png", paste0("/home/pi/R/projects/plots/srf_", datum,".png"))
file.move("/home/pi/R/projects/blick.png","/home/pi/R/projects/plots/")
file.rename("/home/pi/R/projects/plots/blick.png", paste0("/home/pi/R/projects/plots/blick_", datum,".png"))