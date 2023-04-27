# plot pop
# 0.6 resize
# remove ylab, xlab, legend
# make sure legend is good
# make numbers good M -> 1 000 000 000
gen_plot_pop <- function(pop) {
  # pop <- tar_read(population_routine_raw)
  result <- pop |>
    select(year, pop) |>
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
  
  ggsave(
    filename = paste0(pop$adm1 |> unique(), " - 01 - pop", ".eps"),
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
  
  ggsave(
    filename = paste0(cases$adm1 |> unique(), " - 02 - wmr_cases", ".eps"),
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
  
  ggsave(
    filename = paste0(incid$adm1 |> unique(), " - 03 - wmr_incidence", ".eps"),
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
  
  ggsave(
    filename = paste0(rainfall$adm1 |> unique(), " - 09 - rainfall", ".eps"),
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
  
  ggsave(
    filename = paste0(dhs$adm1 |> unique(), " - 04 - prev", ".eps"),
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
        "Anynet in under 5",
        "Existing ITN",
        "ITN in all age",
        "ITN in under 5"
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
  
  ggsave(
    filename = paste0(dhs$adm1 |> unique(), " - 05 - itn_usage", ".eps"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6 ,
    width = 6 * 0.6
  )
  return(result)
}

gen_plot_fever <- function(dhs) {
  fever <- dhs |>
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
    ggplot(aes(x = year)) +
    geom_bar(
      aes(fill = index,
          y = value),
      position = "dodge",
      group = "index",
      stat = "identity"
    ) +
    scale_fill_manual(
      labels = c("Blood taken",
                 "Treatment sought"),
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
  
  ggsave(
    filename = paste0(dhs$adm1 |> unique(), " - 06 - fever", ".eps"),
    plot = result,
    path = "result/plot",
    height = 1.8 * 2  * 0.6 ,
    width = 6  * 0.6
  )
  return(result)
}
# pl <- align_plots(plot1, plot2, align = "v")

gen_plot_llins <- function(llins) {
  result <- llins |>
    mutate(year = as.factor(year)) |>
    ggplot(aes(x = year)) +
    geom_bar(aes(y = llins_num),
             stat = "identity") +
    scale_y_continuous(labels = label_number(accuracy = 1)) +
    scale_fill_manual(
      labels = c("Number of LLINs distributed"),
      values = wesanderson::wes_palette("Darjeeling1")[4]
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
  
  ggsave(
    filename = paste0(llins$adm1 |> unique(), " - 11 - llins", ".eps"),
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
  
  ggsave(
    filename = paste0(smc$adm1 |> unique(), " - 10 - smc", ".eps"),
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
  
  ggsave(
    filename = paste0(cumulative$adm1 |> unique(), " - 12 - cases_averted", ".eps"),
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
    scale_y_continuous(labels = scales::comma) +
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
  
  ggsave(
    filename = paste0(ipt$adm1 |> unique(), " - 08 - ipt_cov", ".eps"),
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