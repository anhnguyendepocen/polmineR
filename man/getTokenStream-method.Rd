% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getTokenStream_method.R
\docType{methods}
\name{getTokenStream}
\alias{getTokenStream}
\alias{getTokenStream,character-method}
\alias{getTokenStream,matrix-method}
\alias{getTokenStream,numeric-method}
\alias{getTokenStream,partition-method}
\title{get token stream}
\usage{
getTokenStream(.Object, ...)

\S4method{getTokenStream}{numeric}(.Object, corpus, pAttribute,
  encoding = NULL, collapse = NULL, beautify = TRUE, cpos = FALSE)

\S4method{getTokenStream}{matrix}(.Object, ...)

\S4method{getTokenStream}{character}(.Object, left, right, ...)

\S4method{getTokenStream}{partition}(.Object, pAttribute, collapse = NULL,
  cpos = FALSE)
}
\arguments{
\item{.Object}{an object of classe \code{matrix} or \code{partition}}

\item{...}{further arguments}

\item{corpus}{the CWB corpus}

\item{pAttribute}{the pAttribute to decode}

\item{encoding}{encoding to use}

\item{collapse}{character string length 1}

\item{beautify}{logical, whether to correct whitespace before and after interpunctation}

\item{cpos}{logical, whether to return cpos as names of the tokens}

\item{left}{left corpus position}

\item{right}{right corpus position}
}
\description{
get token stream
}

