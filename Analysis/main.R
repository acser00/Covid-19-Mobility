# ==== HHPM8 Midterm Assessment Question 1 ====

rm(list=ls())

# Set working directory
setwd("~/University/MSc/Programming/Final/Q1")

# Download necessary packages
library(tidyverse)
library(ggplot2)
library(plm)
library(janitor)
library(lubridate)
library(readxl)
library(zoo)
library(reshape2)
library(gridExtra)
library(texreg)

# Import Mobility Data
mobility_2020_df <- read_csv("2020_GB_Region_Mobility_Report.csv")
mobility_2021_df <- read_csv("2021_GB_Region_Mobility_Report.csv")
mobility_2022_df <- read_csv("2022_GB_Region_Mobility_Report.csv")

mobility_df <- bind_rows(mobility_2020_df, mobility_2021_df, mobility_2022_df)

# Import Spending Data
uk_spending_data <- read_excel("uk_spending.xlsx", skip = 4, sheet = 2, n_max= 5)

# Create dates from excel format
dates <- uk_spending_data %>% names() %>% .[-1] %>% as.integer() %>% as.Date(origin = "1899-12-30")

# Create long format
uk_spending_data_long <- uk_spending_data %>% unname() %>% t() %>% 
                           as_tibble %>% set_names(.[1,]) %>% 
                           slice(-1) %>% cbind(dates, .) %>% 
                           mutate(across(all_of(c("Aggregate", "Social", "Staple", "Work Related")), as.numeric))

# Merge the two datasets
merged_data <- mobility_df %>% 
                left_join(uk_spending_data_long, by = c("date" = "dates")) %>% 
                clean_names

# Create MA of mobility data
merged_data <- merged_data %>%
  mutate(
    MA_retail = rollmean(retail_and_recreation_percent_change_from_baseline, 7, fill = NA, align = "right"),
    MA_grocery = rollmean(grocery_and_pharmacy_percent_change_from_baseline, 7, fill = NA, align = "right"),
    MA_work = rollmean(workplaces_percent_change_from_baseline, 7, fill = NA, align = "right"),
    MA_transit = rollmean(transit_stations_percent_change_from_baseline, 7, fill = NA, align = "right"),
    MA_parks = rollmean(parks_percent_change_from_baseline, 7, fill = NA, align = "right"),
    MA_residential = rollmean(residential_percent_change_from_baseline, 7, fill = NA, align = "right")
  ) %>%
  # Ensure all these columns are numeric
  mutate(across(starts_with("MA_"), as.numeric)) %>%
  # Convert spending categories to numeric
  mutate(across(c(aggregate, social, delayable, staple, work_related), as.numeric))


# Create correlation matrix
correlation_data <- merged_data %>%
  select(MA_retail, MA_grocery, MA_work, MA_transit, MA_parks, aggregate, social, delayable, staple, work_related)

cor_matrix <- cor(correlation_data, use = "complete.obs")

cor_melted <- melt(cor_matrix)

correlation_plot <- ggplot(cor_melted, aes(Var1, Var2, fill = value)) +
  geom_tile(color = "white") + # Adding a white border around the tiles
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0, name = "Correlation") +
  labs(
    title = "Correlation Matrix of Mobility and Spending Categories",
    x = "Categories",
    y = "Categories"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
    axis.text.y = element_text(angle = 45, vjust = 1, hjust = 1),
    axis.title.x = element_text(face = "bold", size = 12),
    axis.title.y = element_text(face = "bold", size = 12),
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    legend.title = element_text(face = "bold", size = 10),
    legend.key.size = unit(1, 'cm') # Adjust legend key size
  ) +
  scale_x_discrete(labels = function(x) str_to_title(x)) +
  scale_y_discrete(labels = function(x) str_to_title(x))

# Save the plot as a PDF file
ggsave("correlation_matrix.pdf", plot = correlation_plot, device = "pdf", width = 10, height = 8, units = "in")

# Linear models
models <- list(
  lm_aggregate = lm(aggregate ~ MA_retail + MA_grocery + MA_work + MA_transit + MA_parks + MA_residential, data = merged_data),
  lm_social = lm(social ~ MA_retail + MA_grocery + MA_work + MA_transit + MA_parks + MA_residential, data = merged_data),
  lm_delayable = lm(delayable ~ MA_retail + MA_grocery + MA_work + MA_transit + MA_parks + MA_residential, data = merged_data),
  lm_staple = lm(staple ~ MA_retail + MA_grocery + MA_work + MA_transit + MA_parks + MA_residential, data = merged_data),
  lm_work_related = lm(work_related ~ MA_retail + MA_grocery + MA_work + MA_transit + MA_parks + MA_residential, data = merged_data)
)

lapply(models, summary)

models_list <- list(models$lm_aggregate, models$lm_social, models$lm_delayable, models$lm_staple, models$lm_work_related)

# Use texreg to create a LaTeX table
latex_table <- texreg(models_list, file = "covid_regression.tex", caption = "Regression Results from Credit/Debit Card Spending and Mobility Data", use.packages = FALSE, dcolumn = TRUE)



# Plot the models

# Plot 1: Retail Mobility and Work-Related Spending
p1 <- ggplot(merged_data, aes(x = date)) +
  geom_line(aes(y = MA_retail, colour = "Retail Mobility")) +
  geom_line(aes(y = aggregate, colour = "Aggregate Spending")) +
  labs(title = "Retail Mobility and Aggregate Spending Over Time", x = "Date", y = "Percentage Change", colour = "Series") +
  theme_minimal() +
  theme(legend.position = "bottom")

# Plot 2: Grocery Mobility and Work-Related Spending
p2 <- ggplot(merged_data, aes(x = date)) +
  geom_line(aes(y = MA_grocery, colour = "Grocery Mobility")) +
  geom_line(aes(y = aggregate, colour = "Aggregate Spending")) +
  labs(title = "Grocery Mobility and Aggregate Spending Over Time", x = "Date", y = "Percentage Change", colour = "Series") +
  theme_minimal() +
  theme(legend.position = "bottom")

# Plot 3: Work Mobility and Work-Related Spending
p3 <- ggplot(merged_data, aes(x = date)) +
  geom_line(aes(y = MA_work, colour = "Work Mobility")) +
  geom_line(aes(y = aggregate, colour = "Aggregate Spending")) +
  labs(title = "Work Mobility and Aggregate Spending Over Time", x = "Date", y = "Percentage Change", colour = "Series") +
  theme_minimal() +
  theme(legend.position = "bottom")

# Plot 4: Transit Mobility and Work-Related Spending
p4 <- ggplot(merged_data, aes(x = date)) +
  geom_line(aes(y = MA_transit, colour = "Transit Mobility")) +
  geom_line(aes(y = aggregate, colour = "Aggregate Spending")) +
  labs(title = "Transit Mobility and Aggregate Spending Over Time", x = "Date", y = "Percentage Change", colour = "Series") +
  theme_minimal() +
  theme(legend.position = "bottom")

# Plot 5: Parks Mobility and Work-Related Spending
p5 <- ggplot(merged_data, aes(x = date)) +
  geom_line(aes(y = MA_parks, colour = "Parks Mobility")) +
  geom_line(aes(y = aggregate, colour = "Aggregate Spending")) +
  labs(title = "Parks Mobility and Aggregate Spending Over Time", x = "Date", y = "Percentage Change", colour = "Series") +
  theme_minimal() +
  theme(legend.position = "bottom")

p5 <- ggplot(merged_data, aes(x = date)) +
  geom_line(aes(y = MA_residential, colour = "Residential Mobility")) +
  geom_line(aes(y = aggregate, colour = "Aggregate Spending")) +
  labs(title = "Parks Mobility and Aggregate Spending Over Time", x = "Date", y = "Percentage Change", colour = "Series") +
  theme_minimal() +
  theme(legend.position = "bottom")

p6 <- ggplot(merged_data, aes(x = date)) +
  geom_line(aes(y = MA_retail, colour = "Retail Mobility")) +
  geom_line(aes(y = aggregate, colour = "Aggregate Spending")) +
  labs(title = "Retail Mobility and Aggregate Spending Over Time", x = "Date", y = "Percentage Change", colour = "Series") +
  theme_minimal() +
  theme(legend.position = "bottom")
# Combine plots into a single object for display or saving
plots <- list(p1, p2, p3, p4, p5)

# Use the grid.arrange function to combine them
combined_plots <- do.call(grid.arrange, c(plots, ncol = 1))

# Save the combined plot to a PDF
ggsave("combined_plots.pdf", combined_plots, device = "pdf", title = "Changes in and Debit/Credit Card Spending", width = 8, height = 10)

