library(tidyverse)
library(Hmisc)

library(tidyverse)
library(Hmisc)

data_file <- 'data.csv'
read_data <- function(data_file) {
  read_csv(data_file, show_col_types = F)
}
refactor_data <- function(raw_data) {
  raw_data %>% mutate(across(where(is.character), factor),
                      Aux = fct_relevel(Aux, 'laten'),
                      Country = fct_relevel(Country, 'NL'))
}
model <- function(mydata) {
  glm(Aux ~ Causation + EPTrans + Country, data = mydata,
      family = binomial)
}

get_c <- function(model, mydata) {
  somers2(fitted(model), as.numeric(mydata$Aux)-1)[['C']]  
}
