# Work-family conflict by working-from-home frequency, schedule control, and gender

The previous analysis showed that different dimensions of workplace flexibility do not follow the same gender pattern. 
Women reported less schedule control and less ease in taking short-notice time off, but somewhat more use of working from home.

This analysis looks more closely at working from home and asks whether reported work-family conflict varies across 
combinations of working-from-home frequency, schedule control, and gender.

Among respondents who work from home at least sometimes, women are more likely than men to be in the low-schedule-control group: 
35.1% of female WFH users versus 25.0% of male WFH users.

## Method

This is a descriptive analysis. No interaction model is fitted at this stage.

Work-family conflict (WFC) is the mean of four reverse-coded q48a-d items:

- `wlb_worry`
- `wlb_tired`
- `wlb_timefamily`
- `wlb_concentrate`

The resulting scale ranges from 1 to 5, with higher values indicating greater work-family conflict.

Respondents coded `-991` ("does not apply / no family responsibilities") on any of the four items were excluded from the
composite rather than treated as "never". This response indicates that the question was not applicable rather than an absence of conflict.

Cronbach's alpha for the cleaned four-item scale is 0.75.

N = 34,692 respondents have complete data on all four items.

Schedule control is based on `wt_arrangements` (q44) and is collapsed into two groups:

- low schedule control: working time is fixed by the employer
- some schedule control: the respondent has at least some ability to choose or adapt working time

Working-from-home frequency (`loc_home`, q29_d) is collapsed from five categories into three:

- Never
- Rarely/sometimes
- Often/always

Means are weighted using `calweight`.

The confidence intervals use an approximate weighted standard error based on the Kish effective sample size. They are not full complex-survey design-based confidence intervals because PSU and strata information are not used here.

## Results

Weighted mean work-family conflict, on a 1 to 5 scale, with approximate 95% confidence intervals:

| | Never | Rarely/sometimes | Often/always |
|---|---:|---:|---:|
| Male, low schedule control | 2.18 [2.14, 2.22] | 2.33 [2.23, 2.43] | 2.34 [2.19, 2.48] |
| Male, some schedule control | 2.25 [2.18, 2.32] | 2.43 [2.36, 2.49] | 2.34 [2.25, 2.42] |
| Female, low schedule control | 2.31 [2.26, 2.35] | 2.51 [2.42, 2.60] | 2.64 [2.51, 2.77] |
| Female, some schedule control | 2.20 [2.12, 2.28] | 2.45 [2.36, 2.53] | 2.42 [2.34, 2.51] |

## Interpretation

Three of the four gender-by-schedule-control groups show a similar descriptive pattern. Mean work-family conflict rises 
from "never" to "rarely/sometimes" working from home, then changes little or declines slightly among those working from 
home often or always.

Women with low schedule control show a different descriptive pattern. Their mean work-family conflict increases across 
all three working-from-home categories:

2.31 → 2.51 → 2.64

The increase from "never" to "often/always" is 0.33 points on the five-point scale. 
This is larger than the corresponding increase in the other three groups.

This pattern suggests that the association between working from home and work-family conflict may vary jointly by schedule control 
and gender. In particular, frequent working from home is associated with relatively high reported conflict among women with low schedule control.

The result should not be interpreted as evidence that working from home without schedule control causes greater work-family conflict. 
Working-from-home frequency is not randomly assigned, and employees with greater family demands or existing work-family conflict may be more likely to work from home.

The composition of WFH users also differs by gender. Among respondents who work from home, women are more often in the low-schedule-control group than men. 
This is descriptively relevant, but it does not establish why women are more likely to occupy this combination of working conditions.

The differences in this analysis are modest in absolute size. Confidence intervals also overlap across several adjacent groups. 
The purpose of this step is therefore to identify a descriptive pattern that can be examined more formally, 
rather than to establish a statistically tested interaction.

Analysis 03 tests the WFH frequency × schedule control × gender interaction in a multilevel model.


