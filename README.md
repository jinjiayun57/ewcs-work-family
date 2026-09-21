# WorkFamily: EWCS 2024

Exploratory analysis of the 2024 European Working Conditions Survey (EWCS), 
focusing on gender patterns in workplace flexibility and how working from home relates to work-family conflict and wellbeing.

## What I explored

I looked at three related aspects of the data:

1. Do men and women show different patterns in schedule control, ease of taking short-notice time off, and use of working from home?
2. Does the association between working from home and work-family conflict vary by schedule control and gender?
3. Do these patterns remain when the relationships are examined in a multilevel model that accounts for clustering within countries?

A related issue throughout the project is selective uptake. 
Employees with greater family demands may be more likely to use flexible working arrangements in the first place. For this reason, an association between frequent use and poorer work-family outcomes cannot by itself be interpreted as an effect of flexible working.

## Data

The analyses use the 2024 European Working Conditions Survey (EWCS), UK Data Service study 9511.

- Sample size: 36,644
- Fieldwork: 2024
- Coverage: 35 European countries
- Mode: face-to-face survey

The raw dataset is stored locally in:

`Data/Raw/`

The microdata are not included in this repository. 

The measures used here are based on employees' own reports. 
Schedule control and ease of taking time off therefore reflect employees' reported working conditions rather than independently observed formal organisational provision.

The data also do not contain organisation or team identifiers, and there are no employer or HR respondents. 
This limits what can be learned about organisational processes from the EWCS alone.

## Analyses

### 01. Workplace flexibility by gender and presence of children

Script:

`R/01_access_and_usage.R`

Notes:

`Notes/01_access_and_usage_results.md`

This analysis compares men and women on:

- schedule control
- ease of taking short-notice time off
- frequency of working from home

It also examines whether these patterns differ by the presence of children in the household.

The descriptive results suggest that women report less schedule control and less ease in taking short-notice time off, 
while reporting somewhat more use of working from home.

The different indicators therefore do not show the same gender pattern and are examined separately rather than treated as interchangeable measures of workplace flexibility.

### 02. Work-family conflict by working from home, schedule control, and gender

Script:

`R/02_wfc_by_wfh_access_gender.R`

Notes:

`Notes/02_wfc_results.md`

This analysis constructs a four-item work-family conflict measure and compares reported conflict across combinations of:

- working-from-home frequency
- schedule control
- gender

The analysis is descriptive and uses weighted group means with approximate confidence intervals.

Women with low schedule control show a descriptive pattern of increasing work-family conflict as working-from-home frequency rises. 
The other gender-by-schedule-control groups show flatter or less monotonic patterns.

No interaction model is estimated in this step.

### 03. Multilevel models

Script:

`R/03_multilevel_model.R`

Notes:

`Notes/03_multilevel_results.md`

This analysis examines the pattern from Analysis 02 more formally among parents.

The main specification includes:

`WFH frequency × schedule control × gender`

with a random intercept for country.

Two outcomes are examined:

- work-family conflict
- WHO-5 wellbeing

The three-way interaction is not statistically significant for work-family conflict.

For wellbeing, the three-way interaction is statistically significant. 
Predicted wellbeing rises with WFH frequency for men and declines slightly for women in the low-schedule-control group, 
while the corresponding slopes are close to flat among respondents with some schedule control.

These results are treated as exploratory associations. 
They do not resolve selection into working from home or establish causal effects.

## Project structure

The public repository contains:

WorkFamily/
├── README.md
├── WorkFamily.Rproj
├── R/
│   ├── 01_access_and_usage.R
│   ├── 02_wfc_by_wfh_access_gender.R
│   └── 03_multilevel_model.R
├── Notes/
│   ├── 01_access_and_usage_results.md
│   ├── 02_wfc_results.md
│   └── 03_multilevel_results.md
└── Output/


## Software

The analyses are written in R.

Main packages:

- `haven`
- `labelled`
- `dplyr`
- `tidyr`
- `ggplot2`
- `scales`
- `lme4`
- `ggeffects`



## Current limitations


- The flexibility measures are based on employee reports rather than formal organisational records.
- The EWCS contains no employer, HR, team, or organisation-level respondent.
- There are no organisation or team identifiers.
- Use of working from home is selective and may be related to family demands and work-family conflict.
- The multilevel models do not establish causal effects.
- The multilevel models are currently unweighted.
- The model specifications have not been subjected to extensive robustness checks.
- The three scripts currently depend on being run sequentially in the same R session.