#' @title Target with a Quarto project (raw version).
#' @export
#' @family Literate programming targets
#' @description Shorthand to include a Quarto project or standalone
#'   Quarto source document in a `targets` pipeline.
#' @details `tar_quarto_raw()` is just like [tar_quarto()]
#'   except that it uses standard evaluation for the
#'   `name` and `execute_params` arguments (instead of quoting them).
#' @return A target object with `format = "file"`.
#'   When this target runs, it returns a sorted character vector
#'   of all the important file paths: the rendered documents,
#'   the Quarto source files, and other input and output files.
#'   The output files are determined by the YAML front-matter of
#'   standalone Quarto documents and `_quarto.yml` in Quarto projects,
#'   and you can see these files with [tar_quarto_files()]
#'   (powered by `quarto::quarto_inspect()`).
#'   All returned paths are *relative* paths to ensure portability
#'   (so that the project can be moved from one file system to another
#'   without invalidating the target).
#'   See the "Target objects" section for background.
#' @inheritSection tar_map Target objects
#' @inheritSection tar_render Literate programming limitations
#' @inheritSection tar_quarto Quarto troubleshooting
#' @inheritParams targets::tar_target_raw
#' @inheritParams quarto::quarto_render
#' @inheritParams tar_render
#' @param path Character of length 1,
#'   either the single `*.qmd` source file to be rendered
#'   or a directory containing a Quarto project.
#'   Defaults to the working directory of the `targets` pipeline.
#'   Passed directly to the `input` argument of `quarto::quarto_render()`.
#' @param extra_files Character vector of extra files and
#'   directories to track for changes. The target will be invalidated
#'   (rerun on the next `tar_make()`) if the contents of these files changes.
#'   No need to include anything already in the output of [tar_quarto_files()],
#'   the list of file dependencies automatically detected through
#'   `quarto::quarto_inspect()`.
#' @param execute_params A non-expression language object
#'   (use `quote()`, not `expression()`) that
#'   evaluates to a named list of parameters
#'   for parameterized Quarto documents. These parameters override the custom
#'   custom elements of the `params` list in the YAML front-matter of the
#'   Quarto source files. The list is quoted
#'   (not evaluated until the target runs)
#'   so that upstream targets can serve as parameter values.
#' @param profile Character of length 1, Quarto profile. If `NULL`,
#'   the default profile will be used. Requires Quarto version 1.2 or higher.
#'   See <https://quarto.org/docs/projects/profiles.html> for details.
#' @param packages Deprecated on 2023-09-05 (version 0.7.8.9000). Please
#'   load R packages inside the Quarto report itself.
#' @param library Deprecated on 2023-09-05 (version 0.7.8.9000). Please
#'   load R packages inside the Quarto report itself.
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
#' # In tar_dir(), not part of the user's file space:
#' writeLines(lines, "report.qmd")
#' # Include the report in a pipeline as follows.
#' targets::tar_script({
#'   library(tarchetypes)
#'   list(
#'     tar_target(data, data.frame(x = seq_len(26), y = letters)),
#'     tar_quarto_raw("report", path = "report.qmd")
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
#' # In tar_dir(), not part of the user's file space:
#' writeLines(lines, "report.qmd")
#' # Include the report in the pipeline as follows.
#' targets::tar_script({
#'   library(tarchetypes)
#'   list(
#'     tar_target(data, data.frame(x = seq_len(26), y = letters)),
#'     tar_quarto_raw(
#'       "report",
#'       path = "report.qmd",
#'       execute_params = quote(list(your_param = data))
#'     )
#'   )
#' }, ask = FALSE)
#' # Then, run the pipeline as usual.
#' })
#' }
tar_quarto_raw <- function(
  name,
  path = ".",
  working_directory = NULL,
  extra_files = character(0),
  execute = TRUE,
  execute_params = NULL,
  cache = NULL,
  cache_refresh = FALSE,
  debug = FALSE,
  quiet = TRUE,
  quarto_args = NULL,
  pandoc_args = NULL,
  profile = NULL,
  packages = NULL,
  library = NULL,
  error = targets::tar_option_get("error"),
  memory = targets::tar_option_get("memory"),
  garbage_collection = targets::tar_option_get("garbage_collection"),
  deployment = "main",
  priority = targets::tar_option_get("priority"),
  resources = targets::tar_option_get("resources"),
  retrieval = targets::tar_option_get("retrieval"),
  cue = targets::tar_option_get("cue"),
  description = targets::tar_option_get("description")
) {
  assert_quarto()
  targets::tar_assert_scalar(name)
  targets::tar_assert_chr(name)
  targets::tar_assert_nzchar(name)
  targets::tar_assert_chr(extra_files)
  targets::tar_assert_nzchar(extra_files)
  targets::tar_assert_file(path)
  if (!is.null(working_directory)) {
    targets::tar_assert_file(working_directory)
  }
  targets::tar_assert_scalar(execute)
  targets::tar_assert_lgl(execute)
  targets::tar_assert_lang(execute_params %|||% quote(x))
  targets::tar_assert_not_expr(execute_params)
  targets::tar_assert_scalar(cache %|||% TRUE)
  targets::tar_assert_lgl(cache %|||% TRUE)
  targets::tar_assert_scalar(cache_refresh)
  targets::tar_assert_lgl(cache_refresh)
  targets::tar_assert_scalar(debug)
  targets::tar_assert_lgl(debug)
  targets::tar_assert_scalar(quiet)
  targets::tar_assert_lgl(quiet)
  targets::tar_assert_chr(quarto_args %|||% ".")
  targets::tar_assert_chr(pandoc_args %|||% ".")
  targets::tar_assert_scalar(profile %|||% ".")
  targets::tar_assert_chr(profile %|||% ".")
  targets::tar_assert_nzchar(profile %|||% ".")
  info <- tar_quarto_files(path = path, profile = profile)
  sources <- info$sources
  output <- info$output
  input <- sort(unique(c(info$input, extra_files)))
  if (!is.null(packages) || !is.null(library)) {
    targets::tar_warn_deprecate(
      "Arguments packages and library of tar_quarto() were ",
      "deprecated on 2023-09-05 (version 0.7.8.9000). Please ",
      "load R packages inside the Quarto report itself."
    )
  }
  command <- tar_quarto_command(
    path = path,
    working_directory = working_directory,
    sources = sources,
    output = output,
    input = input,
    execute = execute,
    execute_params = execute_params,
    cache = cache,
    cache_refresh = cache_refresh,
    debug = debug,
    quiet = quiet,
    quarto_args = quarto_args,
    pandoc_args = pandoc_args,
    profile = profile
  )
  targets::tar_target_raw(
    name = name,
    command = command,
    format = "file",
    repository = "local",
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

tar_quarto_command <- function(
  path,
  working_directory,
  sources,
  output,
  input,
  execute,
  execute_params,
  cache,
  cache_refresh,
  debug,
  quiet,
  quarto_args,
  pandoc_args,
  profile
) {
  args <- substitute(
    list(
      input = path,
      execute = execute,
      execute_params = execute_params,
      execute_dir = execute_dir,
      execute_daemon = 0,
      execute_daemon_restart = FALSE,
      execute_debug = FALSE,
      cache = cache,
      cache_refresh = cache_refresh,
      debug = debug,
      quiet = quiet,
      quarto_args = quarto_args,
      pandoc_args = pandoc_args,
      as_job = FALSE
    ),
    env = list(
      path = path,
      execute = execute,
      execute_dir = working_directory %|||% quote(getwd()),
      execute_params = execute_params,
      cache = cache,
      cache_refresh = cache_refresh,
      debug = debug,
      quiet = quiet,
      quarto_args = quarto_args,
      pandoc_args = pandoc_args
    )
  )
  deps <- sort(unique(unlist(map(sources, ~knitr_deps(.x)))))
  deps <- call_list(as_symbols(deps))
  fun <- call_ns("tarchetypes", "tar_quarto_run")
  expr <- list(
    fun,
    args = args,
    deps = deps,
    sources = sources,
    output = output,
    input = input,
    profile = profile
  )
  as.expression(as.call(expr))
}

#' @title Render a Quarto project inside a `tar_quarto()` target.
#' @description Internal function needed for `tar_quarto()`.
#'   Users should not invoke it directly.
#' @export
#' @keywords internal
#' @return Sorted character vector with the paths to all the important
#'   files that `targets` should track for changes.
#' @param args A named list of arguments to `quarto::quarto_render()`.
#' @param deps An unnamed list of target dependencies of the Quarto
#'   source files.
#' @param sources Character vector of Quarto source files.
#' @param output Character vector of Quarto output files and directories.
#' @param input Character vector of non-source Quarto input files
#'   and directories.
#' @param profile Quarto profile.
#' @examples
#' if (identical(Sys.getenv("TAR_LONG_EXAMPLES"), "true")) {
#' targets::tar_dir({  # tar_dir() runs code from a temporary directory.
#' # Unparameterized Quarto document:
#' lines <- c(
#'   "---",
#'   "title: Quarto source file",
#'   "output_format: html",
#'   "---",
#'   "Assume these lines are in the Quarto source file.",
#'   "```{r}",
#'   "1 + 1",
#'   "```"
#' )
#' tmp <- tempfile(fileext = ".qmd")
#' writeLines(lines, tmp)
#' args <- list(input = tmp, quiet = TRUE)
#' files <- fs::path_ext_set(tmp, "html")
#' tar_quarto_run(args = args, deps = list(), files = files)
#' file.exists(files)
#' })
#' }
tar_quarto_run <- function(args, deps, sources, output, input, profile) {
  rm(deps)
  gc()
  assert_quarto()
  if (!is.null(profile)) {
    withr::local_envvar(.new = c(QUARTO_PROFILE = profile))
  }
  args <- args[!map_lgl(args, is.null)]
  do.call(what = quarto::quarto_render, args = args)
  support <- sprintf("%s_files", fs::path_ext_remove(basename(args$input)))
  output <- if_any(dir.exists(support), unique(c(output, support)), output)
  out <- unique(c(sort(output), sort(sources), sort(input)))
  as.character(fs::path_rel(out))
}
