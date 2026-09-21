# EWCS 2024 — availability / accessibility / uptake of
# flexible working, by gender and caregiving status

library(haven)
library(labelled)
library(dplyr)
library(ggplot2)
library(scales)
library(tidyr)


# 1. Data

ewcs_raw <- read_sav(
  "Data/Raw/ewcs24_dataset_ukda_v2.sav",
  encoding = "latin1"
)


# 2. Construct variables
#
# ACCESS (schedule control): wt_arrangements, "How are your working time arrangements
# set?" 1 = fixed by employer, no possibility for change;
# 2 = choose among employer-set fixed schedules; 3 = adapt hours
# within limits (e.g. flexitime); 4 = entirely self-determined.
# Coded here as "has some control over own schedule" (3 or 4) vs. not (1 or 2).
#
# ACCESS (short-notice time off): able_hour_off, "How easy
# or difficult is it to arrange to take an hour or two off
# during working hours for personal or family matters?"
# 1 = very easy … 4 = very difficult. Coded as "easy" (1 or 2).
#
# USAGE: loc_home, q29_d "How often have you worked from
# home in your main job?" 1 = always … 5 = never. 

ewcs <- ewcs_raw %>%
  mutate(
    ff_schedule_control = wt_arrangements %in% c(3, 4),
    ff_easy_time_off = able_hour_off %in% c(1, 2),
    ff_wfh_usage = loc_home %in% c(1, 2, 3),
    gender = as_factor(sex2),
    has_children = hh_nochilds == 0,
    country = as_factor(country),
    weight = calweight
  )

cat("N respondents:", nrow(ewcs), "\n")
cat("N with valid gender:", sum(!is.na(ewcs$gender)), "\n")
cat("Gender x children cross-tab (unweighted N):\n")
print(table(ewcs$gender, ewcs$has_children, useNA = "ifany"))

# 3. Descriptive deliverable: access (x2) / usage by gender x caregiving status (design-weighted)

summarise_by_group <- function(data, var, var_name) {
  data %>%
    filter(!is.na(.data[[var]]), !is.na(gender), !is.na(has_children)) %>%
    group_by(gender, has_children) %>%
    summarise(
      pct = weighted.mean(.data[[var]], w = weight, na.rm = TRUE) * 100,
      n = n(),
      .groups = "drop"
    ) %>%
    mutate(measure = var_name)
}

results <- bind_rows(
  summarise_by_group(ewcs, "ff_schedule_control", "Access: schedule control\n(wt_arrangements)"),
  summarise_by_group(ewcs, "ff_easy_time_off", "Access: ease of time off\n(able_hour_off)"),
  summarise_by_group(ewcs, "ff_wfh_usage", "Usage: works from home\n(loc_home)")
)

print(results)
write.csv(results, "Output/01_access_usage_by_gender_children.csv", row.names = FALSE)

# 4. Plot

results <- results %>%
  mutate(
    measure = factor(measure, levels = c(
      "Access: schedule control\n(wt_arrangements)",
      "Access: ease of time off\n(able_hour_off)",
      "Usage: works from home\n(loc_home)"
    )),
    group = paste(gender, ifelse(has_children, "with children", "no children"))
  )

p <- ggplot(results, aes(x = group, y = pct, fill = gender)) +
  geom_col(width = 0.65) +
  facet_wrap(~measure, nrow = 1) +
  labs(
    title = "Perceived access and actual usage of workplace flexibility,\nby gender and caregiving status",
    subtitle = "European Working Conditions Survey 2024 (n = 36,644, 35 countries) — design-weighted",
    x = NULL, y = "%",
    caption = paste0(
      "Source: Eurofound EWCS 2024 via UK Data Service (SN 9511). Weighted using calweight.\n",
      "EWCS surveys employees only (single-actor design) — all measures are employee-perceived access,\n",
      "not formal organisational availability. No organisation/team nesting (unlike the ESWS)."
    )
  ) +
  scale_y_continuous(labels = label_percent(scale = 1), limits = c(0, 100)) +
  theme_minimal(base_size = 11) +
  theme(
    axis.text.x = element_text(angle = 30, hjust = 1),
    legend.position = "none",
    strip.text = element_text(face = "bold")
  )

ggsave("Output/01_access_usage_by_gender_children.png", p, width = 10, height = 5.7, dpi = 300, bg = "white")
