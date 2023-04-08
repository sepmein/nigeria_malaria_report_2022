#' template example:
#'  The {district} has a population of {population}
#' district example:
#'  c('Abbia State', 'Lagos State')
#' data example:
#'  data.frame(district = c('Abbia State', 'Lagos State'), population = c(100, 200))
generate_report <- function(template, data) {
  # loop through the list
  data |>
    glue_data(
      template,
      adm1 = adm1,
      population_2019 = label_number(accuracy = 0.1,
                                     scale_cut = cut_short_scale())(population_2019)
    )
}
