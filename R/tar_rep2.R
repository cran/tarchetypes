#' @title Dynamic batched computation downstream of [tar_rep()]
#' @export
#' @family branching
#' @description Batching is important for optimizing the efficiency
#'   of heavily dynamically-branched workflows:
#'   <https://books.ropensci.org/targets/dynamic.html#batching>.
#'   [tar_rep2()] uses dynamic branching to iterate
#'   over the batches and reps of existing upstream targets.
#'
#'   [tar_rep2()] expects unevaluated language for the `name`, `command`,
#'   and `...` arguments
#'   (e.g. `tar_rep2(name = sim, command = simulate(), data1, data2)`)
#'   whereas [tar_rep2_raw()] expects an evaluated string for `name`,
#'   an evaluated expression object for `command`,
#'   and a character vector for `targets`
#'   (e.g.
#'   `tar_rep2_raw("sim", quote(simulate(x, y)), targets = c("x', "y"))`).
#' @return A new target object to perform batched computation.
#'   See the "Target objects" section for background.
#' @inheritSection tar_map Target objects
#' @inheritSection tar_rep Replicate-specific seeds
#' @inheritParams targets::tar_target
#' @inheritParams tar_rep
#' @param name Name of the target.
#'   [tar_rep2()] expects unevaluated language for the `name`, `command`,
#'   and `...` arguments
#'   (e.g. `tar_rep2(name = sim, command = simulate(), data1, data2)`)
#'   whereas [tar_rep2_raw()] expects an evaluated string for `name`,
#'   an evaluated expression object for `command`,
#'   and a character vector for `targets`
#'   (e.g.
#'   `tar_rep2_raw("sim", quote(simulate(x, y)), targets = c("x', "y"))`).
#' @param command R code to run multiple times. Must return a list or
#'   data frame because `tar_rep()` will try to append new elements/columns
#'   `tar_batch` and `tar_rep` to the output to denote the batch
#'   and rep-within-batch IDs, respectively.
#'
#'   [tar_rep2()] expects unevaluated language for the `name`, `command`,
#'   and `...` arguments
#'   (e.g. `tar_rep2(name = sim, command = simulate(), data1, data2)`)
#'   whereas [tar_rep2_raw()] expects an evaluated string for `name`,
#'   an evaluated expression object for `command`,
#'   and a character vector for `targets`
#'   (e.g.
#'   `tar_rep2_raw("sim", quote(simulate(x, y)), targets = c("x', "y"))`).
#' @param ... Symbols to name one or more upstream batched targets
#'   created by [tar_rep()].
#'   If you supply more than one such target, all those targets must have the
#'   same number of batches and reps per batch. And they must all return
#'   either data frames or lists. List targets must use `iteration = "list"`
#'   in [tar_rep()].
#' @param targets Character vector of names of upstream batched targets
#'   created by [tar_rep()].
#'   If you supply more than one such target, all those targets must have the
#'   same number of batches and reps per batch. And they must all return
#'   either data frames or lists. List targets must use `iteration = "list"`
#'   in [tar_rep()].
#' @examples
#' if (identical(Sys.getenv("TAR_LONG_EXAMPLES"), "true")) {
#' targets::tar_dir({ # tar_dir() runs code from a temporary directory.
#' targets::tar_script({
#'   library(tarchetypes)
#'   list(
#'     tar_rep(
#'       data1,
#'       data.frame(value = rnorm(1)),
#'       batches = 2,
#'       reps = 3
#'     ),
#'     tar_rep(
#'       data2,
#'       list(value = rnorm(1)),
#'       batches = 2, reps = 3,
#'       iteration = "list" # List iteration is important for batched lists.
#'     ),
#'     tar_rep2(
#'       aggregate,
#'       data.frame(value = data1$value + data2$value),
#'       data1,
#'       data2
#'     ),
#'     tar_rep2_raw(
#'       "aggregate2",
#'       quote(data.frame(value = data1$value + data2$value)),
#'       targets = c("data1", "data2")
#'     )
#'   )
#' })
#' targets::tar_make()
#' targets::tar_read(aggregate)
#' })
#' }
tar_rep2 <- function(
  name,
  command,
  ...,
  rep_workers = 1,
  tidy_eval = targets::tar_option_get("tidy_eval"),
  packages = targets::tar_option_get("packages"),
  library = targets::tar_option_get("library"),
  format = targets::tar_option_get("format"),
  repository = targets::tar_option_get("repository"),
  iteration = targets::tar_option_get("iteration"),
  error = targets::tar_option_get("error"),
  memory = targets::tar_option_get("memory"),
  garbage_collection = targets::tar_option_get("garbage_collection"),
  deployment = targets::tar_option_get("deployment"),
  priority = targets::tar_option_get("priority"),
  resources = targets::tar_option_get("resources"),
  storage = targets::tar_option_get("storage"),
  retrieval = targets::tar_option_get("retrieval"),
  cue = targets::tar_option_get("cue"),
  description = targets::tar_option_get("description")
) {
  name <- targets::tar_deparse_language(substitute(name))
  envir <- targets::tar_option_get("envir")
  command <- targets::tar_tidy_eval(substitute(command), envir, tidy_eval)
  targets <- as.character(match.call(expand.dots = FALSE)$...)
  tar_rep2_raw(
    name = name,
    command = command,
    targets = targets,
    rep_workers = rep_workers,
    packages = packages,
    library = library,
    format = format,
    repository = repository,
    iteration = iteration,
    error = error,
    memory = memory,
    garbage_collection = garbage_collection,
    deployment = deployment,
    priority = priority,
    resources = resources,
    storage = storage,
    retrieval = retrieval,
    cue = cue,
    description = description
  )
}
