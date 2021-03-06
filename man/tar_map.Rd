% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tar_map.R
\name{tar_map}
\alias{tar_map}
\title{Static branching.}
\usage{
tar_map(values, ..., names = tidyselect::everything(), unlist = FALSE)
}
\arguments{
\item{values}{Named list or data frame with values to iterate over.
The names are the names of symbols in the commands and pattern
statements, and the elements are values that get substituted
in place of those symbols. Elements of the \code{values} list
should be small objects that can easily deparse to names,
such as characters, integers, and symbols.
For more complicated elements of \code{values}, such as
lists with multiple numeric vectors,
\code{tar_map()} attempts to parse the elements into expressions,
but this process is not perfect, and the default
target names come out garbled.
To create a list of symbols as a column of \code{values},
use \code{rlang::syms()}.}

\item{...}{One or more target objects or list of target objects.
Lists can be arbitrarily nested, as in \code{list()}.}

\item{names}{Subset of \code{names(values)}
used to generate the suffixes in the names of the new targets.
You can supply symbols, a character vector,
or tidyselect helpers like \code{\link[=starts_with]{starts_with()}}.}

\item{unlist}{Logical, whether to flatten the returned list of targets.
If \code{unlist = FALSE}, the list is nested and sub-lists
are named and grouped by the original input targets.
If \code{unlist = TRUE}, the return value is a flat list of targets
named by the new target names.}
}
\value{
A list of new target objects. If \code{unlist} is \code{FALSE},
the list is nested and sub-lists are named and grouped by the original
input targets. If \code{unlist = TRUE}, the return value is a flat list of
targets named by the new target names.
See the "Target objects" section for background.
}
\description{
Define multiple new targets based on existing target objects.
}
\details{
\code{tar_map()} creates collections of new
targets by iterating over a list of arguments
and substituting symbols into commands and pattern statements.
}
\section{Target objects}{

Most \code{tarchetypes} functions are target factories,
which means they return target objects
or lists of target objects.
Target objects represent skippable steps of the analysis pipeline
as described at \url{https://books.ropensci.org/targets/}.
Please read the walkthrough at
\url{https://books.ropensci.org/targets/walkthrough.html}
to understand the role of target objects in analysis pipelines.

For developers,
\url{https://wlandau.github.io/targetopia/contributing.html#target-factories}
explains target factories (functions like this one which generate targets)
and the design specification at
\url{https://books.ropensci.org/targets-design/}
details the structure and composition of target objects.
}

\examples{
if (identical(Sys.getenv("TAR_LONG_EXAMPLES"), "true")) {
targets::tar_dir({ # tar_dir() runs code from a temporary directory.
targets::tar_script({
  list(
    tarchetypes::tar_map(
      list(a = c(12, 34), b = c(45, 78)),
      targets::tar_target(x, a + b),
      targets::tar_target(y, x + a, pattern = map(x))
    )
  )
})
targets::tar_manifest()
})
}
}
\seealso{
Other branching: 
\code{\link{tar_combine_raw}()},
\code{\link{tar_combine}()},
\code{\link{tar_rep_map_raw}()},
\code{\link{tar_rep_map}()},
\code{\link{tar_rep_raw}()},
\code{\link{tar_rep}()}
}
\concept{branching}
