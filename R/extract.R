#' @importFrom dplyr "%>%"


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

# TODO - put in handling for a bad decode, either here or in the shiny bit

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

#' @export
extract_exercises = function(df, hash, include_output = FALSE) {
  d = df %>%
    extract_hash(hash) %>%
    dplyr::filter(type == "exercise_submission")


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
      tidyr::unnest_wider(data) %>%
      dplyr::select(-type) %>%
      dplyr::rename(exercise_id = id) %>%
      dplyr::relocate(
        exercise_id, code, output, feedback, checked, .after = dplyr::last_col()
      ) %>%
      dplyr::mutate(
        correct = purrr::map_lgl(feedback, "correct", .default = NA)
      )
  }

  if (!include_output)
    d = dplyr::select(d, -output)

  d
}

#' @export
extract_questions = function(df, hash, include_text = TRUE) {
  # TODO - Fix me if learnr PR accepted

  d = extract_hash(df, hash) %>%
    dplyr::filter(type == "question_submission")

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
      tidyr::unnest_wider(data) %>%
      dplyr::select(-type, -api_version) %>%
      dplyr::rename(
        question_id = id,
        question_text = question
      ) %>%
      dplyr::relocate(
        #question_id, question_text, answer, correct, .after = last_col()
        question_id, question_text, answer, .after = last_col()
      )
  }

  if (!include_text)
    d = dplyr::select(d, -question_text)

  d
}
