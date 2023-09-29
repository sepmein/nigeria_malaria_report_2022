routine <-
  "/Users/sepmein/Library/CloudStorage/OneDrive-SharedLibraries-WorldHealthOrganization/GMP-SIR\ -\ Country_Analytical_Support/Countries/NGA/WHO_NGA/NGA_2022_SNT/Final\ database\ for\ analysis/hflevel_14-21-fixed_outlier.csv"
routine_2021 <- "/Users/sepmein/Library/CloudStorage/OneDrive-SharedLibraries-WorldHealthOrganization/GMP-SIR\ -\ Country_Analytical_Support/Countries/NGA/WHO_NGA/NGA_2022_SNT/_Submitted_data/Routine\ data/NMEP\ 2021\ Routine\ Malaria\ Data_16042022.xlsx"

require(data.table)
require(readxl)
require(tidyverse)
require(ggplot2)

routine <- fread(routine)
routine |> names()

hf_routine_2021 <- read_excel(routine_2021, sheet="2021")
hf_routine_2021 |>
  select(orgunitlevel2, contains("ANC Attendance")) |>
  filter(orgunitlevel2 == "be Benue State") |>
  mutate(sum = rowSums(across(contains("ANC Attendance")), na.rm = TRUE)) |>
  arrange(-sum)

ipt_2021<- hf_routine_2021 |>
  rename(
    adm1 = orgunitlevel2,
    adm2 = orgunitlevel3,
    hf = organisationunitname
  ) |>
  mutate(
    year = lubridate::year(lubridate::ym(periodid)),
    month = lubridate::month(lubridate::ym(periodid)),
    anc_total = rowSums(across(contains("ANC Attendance")), na.rm = TRUE),
    adm1 = stringr::str_remove(adm1, "^\\w{2} "),
    adm1 = stringr::str_remove(adm1, " State"),
    adm1 = stringr::str_remove(adm1, " state"),
    adm1 = stringr::str_replace(adm1, "Akwa-Ibom", "Akwa Ibom"),
  ) |>
  mutate(
    `ANC Attendance â‰¥ 50yrs` = ifelse(`ANC Attendance â‰¥ 50yrs` == 266666625, 0, `ANC Attendance â‰¥ 50yrs`),
    `ANC Attendance 20 - 34yrs` = ifelse(`ANC Attendance 20 - 34yrs` == 106106, 80, `ANC Attendance 20 - 34yrs`),
    `ANC Attendance 35 - 49yrs` = ifelse(`ANC Attendance 35 - 49yrs` == 34444, 80, `ANC Attendance 35 - 49yrs`)
  ) |>
  select(
    adm1, adm2, hf, year, month, anc_total, IPT1p, IPT2p
  ) 

# filter some weird data
ipt_2021 <- ipt_2021 |> filter(
  !(hf == "be Yogbo Primary Health Centre" & year == 2021 & month == 4)
) |> filter(
  !(hf == "be Akpegede Primary Health Centre" & year == 2021 & month == 7)
)|> filter(
  !(hf == "be Akiraba Primary Health Centre" & year == 2021 & month == 8)
)|> filter(
  !(hf == "kn Zogarawa Health Post" & year == 2021 & month == 3)
)|> filter(
  !(hf == "kt Katsina Kofar Marusa Maternal and Child Health Clinic" & year == 2021 & month == 7)
)|> filter(
  !(hf == "kt Dallatu Primary Health Centre" & year == 2021 & month == 5)
)|> filter(
  !(hf == "be Mbagar Community Health Centre" & year == 2021 & month == 6)
)|> filter(
  !(hf == "ab Health Office Maternal And Child Health Center" & year == 2021 & month == 7)
)|> filter(
  !(hf == "za Yariman Bakura Specialist Hospital" & year == 2021 & month == 12)
)|> filter(
  !(hf == "kd Tashan Dogo Health Clinic" & year == 2021 & month == 6)
)|> filter(
  !(hf == "kn Hamdullahi Health Post" & year == 2021 & month == 10)
)|> filter(
  !(hf == "kn KunKurawa Health Post" & year == 2021 & month == 6)
)|> filter(
  !(hf == "kw Ajikobi Cottage Hospital" & year == 2021 & month == 5)
)|> filter(
  !(hf == "go Zaune Primary Health Care Center" & year == 2021 & month == 12)
)|> filter(
  !(hf == "kn Dawanau Psychiatric Hospital" & year == 2021 & month == 6)
)|> filter(
  !(hf == "kd Tsibiri Health Clinic" & year == 2021 & month == 8)
)|> filter(
  !(hf == "za Kasuwar Daji Primary HealthCare  Centre"& year == 2021 & month == 10)
)|> filter(
  !(hf == "kt Danmusa General Hospital" & year == 2021 & month == 10)
)|> filter(
  !(hf == "kn Tsaure Health Clinic" & year == 2021 & month == 10)
)|> filter(
  !(hf == "yo Fakali Primary Health Clinic" & year == 2021 & month == 2)
)|> filter(
  !(hf == "so Sokoto North Women and Child Welfare Clinic" & year == 2021 & month == 7)
)|> filter(
  !(hf == "bo Zuwa EYN Health Clinic" & year == 2021 & month == 6)
)|> filter(
  !(hf == "kn Gurjiya Health Clinic" & year == 2021 & month == 8)
)|> filter(
  !(hf == "im Federal Medical Centre (FMC)" & year == 2021 & month == 3)
)|> filter(
  !(hf == "kn Kantama Babba Health Post" & year == 2021 & month == 7)
)|> filter(
  !(hf == "za Yariman Bakura Specialist Hospital" & year == 2021 & month == 10)
)|> filter(
  !(hf == "eb Owutu Primary Health Center" & year == 2021 & month == 5)
)|> filter(
  !(hf == "ba Gambaki Primary Health Center" & year == 2021 & month == 11)
)|> filter(
  !(hf == "im Federal Medical Centre (FMC)")
)|> filter(
  !(hf == "kn Ja'En Primary Health Centre")
)|> filter(
  !(hf == "la Ikorodu General Hospital")
)|> filter(
  !(anc_total > 1000 & is.na(IPT1p))
)|> filter(
  !(anc_total > 1000 & is.na(IPT2p))
)|> filter(
  !(anc_total > 500 & IPT1p < 5)
)|> filter(
  !(anc_total > 500 & IPT2p < 5)
)|> filter(
  !(hf == "la Ikorodu General Hospital" & year == 2021 & month == 3)
)|> filter(
  !(hf == "yo Fakali Primary Health Clinic" & year == 2021 & month == 2)
)|> filter(
  !(hf == "ni Old Airport Road Clinic" & year == 2021 & month == 1)
)|> filter(
  !(hf == "go Malala Primary Health Care Centre" & year == 2021 & month == 1)
)|> filter(
  !(hf == "kn Burji Primary Heath Centre" & year == 2021 & month == 2)
)|> filter(
  !(hf == "kn Harbau Primary Health Centre" & year == 2021 & month == 5)
)|> filter(
  !(anc_total < 200 & IPT1p > 1000)
)|> filter(
  !(anc_total < 200 & IPT2p > 1000)
)|> filter(
  !(hf == "ba Soro Primary Health Centre" & year == 2021 & month == 8)
)|> filter(
  !(hf == "kn Gandu Primary Health Centre" & year == 2021 & month == 3)
)|> filter(
  !(hf == "ba Ardo Medicare Standard" & year == 2021 & month == 3)
)|> filter(
  !(hf == "ba Soro Primary Health Centre" & year == 2021 & month == 8)
)|> filter(
  !(hf == "an Oko II Primary Health Centre" & year == 2021 & month == 11)
)|> filter(
  !(hf == "ri Kpean Model Primary Health Center" & year == 2021 & month == 9)
)|> filter(
  !(hf == "ri KPOR PRIMARY HEALTH CENTER" & year == 2021 & month == 9)
)|> filter(
  !(hf == "kn Mohammed Abdullahi Wase General Hospital" & year == 2021 & month == 12)
)|> filter(
  !(hf == "la Ikate Primary Health Centre" & year == 2021 & month == 5)
)|> filter(
  !(hf == "ad Gangjari Health Post" & year == 2021 & month == 2)
)|> filter(
  !(hf == "cr Ijiman Health Post" & year == 2021 & month == 12)
)|> filter(
  !(hf == "be Imana-Ikobi Primary Health Centre" & year == 2021 & month == 5)
)|> filter(
  !(hf == "be Gbatse  Primary Health  Care Clinic" & year == 2021 & month == 11)
)|> filter(
  !(hf == "cr Ijiman Health Post" & year == 2021 & month == 12)
)|> filter(
  !(hf == "ko Ogegume Primary Health Centre" & year == 2021 & month == 7)
) |> filter(
  !(hf == "de Otu Jeremi General Hospital")
) |> filter(
  !(hf == "de Ehwerhe Government  Hospital")
)|> filter(
  !(hf == "de Government Hospital Ibusa")
)|> filter(
  !(hf == "de Owa-Alero Government Hospital")
)|> filter(
  !(hf == "de Government Hospital Okwe-Asaba")
) |> filter(
  !(hf == "en 82 Division Military Hospital")
)|> filter(
  !(hf == "ab POLICY CLINIC" & year == 2021 & month == 1)
)

ipt_2021 <- ipt_2021 |> filter(
  !(adm1 == "Delta" & anc_total > 300 & (is.na(IPT1p) | is.na(IPT2p)))
)

ipt_2021 |> 
  group_by(adm1, adm2, hf, year) |>
  mutate(anc_total_median = median(anc_total, na.rm = TRUE)) |> 
  filter((anc_total_median != 0 & anc_total > 50 * anc_total_median))

ipt_2021 |> 
  group_by(adm1, adm2, hf, year) |>
  mutate(ipt1_median = median(IPT1p, na.rm = TRUE)) |> 
  filter((ipt1_median != 0 & IPT1p > 50 * ipt1_median)) 
ipt_2021 |> 
  group_by(adm1, adm2, hf, year) |>
  mutate(ipt2_median = median(IPT2p, na.rm = TRUE)) |> 
  filter((ipt2_median != 0 & IPT2p > 50 * ipt2_median)) 

ipt_2021 |> 
  select(-month,-adm2, -hf) |>
  group_by(
    adm1, year
  ) |> 
  summarise_all(~ sum(., na.rm = TRUE)) |>
  filter(anc_total < IPT1p)

ipt_2021 |> 
  select(-month,-adm2, -hf) |>
  group_by(
    adm1, year
  ) |> 
  summarise_all(~ sum(., na.rm = TRUE)) |>
  filter(anc_total < IPT2p) 

ipt_2021 |> 
  select(-month,-adm2, -hf) |>
  group_by(
    adm1, year
  ) |> 
  summarise_all(~ sum(., na.rm = TRUE)) |>
  filter(IPT1p < IPT2p)

ipt_2021 |> 
  select(-month,-adm2, -hf) |>
  group_by(
    adm1, year
  ) |> 
  summarise_all(~ sum(., na.rm = TRUE)) |>
  mutate(
    ipt1_cov = IPT1p / anc_total,
    ipt2_cov = IPT2p / anc_total
  ) |>
  select(
    adm1, year, ipt1_cov,
    ipt2_cov
  ) 

ipt_2021 |> 
  select(-month) |>
  group_by(
  adm1, adm2, hf, year
) |> 
  summarise_all(~ sum(., na.rm = TRUE)) |>
  filter(anc_total < IPT1p) |> View()
  
ipt_2021 <- ipt_2021 |>
  select(-adm2, -hf, -month) |>
  group_by(adm1, year) |>
  summarise_all(~ sum(., na.rm = TRUE)) |>
  mutate(anc_total = ifelse(anc_total == 266957046, 
                            anc_total - 266666625,  anc_total)) |>
  mutate(
    ipt1_cov = IPT1p / anc_total,
    ipt2_cov = IPT2p / anc_total
  ) |>
  select(
    adm1, year, anc_total, ipt1_cov,
    ipt2_cov
  )

ipt_2021 <- ipt_2021 |> as.data.table()

# get only ipt from the routine database
ipt <-
  routine[, .(
    state,
    stateuid,
    lga,
    lgauid,
    facility_name,
    facilityuid,
    year,
    month,
    anc_total,
    ipt1,
    ipt2
  )]
ipt[, lapply(
  .SD, sum, na.rm = TRUE
), 
by = .(year),
.SDcols = c("anc_total", "ipt1", "ipt2")
]

ipt[,
  state := fifelse(state == "Cross-River", "Cross River", state)]
ipt[,
  state := fifelse(state == "FCT-Abuja", "Federal Capital Territory", state)]
ipt[,
  state := fifelse(state == "Akwa-Ibom", "Akwa Ibom", state)
  ]
# remove the lines with NAs in the anc_total or ipt1 or ipt1
ipt2 <- ipt[year < 2021][!is.na(anc_total) | !is.na(ipt1) | !is.na(ipt2)]
ipt2[, lapply(
  .SD, sum, na.rm = TRUE
), 
by = .(year),
.SDcols = c("anc_total", "ipt1", "ipt2")
]
# consistency checks
# 191891 / 586347 = 32%
ipt2[ipt1 < ipt2]
# ipt1 > anc_total
ipt2[ipt1 > anc_total]
# ipt2 > anc_total
ipt2[ipt2 > anc_total]

ipt3 <- ipt2[ipt1 < anc_total & ipt2 < anc_total]
ipt3[, lapply(
  .SD, sum, na.rm = TRUE
), 
by = .(state, year),
.SDcols = c("anc_total", "ipt1", "ipt2")
]

# outliers check

# very high anc_total, very low coverage rate
fix_11650 <- ipt3[year == 2018 & facilityuid == "L9mgsEyKcJy" & month != 7][, mean(anc_total)]
ipt3[, anc_total := fifelse(anc_total == 11650, fix_11650, anc_total)]

fix_6920 <- ipt3[year != 2020 & facilityuid == "CbnHYA6A5l8"][, mean(anc_total)]
ipt3[, anc_total := fifelse(anc_total == 6920, fix_6920, anc_total)]

fix_5784 <- ipt3[year == 2020 & facilityuid == "k0hYtd19hp6" & month != 1][, mean(anc_total)]
fix_5784
ipt3[, anc_total := fifelse(anc_total == 5784, fix_5784, anc_total)]

fix_9112 <- ipt3[year != 2017 & facilityuid == "tUgl6O5EPCI"][, mean(anc_total)]
fix_9112
ipt3[, anc_total := fifelse(anc_total == 9112, fix_9112, anc_total)]

fix_3816 <- ipt3[!(year == 2020 & month ==7)  & facilityuid == "uydTx1ZL8n5"][, mean(anc_total)]
fix_3816
ipt3[, anc_total := fifelse(anc_total == 3816 & facilityuid == "uydTx1ZL8n5", fix_3816, anc_total)]

fix_3816 <- ipt3[!(year == 2020 & month ==7)  & facilityuid == "uydTx1ZL8n5"][, mean(anc_total)]
fix_3816
ipt3[, anc_total := fifelse(anc_total == 3816 & facilityuid == "uydTx1ZL8n5", fix_3816, anc_total)]

fix_2011 <- ipt3[!(year == 2020 & month == 6)  & facilityuid == "lzvQXcqqafR"][, mean(anc_total)]
fix_2011
ipt3[, anc_total := fifelse(anc_total == 2011 & facilityuid == "lzvQXcqqafR", fix_2011, anc_total)]

fix_2 <- ipt3[!(year == 2014 & month == 5)  & facilityuid == "PKpbaKPq5kh"][, mean(ipt2)]
fix_2
ipt3[, ipt2 := fifelse(ipt2 == 2 & facilityuid == "PKpbaKPq5kh", fix_2, ipt2)]

# very low ipt2
ipt3 <- ipt3[!(facilityuid == "ymQxjhLIL12" & year == 2019 & month == 12)]
ipt3 <- ipt3[!(facilityuid == "u6wzgrpVyyi" & year == 2018 & month == 7)]
ipt3 <- ipt3[!(facilityuid == "u6wzgrpVyyi" & year == 2018 & month == 10)]
ipt3 <- ipt3[!(facilityuid == "vFBRav0l8R7" & year == 2018 & month == 6)]
ipt3 <- ipt3[!(facilityuid == "ymQxjhLIL12" & year == 2019 & month == 2)]
ipt3 <- ipt3[!(facilityuid == "ZvvXmvndVp9" & year == 2020 & month == 3)]
ipt3 <- ipt3[!(facilityuid == "ldkoEZvHjrH" & year == 2017 & month == 5)]
ipt3 <- ipt3[!(facilityuid == "vON6XO4nPvk" & year == 2017 & month == 4)]
ipt3 <- ipt3[!(facilityuid == "o85JYGltWtQ" & year == 2017 & month == 9)]
ipt3 <- ipt3[!(facilityuid == "b34IwqecZaA" & year == 2014 & month == 1)]
ipt3 <- ipt3[!(facilityuid == "CAJHBJiJOrA" & year == 2015 & month == 8)]
ipt3 <- ipt3[!(facilityuid == "MJcceQLOvy4" & year == 2015 & month == 11)]
ipt3 <- ipt3[!(facilityuid == "zWkM1q3aEaL" & year == 2016 & month == 11)]
ipt3 <- ipt3[!(facilityuid == "rb0EXschcyR" & year == 2016 & month == 9)]
ipt3 <- ipt3[!(facilityuid == "PVsVRInfoHE" & year == 2020 & month == 2)]
ipt3 <- ipt3[!(facilityuid == "PVsVRInfoHE" & year == 2020 & month == 6)]

ipt3 <- ipt3[!(state == "Cross-River" & year == 2020 & (ipt1 * 3 < ipt2))]
ipt3 <- ipt3[!(state == "Delta" & year == 2019 & (ipt1 * 3 < ipt2))]
ipt3 <- ipt3[!(state == "Katsina" & year == 2019 & (ipt1 * 3 < ipt2))]
ipt3 <- ipt3[!(state == "Yobe" & year == 2015 & (ipt1 * 1.5 < ipt2))]
ipt3 <- ipt3[!(state == "Yobe" & year == 2016 & (ipt1 * 1.5 < ipt2))]
ipt3 <- ipt3[!(state == "Yobe" & year == 2017 & (ipt1 * 2 < ipt2))]
ipt3 <- ipt3[!(state == "Yobe" & year == 2020 & (ipt2 - ipt1 > 500))]

ipt3[ipt1 > 500 & ipt2 < 10]
ipt3 <- ipt3[ipt1 * 5 > ipt2]
ipt4 <- ipt3[, lapply(.SD, sum, na.rm = TRUE), by = .(state, year), .SDcols = c("anc_total", "ipt1", "ipt2")]

nga_ipt <- ipt4[, .(adm1  = state, year, anc_total, ipt1_cov = ipt1/anc_total, ipt2_cov = ipt2/anc_total)]
nga_ipt[ipt1_cov < ipt2_cov]


nga_ipt <- data.table::rbindlist(list(nga_ipt, ipt_2021))

nga_ipt_national <- nga_ipt[, .(anc_total = sum(anc_total), ipt1 = sum(ipt1_cov * anc_total), ipt2 = sum(ipt2_cov * anc_total)), by = .(year)]
nga_ipt_national <- nga_ipt_national[, .(ipt1_cov = ipt1/ anc_total, ipt2_cov = ipt2/ anc_total), by = year]
nga_ipt_national <- nga_ipt_national |> melt(
  id.vars = c("year"),
  variable.name = "name"
)

nga_ipt <- nga_ipt[, .SD, .SDcols = -c("anc_total")] |> melt(
  id.vars = c("adm1", "year"),
  variable.name = "name"
)


nga_ipt |> fwrite("data/2023-06-27-nga_ipt.csv")
nga_ipt_national |> fwrite("data/2023-06-27-nga_national_ipt.csv")
