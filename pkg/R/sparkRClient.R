# Client code to connect to SparkRBackend

# Creates a SparkR client connection object
# if one doesn't already exist
connectBackend <- function(hostname, port, timeout = 6000) {
  if (exists(".sparkRcon", envir = .sparkREnv)) {
    cat("SparkRBackend client connection already exists\n")
    return(get(".sparkRcon", envir = .sparkREnv))
  }

  con <- socketConnection(host = hostname, port = port, server = FALSE,
                          blocking = TRUE, open = "wb", timeout = timeout)

  assign(".sparkRCon", con, envir = .sparkREnv)
  con
}

# Launch the SparkR backend using a call to 'system2'.
launchBackend <- function(
    classPath, 
    mainClass, 
    args, 
    javaOpts = "-Xms2g -Xmx2g",
    javaHome = Sys.getenv("JAVA_HOME")) {
  if (.Platform$OS.type == "unix") {
    java_bin_name = "java"
  } else {
    java_bin_name = "java.exe"
  }

  if (javaHome != "") {
    java_bin <- file.path(javaHome, "bin", java_bin_name)
  } else {
    java_bin <- java_bin_name
  }
  combinedArgs <- paste(javaOpts, "-cp", classPath, mainClass, args, sep = " ")
  cat("Launching java with command ", java_bin, " ", combinedArgs, "\n")
  invisible(system2(java_bin, combinedArgs, wait = F))
}
