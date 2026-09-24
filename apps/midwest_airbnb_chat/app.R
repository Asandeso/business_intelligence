# ISA 401 Job Scout Chat, reference Space for Assignment 05.
# The class app (querychat on midwest_airbnb.db) plus a bslib layout: a Home tab that says
# what the app is and who built it, and an Explorer tab where a question in
# English becomes SQL, a table, and (on request) a chart in the chat.
library(shiny)
library(bslib)
library(querychat)

# ---------------------------------------------------------------------------
# Data and querychat
# ---------------------------------------------------------------------------

con = DBI::dbConnect(RSQLite::SQLite(), "data/midwest_airbnb.db")

n_postings  = DBI::dbGetQuery(con, "SELECT COUNT(*) AS n FROM listings")$n
n_companies = DBI::dbGetQuery(con, "SELECT COUNT(DISTINCT host_id) AS n FROM listings")$n

client = ellmer::chat_openai(
  model  = "gpt-5.6-luna",
  params = ellmer::params(reasoning_effort = "none")
)

qc = querychat(
  con, "listings",
  client             = client,
  tools              = c("filter", "query", "visualize"),   # visualize: charts in the chat (ggsql)
  greeting           = paste(
    "Ask me about the", format(n_postings, big.mark = ","), "AirBnb postings collected.",
    "Try: *Which houses posted the most? Show it as a bar chart.*"
  ),
  data_description   = "data/data_desc.md",
  extra_instructions = "data/extra_instructions.md"
)

# ---------------------------------------------------------------------------
# UI
# ---------------------------------------------------------------------------

link_btn = function(label, href, icon, class = "btn btn-outline-secondary btn-sm") {
  tags$a(class = class, href = href, target = "_blank", icon, " ", label)
}

ui = page_navbar(
  id       = "navbar",
  title    = "ISA 401 Job Scout Chat",
  theme    = bs_theme(primary = "#C3142D", base_font = font_google("Lato")),
  navbar_options = navbar_options(bg = "#C3142D"),
  fillable = "Explorer",

  sidebar = sidebar(
    id = "sidebar", width = 420, fillable = TRUE,
    conditionalPanel("input.navbar == 'Explorer'", qc$ui()),
    conditionalPanel(
      "input.navbar == 'Home'",
      div(class = "p-2",
        h5("Welcome"),
        p("Open the ", strong("Explorer"), " tab and ask a question in plain English. ",
          "The model writes the SQL, the table updates, and you can read the query it ran."),
        hr(),
        p("Try asking:"),
        tags$ul(
          tags$li("Show the internship postings in Ohio."),
          tags$li("Which companies posted the most remote jobs? Show it as a bar chart."),
          tags$li("How many companies require R and data visualization?")
        )
      )
    )
  ),

  # ---------- Home ----------
  nav_panel(
    title = "Home", value = "Home", icon = bsicons::bs_icon("house"),

    card(
      class = "text-white border-0",
      style = "background: linear-gradient(135deg, #C3142D 0%, #8B0E20 100%);",
      card_body(
        class = "text-center py-5",
        h1("Job Scout Chat", class = "display-5 fw-bold"),
        p(class = "lead mt-3 mb-2",
          "Ask questions about ", format(n_postings, big.mark = ","),
          " job postings in plain English and get the SQL, the table, and a chart back."),
        p(class = "text-white-50 mb-4", "Built in ISA 401, Business Intelligence and Data Visualization, at Miami University"),
        actionButton("go_explorer", "Start Exploring", class = "btn btn-outline-light btn-lg px-4",
                     icon = icon("magnifying-glass"))
      )
    ),

    layout_column_wrap(
      width = 1 / 4, fill = FALSE,
      value_box(title = "Version", value = "0.2.0", showcase = bsicons::bs_icon("tag"), theme = "light"),
      value_box(title = "Last Updated", value = "Sep 2026", showcase = bsicons::bs_icon("calendar-check"), theme = "light"),
      value_box(title = "By", value = tags$span("Fadel M. Megahed", style = "font-size: 1em;"),
                p("Miami University"), showcase = bsicons::bs_icon("person"), theme = "light"),
      value_box(title = "Data", value = tags$span("Jul 29 to Aug 23, 2026", style = "font-size: 1em;"),
                p(format(n_postings, big.mark = ","), " postings, ", format(n_companies, big.mark = ","), " companies"),
                showcase = bsicons::bs_icon("briefcase"), theme = "light")
    ),

    layout_columns(
      col_widths = c(6, 6), fill = FALSE,

      card(
        card_header(class = "fw-bold", bsicons::bs_icon("info-circle"), " About"),
        card_body(
          p("This app uses the ",
            a("querychat", href = "https://posit-dev.github.io/querychat/", target = "_blank"),
            " R package on job postings that ",
            a("ChatISA Job Scout", href = "https://chatisa.fsb.miamioh.edu", target = "_blank"),
            " harvested from public job boards (ActiveJobs and USAJobs) between July 29 and August 23, 2026. ",
            "An OpenAI model turns your question into SQL; SQLite runs it on the server. ",
            "The model sees only the column names, types, and ranges, never the rows."),
          hr(),
          h6(class = "fw-bold mb-2", "Developer"),
          div(class = "d-flex align-items-start gap-3",
            bsicons::bs_icon("person-circle", size = "2em"),
            div(
              div(class = "fw-semibold", "Fadel M. Megahed"),
              tags$small(class = "text-muted d-block", "Raymond E. Glos Professor, Farmer School of Business"),
              tags$small(class = "text-muted d-block mb-2", "Miami University"),
              div(class = "d-flex flex-wrap gap-2",
                tags$a(class = "btn btn-outline-secondary btn-sm", href = "mailto:fmegahed@miamioh.edu",
                       bsicons::bs_icon("envelope"), " Email"),
                link_btn("LinkedIn", "https://www.linkedin.com/in/fadel-megahed-289046b4/", bsicons::bs_icon("linkedin")),
                link_btn("Website", "https://miamioh.edu/fsb/directory/?up=/directory/megahefm", bsicons::bs_icon("globe")),
                link_btn("GitHub", "https://github.com/fmegahed/", icon("github"))
              )
            )
          ),
          hr(),
          h6(class = "fw-bold mb-2", "Course and Data"),
          div(class = "d-flex flex-wrap gap-2",
            link_btn("Class 06 slides", "https://fmegahed.github.io/isa401/fall2026/class06/06_sqlite_deployed_app.html",
                     bsicons::bs_icon("easel"), class = "btn btn-outline-primary btn-sm"),
            link_btn("ChatISA Job Scout", "https://chatisa.fsb.miamioh.edu",
                     bsicons::bs_icon("search"), class = "btn btn-outline-primary btn-sm")
          )
        )
      ),

      card(
        card_header(class = "fw-bold", bsicons::bs_icon("diagram-3"), " How a Question Becomes an Answer"),
        card_body(
          tags$ol(class = "mb-2",
            tags$li(strong("You ask"), " in English, for example ", em("remote data analyst jobs in Ohio"), "."),
            tags$li(strong("The model writes SQL"), " from the table's schema and the data dictionary, such as ",
                    code("SELECT * FROM listings WHERE remote = 1 AND location_state = 'OH'"), "."),
            tags$li(strong("SQLite runs it"), " on this server. The rows never go to the model."),
            tags$li(strong("You get"), " the table in the Explorer tab, the SQL under ", em("SQL behind the table"),
                    ", and a chart in the chat when you ask for one.")
          ),
          p(class = "text-muted small mb-0",
            "Read the SQL before you trust the answer. A question like \"which companies require R\" depends on ",
            "which column the model searched and whether it counted companies or postings.")
        )
      )
    )
  ),

  # ---------- Explorer ----------
  nav_panel(
    title = "Explorer", value = "Explorer", icon = bsicons::bs_icon("search"),

    layout_columns(
      fill = FALSE,
      value_box("Postings shown", textOutput("n_shown"),     theme = "light", height = "110px"),
      value_box("Remote",         textOutput("pct_remote"),  theme = "light", height = "110px"),
      value_box("Companies",      textOutput("n_companies"), theme = "light", height = "110px"),
      value_box("States",         textOutput("n_states"),    theme = "light", height = "110px")
    ),
    card(
      full_screen = TRUE,
      card_header(textOutput("title")),
      DT::DTOutput("table")
    ),
    accordion(
      open = FALSE,
      accordion_panel("SQL behind the table", icon = bsicons::bs_icon("code-square"), verbatimTextOutput("sql"))
    )
  )
)

# ---------------------------------------------------------------------------
# Server
# ---------------------------------------------------------------------------

server = function(input, output, session) {
  vals  = qc$server()
  shown = reactive(vals$df())

  observeEvent(input$go_explorer, nav_select("navbar", "Explorer"))

  output$title       = renderText(vals$title() %||% paste("All", format(n_postings, big.mark = ","), "postings"))
  output$sql         = renderText(vals$sql() %||% "SELECT * FROM listings")
  output$n_shown     = renderText(format(nrow(shown()), big.mark = ","))
  output$pct_remote  = renderText(
    if (nrow(shown()) == 0) "0%" else sprintf("%.0f%%", 100 * mean(shown()$remote == 1, na.rm = TRUE))
  )
  output$n_companies = renderText(format(length(unique(shown()$company)), big.mark = ","))
  output$n_states    = renderText(length(unique(na.omit(shown()$location_state))))

  output$table = DT::renderDT(
    shown(),
    rownames = FALSE,
    plugins  = "ellipsis",
    options  = list(
      pageLength = 10, scrollX = TRUE,
      columnDefs = list(list(targets = "_all", render = DT::JS("$.fn.dataTable.render.ellipsis(60, false)")))
    )
  )
}

shinyApp(ui, server)
