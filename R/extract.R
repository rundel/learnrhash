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
#' @param df A data frame containing the hashes
#' @param hash The name of the column containing the hashes
#'
NULL

fix_empty_state_obj = function(obj) {
  if (length(obj) == 0) {
    list(
      list(
        type = NA_character_,
        data = NULL,
        id = NA_character_
      )
    )
  } else {
    obj
  }
}

#' @rdname extract
#' @export
extract_hash = function(df, hash) {
  df %>%
    dplyr::rename(hash = {{hash}}) %>%
    dplyr::mutate(
      hash = lapply(hash, learnrhash::decode_obj)
    ) %>%
    tidyr::unnest(hash)
}

#' @rdname extract
#' @export
extract_exercises = function(df, hash) {
  extract_hash(df, hash) %>%
    dplyr::filter(type == "exercise")
}

#' @rdname extract
#' @export
extract_questions = function(df, hash) {
  extract_hash(df, hash) %>%
    dplyr::filter(type == "question")
}
