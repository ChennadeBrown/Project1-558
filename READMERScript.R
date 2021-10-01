
rmarkdown:: render("Project 1.Rmd",
                   output_format = "github_document",
                   output_file = "README.md",
                   output_options = list(html_preview = FALSE, keep_html = FALSE, toc = TRUE, toc_depth = "1", df_print = "tibble"))



