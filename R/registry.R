#' reset CORPUS_REGISTRY
#' 
#' A utility function to reset the environment variable CORPUS_REGISTRY. That may
#' be necessary if you want use a CWB corpus that is not stored in the usual
#' place. In particular, resetting the environment variable is required if you
#' want to use a corpus delivered in a R package,
#' 
#' Resetting the CORPUS_REGISTRY environment variable is achieved by unloading 
#' and reloading the C library 'rcqp' that is the backend for the rcqp package. 
#' It may not be the most artful way to do things, but it works.
#' 
#' To get the path to a package that contains a CWB corpus, use
#' \code{system.file}.
#' @examples 
#' \dontrun{
#' sampleCorpusPkgDir <- system.file(package="polmineR.sampleCorpus")
#' sampleCorpusRegistryDir <- file.path(sampleCorpusPkgDir, "extdata", "cwb", "registry")
#' oldRegistryDir <- resetRegistry(sampleCorpusRegistryDir)
#' sampleCorpusPartition <- partition("PLPRBTTXT", def=list(text_id=".*"), method="grep", verbose=F)
#' resetRegistry(oldRegistryDir)
#' }
#' @param registryDir path to the registry directory to be used
#' @return the registry directory used before resetting CORPUS_REGISTRY
#' @export resetRegistry
resetRegistry <- function(registryDir=NULL) {
  if (!is.null(registryDir)){
    oldRegistry <- Sys.getenv("CORPUS_REGISTRY")
    Sys.setenv(CORPUS_REGISTRY=registryDir)
    # toUnload <- .dynLibs()[grep("rcqp.so", .dynLibs())][[1]][2]$path
  } else {
    oldRegistry <- Sys.getenv("CORPUS_REGISTRY")
    Sys.setenv(CORPUS_REGISTRY=session@defaultRegistry)
  }
  library.dynam.unload("rcqp", libpath=system.file(package="rcqp"))
  library.dynam("rcqp", package="rcqp", lib.loc=.libPaths()[1])
  oldRegistry
}


.parseRegistry <- function(corpus){
  registry <- scan(
    file=file.path(Sys.getenv("CORPUS_REGISTRY"), tolower(corpus)),
    sep="\n",
    what="character",
    quiet=TRUE
  )
  registryList <- lapply(
    setNames(c("NAME", "ID", "HOME", "INFO"), c("NAME", "ID", "HOME", "INFO")),
    function(query){
      gsub(paste("^", query, "\\s+(.*?)$", sep=""), "\\1", grep(paste("^", query, sep=""), registry, value=T), perl=T)
    })
  # get pAttributes
  registryList[["pAttributes"]] <- gsub("^ATTRIBUTE\\s+(.*?)$", "\\1", grep("^ATTRIBUTE", registry, value=T))
  # get language
  registryList[["language"]] <- gsub("^.*language\\s=\\s\"(.*?)\".*$", "\\1", grep("language =", registry, value=T))
  # getEncoding
  encodingLine <- registry[grep('charset\\s*=\\s*"', registry)]
  encoding <- sub('^.*charset\\s*=\\s*"(.+?)".*$', "\\1", encodingLine)
  encoding <- toupper(encoding)
  if (!encoding %in% iconvlist()){
    warning('Please check encoding in the registry file (charset="..." provides unknown encoding) or provide encoding explicitly')
  }
  registryList[["encoding"]] <- tolower(encoding)
  return(registryList)
}

.parseInfoFile <- function(corpus){
  pathInfoFile <- .parseRegistry(corpus)$INFO
  if (file.exists(pathInfoFile)){
    infoFile <- scan(
      file=.parseRegistry(corpus)$INFO,
      sep="\n", what="character", quiet=TRUE
    )
    retval <- sapply(
      strsplit(infoFile, "\\s*=\\s*"),
      function(x) setNames(x[2], x[1])
    )
  } else {
    retval <- NULL
  }
  retval
}
