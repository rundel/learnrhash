#' @export
shiny_logic = function(input, output, session) {

  encoded_txt = shiny::eventReactive(
    input$hash_generate,
    {
      objs = learnr:::get_all_state_objects(session)
      objs = learnr:::submissions_from_state_objects(objs)

      encode_obj(objs)
    }
  )

  output$hash_output = shiny::renderText(encoded_txt())


  shiny::observeEvent(input$hash_copy, {
    clipr::write_clip(encoded_txt(), allow_non_interactive = TRUE)
  })
}

#' @export
shiny_hash_ui = function(inst=NULL, url=NULL) {

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
