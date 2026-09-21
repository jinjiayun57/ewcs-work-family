# WorkFamily: EWCS 2024

Exploratory analysis of the 2024 European Working Conditions Survey (EWCS), focusing on gender differences in access to and use of flexible working arrangements, and how these patterns relate to work-family conflict and wellbeing.

## Research focus

The analyses keep access and uptake separate and ask three related questions:

1. Do men and women differ in their reported access to flexible working arrangements and in their actual use of working from home?
2. Does the association between working from home and work-family conflict vary by schedule control and gender?
3. Do these patterns remain when the relationships are examined in a multilevel model that accounts for clustering within countries?

A related issue throughout the project is selective uptake. 
Employees with greater family demands may be more likely to use flexible working arrangements in the first place. 
For this reason, an association between frequent use and poorer work-family outcomes cannot by itself be interpreted as an effect of flexible working.

## Data

The analyses use the 2024 European Working Conditions Survey (EWCS), UK Data Service study 9511.

- Sample size: 36,644
- Fieldwork: 2024
- Coverage: 35 European countries
- Mode: face-to-face survey

The raw dataset is stored locally in:

`Data/Raw/`

The microdata are not included in any public version of this project. Anyone wishing to reproduce the analyses would need to obtain the EWCS 2024 data separately through the UK Data Service.

The EWCS is based on employee reports. Measures of access in this project therefore refer to employees' perceived access rather than formal organisational provision.

The data also do not contain organisation or team identifiers, and there are no employer or HR respondents. This limits what can be learned about organisational processes from the EWCS alone. These limitations are one reason why multi-actor, multilevel datasets such as the European Sustainable Workforce Survey are useful for related questions.

## Analyses

### 01. Access and usage

Script:

`R/01_access_and_usage.R`

Notes:

`Notes/01_access_and_usage_results.md`

This analysis compares men and women on:

- schedule control
- ease of taking short-notice time off
- frequency of working from home

It also examines whether these patterns differ by caregiving and parental status.

The descriptive results suggest that women report somewhat lower access on the access measures while reporting higher use of working from home. This illustrates why access and use may need to be examined separately rather than represented by a single indicator.

### 02. Work-family conflict by working from home, access, and gender

Script:

`R/02_wfc_by_wfh_access_gender.R`

Notes:

`Notes/02_wfc_results.md`

This analysis constructs a four-item work-family conflict measure and compares reported conflict across combinations of:

- working-from-home frequency
- schedule control
- gender

The analysis is descriptive and uses weighted group means with approximate confidence intervals.

Women with low schedule control show a descriptive pattern of increasing work-family conflict as working-from-home frequency rises. The other gender-by-access groups show flatter or less monotonic patterns.

No interaction model is estimated in this step.

### 03. Multilevel models

Script:

`R/03_multilevel_model.R`

Notes:

`Notes/03_multilevel_results.md`

This analysis tests the pattern from Analysis 02 more formally among parents.

The main specification includes:

`WFH frequency × schedule control × gender`

with a random intercept for country.

Two outcomes are examined:

- work-family conflict
- WHO-5 wellbeing

The three-way interaction is not statistically significant for work-family conflict.

For wellbeing, the three-way interaction is statistically significant. Model predictions suggest that wellbeing patterns under frequent working from home and low schedule control differ by gender, with higher predicted wellbeing for men and lower predicted wellbeing for women in this combination.

These results are treated as exploratory associations. They do not resolve selection into flexible working or establish causal effects.

## Project structure

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
├── Output/
├── Data/
│   └── Raw/
└── Literature/

The `Literature/` folder contains the papers used during the development of the project.

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

## Running the analyses

Open `WorkFamily.Rproj` in RStudio and run the scripts in order:

`source("R/01_access_and_usage.R")`

`source("R/02_wfc_by_wfh_access_gender.R")`

`source("R/03_multilevel_model.R")`

At present, the scripts are not fully independent. Scripts 02 and 03 use objects created earlier in the same R session, so the scripts should be run in sequence without clearing the environment.

Paths are relative to the project root.

The raw `.sav` file is read with:

`encoding = "latin1"`

because some translated responses in the source file are not valid UTF-8.

## Current limitations

This project is exploratory and has several important limitations.

- Access is measured from the employee perspective rather than from formal organisational records.
- The EWCS contains no employer, HR, team, or organisation-level respondent.
- There are no organisation or team identifiers.
- Use of flexible working is selective and may be related to family demands and work-family conflict.
- The multilevel models do not establish causal effects.
- The multilevel models are currently unweighted.
- The model specifications have not been subjected to extensive robustness checks.
- The three scripts currently depend on being run sequentially in the same R session.

