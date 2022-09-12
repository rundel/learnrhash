#' @rdname extract
#' @name extract
#'
#' @title Extract hash contents
#'
#' @description
#' The following are helper functions for extracting data from hashed learnr solutions.
#'
#' * `extract_hash` - extracts the contents of the hashes into label, type, answer, correct, and timestamp columns
#'
#' * `extract_questions` - extracts the contents of the hashes for answered questions.
#'
#' * `extract_exercises` - extracts the contents of the hashes for answered exercises.
#'
#' @param df Data Frame. A data frame containing hash in a character column.
#' @param hash Character. The name of the column containing the hashes
#'
NULL

fix_empty_state_obj = function(obj) {
  if (length(obj) == 0) {
    list(
      list(
        id = NA_character_,
        type = NA_character_,
        data = NULL
      )
    )
  } else {
    obj
  }
}

#' @rdname extract
#' @export
extract_hash = function(df, hash = "hash") {
  d = df %>%
    dplyr::rename(hash = .data[[hash]]) %>%
    dplyr::mutate(
      hash = lapply(.data[[hash]], learnrhash::decode_obj),
      hash = lapply(.data[[hash]], fix_empty_state_obj)
    ) %>%
    tidyr::unnest_longer(.data[[hash]]) %>%
    tidyr::unnest_wider(.data[[hash]]) %>%
    dplyr::relocate(.data[["data"]], .before="type")

  if (is.null(d[["data"]]))
    d$data = list(NULL)

  d
}

#' @rdname extract
#' @export
extract_exercises = function(df, hash = "hash") {
  extract_hash(df, hash) %>%
    dplyr::filter(startsWith(.data[["type"]], "exercise"))
}

#' @rdname extract
#' @export
extract_questions = function(df, hash = "hash") {
  extract_hash(df, hash) %>%
    dplyr::filter(startsWith(.data[["type"]], "question"))
}
