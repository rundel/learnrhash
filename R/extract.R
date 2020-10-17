#' @rdname extract
#' @name extract
#'
#' @title Extract hash contents
#'
#' @description
#' The following are helper functions for extracting data from hashed learnr solutions.
#'
#' * `extract_hash` - extracts the contents of the hashes into a list column.
#'
#' * `extract_questions` - extracts the contents of the hashes and expands answered questions.
#'
#' * `extract_exercises` - extracts the contents of the hashes and expands answered exercises.
#'
#' @param df A data frame containing the hashes
#' @param hash The name of the column containing the hashes
#' @param include_output Logical. Should the exercises' code output be included.
#' @param include_text Logical. Should the questions' text be included.
#'
#' @importFrom rlang .data
#' @importFrom dplyr `%>%`
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
      hash = lapply(hash, learnrhash::decode_obj),
      hash = lapply(hash, fix_empty_state_obj)
    ) %>%
    tidyr::unnest_longer(hash) %>%
    tidyr::unnest_wider(hash,)
}

#' @rdname extract
#' @export
extract_exercises = function(df, hash, include_output = FALSE) {
  d = df %>%
    extract_hash(hash) %>%
    dplyr::filter(.data$type == "exercise_submission")


  if (nrow(d) == 0) {
    # Since we don't know the other column names we need to do this
    d = d %>%
      dplyr::select(-dplyr::any_of(c("type", "data", "id"))) %>%
      dplyr::mutate(
        exercise_id = character(),
        code = character(),
        output = list(),
        feedback = list(),
        checked = logical(),
        correct = logical()
      )
  } else {
    d = d %>%
      tidyr::hoist( # list columns
        "data", "output", "feedback", .simplify = FALSE
      ) %>%
      tidyr::hoist( # vector columns
        "data", "code", "checked"
      ) %>%
      dplyr::select(-.data$type) %>%
      dplyr::rename(exercise_id = .data$id) %>%
      dplyr::relocate(
        .data$exercise_id, .data$code, .data$output,
        .data$feedback, .data$checked,
        .after = dplyr::last_col()
      ) %>%
      dplyr::mutate(
        correct = purrr::map_lgl(.data$feedback, "correct", .default = NA)
      )
  }

  if (!include_output)
    d = dplyr::select(d, -.data$output)

  d
}

#' @rdname extract
#' @export
extract_questions = function(df, hash, include_text = TRUE) {
  # TODO - Fix me if learnr PR accepted

  d = extract_hash(df, hash) %>%
    dplyr::filter(.data$type == "question_submission")

  if (nrow(d) == 0) {
    # Since we don't know the other column names we need to do this
    d = d %>%
      dplyr::select(-dplyr::any_of(c("type", "data", "id"))) %>%
      dplyr::mutate(
        question_id = character(),
        question_text = character(),
        answer = list()
        #correct = logical()
      )
  } else {
    d = d %>%
      tidyr::unnest_wider(.data$data) %>%
      dplyr::select(-.data$type, -.data$api_version) %>%
      dplyr::rename(
        question_id = .data$id,
        question_text = .data$question
      ) %>%
      dplyr::relocate(
        #question_id, question_text, answer, correct, .after = last_col()
        .data$question_id, .data$question_text, .data$answer,
        .after = dplyr::last_col()
      )
  }

  if (!include_text)
    d = dplyr::select(d, -.data$question_text)

  d
}
