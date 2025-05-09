#' @title Target with a Quarto project.
#' @export
#' @family Literate programming targets
#' @description Shorthand to include a Quarto project in a
#'   `targets` pipeline.
#'
#'   [tar_quarto()] expects an unevaluated symbol for the `name`
#'   argument and an unevaluated expression for the `execute_params` argument.
#'   [tar_quarto_raw()] expects a character string for the `name`
#'   argument and an evaluated expression object
#'   for the `execute_params` argument.
#' @details `tar_quarto()` is an alternative to `tar_target()` for
#'   Quarto projects and standalone Quarto source documents
#'   that depend on upstream targets. The Quarto
#'   R source documents (`*.qmd` and `*.Rmd` files)
#'   should mention dependency targets with `tar_load()` and `tar_read()`
#'   in the active R code chunks (which also allows you to render the project
#'   outside the pipeline if the `_targets/` data store already exists).
#'   (Do not use `tar_load_raw()` or `tar_read_raw()` for this.)
#'   Then, `tar_quarto()` defines a special kind of target. It
#'     1. Finds all the `tar_load()`/`tar_read()` dependencies in the
#'       R source reports and inserts them into the target's command.
#'       This enforces the proper dependency relationships.
#'       (Do not use `tar_load_raw()` or `tar_read_raw()` for this.)
#'     2. Sets `format = "file"` (see `tar_target()`) so `targets`
#'       watches the files at the returned paths and reruns the report
#'       if those files change.
#'     3. Configures the target's command to return both the output
#'       rendered files and the input dependency files (such as
#'       Quarto source documents). All these file paths
#'       are relative paths so the project stays portable.
#'     4. Forces the report to run in the user's current working directory
#'       instead of the working directory of the report.
#'     5. Sets convenient default options such as `deployment = "main"`
#'       in the target and `quiet = TRUE` in `quarto::quarto_render()`.
#' @inheritSection tar_render Literate programming limitations
#' @section Quarto troubleshooting:
#'   If you encounter difficult errors, please read
#'   <https://github.com/quarto-dev/quarto-r/issues/16>.
#'   In addition, please try to reproduce the error using
#'   `quarto::quarto_render("your_report.qmd", execute_dir = getwd())`
#'   without using `targets` at all. Isolating errors this way
#'   makes them much easier to solve.
#' @return A target object with `format = "file"`.
#'   When this target runs, it returns a character vector
#'   of file paths: the rendered documents, the Quarto source files,
#'   and other input and output files.
#'   The output files are determined by the YAML front-matter of
#'   standalone Quarto documents and `_quarto.yml` in Quarto projects,
#'   and you can see these files with [tar_quarto_files()]
#'   (powered by `quarto::quarto_inspect()`).
#'   All returned paths are *relative* paths to ensure portability
#'   (so that the project can be moved from one file system to another
#'   without invalidating the target).
#'   See the "Target objects" section for background.
#' @inheritSection tar_map Target objects
#' @inheritParams targets::tar_target
#' @inheritParams quarto::quarto_render
#' @inheritParams tar_render
#' @param name Name of the target.
#'   [tar_quarto()] expects an unevaluated symbol for the `name`
#'   argument, and
#'   [tar_quarto_raw()] expects a character string for `name`.
#' @param path Character string, path to the Quarto source file if rendering
#'   a single file, or the path to the root of the project if rendering
#'   a whole Quarto project.
#' @param extra_files Character vector of extra files and
#'   directories to track for changes. The target will be invalidated
#'   (rerun on the next `tar_make()`) if the contents of these files changes.
#'   No need to include anything already in the output of [tar_quarto_files()],
#'   the list of file dependencies automatically detected through
#'   `quarto::quarto_inspect()`.
#' @param execute_params Named collection of parameters
#'   for parameterized Quarto documents. These parameters override the custom
#'   custom elements of the `params` list in the YAML front-matter of the
#'   Quarto source files.
#'
#'   [tar_quarto()] expects an unevaluated expression for the
#'   `execute_params` argument, whereas
#'   [tar_quarto_raw()] expects an evaluated expression object.
#' @examples
#' if (identical(Sys.getenv("TAR_LONG_EXAMPLES"), "true")) {
#' targets::tar_dir({  # tar_dir() runs code from a temporary directory.
#' # Unparameterized Quarto document:
#' lines <- c(
#'   "---",
#'   "title: report.qmd source file",
#'   "output_format: html",
#'   "---",
#'   "Assume these lines are in report.qmd.",
#'   "```{r}",
#'   "targets::tar_read(data)",
#'   "```"
#' )
# In tar_dir(), not part of the user's file space:
#' writeLines(lines, "report.qmd")
#' # Include the report in a pipeline as follows.
#' targets::tar_script({
#'   library(tarchetypes)
#'   list(
#'     tar_target(data, data.frame(x = seq_len(26), y = letters)),
#'     tar_quarto(name = report, path = "report.qmd")
#'   )
#' }, ask = FALSE)
#' # Then, run the pipeline as usual.
#'
#' # Parameterized Quarto:
#' lines <- c(
#'   "---",
#'   "title: 'report.qmd source file with parameters'",
#'   "output_format: html_document",
#'   "params:",
#'   "  your_param: \"default value\"",
#'   "---",
#'   "Assume these lines are in report.qmd.",
#'   "```{r}",
#'   "print(params$your_param)",
#'   "```"
#' )
# In tar_dir(), not part of the user's file space:
#' writeLines(lines, "report.qmd")
#' # Include the report in the pipeline as follows.
#' unlink("_targets.R") # In tar_dir(), not the user's file space.
#' targets::tar_script({
#'   library(tarchetypes)
#'   list(
#'     tar_target(data, data.frame(x = seq_len(26), y = letters)),
#'     tar_quarto(
#'       name = report,
#'       path = "report.qmd",
#'       execute_params = list(your_param = data)
#'     ),
#'     tar_quarto_raw(
#'       name = "report2",
#'       path = "report.qmd",
#'       execute_params = quote(list(your_param = data))
#'     )
#'   )
#' }, ask = FALSE)
#' })
#' # Then, run the pipeline as usual.
#' }
tar_quarto <- function(
  name,
  path = ".",
  output_file = NULL,
  working_directory = NULL,
  extra_files = character(0),
  execute = TRUE,
  execute_params = list(),
  cache = NULL,
  cache_refresh = FALSE,
  debug = FALSE,
  quiet = TRUE,
  quarto_args = NULL,
  pandoc_args = NULL,
  profile = NULL,
  tidy_eval = targets::tar_option_get("tidy_eval"),
  packages = NULL,
  library = NULL,
  error = targets::tar_option_get("error"),
  memory = targets::tar_option_get("memory"),
  garbage_collection = targets::tar_option_get("garbage_collection"),
  deployment = targets::tar_option_get("deployment"),
  priority = targets::tar_option_get("priority"),
  resources = targets::tar_option_get("resources"),
  retrieval = targets::tar_option_get("retrieval"),
  cue = targets::tar_option_get("cue"),
  description = targets::tar_option_get("description")
) {
  name <- targets::tar_deparse_language(substitute(name))
  execute_params <- targets::tar_tidy_eval(
    substitute(execute_params),
    envir = tar_option_get("envir"),
    tidy_eval = tidy_eval
  )
  tar_quarto_raw(
    name = name,
    path = path,
    output_file = output_file,
    working_directory = working_directory,
    extra_files = extra_files,
    execute = execute,
    execute_params = execute_params,
    cache = cache,
    cache_refresh = cache_refresh,
    debug = debug,
    quiet = quiet,
    quarto_args = quarto_args,
    pandoc_args = pandoc_args,
    profile = profile,
    packages = packages,
    library = library,
    error = error,
    memory = memory,
    garbage_collection = garbage_collection,
    deployment = deployment,
    priority = priority,
    resources = resources,
    retrieval = retrieval,
    cue = cue,
    description = description
  )
}
