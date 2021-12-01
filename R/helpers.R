download_data <- function(url = "https://cricsheet.org/downloads/tests_json.zip", output_dir = NULL) {
  file_name <- basename(url)
  file_path <- here(output_dir, file_name)

  if(!file.exists(file_path)) {
    message("Downloading data file from ", url)
    download.file(url, file_path)
  } else{
    message("Data file already exists at: ", file_path)
    message("Delete file to redownload")
  }
  return(file_path)
}


clean_data <- function(data) {

  # Unnest overs detail
  overs <- data$innings %>%
    unnest(cols = overs) %>%
    unnest(cols = deliveries) %>%
    flatten(recursive = TRUE) %>%
    mutate(match_row_id = row_number(), .before = team)

  wickets <- overs %>%
    select(match_row_id, wickets) %>%
    unnest(cols = wickets) %>%
    rename_all( ~ paste0("wicket.", .x)) %>%
    rename_at(vars(contains("match_row_id")), ~ {
      "match_row_id"
    })

  fielders <- wickets %>%
    select(match_row_id, wicket.fielders) %>%
    unnest(cols = wicket.fielders) %>%
    rename(wicket.fielder = name)

  # Combine overs detail
  overs_full_detail <- overs %>%
    select(-wickets) %>%
    left_join(wickets, by = "match_row_id") %>%
    select(-wicket.fielders) %>%
    left_join(fielders, by = "match_row_id") %>%
    clean_names()

  # Prepare match info
  match_info <- data$info %>%
    unlist() %>%
    enframe() %>%
    pivot_wider(names_from = name, values_from = value) %>%
    # Drops out player info and officals info as doesn't cleanly sit in dataframe
    select(-starts_with("players"),
           -starts_with("registry"),
           -starts_with("officials")) %>%
    clean_names()

  # Create final data
  data.frame(
    match_info,
    overs_full_detail
  )
}
