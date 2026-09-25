# Midwest Airbnb Explorer, ISA 401 Assignment 05.
# querychat on midwest_airbnb.db plus a bslib layout: a Home tab that says
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
    "Ask me about", format(n_postings, big.mark = ","), "Airbnb listings in Chicago, Columbus, and the Twin Cities.",
    "Try: *Do superhosts charge more per night than other hosts? Show it as a bar chart.*"
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
  title    = "Midwest Airbnb Explorer",
  theme    = bs_theme(primary = "#1F5F8B", base_font = font_google("Source Sans 3")),
  navbar_options = navbar_options(bg = "#1F5F8B"),
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
            tags$li("Which Columbus neighbourhood has the priciest entire homes?"),
            tags$li("Do superhosts charge more per night than other hosts? Show it as a bar chart."),
            tags$li("How many listings could host a party of ten?")
          )
      )
    )
  ),
  
  # ---------- Home ----------
  nav_panel(
    title = "Home", value = "Home", icon = bsicons::bs_icon("house"),
    
    card(
      class = "text-white border-0",
      style = "background: linear-gradient(135deg, #1F5F8B 0%, #133D5A 100%);",
      card_body(
        class = "text-center py-5",
        h1("Midwest Airbnb Explorer", class = "display-5 fw-bold"),
        p(class = "lead mt-3 mb-2",
          "Ask questions about ", format(n_postings, big.mark = ","),
          " Airbnb listings in Chicago, Columbus, and the Twin Cities in plain English and get the SQL, the table, and a chart back."),
        p(class = "text-white-50 mb-4", "Built in ISA 401, Business Intelligence and Data Visualization, at Miami University"),
        actionButton("go_explorer", "Start Exploring", class = "btn btn-outline-light btn-lg px-4",
                     icon = icon("magnifying-glass"))
      )
    ),
    
    layout_column_wrap(
      width = 1 / 4, fill = FALSE,
      value_box(title = "Version", value = "1.0.0", showcase = bsicons::bs_icon("tag"), theme = "light"),
      value_box(title = "Last Updated", value = "Sep 2026", showcase = bsicons::bs_icon("calendar-check"), theme = "light"),
      value_box(title = "By", value = tags$span("Sebastian Asander", style = "font-size: 1em;"),
                p("Miami University"), showcase = bsicons::bs_icon("person"), theme = "light"),
      value_box(title = "Data", value = tags$span("Jul 20 to 23, 2026", style = "font-size: 1em;"),
                p(format(n_postings, big.mark = ","), " listings, ", format(n_companies, big.mark = ","), " hosts"),
                showcase = bsicons::bs_icon("house-door"), theme = "light")
    ),
    
    layout_columns(
      col_widths = c(6, 6), fill = FALSE,
      
      card(
        card_header(class = "fw-bold", bsicons::bs_icon("info-circle"), " About"),
        card_body(
          p("This app uses the ",
            a("querychat", href = "https://posit-dev.github.io/querychat/", target = "_blank"),
            " R package on Airbnb listings from ",
            a("Inside Airbnb", href = "https://insideairbnb.com/get-the-data/", target = "_blank"),
            ", using the July 2026 snapshots for Chicago (2026-07-20), Columbus (2026-07-23), ",
            "and the Twin Cities (2026-07-21). ",
            "An OpenAI model turns your question into SQL; SQLite runs it on the server. ",
            "The model sees only the column names, types, and ranges, never the rows."),
          hr(),
          h6(class = "fw-bold mb-2", "Developer"),
          div(class = "d-flex align-items-start gap-3",
              bsicons::bs_icon("person-circle", size = "2em"),
              div(
                div(class = "fw-semibold", "Sebastian Asander"),
                tags$small(class = "text-muted d-block", "Student, ISA 401"),
                tags$small(class = "text-muted d-block mb-2", "Miami University"),
                div(class = "d-flex flex-wrap gap-2",
                    link_btn("GitHub", "https://github.com/Asandeso", icon("github"))
                )
              )
          ),
          hr(),
          h6(class = "fw-bold mb-2", "Course and Data"),
          div(class = "d-flex flex-wrap gap-2",
              link_btn("Class 06 slides", "https://fmegahed.github.io/isa401/fall2026/class06/06_sqlite_deployed_app.html",
                       bsicons::bs_icon("easel"), class = "btn btn-outline-primary btn-sm"),
              link_btn("Inside Airbnb", "https://insideairbnb.com/get-the-data/",
                       bsicons::bs_icon("search"), class = "btn btn-outline-primary btn-sm")
          )
        )
      ),
      
      card(
        card_header(class = "fw-bold", bsicons::bs_icon("diagram-3"), " How a Question Becomes an Answer"),
        card_body(
          tags$ol(class = "mb-2",
                  tags$li(strong("You ask"), " in English, for example ", em("how many listings are in each city"), "."),
                  tags$li(strong("The model writes SQL"), " from the table's schema and the data dictionary, such as ",
                          code("SELECT city, COUNT(*) FROM listings GROUP BY city"), "."),
                  tags$li(strong("SQLite runs it"), " on this server. The rows never go to the model."),
                  tags$li(strong("You get"), " the table in the Explorer tab, the SQL under ", em("SQL behind the table"),
                          ", and a chart in the chat when you ask for one.")
          ),
          p(class = "text-muted small mb-0",
            "Read the SQL before you trust the answer. A question like \"which neighbourhood is priciest\" depends on ",
            "which column the model used and whether it averaged price per listing or per night.")
        )
      )
    )
  ),
  
  # ---------- Explorer ----------
  nav_panel(
    title = "Explorer", value = "Explorer", icon = bsicons::bs_icon("search"),
    
    layout_columns(
      fill = FALSE,
      value_box("Listings shown", textOutput("n_shown"),     theme = "light", height = "110px"),
      value_box("Superhosts",     textOutput("pct_remote"),  theme = "light", height = "110px"),
      value_box("Hosts",          textOutput("n_companies"), theme = "light", height = "110px"),
      value_box("Neighbourhoods", textOutput("n_states"),    theme = "light", height = "110px")
    ),
    card(
      full_screen = TRUE,
      card_header(textOutput("title")),
      DT::DTOutput("table")
    ),
    accordion(
      open = TRUE,
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
  
  output$title       = renderText(vals$title() %||% paste("All", format(n_postings, big.mark = ","), "listings"))
  output$sql         = renderText(vals$sql() %||% "SELECT * FROM listings")
  output$n_shown     = renderText(format(nrow(shown()), big.mark = ","))
  output$pct_remote  = renderText(
    if (nrow(shown()) == 0) "0%" else sprintf("%.0f%%", 100 * mean(shown()$host_is_superhost %in% c("t", "1", "TRUE"), na.rm = TRUE))
  )
  output$n_companies = renderText(format(length(unique(shown()$host_id)), big.mark = ","))
  output$n_states    = renderText(length(unique(na.omit(shown()$neighbourhood))))
  
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