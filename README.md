# COVID-19 Mobility and Spending Dynamics in the UK: A Time-Series Analysis

This repository contains the code and materials for a research project analyzing the effects of COVID-19-induced mobility changes on credit/debit card spending in the UK. This project was completed as part of my university coursework and explores the relationship between mobility data and consumer spending behavior.

## Overview

The study investigates how mobility restrictions during the COVID-19 pandemic influenced consumer spending in the UK. By leveraging data from Google COVID-19 Community Mobility Reports and the ONS UK Spending on Credit and Debit Cards dataset, the analysis examines correlations between mobility and spending patterns using time-series visualizations and regression models.

## Methodology

- **Data Sources:**  
  - [Google COVID-19 Community Mobility Reports](https://www.google.com/covid19/mobility/) – Tracks changes in visits to various types of locations.  
  - [ONS UK Spending on Credit and Debit Cards](https://www.ons.gov.uk/) – Provides a seven-day rolling average of spending across several categories.

- **Analytical Techniques:**  
  - Time-series analysis using moving averages  
  - Regression analysis to evaluate the relationship between mobility and spending  
  - Visualization through time-series plots and correlation matrices

## Repository Structure

```
├── [Analysis](./Analysis/)       # Main analysis script (main.R) that runs the analysis and produces tables
├── [Docs](./Docs/)               # Research paper (PDF) and LaTeX source files
├── [Figures](./Figures/)         # Generated figures and tables
├── [Data](./Data/)               # Raw data files
└── README.md                    # Project overview
```

## Dependencies

- **R** (for analysis)
- **LaTeX** (for document preparation)


## Reproduction

Clone the repository:

```bash
git clone https://github.com/acser00/Covid-19-Mobility.git
cd Covid-19-Mobility
```

Run the analysis in an R session:

```r
source("Analysis/main.R")
```

The `main.R` script in the [Analysis](./Analysis/) directory runs the analysis and produces the required tables.

## More Information

For a detailed description of the methodology and results, please refer to the research paper in the [Docs](./Docs/) directory. Generated figures can be found in the [Figures](./Figures/) directory.
