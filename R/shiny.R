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
        output$decode_submissions = shiny::renderText(
          learnrhash:::obj_to_text(learnrhash::decode_obj(input$decode_text))
        )
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
    shiny::tags$h4("Submission:"),
    wrapped_verbatim_text_output("decode_submissions")
  )
}

#' @rdname learnr_elements
#'
#' @param strip_output Exercises save their output as html, for exercises
#' that result in plots these can result in very large hashes. The option allows
#' this information to be removed to keep hash sizes more manageable.
#'
#' @export
encoder_logic = function(strip_output = FALSE) {
  p = parent.frame()
  check_server_context(p)

  # Make this var available within the local context below
  assign("strip_output", strip_output, envir = p)


  # Evaluate in parent frame to get input, output, and session
  local({
    encoded_txt = shiny::eventReactive(
      input$hash_generate,
      {
        # shiny::getDefaultReactiveDomain()$userData$tutorial_state
        state = learnr:::get_tutorial_state()
        shiny::validate(shiny::need(length(state) > 0, "No progress yet."))

        user_state = purrr::map_dfr(state, identity, .id = "label")
        user_state = dplyr::group_by(user_state, .data$label, .data$type, .data$correct)
        user_state = dplyr::summarize(
          user_state,
          answer = list(.data$answer),
          timestamp = dplyr::first(.data$timestamp),
          .groups = "drop"
        )
        user_state = dplyr::relocate(user_state, .data$correct, .before = .data$timestamp)

        learnrhash::encode_obj(user_state)
      }
    )

    output$hash_output = shiny::renderText(encoded_txt())

  }, envir = p)
}

#' @rdname learnr_elements
#' @param url Link url to use.
#' @export
default_ui = function(url = "http://google.com") {
  shiny::div(
    "If you have completed this tutorial and are happy with all of your",
    "solutions, please click the button below to generate your hash and",
    "submit it using the following link:",
    shiny::tags$br(),
    shiny::tags$h3(
      shiny::tags$a(url, href=url, target="_blank")
    ),
    shiny::tags$br()
  )
}

#' @rdname learnr_elements
#' @param src Source of the iframe.
#' @param ... Other iframe attributes, e.g. height and width
#' @export
iframe_ui = function(src = "http://google.com", ...) {
  shiny::div(
    shiny::tags$iframe(src = src, ...),
    shiny::tags$br()
  )
}

#' @rdname learnr_elements
#'
#' @param ui_before Shiny ui elements to include before the hash ui
#' @param ui_after Shiny ui elements to include after the hash ui,
#'
#' @details For either of the ui parameters you can wrap multiple
#' shiny elements together with `shiny::div`.
#'
#' @export
encoder_ui = function(ui_before = default_ui(), ui_after = NULL) {
  check_not_server_context(parent.frame())

  shiny::tags$div(
    class = "encoder_ui",
    ui_before,
    shiny::fixedRow(
      shiny::column(
        width = 3,
        shiny::actionButton("hash_generate", "Generate", title = "Generate hash")
      ),
      shiny::column(width = 7),
      shiny::column(
        width = 2,
        shiny::tags$div(
          class = "btn-group btn-group-sm pull-right",
          role = "group",
          `aria-label` = "Clipboard buttons",

          shiny::tags$button(
            id="hash_select", class="btn btn-default", type="button",
            title = "Select hash",
            cursor_svg("16px")
          ),

          shiny::tags$span(class="btn-separator"),

          shiny::tags$button(
            id="hash_copy", class="btn btn-default", type="button",
            title = "Copy hash to clipboard",
            clipboard_svg("16px")
          )
        )
      ),
      style = "padding-bottom: 0.5em;"
    ),
    #shiny::tags$br(),
    wrapped_verbatim_text_output("hash_output", TRUE),
    shiny::tags$br(),
    ui_after,
    encoder_clipboard_js()
  )
}

cursor_svg = function(height) {
  shiny::HTML( paste0(
    '<svg
      aria-hidden="true" focusable="false"
      data-prefix="fas" data-icon="i-cursor"
      class="svg-inline--fa fa-i-cursor fa-w-8"
      role="img" xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 256 512"',
    ' style="height: ', height, ';"',
    '>
      <path fill="currentColor" d="M256 52.048V12.065C256 5.496 250.726.148 244.158.066 211.621-.344 166.469.011 128 37.959 90.266.736 46.979-.114 11.913.114 5.318.157 0 5.519 0 12.114v39.645c0 6.687 5.458 12.078 12.145 11.998C38.111 63.447 96 67.243 96 112.182V224H60c-6.627 0-12 5.373-12 12v40c0 6.627 5.373 12 12 12h36v112c0 44.932-56.075 48.031-83.95 47.959C5.404 447.942 0 453.306 0 459.952v39.983c0 6.569 5.274 11.917 11.842 11.999 32.537.409 77.689.054 116.158-37.894 37.734 37.223 81.021 38.073 116.087 37.845 6.595-.043 11.913-5.405 11.913-12V460.24c0-6.687-5.458-12.078-12.145-11.998C217.889 448.553 160 444.939 160 400V288h36c6.627 0 12-5.373 12-12v-40c0-6.627-5.373-12-12-12h-36V112.182c0-44.932 56.075-48.213 83.95-48.142 6.646.018 12.05-5.346 12.05-11.992z">
      </path>
    </svg>'
  ) )
}

clipboard_svg = function(height) {
  shiny::HTML( paste0(
    '<svg
      aria-hidden="true" focusable="false"
      data-prefix="far" data-icon="clipboard"
      class="svg-inline--fa fa-clipboard fa-w-12"
      role="img" xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 384 512"',
    ' style="height: ', height, ';"',
    '>
      <path fill="currentColor" d="M336 64h-80c0-35.3-28.7-64-64-64s-64 28.7-64 64H48C21.5 64 0 85.5 0 112v352c0 26.5 21.5 48 48 48h288c26.5 0 48-21.5 48-48V112c0-26.5-21.5-48-48-48zM192 40c13.3 0 24 10.7 24 24s-10.7 24-24 24-24-10.7-24-24 10.7-24 24-24zm144 418c0 3.3-2.7 6-6 6H54c-3.3 0-6-2.7-6-6V118c0-3.3 2.7-6 6-6h42v36c0 6.6 5.4 12 12 12h168c6.6 0 12-5.4 12-12v-36h42c3.3 0 6 2.7 6 6z">
      </path>
    </svg>'
  ) )
}


encoder_clipboard_js = function() {
  list(
    shiny::tags$script( shiny::HTML(
      "selectText = function(node) {
        node = document.getElementById(node);

        if (document.body.createTextRange) {
          const range = document.body.createTextRange();
          range.moveToElementText(node);
          range.select();
        } else if (window.getSelection) {
          const selection = window.getSelection();
          const range = document.createRange();
          range.selectNodeContents(node);
          selection.removeAllRanges();
          selection.addRange(range);
        } else {
          console.warn('Could not select text in node: Unsupported browser.');
        }
      }"
    ) ),

    shiny::tags$script( shiny::HTML(
      "document.getElementById('hash_select').addEventListener('click', function(e) {
        e.preventDefault();

        selectText('hash_output');
      });"
    ) ),

    shiny::tags$script( shiny::HTML(
      "document.getElementById('hash_copy').addEventListener('click', function(e) {
        e.preventDefault();

        selectText('hash_output');
        document.execCommand('copy');
      });"
    ) )
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
