% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/context_method.R
\docType{methods}
\name{context}
\alias{as.matrix,contextBundle-method}
\alias{context}
\alias{context,character-method}
\alias{context,contextBundle-method}
\alias{context,cooccurrences-method}
\alias{context,missing-method}
\alias{context,partition-method}
\alias{context,partitionBundle-method}
\title{Analyze context of a node word}
\usage{
\S4method{context}{partition}(.Object, query, cqp = is.cqp,
  pAttribute = getOption("polmineR.pAttribute"), sAttribute = NULL,
  left = getOption("polmineR.left"), right = getOption("polmineR.right"),
  stoplist = NULL, positivelist = NULL, count = TRUE, method = "ll",
  mc = getOption("polmineR.mc"), verbose = TRUE, progress = FALSE)

\S4method{context}{character}(.Object, query, ...)

\S4method{context}{partitionBundle}(.Object, query, verbose = TRUE, ...)

\S4method{context}{cooccurrences}(.Object, query, complete = FALSE)

\S4method{context}{missing}()
}
\arguments{
\item{.Object}{a partition or a partitionBundle object}

\item{query}{query, which may by a character vector or a cqpQuery object}

\item{cqp}{defaults to is.cqp-function, or provide TRUE/FALSE}

\item{pAttribute}{p-attribute of the query}

\item{sAttribute}{if provided, it will be checked that cpos do not extend beyond
the region defined by the s-attribute}

\item{left}{no of tokens and to the left of the node word}

\item{right}{no of tokens to the right of the node word}

\item{stoplist}{exclude a query hit from analysis if stopword(s) is/are in
context}

\item{positivelist}{character vector or numeric vector: include a query hit
only if token in positivelist is present. If positivelist is a character
vector, it is assumed to provide regex expressions (incredibly long if the
list is long)}

\item{count}{logical}

\item{method}{either "LL" (default) or "pmi", if NULL, calculating
the statistics will be skipped}

\item{mc}{whether to use multicore; if NULL (default), the function will get
the value from the options}

\item{verbose}{report progress, defaults to TRUE}

\item{progress}{logical, whether to show progress bar}

\item{...}{further parameters}

\item{complete}{enhance completely}
}
\value{
depending on whether a partition or a partitionBundle serves as
  input, the return will be a context object, or a contextBundle object
}
\description{
Retrieve the word context of a token, checking for the boundaries of a XML
region. For formulating the query, CPQ syntax may be used (see
examples). Statistical tests available are log-likelihood, t-test, pmi.
}
\examples{
if (require(polmineR.sampleCorpus) && require(rcqp)){
  use("polmineR.sampleCorpus")
  p <- partition("PLPRBTTXT", list(text_type="speech"))
  a <- context(p, query="Integration", pAttribute="word")
}
}
\author{
Andreas Blaette
}

