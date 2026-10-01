# Script 02 showed a descriptive pattern in which work-family conflict rises
# most steadily with WFH frequency among women with low schedule control.
# This script tests whether the association between WFH frequency and two
# outcomes (work-family conflict and WHO-5 wellbeing) varies by schedule
# control and gender, using multilevel models with a random intercept for
# country.
#
# Sample: employees with children under 15 in the household (the `ewcs`
# data frame from scripts 01 and 02). Models are unweighted.

library(haven)
library(labelled)
library(dplyr)
library(lme4)
library(ggeffects)
library(ggplot2)
library(scales)


# 1. Variables

# WFH frequency as a continuous score: loc_home (1 = always ... 5 = never)
# is reversed to 0-4, so higher values mean more frequent WFH.
# WHO-5 wellbeing is Eurofound's 0-100 index (higher = better).

ewcs <- ewcs %>%
  mutate(
    wellbeing = as.numeric(wellbeing),
    wfh_freq_c = ifelse(loc_home %in% 1:5, 5 - as.numeric(loc_home), NA)
  )


# 2. Analytic sample: parents

parents <- ewcs %>%
  filter(
    has_children,
    !is.na(schedule_control), !is.na(wfh_freq_c), !is.na(gender), !is.na(country)
  ) %>%
  mutate(
    gender = relevel(gender, ref = "Male"),
    schedule_control = relevel(schedule_control, ref = "Low")
  )


# 3. Models
#
# Reference group: men with low schedule control.

# Model 1: work-family conflict (1 = low ... 5 = high)
m_wfc <- lmer(
  wfc ~ wfh_freq_c * schedule_control * gender + (1 | country),
  data = parents, REML = TRUE
)

# Model 2: WHO-5 wellbeing (0 = worst ... 100 = best)
m_wb <- lmer(
  wellbeing ~ wfh_freq_c * schedule_control * gender + (1 | country),
  data = parents, REML = TRUE
)

print(summary(m_wfc))
print(summary(m_wb))


# 4. Simple slopes of WFH frequency and slope contrasts
#
# Linear combinations of the fixed effects. p-values use a normal
# approximation, as lme4 does not report degrees of freedom.

slope_tests <- function(model) {
  b <- fixef(model)
  V <- as.matrix(vcov(model))
  k <- function(...) {
    x <- setNames(rep(0, length(b)), names(b))
    x[c(...)] <- 1
    x
  }
  w   <- "wfh_freq_c"
  wS  <- "wfh_freq_c:schedule_controlHigh"
  wF  <- "wfh_freq_c:genderFemale"
  wSF <- "wfh_freq_c:schedule_controlHigh:genderFemale"
  L <- rbind(
    "Slope: men, low schedule control"            = k(w),
    "Slope: men, some schedule control"           = k(w, wS),
    "Slope: women, low schedule control"          = k(w, wF),
    "Slope: women, some schedule control"         = k(w, wS, wF, wSF),
    "Difference: men, some vs. low control"       = k(wS),
    "Difference: women, some vs. low control"     = k(wS, wSF),
    "Difference: low control, women vs. men"      = k(wF),
    "Difference: some control, women vs. men"     = k(wF, wSF)
  )
  est <- drop(L %*% b)
  se  <- sqrt(diag(L %*% V %*% t(L)))
  z   <- est / se
  data.frame(estimate = round(est, 3), se = round(se, 3),
             z = round(z, 2), p = round(2 * pnorm(-abs(z)), 3))
}

slopes_wfc <- slope_tests(m_wfc)
slopes_wb  <- slope_tests(m_wb)
print(slopes_wfc)
print(slopes_wb)

sink("Output/03_multilevel_model_summaries.txt")
cat("MODEL 1: Work-family conflict ~ WFH frequency * schedule control * gender + (1 | country)\n")
cat("Sample: employed parents, n =", nobs(m_wfc), "\n\n")
print(summary(m_wfc))
cat("\nSimple slopes of WFH frequency and contrasts:\n")
print(slopes_wfc)
cat("\n\n=====================================================\n\n")
cat("MODEL 2: WHO-5 wellbeing ~ WFH frequency * schedule control * gender + (1 | country)\n")
cat("Sample: employed parents, n =", nobs(m_wb), "\n\n")
print(summary(m_wb))
cat("\nSimple slopes of WFH frequency and contrasts:\n")
print(slopes_wb)
sink()


# 5. Predicted values

pred_wfc <- ggpredict(m_wfc, terms = c("wfh_freq_c [0:4]", "schedule_control", "gender"))
pred_wb  <- ggpredict(m_wb,  terms = c("wfh_freq_c [0:4]", "schedule_control", "gender"))

pred_wfc_df <- as.data.frame(pred_wfc) %>%
  rename(wfh_freq_c = x, mean = predicted, schedule_control = group, gender = facet)
pred_wb_df <- as.data.frame(pred_wb) %>%
  rename(wfh_freq_c = x, mean = predicted, schedule_control = group, gender = facet)

write.csv(pred_wfc_df, "Output/03_predicted_wfc.csv", row.names = FALSE)
write.csv(pred_wb_df, "Output/03_predicted_wellbeing.csv", row.names = FALSE)


# 6. Plots

wfh_labels <- c("Never", "Rarely", "Sometimes", "Often", "Always")
sc_colours <- c(Low = "#e07856", High = "#2f6a5c")
sc_labels  <- c(Low = "Low schedule control", High = "Some schedule control")

plot_predictions <- function(df, n, title, y_label) {
  ggplot(df, aes(x = wfh_freq_c, y = mean, colour = schedule_control, fill = schedule_control)) +
    geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.15, colour = NA) +
    geom_line(linewidth = 1) +
    facet_wrap(~gender) +
    scale_x_continuous(breaks = 0:4, labels = wfh_labels) +
    scale_colour_manual(values = sc_colours, labels = sc_labels) +
    scale_fill_manual(values = sc_colours, labels = sc_labels) +
    labs(
      title = title,
      subtitle = paste0(
        "EWCS 2024, employed parents (n = ", format(n, big.mark = ","), ").\n",
        "Multilevel model with country random intercept, unweighted. Bands = 95% CI"
      ),
      x = "Working from home", y = y_label, colour = NULL, fill = NULL,
      caption = paste0(
        "Source: Eurofound EWCS 2024 via UK Data Service (SN 9511).\n",
        "Estimates are associations, not causal effects; selection into working from home is not addressed."
      )
    ) +
    theme_minimal(base_size = 11) +
    theme(
      strip.text = element_text(face = "bold"),
      legend.position = "top",
      legend.justification = "left",
      panel.grid.minor = element_blank(),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      plot.caption = element_text(hjust = 0, size = 7.5, colour = "grey40")
    )
}

p_wfc <- plot_predictions(
  pred_wfc_df, nobs(m_wfc),
  "Predicted work-family conflict by WFH frequency, schedule control and gender",
  "Work-family conflict (1 = low ... 5 = high)"
)

p_wb <- plot_predictions(
  pred_wb_df, nobs(m_wb),
  "Predicted WHO-5 wellbeing by WFH frequency, schedule control and gender",
  "WHO-5 wellbeing (0 = worst ... 100 = best)"
)

ggsave("Output/03_predicted_wfc_by_wfh_sc_gender.png", p_wfc,
       width = 8.5, height = 5.5, dpi = 300, bg = "white")
ggsave("Output/03_predicted_wellbeing_by_wfh_sc_gender.png", p_wb,
       width = 8.5, height = 5.5, dpi = 300, bg = "white")
