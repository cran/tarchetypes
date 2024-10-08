% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tar_sub.R, R/tar_sub_raw.R
\name{tar_sub}
\alias{tar_sub}
\alias{tar_sub_raw}
\title{Create multiple expressions with symbol substitution.}
\usage{
tar_sub(expr, values)

tar_sub_raw(expr, values)
}
\arguments{
\item{expr}{Starting expression. Values are iteratively substituted
in place of symbols in \code{expr} to create each new expression.

\code{\link[=tar_sub]{tar_sub()}} expects an unevaluated expression for
the \code{expr} object, whereas \code{\link[=tar_sub_raw]{tar_sub_raw()}} expects an
evaluated expression object.}

\item{values}{List of values to substitute into \code{expr} to create
the expressions. All elements of \code{values} must have the same length.}
}
\value{
A list of expression objects. Often, these expression objects
evaluate to target objects (but not necessarily).
See the "Target objects" section for background.
}
\description{
Loop over a grid of values and create an expression object
from each one. Helps with general metaprogramming.

\code{\link[=tar_sub]{tar_sub()}} expects an unevaluated expression for
the \code{expr} object, whereas \code{\link[=tar_sub_raw]{tar_sub_raw()}} expects an
evaluated expression object.
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
# tar_map() is incompatible with tar_render() because the latter
# operates on preexisting tar_target() objects. By contrast,
# tar_eval() and tar_sub() iterate over code farther upstream.
values <- list(
  name = lapply(c("name1", "name2"), as.symbol),
  file = list("file1.Rmd", "file2.Rmd")
)
tar_sub(tar_render(name, file), values = values)
tar_sub_raw(quote(tar_render(name, file)), values = values)
}
\seealso{
Other Metaprogramming utilities: 
\code{\link{tar_eval}()}
}
\concept{Metaprogramming utilities}
