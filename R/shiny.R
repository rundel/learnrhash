#' @rdname learnr_elements
#' @name learnr_elements
#'
#' @title Learnr addon elements
#'
#' @description
#' The following are addon element for learnr tutorials that enable the encoding and
#' decoding of hashed learnr solutions.
#'
#' Note that when including these functions in a learnr Rmd document it is necessary that
#' the logic functions, `*_logic()`, be included in an R chunk where `context="server"` as
#' they interact with the underlying Shiny functionality. Conversely, any of the ui functions,
#' `*_ui()`, must *not* be included in an R chunk with a `context`. Both types of functions
#' have been written to provide useful feedback if they detect they are in the wrong R chunk
#' type.
#'
NULL

#' @rdname learnr_elements
#' @export
decoder_logic = function() {
  p = parent.frame()
  check_server_context(p)

  local({
    shiny::observeEvent(
      input$decode,
      {
        d = tibble::tibble(
          hash = input$decode_text
        )

        qu_tibble = learnrhash::extract_questions(d, .data$hash)
        output$decode_questions = shiny::renderText(learnrhash:::obj_to_text(qu_tibble))

        ex_tibble = learnrhash::extract_exercises(d, .data$hash)
        output$decode_exercises = shiny::renderText(learnrhash:::obj_to_text(ex_tibble))
      }
    )
  }, envir = p)
}

#' @rdname learnr_elements
#' @export
decoder_ui = function() {
  check_not_server_context(parent.frame())

  shiny::tags$div(
    shiny::textAreaInput("decode_text", "Hash to decode"),
    shiny::actionButton("decode", "Decode!"),
    shiny::tags$br(),
    shiny::tags$br(),
    shiny::tags$h4("Questions:"),
    wrapped_verbatim_text_output("decode_questions"),
    shiny::tags$br(),
    shiny::tags$h4("Exercises:"),
    wrapped_verbatim_text_output("decode_exercises")
  )
}

#' @rdname learnr_elements
#' @export
encoder_logic = function() {
  p = parent.frame()
  check_server_context(p)

  # Evaluate in parent frame to get input, output, and session
  local({
    encoded_txt = shiny::eventReactive(
      input$hash_generate,
      {
        objs = learnr:::get_all_state_objects(session)
        objs = learnr:::submissions_from_state_objects(objs)

        learnrhash::encode_obj(objs)
      }
    )

    output$hash_output = shiny::renderText(encoded_txt())


    shiny::observeEvent(input$hash_copy, {
      clipr::write_clip(encoded_txt(), allow_non_interactive = TRUE)
    })
  }, envir = p)
}

#' @rdname learnr_elements
#'
#' @param url Link url of the submission form being used.
#'
#' @export
encoder_ui = function(url = "http://localhost") {
  check_not_server_context(parent.frame())

  # TODO - allow this to be dynamic (text, tags, etc.)
  inst = paste(
    "If you have completed this tutorial and are happy with all of your",
    "solutions, please click the button below to generate your hash and",
    "submit it using the following link:"
  )

  shiny::tags$div(
    inst,
    shiny::tags$br(),
    shiny::tags$h3(
      shiny::tags$a(url, href=url, target="_blank")
    ),
    shiny::tags$br(),
    shiny::actionButton("hash_generate", "Generate Submission"),
    shiny::tags$br(),
    shiny::tags$br(),
    wrapped_verbatim_text_output("hash_output", TRUE),
    shiny::actionButton("hash_copy", "Copy")
  )
}

wrapped_verbatim_text_output = function(outputId, placeholder = FALSE) {
  x = shiny::verbatimTextOutput(outputId, placeholder)
  x$attribs$style = "white-space: pre-wrap;"

  x
}



is_server_context = function(.envir) {
  # We are in the server context if there are the follow:
  # * input - input reactive values
  # * output - shiny output
  # * session - shiny session
  #
  # Check context by examining the class of each of these.
  # If any is missing then it will be a NULL which will fail.

  inherits(.envir$input,   "reactivevalues") &
  inherits(.envir$output,  "shinyoutput")    &
  inherits(.envir$session, "ShinySession")
}

check_not_server_context = function(.envir) {
  if (is_server_context(.envir)) {
    calling_func = deparse(sys.calls()[[sys.nframe()-1]])

    err = paste0(
      "Function `", calling_func,"`",
      " must *not* be called from an Rmd chunk where `context = \"server\"`"
    )

    # The following seems to be necessary - since this is in the server context
    # it will not run at compile time
    shiny::stopApp()

    stop(err, call. = FALSE)
  }
}

check_server_context = function(.envir) {
  if (!is_server_context(.envir)) {
    calling_func = deparse(sys.calls()[[sys.nframe()-1]])

    err = paste0(
      "Function `", calling_func,"`",
      " must be called from an Rmd chunk where `context = \"server\"`"
    )

    stop(err, call. = FALSE)
  }
}

obj_to_text = function(obj) {
  text = utils::capture.output(print(obj))

  paste(text, collapse="\n")
}
