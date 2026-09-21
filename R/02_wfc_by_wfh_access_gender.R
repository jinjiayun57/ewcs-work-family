# In the previous script, we see a gender gap (access lower, usage higher for women).
# This script asks: is the access/usage-WFC relationship itself gendered? 

# 1. WFC composite

# Note: -991 is a real substantive category, not the same as DK/Refused

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
# 2. Build access (focused on wt_arrangements), usage, gender

ewcs <- ewcs %>%
  mutate(
    access = ifelse(wt_arrangements %in% c(3, 4), "High",
                    ifelse(wt_arrangements %in% c(1, 2), "Low", NA)),
    access = factor(access, levels = c("Low",
                                       "High")),
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

# 3. Weighted mean WFC by wfh_freq x access x gender, with an
#    approximate weighted SE 

weighted_se <- function(x, w) {
  wm <- weighted.mean(x, w)
  n_eff <- (sum(w)^2) / sum(w^2)  # Kish effective sample size
  wvar <- sum(w * (x - wm)^2) / sum(w)
  sqrt(wvar / n_eff)
}


summary_df <- ewcs %>%
  filter(!is.na(wfc), !is.na(access), !is.na(wfh_freq), !is.na(gender)) %>%
  group_by(gender, access, wfh_freq) %>%
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

# 4. Plot: does the WFH-WFC relationship differ by access,
#    and does THAT pattern itself differ by gender?

access_display_labels <- c(
  Low  = "Low access\n(schedule fixed by employer)",
  High = "High access\n(control over own schedule)"
)

p <- ggplot(summary_df, aes(x = wfh_freq, y = mean_wfc, group = 1)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "#2f6a5c", alpha = 0.15) +
  geom_line(color = "#2f6a5c", linewidth = 0.9) +
  geom_point(color = "#2f6a5c", size = 2.2) +
  facet_grid(gender ~ access, labeller = labeller(access = access_display_labels)) +
  labs(
    title = "Work-family conflict by WFH frequency, access, and gender",
    subtitle = "European Working Conditions Survey 2024 — design-weighted means, approximate 95% CI",
    x = NULL, y = "Work-family conflict\n(1 = low ... 5 = high)",
    caption = paste0(
      "Source: Eurofound EWCS 2024 via UK Data Service (SN 9511). WFC = mean of 4 reverse-coded items ",
      "(q48a-d), respondents reporting the items don't apply excluded.\n",
      "Access = q44 (wt_arrangements). Error bars are an approximate weighted SE (Kish effective n), ",
      "not a full complex-survey design-based SE.\n",
      "NOTE: y-axis is zoomed to 2.0-2.8, not the full 1-5 scale, to make the pattern visible — the ",
      "actual variation across every cell shown is 2.18 to 2.64."
    )
  ) +
  coord_cartesian(ylim = c(2.0, 2.8)) +
  theme_minimal(base_size = 11) +
  theme(
    strip.text = element_text(face = "bold"),
    plot.caption = element_text(hjust = 0, size = 7.5, color = "grey40")
  )

# 5. Save outputs

write.csv(summary_df, "Output/02_wfc_by_wfh_access_gender.csv", row.names = FALSE)
ggsave("Output/02_wfc_by_wfh_access_gender_zoomed.png", p, width = 8.5, height = 7, dpi = 300, bg = "white")












