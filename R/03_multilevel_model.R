
library(haven)
library(labelled)
library(dplyr)
library(lme4)
library(ggeffects)
library(ggplot2)
library(scales)

ewcs <- ewcs %>%
  mutate(
    wellbeing = as.numeric(wellbeing),
    # continuous WFH frequency: reverse loc_home (1=always..5=never)
    # to 0-4, higher = more frequent WFH
    wfh_freq_c = ifelse(loc_home %in% 1:5, 5 - as.numeric(loc_home), NA)  )

# restric to parents
parents <- ewcs %>%
  filter(
    has_children,
    !is.na(access), !is.na(wfh_freq_c), !is.na(gender), !is.na(country)
  )

# Model 1 — Work-family conflict
parents <- parents %>% mutate(gender = relevel(gender, ref = "Male"),
                              access = relevel(access, ref = "Low"))


m_wfc <- lmer(
  wfc ~ wfh_freq_c * access * gender + (1 | country),
  data = parents, REML = TRUE
)

# Model 2 — WHO-5 wellbeing (higher = BETTER, opposite direction from WFC)

m_wb <- lmer(
  wellbeing ~ wfh_freq_c * access * gender + (1 | country),
  data = parents, REML = TRUE
)
print(summary(m_wfc))
print(summary(m_wb))

# Save both model summaries to a text file for the record
# (added during Sep 2026 cleanup — m_wfc's summary was never printed or
# saved, and neither summary was written to disk; 03_multilevel_results.md
# reports numbers from both models, so both need to exist as a saved file.)
sink("Output/03_multilevel_model_summaries.txt")
cat("MODEL 1: Work-family conflict ~ WFH freq * Access * Gender + (1|country)\n")
cat("Sample: parents only, n =", nobs(m_wfc), "\n\n")
print(summary(m_wfc))
cat("\n\n=====================================================\n\n")
cat("MODEL 2: WHO-5 wellbeing ~ WFH freq * Access * Gender + (1|country)\n")
cat("Sample: parents only, n =", nobs(m_wb), "\n\n")
print(summary(m_wb))
sink()

# Predicted-values plots

pred_wfc <- ggpredict(m_wfc, terms = c("wfh_freq_c [0:4]", "access", "gender"))
pred_wb  <- ggpredict(m_wb,  terms = c("wfh_freq_c [0:4]", "access", "gender"))

pred_wfc_df <- as.data.frame(pred_wfc) %>%
  rename(wfh_freq_c = x, mean = predicted, access = group, gender = facet)
pred_wb_df <- as.data.frame(pred_wb) %>%
  rename(wfh_freq_c = x, mean = predicted, access = group, gender = facet)

write.csv(pred_wfc_df, "Output/03_predicted_wfc.csv", row.names = FALSE)
write.csv(pred_wb_df, "Output/03_predicted_wellbeing.csv", row.names = FALSE)

wfh_labels <- c("Never", "Rarely", "Sometimes", "Often", "Always")

p_wfc <- ggplot(pred_wfc_df, aes(x = wfh_freq_c, y = mean, color = access, fill = access)) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.15, color = NA) +
  geom_line(linewidth = 1) +
  facet_wrap(~gender) +
  scale_x_continuous(breaks = 0:4, labels = wfh_labels) +
  scale_color_manual(values = c(Low = "#e07856", High = "#2f6a5c")) +
  scale_fill_manual(values = c(Low = "#e07856", High = "#2f6a5c")) +
  labs(
    title = "Predicted work-family conflict, by WFH frequency, access, and gender",
    subtitle = "Parents only. Multilevel model (random intercept: country), unweighted. Bands = 95% CI.",
    x = NULL, y = "Predicted WFC (1 = low ... 5 = high)", color = "Access", fill = "Access",
    caption = "EWCS 2024 (SN 9511), n as reported in 03_multilevel_results.md. Association, not a causal effect — selection on family demands is not addressed."
  ) +
  theme_minimal(base_size = 11) +
  theme(strip.text = element_text(face = "bold"), legend.position = "top",
        plot.caption = element_text(hjust = 0, size = 7.5, color = "grey40"))

ggsave("Output/03_predicted_wfc_by_wfh_access_gender.png", p_wfc, width = 8.5, height = 5.5, dpi = 300, bg = "white")

p_wb <- ggplot(pred_wb_df, aes(x = wfh_freq_c, y = mean, color = access, fill = access)) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.15, color = NA) +
  geom_line(linewidth = 1) +
  facet_wrap(~gender) +
  scale_x_continuous(breaks = 0:4, labels = wfh_labels) +
  scale_color_manual(values = c(Low = "#e07856", High = "#2f6a5c")) +
  scale_fill_manual(values = c(Low = "#e07856", High = "#2f6a5c")) +
  labs(
    title = "Predicted WHO-5 wellbeing, by WFH frequency, access, and gender",
    subtitle = "Parents only. Multilevel model (random intercept: country), unweighted. Bands = 95% CI.",
    x = NULL, y = "Predicted wellbeing (0 = worst ... 100 = best)", color = "Access", fill = "Access",
    caption = "EWCS 2024 (SN 9511), n as reported in 03_multilevel_results.md. Association, not a causal effect — selection on family demands is not addressed."
  ) +
  theme_minimal(base_size = 11) +
  theme(strip.text = element_text(face = "bold"), legend.position = "top",
        plot.caption = element_text(hjust = 0, size = 7.5, color = "grey40"))

ggsave("Output/03_predicted_wellbeing_by_wfh_access_gender.png", p_wb, width = 8.5, height = 5.5, dpi = 300, bg = "white")




