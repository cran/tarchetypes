% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tar_quarto_files.R
\name{tar_quarto_files_get_source_files}
\alias{tar_quarto_files_get_source_files}
\title{Get Source Files From Quarto Inspect}
\usage{
tar_quarto_files_get_source_files(file_information)
}
\arguments{
\item{file_information}{The \code{fileInformation} element of the list
returned by \code{quarto::quarto_inspect()}.}
}
\value{
A character vector of Quarto source files.
}
\description{
Collects all files from the
\code{fileInformation} field that are used in the current report.
}
\details{
\code{fileInformation} contains a list of files. Each file entry contains
two data frames. The first, \code{includeMap}, contains a \code{source} column (files
that include other files, e.g. the main report file) and a \code{target} column
(files that get included by the \code{source} files). The \code{codeCells} data frame
contains all code cells from the files represented in \code{includeMap}.
}
\keyword{internal}
