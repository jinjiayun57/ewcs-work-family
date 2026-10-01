# EWCS 2024: schedule control, ease of taking time off and working from
# home, by gender and presence of children

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
# SCHEDULE CONTROL (proxy for access to time flexibility):
# wt_arrangements, q44 "How are your working time arrangements set?"
# 1 = set by the organisation, no possibility for change;
# 2 = choose between several fixed schedules set by the organisation;
# 3 = adapt hours within certain limits (e.g. flexitime);
# 4 = entirely determined by yourself.
# Coded as "some control" (3 or 4) vs. not (1 or 2).
#
# PERCEIVED ACCESSIBILITY (ad hoc time off): able_hour_off, q52
# "How easy or difficult is it for you to arrange to take an hour or two
# off during working hours to attend to personal or family matters?"
# 1 = very easy, 2 = fairly easy, 3 = fairly difficult, 4 = very difficult.
#
# WFH USAGE (place flexibility): loc_home, q29_d "How often have you
# worked in your own home in your main job?"
# 1 = always, 2 = often, 3 = sometimes, 4 = rarely, 5 = never.
#
# SAMPLE: employees only (employee_selfdeclared == 1). Self-employed
# respondents are excluded because employer-provided flexibility does
# not apply to them.

ewcs <- ewcs_raw %>%
  filter(employee_selfdeclared == 1) %>%
  mutate(
    ff_schedule_control = wt_arrangements %in% c(3, 4),
    ff_easy_time_off = able_hour_off %in% c(1, 2),
    ff_wfh_usage = loc_home %in% c(1, 2, 3),
    gender = as_factor(sex2),
    has_children = hh_nochilds == 0,
    country = as_factor(country),
    weight = calweight
  )


# 3. Weighted percentages by gender x presence of children

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

labels <- c(
  "Schedule control\n(wt_arrangements)",
  "Ease of taking time off\n(able_hour_off)",
  "Works from home\n(loc_home)"
)

results <- bind_rows(
  summarise_by_group(ewcs, "ff_schedule_control", labels[1]),
  summarise_by_group(ewcs, "ff_easy_time_off",    labels[2]),
  summarise_by_group(ewcs, "ff_wfh_usage",        labels[3])
)

print(results)
write.csv(results, "Output/01_flexibility_by_gender_children.csv", row.names = FALSE)

# 4. Plot

plot_df <- results %>%
  mutate(
    measure = factor(measure, levels = labels),
    children = factor(
      ifelse(has_children, "With children", "No children"),
      levels = c("No children", "With children")
    ),
    gender = factor(gender, levels = c("Female", "Male"))
  )

p <- ggplot(plot_df, aes(x = children, y = pct, fill = gender)) +
  geom_col(position = position_dodge(width = 0.75), width = 0.7) +
  geom_text(
    aes(label = sprintf("%.0f%%", pct)),
    position = position_dodge(width = 0.75),
    vjust = -0.4, size = 3.2
  ) +
  facet_wrap(~measure, nrow = 1) +
  scale_fill_manual(values = c(Female = "#C0504D", Male = "#4F81BD")) +
  scale_y_continuous(
    labels = label_percent(scale = 1),
    limits = c(0, 100),
    expand = expansion(mult = c(0, 0.02))
  ) +
  labs(
    title = "Schedule control, ease of taking time off and working from home,\nby gender and presence of children",
    subtitle = paste0(
      "European Working Conditions Survey 2024, employees (n = ",
      format(nrow(ewcs), big.mark = ","), ", 35 countries), weighted"
    ),
    x = NULL, y = NULL, fill = NULL,
    caption = paste0(
      "Source: Eurofound EWCS 2024 via UK Data Service (SN 9511). Weighted using calweight.\n",
      "Measures are self-reported. EWCS has no employer or HR respondent, so formal organisational provision is not observed."
    )
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position = "top",
    legend.justification = "left",
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    strip.text = element_text(face = "bold"),
    plot.caption = element_text(hjust = 0, colour = "grey40"),
    plot.title.position = "plot",
    plot.caption.position = "plot"
  )

ggsave("Output/01_flexibility_by_gender_children.png", p,
       width = 10, height = 5.7, dpi = 300, bg = "white")
