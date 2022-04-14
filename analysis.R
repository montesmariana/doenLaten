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

prettify_model <- function(model, mydata) {
  variables <- map_df(colnames(mydata), function(v) {
    if (class(mydata[[v]]) == 'factor') {
      values <- names(table(mydata[[v]]))
      reference <- levels(mydata[[v]])[[1]]
    } else {
      values <- ''
      reference <- ''
    }
    tibble(varname = v, varvalues = values, reference = reference, class = class(mydata[[v]]))
  }) %>% 
    filter(class == 'numeric' | varvalues != reference) %>% 
    mutate(varcode = paste0(varname, varvalues)) %>% 
    filter(varcode %in% colnames(model.matrix(model))) %>% 
    mutate(varparse = if_else(class == 'factor', sprintf("<strong>%s</strong> vs. %s", varvalues, reference), ''))
  
  response <- all.vars(formula(model))[[1]]
  predicted_response <- levels(mydata[[response]])[[2]]
  
  as_tibble(data.frame(summary(model)$coefficients), rownames = "Variables") %>% 
    left_join(variables, by = c('Variables' = 'varcode')) %>% 
    rename(Significance = `Pr...z..`) %>% 
    mutate(varparse = if_else(Variables == '(Intercept)', 'Intercept', varparse),
           varname = if_else(Variables == '(Intercept)', '', varname),
           isSignificant = Significance < 0.05,
           Odds = exp(Estimate),
           across(c('Significance', 'Estimate', 'Odds'), ~cell_spec(sprintf("%.3f", .x), bold = isSignificant)),
           varname = text_spec(varname, extra_css = "font-variant:small-caps;")
           ) %>% 
    select(
      ` ` = varname,
      `Independent variables` = varparse,
      Estimate,
      Significance,
      `Odds Ratio` = Odds,
    ) %>% 
    kable(escape = F, booktabs = T, caption = sprintf("Logistic regression model predicting *%s*.", predicted_response)) %>% 
    kable_paper() %>% 
    collapse_rows(columns = 1, valign = 'top')
  
}
