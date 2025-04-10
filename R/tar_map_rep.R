#' @title Dynamic batched replication within static branches
#'   for data frames.
#' @export
#' @family branching
#' @description Define targets for batched replication
#'   within static branches for data frames.
#'
#'   [tar_map_rep()] expects an unevaluated symbol for the `name` argument
#'   and an unevaluated expression for `command`,
#'   whereas [tar_map_rep_raw()] expects a character string for `name`
#'   and an evaluated expression object for `command`.
#' @return A list of new target objects.
#'   See the "Target objects" section for background.
#' @inheritSection tar_map Target objects
#' @inheritSection tar_rep Replicate-specific seeds
#' @inheritParams tar_map
#' @inheritParams tar_rep
#' @param name Name of the target.
#'   [tar_map_rep()] expects an unevaluated symbol for the `name` argument,
#'   whereas [tar_map_rep_raw()] expects a character string for `name`.
#' @param command R code for a single replicate. Must return
#'   a data frame when run.
#'   [tar_map_rep()] expects  an unevaluated expression for `command`,
#'   whereas [tar_map_rep_raw()] expects
#'   an evaluated expression object for `command`.
#' @param columns A tidyselect expression to select which columns of `values`
#'   to append to the output. Columns already in the target output
#'   are not appended.
#' @param combine Logical of length 1, whether to create additional downstream
#'   targets to combine the results of static branches.
#'   The `values` argument must not be `NULL`
#'   for this combining to take effect.
#'   If `combine` is `TRUE` and `values` is not `NULL`,
#'   then separate targets aggregate all dynamic branches within each
#'   static branch, and then a final target combines all
#'   the static branches together.
#' @examples
#' if (identical(Sys.getenv("TAR_LONG_EXAMPLES"), "true")) {
#' targets::tar_dir({ # tar_dir() runs code from a temporary directory.
#' targets::tar_script({
#'   library(tarchetypes)
#'   # Just a sketch of a Bayesian sensitivity analysis of hyperparameters:
#'   assess_hyperparameters <- function(sigma1, sigma2) {
#'     # data <- simulate_random_data() # user-defined function
#'     # run_model(data, sigma1, sigma2) # user-defined function
#'     # Mock output from the model:
#'     posterior_samples <- stats::rnorm(1000, 0, sigma1 + sigma2)
#'     tibble::tibble(
#'       posterior_median = median(posterior_samples),
#'       posterior_quantile_0.025 = quantile(posterior_samples, 0.025),
#'       posterior_quantile_0.975 = quantile(posterior_samples, 0.975)
#'     )
#'   }
#'   hyperparameters <- tibble::tibble(
#'     scenario = c("tight", "medium", "diffuse"),
#'     sigma1 = c(10, 50, 50),
#'     sigma2 = c(10, 5, 10)
#'   )
#'   list(
#'     tar_map_rep(
#'       name = sensitivity_analysis,
#'       command = assess_hyperparameters(sigma1, sigma2),
#'       values = hyperparameters,
#'       names = tidyselect::any_of("scenario"),
#'       batches = 2,
#'       reps = 3
#'     ),
#'     tar_map_rep_raw(
#'       name = "sensitivity_analysis2",
#'       command = quote(assess_hyperparameters(sigma1, sigma2)),
#'       values = hyperparameters,
#'       names = tidyselect::any_of("scenario"),
#'       batches = 2,
#'       reps = 3
#'     )
#'   )
#' })
#' targets::tar_make()
#' targets::tar_read(sensitivity_analysis)
#' })
#' }
tar_map_rep <- function(
  name,
  command,
  values = NULL,
  names = NULL,
  descriptions = tidyselect::everything(),
  columns = tidyselect::everything(),
  batches = 1,
  reps = 1,
  rep_workers = 1,
  combine = TRUE,
  delimiter = "_",
  unlist = FALSE,
  tidy_eval = targets::tar_option_get("tidy_eval"),
  packages = targets::tar_option_get("packages"),
  library = targets::tar_option_get("library"),
  format = targets::tar_option_get("format"),
  repository = targets::tar_option_get("repository"),
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
  tar_map_rep_raw(
    name = deparse(substitute(name)),
    command = substitute(command),
    values = values,
    names = substitute(names),
    descriptions = substitute(descriptions),
    columns = substitute(columns),
    batches = batches,
    reps = reps,
    rep_workers = rep_workers,
    combine = combine,
    delimiter = delimiter,
    unlist = unlist,
    tidy_eval = tidy_eval,
    packages = packages,
    library = library,
    format = format,
    repository = repository,
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
