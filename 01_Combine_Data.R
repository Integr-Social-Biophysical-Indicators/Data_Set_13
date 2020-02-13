# Load the main packages
library(tidyverse)
library(googledrive)
library(readxl)



# identify this file by it ID
google_file <- drive_get(as_id('1QFxp1E7qdoHObIibww4g5PDx6o_qH64vZEfrtxiIjgE'))


# download the file
drive_download(google_file,
               path = paste0('Input_Data/', google_file$name),
               overwrite = TRUE)


# read the file
questions <- read_excel('Input_Data/NRS Data Dictionary.xlsx', sheet = 2, skip = 1) 
answers <- read_excel('Input_Data/NRS Data Dictionary.xlsx', sheet = 3, skip = 1) 

# transform the answer
answers_transformed <-
  answers %>%
  rename(Variable = Value, Value = `...2`, Sublabel = Label) %>%
  fill(Variable) %>%
  filter(!is.na(Value)) %>%
  group_by(Variable) %>%
  nest() %>%
  mutate(Value = map(data, 'Value'),
         Sublabel = map(data, 'Sublabel')) %>%
  mutate(Values = map_chr(Value, ~ paste(.x, collapse = ',\n')),
         Sublabels = map_chr(Sublabel, ~ paste(.x, collapse = ',\n'))) %>%
  select(Variable, Values, Sublabels)
  

# combine them
question_answers <-
  questions %>%
  filter(!is.na(Position)) %>%
  left_join(answers_transformed, by = 'Variable') %>%
  select(Variable:Label, Values, Sublabels, everything())


# save as a csv file
write_csv(question_answers, 'Output_Data/NRS_Data_Dictionary.csv')


# # save file on Google Drive for the first time
# # NOTE: when uploading to Google Drive some cells are automatically converted into other data types
# # as a result Sublabels '1, 2, 3' becomes date '1, 2, 2003'
# drive_upload(media = 'Output_Data/NRS_Data_Dictionary.csv',
#              path = as_id('1azOKbtLvI4M5nBUCPdbczJVddbMI43Jc'),
#              name = 'NRS_Data_Dictionary.csv',
#              type = 'spreadsheet')


# update file on Google Drive
drive_update(file = as_id('1gab8xx3XmVR1i3inEgSkBSBwKti96GqaqEZqX7Zq8ZA'),
             media = 'Output_Data/NRS_Data_Dictionary.csv')

