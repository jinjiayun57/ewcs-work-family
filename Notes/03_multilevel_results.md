# Multilevel models of working from home, schedule control, gender, and work-family outcomes

This analysis follows the descriptive patterns examined in Analysis 02 and tests whether the association between working-from-home frequency and work-family outcomes varies by schedule control and gender.

Two outcomes are considered:

- work-family conflict
- WHO-5 wellbeing

The models account for clustering of respondents within countries through a random intercept for country. They are exploratory association models and are not intended to estimate causal effects.

## Sample

The analysis includes 12,587 parents with complete data on schedule control, working-from-home frequency, gender, and country:

- 6,064 men
- 6,523 women
- 35 countries

Of these respondents:

- 12,304 have complete data on the work-family conflict composite
- 12,581 have complete WHO-5 wellbeing data

## Model

The same basic specification is estimated for both outcomes:

`outcome ~ wfh_freq_c * schedule_control * gender + (1 | country)`

where:

- `wfh_freq_c` measures working-from-home frequency from 0 (never) to 4 (always)
- `schedule_control` distinguishes low schedule control from some schedule control
- `gender` distinguishes men and women
- the reference group is men with low schedule control
- country is included as a random intercept

Schedule control is based on `wt_arrangements` (q44). Low schedule control refers to respondents whose working time is fixed by the employer. The comparison category includes respondents reporting at least some ability to choose or adapt their working time.

The models are unweighted.

These estimates describe associations rather than causal effects. Working-from-home frequency may itself be related to family demands, occupation, seniority, job characteristics, or existing work-family difficulties. These sources of selection are not addressed by the present specification.

## Results: work-family conflict

Work-family conflict ranges from 1 (low conflict) to 5 (high conflict).

| Term | Estimate | t | approx. p |
|---|---:|---:|---:|
| WFH frequency, men with low schedule control | +0.081 | 5.90 | <.001 |
| Some schedule control, men who never WFH | +0.121 | 4.60 | <.001 |
| Female, low schedule control and never WFH | +0.063 | 3.35 | <.001 |
| WFH × schedule control | -0.058 | -3.30 | .001 |
| WFH × Female | +0.040 | 2.25 | .025 |
| Schedule control × Female | -0.040 | -1.05 | .29 |
| **WFH × schedule control × Female** | **-0.033** | **-1.38** | **.17** |

For men with low schedule control, more frequent working from home is associated with higher work-family conflict. 
The estimated slope is +0.081 for each one-category increase in WFH frequency.

The negative WFH × schedule-control interaction indicates that this slope is flatter among men who report some schedule control. 
For men with some schedule control, the estimated WFH slope is approximately:

`0.081 - 0.058 = 0.023`

The positive WFH × Female interaction indicates that, among respondents with low schedule control, 
the WFH-conflict slope is steeper for women than for men. For women with low schedule control, the estimated slope is approximately:

`0.081 + 0.040 = 0.121`

These two-way interactions correspond to parts of the descriptive pattern observed in Analysis 02. 
Their interpretation, however, is conditional on the reference categories of the model.

The three-way interaction is not statistically significant (`p = .17`). 
The model therefore does not provide strong evidence that the gender difference in the WFH-conflict association itself varies by schedule control.

The predicted-values plot shows the highest increase in conflict among women with low schedule control, 
but this visual pattern should not be interpreted as a confirmed three-way interaction.

## Results: WHO-5 wellbeing

WHO-5 wellbeing ranges from 0 (lowest wellbeing) to 100 (highest wellbeing).

| Term | Estimate | t | approx. p |
|---|---:|---:|---:|
| WFH frequency, men with low schedule control | +0.88 | 2.59 | .010 |
| Some schedule control, men who never WFH | +1.04 | 1.59 | .11 |
| Female, low schedule control and never WFH | -2.03 | -4.32 | <.001 |
| WFH × schedule control | -0.84 | -1.90 | .058 |
| WFH × Female | -1.13 | -2.57 | .010 |
| Schedule control × Female | -0.88 | -0.94 | .35 |
| **WFH × schedule control × Female** | **+1.21** | **2.05** | **.041** |

For men with low schedule control, more frequent working from home is associated with higher predicted wellbeing. 
The estimated slope is +0.88 per one-category increase in WFH frequency.

Among women with low schedule control, the corresponding estimated slope is:

`0.88 - 1.13 = -0.25`

The predicted values therefore move in opposite directions for men and women in the low-schedule-control group: 
predicted wellbeing increases with WFH frequency for men and decreases slightly for women.

For men with some schedule control, the estimated WFH slope is approximately:

`0.88 - 0.84 = 0.04`

For women with some schedule control, it is approximately:

`0.88 - 0.84 - 1.13 + 1.21 = 0.12`

Both are close to flat.

The three-way interaction is statistically significant at the conventional 5% level (`p = .041`). 
This indicates that the gender difference in the association between WFH frequency and wellbeing varies by schedule-control group.

This result should still be treated cautiously. A significant three-way interaction does not by itself establish that each simple slope differs significantly from zero. 
The predicted patterns are useful for describing the interaction, but formal simple-slope or contrast tests would be needed to make stronger claims about the individual slopes.

The result is also based on one exploratory model specification, is unweighted, and has not been adjusted for multiple testing across the two outcome models.

## Comparing the two outcomes

The two outcomes do not show the same interaction pattern.

For work-family conflict, the descriptive pattern from Analysis 02 is partly reflected in the model, 
but the WFH × schedule control × gender interaction is not statistically significant.

For wellbeing, the three-way interaction is statistically significant. 
Predicted wellbeing rises with WFH frequency for men with low schedule control and declines slightly for women in the same schedule-control group, 
while the corresponding slopes are close to flat among respondents with some schedule control.

This difference suggests that work-family conflict and general wellbeing should not be treated as interchangeable outcomes. 
The present analysis does not identify the mechanisms behind the different patterns.

## Predicted-values plots

Two figures are generated:

- `Output/03_predicted_wfc_by_wfh_access_gender.png`
- `Output/03_predicted_wellbeing_by_wfh_access_gender.png`

The work-family conflict plot shows a steeper predicted increase among women with low schedule control, 
but the corresponding three-way interaction is not statistically significant.

The wellbeing plot shows different WFH slopes by gender among respondents with low schedule control, 
while the slopes are much closer to flat among respondents with some schedule control.

## Take-aways

- More frequent working from home is associated with higher work-family conflict among men with low schedule control, 
and this association is steeper among women in the same schedule-control group.

- Schedule control is associated with a flatter WFH-conflict slope among men, 
but the three-way interaction with gender is not statistically significant.

- For wellbeing, the WFH × schedule control × gender interaction is statistically significant. 
Predicted wellbeing patterns differ by gender under low schedule control, while WFH slopes are close to flat under some schedule control.

- The work-family conflict and wellbeing models therefore show different patterns rather than providing two versions of the same result.

- These are exploratory associations. Selection into working from home remains unaddressed, the models are unweighted, 
and stronger interpretation would require additional model checks and formal tests of relevant simple slopes and contrasts.

## Files

- `R/03_multilevel_model.R` contains the model estimation and predicted-values calculations.
- `Notes/03_multilevel_results.html` contains the knitted analysis output.
- `Output/03_predicted_wfc_by_wfh_access_gender.png` contains predicted work-family conflict.
- `Output/03_predicted_wellbeing_by_wfh_access_gender.png` contains predicted WHO-5 wellbeing.