# This file contains functions to generate various plots related to malaria in Nigeria.
# The functions included are:
# - gen_plot_pop: generates a plot of population over time
# - gen_plot_estimated_cases: generates a plot of estimated malaria cases over time
# - gen_plot_estimated_incidence: generates a plot of estimated malaria incidence over time
# - gen_plot_rainfall: generates a boxplot of rainfall by month
# - gen_plot_prevalence: generates a plot of malaria prevalence over time
# 
# Each function takes a data frame as input and returns a ggplot object. The plot is saved as both a PNG and EPS file in the "result/plot" directory.
# 
# Required packages: ggplot2, cowplot, wesanderson


# plot pop
# 0.6 resize
# remove ylab, xlab, legend
# make sure legend is good
# make numbers good M -> 1 000 000 000
gen_plot_pop <- function(pop) {
  # pop <- tar_read(population_routine_raw)
  result <- pop |>
    select(year, pop) |>
    filter(year != 2022) |>
    mutate(year = as.factor(year)) |>
    ggplot(aes(year, pop)) +
    geom_line(
      colour = wes_palette("Darjeeling1", n = 5)[5],
      linewidth = 2,
      group = 1
    ) +
    geom_point(
      fill = "white",
      shape = 21,
      size = 3,
      stroke = 1,
      colour = wes_palette("Darjeeling1", n = 5)[5]
    ) +
    # labs(y = "Population") +
    scale_y_continuous(labels = label_number(accuracy = 1)) +
    scale_x_discrete(guide = guide_axis(check.overlap = TRUE)) +
    cowplot::theme_cowplot() +
    theme(
      plot.margin = unit(c(0, 0, 0, 0), "mm"),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
     legend.position = "none",
      axis.text = element_text(size = 6.6)
    )

  if ("adm1" %in% names(pop)) {
    filename <- pop$adm1 |> unique()
  } else {
    filename <- "National"
  }

  ggsave(
    filename = paste0(filename, " - 01 - pop", ".eps"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2 * 0.6,
    width = 6 * 0.6
  )
  ggsave(
    filename = paste0(filename, " - 01 - pop", ".png"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2 * 0.6,
    width = 6 * 0.6
  )
  return(result)
}

gen_plot_estimated_cases <- function(cases) {
  minimum_incidences <- min(cases$cases)
  min_incidences_y_lab <- minimum_incidences / 4
  result <- cases |>
    filter(year < 2022) |>
    filter(year > 2013) |>
    mutate(year = as.factor(year)) |>
    ggplot(aes(x = year, y = cases)) +
    geom_line(
      colour = wes_palette("Darjeeling1", n = 5)[4],
      linewidth = 2,
      group = 1
    ) +
    geom_point(
      fill = "white",
      shape = 21,
      size = 3,
      stroke = 1,
      colour = wes_palette("Darjeeling1", n = 5)[4]
    ) +
    # labs(y = "Estimated malaria cases") +
    scale_y_continuous(labels = label_number(accuracy = 1),
                       limits = c(min_incidences_y_lab, NA)) +
    cowplot::theme_cowplot() +
    theme(
      plot.margin = unit(c(0, 0, 0, 0), "mm"),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
     legend.position = "none",
      axis.text = element_text(size = 6.6)
    )
  
  if ("adm1" %in% names(cases)) {
    filename <- cases$adm1 |> unique()
  } else {
    filename <- "National"
  }

  ggsave(
    filename = paste0(filename, " - 02 - wmr_cases", ".eps"),
    plot = result,
    path = "result/plot",
    height = 2.4 * 0.6,
    width = 6 * 0.6
  )
  ggsave(
    filename = paste0(filename, " - 02 - wmr_cases", ".png"),
    plot = result,
    path = "result/plot",
    height = 2.4 * 0.6,
    width = 6 * 0.6
  )
  return(result)
}

gen_plot_estimated_incidence <- function(incid) {
  minimum_incidences <- min(incid$incidence_estimated_rmean)
  min_incidences_y_lab <- minimum_incidences / 4
  result <- incid |>
    select(year, incidence_estimated_rmean) |>
    filter(year < 2022) |>
    filter(year > 2013) |>
    mutate(year = as.factor(year)) |>
    ggplot(aes(x = year, y = incidence_estimated_rmean)) +
    geom_line(
      colour = wes_palette("Darjeeling1", n = 5)[3],
      linewidth = 2,
      group = 1
    ) +
    geom_point(
      fill = "white",
      shape = 21,
      size = 3,
      stroke = 1,
      colour = wes_palette("Darjeeling1", n = 5)[3]
    ) +
    # labs(y = "Estimated malaria incidence per 1000 population") +
    scale_y_continuous(labels = label_number(accuracy = 0.1),
                       limits = c(min_incidences_y_lab, NA)) +
    cowplot::theme_cowplot() +
    theme(
      plot.margin = unit(c(0, 0, 0, 7.6), "mm"),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
     legend.position = "none",
      axis.text = element_text(size = 6.6)
    )
  
  if ("adm1" %in% names(incid)) {
    filename <- incid$adm1 |> unique()
  } else {
    filename <- "National"
  }
  ggsave(
    filename = paste0(filename, " - 03 - wmr_incidence", ".eps"),
    plot = result,
    path = "result/plot",
    height = 2.4 * 0.6 ,
    width = 6 * 0.6
  )
  return(result)
}

gen_plot_rainfall <- function(rainfall) {
  result <- rainfall |>
    mutate(month = factor(month, labels = month.abb)) %>%
    ggplot(aes(month, rainfall, group = month)) +
    geom_boxplot(fill = wesanderson::wes_palette("Darjeeling1")[3]) +
    # labs(x = "Month", y = "Rainfall (mm)") +
    cowplot::theme_cowplot() +
    theme(
      plot.margin = unit(c(0, 0, 0, 6.3), "mm"),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
     legend.position = "none",
      axis.text = element_text(size = 6.6)
    )
  
  if ("adm1" %in% names(rainfall)) {
    filename <- rainfall$adm1 |> unique()
  } else {
    filename <- "National"
  }
  ggsave(
    filename = paste0(filename, " - 09 - rainfall", ".eps"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6 ,
    width = 6 * 0.6
  )
  return(result)
}

gen_plot_prevalence <- function(dhs) {
  prev_rdt_mic <- dhs |>
    filter(year != 2013) |>
    filter(year >= 2010) |>
    mutate(year = as.factor(year)) |>
    select(year, prevalence_rdt, prevalence_microscopy)
  
  result <- prev_rdt_mic |>
    pivot_longer(
      cols = c("prevalence_rdt",
               "prevalence_microscopy"),
      names_to = "index",
      values_to = "value"
    ) |>
    ggplot(aes(x = year)) +
    geom_bar(
      aes(fill = index,
          y = value),
      position = "dodge",
      group = "index",
      stat = "identity"
    ) +
    scale_fill_manual(
      labels = c("Microscopy",
                 "RDT"),
      values = wesanderson::wes_palette("Darjeeling1")[1:2]
    ) +
    scale_y_continuous(labels = scales::comma) +
    # labs(y = "Malaria prevalence in children under 5 years old") +
    cowplot::theme_cowplot() +
    theme(
      legend.title = element_blank(),
      plot.margin = unit(c(0, 0, 0, 8.6), "mm"),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
     legend.position = "none",
      axis.text = element_text(size = 6.6)
      
    )
  
  if ("adm1" %in% names(dhs)) {
    filename <- dhs$adm1 |> unique()
  } else {
    filename <- "National"
  }
  ggsave(
    filename = paste0(filename, " - 04 - prev", ".eps"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6 ,
    width = 6 * 0.6
  )
  ggsave(
    filename = paste0(filename, " - 04 - prev", ".png"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6 ,
    width = 6 * 0.6
  )
  return(result)
}

gen_plot_itn <- function(dhs) {
  itn_usage <- dhs |>
    mutate(year = as.factor(year)) |>
    select(year,
           population_slept_itn,
           u5_slept_itn,
           u5_slept_any_net,
           existing_itn_used)
  result <- itn_usage |>
    pivot_longer(
      cols = c(
        "population_slept_itn",
        "u5_slept_itn",
        "u5_slept_any_net",
        "existing_itn_used"
      ),
      names_to = "index",
      values_to = "value"
    ) |>
    arrange(year, index) |>
    ggplot(aes(x = year)) +
    geom_bar(
      aes(fill = index,
          y = value),
      position = "dodge",
      group = "index",
      stat = "identity"
    ) +
    scale_fill_manual(
      labels = c(
        "% of all existing ITN used",
        "Use of ITN (all age)",
        "Use of any net (children under 5)",
        "Use of ITN (children under 5)"
      ),
      values = wesanderson::wes_palette("Darjeeling1")[2:5]
    ) +
    scale_y_continuous(labels = scales::comma) +
    # labs(y = "Percentage of net usage") +
    cowplot::theme_cowplot() +
    theme(
      legend.title = element_blank(),
      plot.margin = unit(c(0, 0, 0, 8.9), "mm"),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
     legend.position = "none",
      axis.text = element_text(size = 6.6)
    )

  if ("adm1" %in% names(dhs)) {
    filename <- dhs$adm1 |> unique()
  } else {
    filename <- "National"
  }
  ggsave(
    filename = paste0(filename, " - 05 - itn_usage", ".eps"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6,
    width = 6 * 0.6
  )
  return(result)
}

gen_plot_fever <- function(dhs) {
  
  fever <- dhs |>
    filter(year >= 2013) |>
    mutate(year = as.factor(year)) |>
    select(year,
           advice_treatment_fever,
           children_fever_blood)

  result <- fever |>
    pivot_longer(
      cols = c("advice_treatment_fever",
               "children_fever_blood"),
      names_to = "index",
      values_to = "value"
    ) |>
    arrange(year, index) |>
    ggplot(aes(x = year)) +
    geom_bar(
      aes(fill = index,
          y = value),
      position = "dodge",
      group = "index",
      stat = "identity"
    ) +
    scale_fill_manual(
      labels = c("Treatment sought",
                 "Blood test done"),
      values = wesanderson::wes_palette("Darjeeling1")[3:4]
    ) +
    scale_y_continuous(labels = scales::comma) +
    # labs(y = "Percentage in children who had fever in last two weeks") +
    cowplot::theme_cowplot() +
    theme(
      legend.title = element_blank(),
      plot.margin = unit(c(0, 0, 0, 8.6), "mm"),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
     legend.position = "none",
      axis.text = element_text(size = 6.6)
    )

  if ("adm1" %in% names(dhs)) {
    filename <- dhs$adm1 |> unique()
  } else {
    filename <- "National"
  }
  ggsave(
    filename = paste0(filename, " - 06 - fever", ".eps"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6 ,
    width = 6  * 0.6
  )
  ggsave(
    filename = paste0(filename, " - 06 - fever", ".png"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6 ,
    width = 6  * 0.6
  )
  return(result)
}
# pl <- align_plots(plot1, plot2, align = "v")

gen_plot_llins <- function(llins) {
  browser()
  result <- llins |>
    mutate(year = as.factor(year)) |>
    ggplot(aes(x = year)) +
    geom_bar(aes(y = llins_num),
             stat = "identity", fill = "#469C89") +
    scale_y_continuous(labels = label_number(accuracy = 1)) +
    scale_fill_manual(
      labels = c("Number of LLINs distributed"),
      values = c("#469C89")
    ) +
    # labs(y = "Numbers of LLIns distributed") +
    cowplot::theme_cowplot() +
    theme(
      plot.margin = unit(c(0, 0, 0, 0), "mm"),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
     legend.position = "none",
      axis.text = element_text(size = 6.6)
      
    )
  
  if ("adm1" %in% names(llins)) {
    filename <- llins$adm1 |> unique()
  } else {
    filename <- "National"
  }
  ggsave(
    filename = paste0(filename, " - 11 - llins", ".eps"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6 ,
    width = 6 * 0.6
  )
  ggsave(
    filename = paste0(filename, " - 11 - llins", ".png"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6 ,
    width = 6 * 0.6
  )
  return(result)
}

gen_plot_smc <- function(smc) {
  result <- smc |>
    mutate(year = as.factor(year)) |>
    ggplot(aes(x = year)) +
    geom_bar(
      aes(fill = name,
          y = value),
      position = "dodge",
      group = "name",
      stat = "identity"
    ) +
    scale_fill_manual(
      labels = c("SMC_1",
                 "SMC_2",
                 "SMC_3",
                 "SMC_4"),
      values = wesanderson::wes_palette("Darjeeling1")[1:4]
    ) +
    scale_y_continuous(labels = label_number(accuracy = 1)) +
    # labs(y = "Number of SMC deliveries") +
    cowplot::theme_cowplot() +
    theme(
      legend.title = element_blank(),
      plot.margin = unit(c(0, 0, 0, 7.6), "mm"),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
     legend.position = "none",
      axis.text = element_text(size = 6.6)
      
    )
  
  if ("adm1" %in% names(smc)) {
    filename <- smc$adm1 |> unique()
  } else {
    filename <- "National"
  }
  ggsave(
    filename = paste0(filename, " - 10 - smc", ".eps"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6 ,
    width = 6 * 0.6
  )
  browser()
  ggsave(
    filename = paste0(filename, " - 10 - smc", ".png"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6 ,
    width = 6 * 0.6
  )
  return(result)
}

gen_plot_cum <- function(cumulative) {
  result <- cumulative |>
    filter(year < 2022) |>
    mutate(year = as.factor(year)) |>
    ggplot(aes(x = year,
               y = cumulative_cases_averted,
               group = 1)) +
    geom_line(
      colour = wes_palette("Darjeeling1", n = 5)[2],
      linewidth = 2,
      group = 1
    ) +
    geom_point(
      fill = "white",
      shape = 21,
      size = 3,
      stroke = 1,
      colour = wes_palette("Darjeeling1", n = 5)[2]
    ) +
    ylab("Cumulative Estimated Cases Averted") +
    scale_y_continuous(labels = label_number(accuracy = 1))  +
    scale_x_discrete(guide = guide_axis(check.overlap = TRUE)) +
    cowplot::theme_cowplot() +
    theme(
      legend.title = element_blank(),
      plot.margin = unit(c(0, 0, 0, 3.7), "mm"),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
     legend.position = "none",
      axis.text = element_text(size = 6.6)
      
    )
  
  if ("adm1" %in% names(cumulative)) {
    filename <- cumulative$adm1 |> unique()
  } else {
    filename <- "National"
  }
  ggsave(
    filename = paste0(filename, " - 12 - cases_averted", ".eps"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6 ,
    width = 6 * 0.6
  )
  return(result)
}

gen_plot_cum_deaths <- function(cumulative) {
  result <- cumulative |>
    filter(year < 2022) |>
    mutate(year = as.factor(year)) |>
    ggplot(aes(x = year,
               y = cumulative_deaths_averted,
               group = 1)) +
    geom_line(
      colour = wes_palette("Darjeeling1", n = 5)[1],
      linewidth = 2,
      group = 1
    ) +
    geom_point(
      fill = "white",
      shape = 21,
      size = 3,
      stroke = 1,
      colour = wes_palette("Darjeeling1", n = 5)[1]
    ) +
    ylab("Cumulative Estimated Deaths Averted") +
    scale_y_continuous(labels = label_number(accuracy = 1))  +
    scale_x_discrete(guide = guide_axis(check.overlap = TRUE)) +
    cowplot::theme_cowplot() +
    theme(
      legend.title = element_blank(),
      plot.margin = unit(c(0, 0, 0, 3.7), "mm"),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      legend.position = "none",
      axis.text = element_text(size = 6.6)
      
    )
  
  if ("adm1" %in% names(cumulative)) {
    filename <- cumulative$adm1 |> unique()
  } else {
    filename <- "National"
  }
  ggsave(
    filename = paste0(filename, " - 13 - deaths_averted", ".eps"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6 ,
    width = 6 * 0.6
  )
  ggsave(
    filename = paste0(filename, " - 13 - deaths_averted", ".png"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6 ,
    width = 6 * 0.6
  )
  return(result)
}


gen_plot_ipt <- function(ipt) {
  result <- ipt |>
    mutate(year = as.factor(year)) |>
    ggplot(aes(
      x = year,
      y = value * 100,
      group = name,
      color = name
    )) +
    geom_line(aes(linetype = name),
              # colour = wes_palette("Darjeeling1", n = 2),
              linewidth = 2, ) +
    geom_point(
      aes(shape = name),
      fill = "white",
      shape = 21,
      size = 3,
      stroke = 1
    ) +
    ylab("Percentage") +
    scale_y_continuous(labels = scales::comma, limits = c(0, NA) ) +
    scale_color_manual(values = wes_palette("Darjeeling1", n = 2))  +
    cowplot::theme_cowplot() +
    theme(
      legend.title = element_blank(),
      plot.margin = unit(c(0, 0, 0, 5.4), "mm"),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
     legend.position = "none",
      axis.text = element_text(size = 6.6)
    )
  
  if ("adm1" %in% names(ipt)) {
    filename <- ipt$adm1 |> unique()
  } else {
    filename <- "National"
  }
  ggsave(
    filename = paste0(filename, " - 08 - ipt_cov", ".eps"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6 ,
    width = 6 * 0.6
  )
  ggsave(
    filename = paste0(filename, " - 08 - ipt_cov", ".png"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6 ,
    width = 6 * 0.6
  )
  return(result)
}

#

#
# ## add map for each
# ## country
# district_only_map <- adm1_sf |>
#     mutate(target = if_else(State ==
#         district, TRUE, FALSE)) |>
#     tm_shape() + tm_polygons("target",
#         palette = c(
#             "#949393",
#             "#fb8039"
#         )
#     ) + tm_layout(legend.show = FALSE)
# tmap_save(
#     district_only_map,
#     o_plot_map(district)
# )

gen_plot_incidence_map <- function(data, shapefile) {
data <- data[, adm1:= toupper(adm1)][year == 2021]
  
  data$adm1 %in% shapefile$ADM1_NAME |> unique()
  data <- data[year == 2021][, adm1 := fifelse(adm1 =="FEDERAL CAPITAL TERRITORY", "FCT", adm1)][, incidence_estimated_rmean := incidence_estimated_rmean * 1000]
  data <- as_tibble(data)
  data_map <- shapefile |> left_join(data, by = c("ADM1_NAME" = "adm1")) |> st_as_sf()
  map <- data_map |>
    tm_shape() +
    tm_polygons("incidence_estimated_rmean", title = "Estimated incidence per 1,000 population in 2021")
  tmap_save(map, "result/plot_map_national_incidence.tiff")
  return(map)
}

gen_plot_prevalence_map <- function(data, shapefile) {
data <- data[, adm1:= toupper(adm1)][year == 2021]
  
  data$adm1 %in% shapefile$ADM1_NAME
  data <- data[year == 2021][, adm1 := fifelse(adm1 =="FEDERAL CAPITAL TERRITORY", "FCT", adm1)]
  data <- as.tibble(data)
  data_map <- shapefile |> left_join(data, by = c("ADM1_NAME" = "adm1")) |> st_as_sf()
  map <- data_map |>
    tm_shape() +
    tm_polygons("prevalence_rdt", title = "Malaria prevalence according to RDT in 2021",
                breaks = c(0,5,10,20,40,60,100)
                ) 
  tmap_save(map, "result/plot_map_national_prevalence.tiff")
  return(map)
}

gen_plot_deaths <- function(deaths) {
  minimum_deaths <- min(deaths$deaths)
  min_deaths_y_lab <- minimum_deaths / 4
  result <- deaths[, .(year = as.factor(year), deaths)] |>
    ggplot(aes(x = year, y = deaths)) +
    geom_line(
      colour = wes_palette("Darjeeling1", n = 5)[1],
      linewidth = 2,
      group = 1
    ) +
    geom_point(
      fill = "white",
      shape = 21,
      size = 3,
      stroke = 1,
      colour = wes_palette("Darjeeling1", n = 5)[1]
    ) +
    # labs(y = "Estimated malaria incidence per 1000 population") +
    scale_y_continuous(labels = label_number(accuracy = 1),
                       limits = c(min_deaths_y_lab, NA)) +
    cowplot::theme_cowplot() +
    theme(
      plot.margin = unit(c(0, 0, 0, 7.6), "mm"),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      legend.position = "none",
      axis.text = element_text(size = 6.6)
    )
  
  if ("adm1" %in% names(deaths)) {
    filename <- deaths$adm1 |> unique()
  } else {
    filename <- "National"
  }
  ggsave(
    filename = paste0(filename, " - 13 - deaths", ".eps"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6 ,
    width = 6 * 0.6
  )
  ggsave(
    filename = paste0(filename, " - 13 - deaths", ".png"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6 ,
    width = 6 * 0.6
  )
  return(result)
}

gen_plot_mortality <- function(mortality) {
  minimum_mortality <- min(mortality$mortality)
  min_mortality_y_lab <- minimum_mortality / 4
  result <- mortality[, .(year = as.factor(year), mortality)] |>
  ggplot(aes(x = year, y = mortality)) +
    geom_line(
      colour = wes_palette("Darjeeling1", n = 5)[1],
      linewidth = 2,
      group = 1
    ) +
    geom_point(
      fill = "white",
      shape = 21,
      size = 3,
      stroke = 1,
      colour = wes_palette("Darjeeling1", n = 5)[1]
    ) +
    # labs(y = "Estimated malaria incidence per 1000 population") +
    scale_y_continuous(labels = label_number(accuracy = 1),
                       limits = c(min_mortality_y_lab, 100)) +
    cowplot::theme_cowplot() +
    theme(
      plot.margin = unit(c(0, 0, 0, 7.6), "mm"),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      legend.position = "none",
      axis.text = element_text(size = 6.6)
    )
  
  if ("adm1" %in% names(mortality)) {
    filename <- mortality$adm1 |> unique()
  } else {
    filename <- "National"
  }
  ggsave(
    filename = paste0(filename, " - 13 - mortality", ".eps"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6 ,
    width = 6 * 0.6
  )
  ggsave(
    filename = paste0(filename, " - 13 - mortality", ".png"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6 ,
    width = 6 * 0.6
  )
  return(result)
}