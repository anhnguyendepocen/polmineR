#' @include cooccurrences_class.R generics.R
NULL

setMethod("[", "cooccurrences", function(x,i){
  tab <- subset(x@stat, node == i)
  tab <- tab[, c("cooccurrenceWindowFreq", "cooccurrenceCorpusFreq", "expCoi", "expCorpus", "ll")]
  colnames(tab) <- c("cooccurrence", "countCoi", "countCorpus", "expCoi", "expCorpus", "ll")
  return(tab)
})

setMethod("show", "cooccurrences", function(object){
  cat("Object of 'cooccurrences'-class\n")
  cat("Number of rows: ", nrow(object@stat), "\n")
})


setMethod("summary", "cooccurrences", function(object){
  return(.statisticalSummary(object))
})

#' @importFrom parallel mcparallel mccollect
setMethod("as.sparseMatrix", "cooccurrences", function(x, col, mc=FALSE){
  uniqueTerms <- unique(c(x@stat[,"node"], x@stat[,"cooccurrence"]))
  keyVector <- setNames(c(1:length(uniqueTerms)), uniqueTerms)
  splittedTab <- split(x=x@stat[,c(col, "cooccurrence")], f=x@stat[,"node"])
  system.time(
  if (mc==FALSE){
    bag <- list()
    bag[["i"]] <- unname(unlist(lapply(names(splittedTab), function(n) rep(keyVector[n], times=nrow(splittedTab[[n]]))))) #nodes
    bag[["j"]] <- unname(unlist(lapply(splittedTab, function(tab) keyVector[tab[,"cooccurrence"]]))) # cooccurrences
    bag[["x"]] <- unname(unlist(lapply(splittedTab, function(tab) tab[,col]))) # values
  } else if (mc==TRUE) {
    i <- mcparallel(unname(unlist(lapply(names(splittedTab), function(n) rep(keyVector[n], times=nrow(splittedTab[[n]])))))) #nodes
    j <- mcparallel(unname(unlist(lapply(splittedTab, function(tab) keyVector[tab[,"cooccurrence"]])))) # cooccurrences
    x <- mcparallel(unname(unlist(lapply(splittedTab, function(tab) tab[,col])))) # values
    bag <- mccollect(list(i,j,x), wait=TRUE)
    names(bag) <- c("i", "j", "x")
  }
  )
  retval <- sparseMatrix(
    i=bag[["i"]], j=bag[["j"]], x=bag[["x"]], 
    dims=c(length(uniqueTerms), length(uniqueTerms)),
    dimnames=list(names(keyVector), names(keyVector)),
    giveCsparse=TRUE
  )   
  return(retval)
})


.reshapeCooccurrences <- function(object, mc=TRUE){
  message("... ordering cooccurrences and nodes by id")
  minMaxMatrix <- t(apply(
    as.matrix(object@stat[,c("nodeId", "cooccurrenceId")]),
    1, .minMaxId
    ))
  colnames(minMaxMatrix) <- c("a", "b", "minId", "maxId")
  minMaxOrder <- apply(minMaxMatrix, 1, function(row) ifelse(row["a"] <= row["b"], 0, 1 ))
  statPlus <- data.frame(
    minMaxMatrix[,c("minId", "maxId")], idOrder=minMaxOrder,
    idId=paste(minMaxMatrix[,"minId"], minMaxMatrix[,"maxId"], sep="-"),
    object@stat
    )
  message("... creating subsets of paired couples")
  bag <- split(statPlus, f=statPlus[,"idId"])
  .reassembleSubsets <- function(set){
    if(nrow(set) == 2){
      set <- set[order(set[,"idOrder"]),]
      retval <- c(
        aId=set[1,"minId"], bId=set[1,"maxId"],
        tf_a=set[which(set[,"cooccurrenceId"] == set[1,"minId"]), "cooccurrenceCorpusFreq"],
        tf_b=set[which(set[,"cooccurrenceId"] == set[1,"maxId"]), "cooccurrenceCorpusFreq"],
        tf_ab=set[1, "cooccurrenceWindowFreq"],
        ll_a2b=set[1,"ll"], ll_b2a=set[2,"ll"]
      )
    } else {
      if (set[,"idOrder"] == 0){
        retval <- c(
          aId=set[1,"minId"], bId=set[1,"maxId"],
          tf_a=set[1, "cooccurrenceCorpusFreq"], tf_b=set[1, "cooccurrenceCorpusFreq"],
          tf_ab=set[1, "cooccurrenceWindowFreq"],          
          ll_a2b=set[1,"ll"], ll_b2a=NA
        )
      } else if (set[,"idOrder"] == 1) {
        retval <- c(
          aId=set[1,"minId"], bId=set[1,"maxId"],
          tf_a=set[1, "cooccurrenceCorpusFreq"], tf_b=set[1, "cooccurrenceCorpusFreq"],
          tf_ab=set[1, "cooccurrenceWindowFreq"],
          ll_a2b=NA, ll_b2a=set[2,"ll"]
        )
      }
    }
    retval
  }
  message("... reassembling information")
  if (mc == FALSE){
    consList <- lapply(bag, .reassembleSubsets) 
  } else {
    consList <- mclapply(bag, .reassembleSubsets) 
  }
  consDf <- do.call(rbind, consList)
  message("... preparing table to be returned")
  abStr <- lapply(c("aId", "bId"), function(x){
    foo <- cqi_id2str(paste(object@corpus, ".", object@pAttribute, sep=""), consDf[,x])
    iconv(foo, from=object@encoding, to="UTF-8")
  })
  consDf2 <- data.frame(
    a=abStr[[1]],
    b=abStr[[2]],
    consDf[,c("tf_a", "tf_b", "tf_ab", "ll_a2b", "ll_b2a")],
    row.names=paste(abStr[[1]], abStr[[2]], sep="<->")
    )
  consDf2
  retval <- new(
    "cooccurrencesReshaped",
#   call="character",
    partition=object@partition,
    partitionSize=object@partitionSize,
    leftContext=object@leftContext, rightContext=object@rightContext,
    pAttribute=object@pAttribute,
    corpus=object@corpus,
    stat=consDf2,
    encoding=object@encoding,
    posFilter=object@posFilter,
    method=object@method,
    cutoff=object@cutoff
  )
  return(retval)
}

