#' @export
decoder_logic = function() {
  p = parent.frame()
  check_server_context(p)

  local({
    obj_txt = shiny::eventReactive(
      input$decode,
      {
        obj = learnrhash::decode_obj(input$decode_text)
        txt = capture.output(print(str(obj)))
        paste(txt, collapse="\n")
      }
    )

    output$decode_out = renderText(obj_txt())
  }, envir = p)
}

#' @export
decoder_ui = function() {
  check_not_server_context(parent.frame())

  shiny::tags$div(
    shiny::textAreaInput("decode_text", "Hash to decode"),
    shiny::actionButton("decode", "Decode!"),
    shiny::tags$br(),
    shiny::tags$br(),
    learnrhash:::wrapped_verbatim_text_output("decode_out")
  )
}

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

#' @export
encoder_ui = function(inst=NULL, url=NULL) {
  check_not_server_context(parent.frame())

  inst = paste(
    "If you have completed this learnr assignment and are happy with all of your",
    "solutions, please click the button below to generate your solution hash which",
    "you can submit at the following website:"
  )
  url = "http://localhost"

  shiny::tags$div(
    #shiny::tags$style(
    #  type='text/css',
    #  '#hash_output {white-space: pre-wrap;}'
    #),
    #style="align: center;",
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
