# install.packages('../../levshina/Rling_1.0.tar.gz',
                 # type = 'source', repos = NULL)
data(doenLaten, package = 'Rling')
head(doenLaten)

install.packages('tidyverse')
readr::write_csv(doenLaten, 'data.csv')

renv::snapshot()
install.packages('Hmisc')
