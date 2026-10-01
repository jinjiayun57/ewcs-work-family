# Script 01 showed that women report less schedule control and less ease of
# taking time off than men, but slightly more working from home.
# This script asks whether the association between WFH frequency and
# work-family conflict differs by schedule control and gender.
#
# Sample: employees only (the `ewcs` data frame created in script 01).

# 1. WFC composite

# Items q48a-d (wlb_worry, wlb_tired, wlb_timefamily, wlb_concentrate),
# 1 = always ... 5 = never. -991 ("does not apply / no family
# responsibilities") is set to missing together with DK (-999) and
# refused (-998), so these respondents are excluded from the composite
# rather than treated as reporting no conflict.

clean_wlb <- function(x){
  x <- as.numeric(x)
  x[x %in% c(-999, -998, -991)] <- NA
  x
}

ewcs <- ewcs %>%
  mutate(
    w1 = clean_wlb(wlb_worry),
    w2 = clean_wlb(wlb_tired),
    w3 = clean_wlb(wlb_timefamily),
    w4 = clean_wlb(wlb_concentrate)
  )

# reverse-code (1=Always...5=Never -> higher = more conflict) and average
ewcs <- ewcs %>%
  mutate(
    wfc = ifelse(
      !is.na(w1) & !is.na(w2) & !is.na(w3) & !is.na(w4),
      rowMeans(cbind(6 - w1, 6 - w2, 6 - w3, 6 - w4)),
      NA_real_
    )
  )
# 2. Schedule control, WFH frequency, gender
#
# Schedule control (wt_arrangements, q44):
#   High = adapt hours within limits or entirely self-determined (3, 4)
#   Low  = set by the organisation, or chosen from fixed schedules (1, 2)
# WFH frequency (loc_home, q29_d):
#   Never (5), Rarely/sometimes (3, 4), Often/always (1, 2)

ewcs <- ewcs %>%
  mutate(
    schedule_control = ifelse(wt_arrangements %in% c(3, 4), "High",
                              ifelse(wt_arrangements %in% c(1, 2), "Low", NA)),
    schedule_control = factor(schedule_control, levels = c("Low", "High")),
    wfh_freq = case_when(
      loc_home == 5 ~ "Never",
      loc_home %in% c(3, 4) ~ "Rarely/\nsometimes",
      loc_home %in% c(1, 2) ~ "Often/\nalways",
      TRUE ~ NA_character_
    ),
    wfh_freq = factor(wfh_freq, levels = c("Never", "Rarely/\nsometimes", "Often/\nalways")),
    gender = as_factor(sex2),
    weight = calweight
  )

# 3. Weighted mean WFC by WFH frequency x schedule control x gender,
#    with an approximate weighted SE (Kish effective sample size)

weighted_se <- function(x, w) {
  wm <- weighted.mean(x, w)
  n_eff <- (sum(w)^2) / sum(w^2)  # Kish effective sample size
  wvar <- sum(w * (x - wm)^2) / sum(w)
  sqrt(wvar / n_eff)
}


summary_df <- ewcs %>%
  filter(!is.na(wfc), !is.na(schedule_control), !is.na(wfh_freq), !is.na(gender)) %>%
  group_by(gender, schedule_control, wfh_freq) %>%
  summarise(
    mean_wfc = weighted.mean(wfc, weight),
    se_wfc = weighted_se(wfc, weight),
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(
    lower = mean_wfc - 1.96 * se_wfc,
    upper = mean_wfc + 1.96 * se_wfc
  )

# 4. Plot

schedule_control_labels <- c(
  Low  = "Low schedule control\n(set by employer or fixed options)",
  High = "Some schedule control\n(flexitime or self-determined)"
)

n_plot <- sum(summary_df$n)
y_range <- c(floor(min(summary_df$lower) * 10) / 10,
             ceiling(max(summary_df$upper) * 10) / 10)

p <- ggplot(summary_df, aes(x = wfh_freq, y = mean_wfc, group = 1)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "#2f6a5c", alpha = 0.15) +
  geom_line(color = "#2f6a5c", linewidth = 0.9) +
  geom_point(color = "#2f6a5c", size = 2.2) +
  facet_grid(gender ~ schedule_control, labeller = labeller(schedule_control = schedule_control_labels)) +
  labs(
    title = "Work-family conflict by WFH frequency, schedule control and gender",
    subtitle = paste0(
      "EWCS 2024, employees (n = ", format(n_plot, big.mark = ","),
      "). Weighted means with approximate 95% CI"
    ),
    x = NULL, y = "Work-family conflict\n(1 = low ... 5 = high)",
    caption = paste0(
      "Source: Eurofound EWCS 2024 via UK Data Service (SN 9511). Weighted using calweight.\n",
      "WFC = mean of four reverse-coded items (q48a-d); employees for whom the items do not apply are excluded.\n",
      "Schedule control = q44 (wt_arrangements). CIs use an approximate weighted SE (Kish effective n), ",
      "not a full design-based SE.\n",
      "The y-axis shows ", y_range[1], " to ", y_range[2], " of the 1-5 scale; cell means range from ",
      sprintf("%.2f", min(summary_df$mean_wfc)), " to ", sprintf("%.2f", max(summary_df$mean_wfc)), "."
    )
  ) +
  coord_cartesian(ylim = y_range) +
  theme_minimal(base_size = 11) +
  theme(
    strip.text = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    plot.title.position = "plot",
    plot.caption.position = "plot",
    plot.caption = element_text(hjust = 0, size = 7.5, color = "grey40")
  )

# 5. Save outputs

write.csv(summary_df, "Output/02_wfc_by_wfh_sc_gender.csv", row.names = FALSE)
ggsave("Output/02_wfc_by_wfh_sc_gender_zoomed.png", p, width = 8.5, height = 7, dpi = 300, bg = "white")
