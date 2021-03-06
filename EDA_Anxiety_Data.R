
# Exploratory Data Analysis -----------------------------------------------
# Leila Darwiche ----------------------------------------------------------

# load packages
library(tidyverse)
library(readxl)
library(forcats)
library(gghighlight)

# load data
UShousehold <- read_excel("data/datahousehold.xlsx", 
                          sheet = "US")
ILhousehold <- read_excel("data/datahousehold.xlsx", 
                          sheet = "IL")
Anxiety <- read_csv("data/Indicators_of_Anxiety_or_Depression_Based_on_Reported_Frequency_of_Symptoms_During_Last_7_Days.csv") %>%
  filter(Indicator == "Symptoms of Anxiety Disorder") %>%
  filter(Group == "National Estimate")

# Making Subsets ----------------------------------------------------------

US_age <- UShousehold %>%
  filter(Category %in% c("18_29","30_39","40_49","50_59","60_69","70_79","80+"))

IL_age <- ILhousehold %>%
  filter(Category %in% c("18_29","30_39","40_49","50_59","60_69","70_79","80+"))

US_sex <- UShousehold %>%
  filter(Category %in% c("Female","Male"))

IL_sex <- ILhousehold %>%
  filter(Category %in% c("Female","Male"))

US_total <- UShousehold %>%
  filter(Category == "Total") %>%
  select(-Category) %>%
  rename(Several_Days = Sev_Anx,
         No_Anxiety = No_Anx,
         Half_Days = Half_Anx,
         Every_Day = Every_Anx,
         No_Report = NA_Anx) %>%
  gather(key = Anxiety_Level, value = Percentage, -Week)

IL_total <- ILhousehold %>%
  filter(Category == "Total") %>%
  select(-Category) %>%
  rename(Several_Days = Sev_Anx,
         No_Anxiety = No_Anx,
         Half_Days = Half_Anx,
         Every_Day = Every_Anx,
         No_Report = NA_Anx) %>%
  gather(key = Anxiety_Level, value = Percentage, -Week)

US_Employment <- UShousehold %>%
  filter(Category %in% c("Employment_Loss_HH","No_Employment_Loss_HH"))

IL_Employment <- ILhousehold %>%
  filter(Category %in% c("Employment_Loss_HH","No_Employment_Loss_HH"))

US_age_adjust <- US_age %>%
  mutate(total = No_Anx+Sev_Anx+Every_Anx+Half_Anx,
         No_Anx = No_Anx/total,
         Sev_Anx = Sev_Anx/total,
         Every_Anx = Every_Anx/total,
         Half_Anx = Half_Anx/total)

IL_age_adjust <- IL_age %>%
  mutate(total = No_Anx+Sev_Anx+Every_Anx+Half_Anx,
         No_Anx = No_Anx/total,
         Sev_Anx = Sev_Anx/total,
         Every_Anx = Every_Anx/total,
         Half_Anx = Half_Anx/total)

# Exploration -------------------------------------------------------------

# employment
  UShousehold %>%
    filter(Category == "Total") %>%
    mutate(some_anx = (1 - No_Anx)) %>%
    summarise(mean(some_anx))
  x <- UShousehold %>%
    filter(Category == "Employment_Loss_HH") %>%
    mutate(some_anx = (1 - No_Anx)) %>%
    summarise(mean(some_anx))
  x/0.7149187		

# anxiety over time
  ggplot(data = US_total, aes(x= Week, y = Percentage, color = Anxiety_Level)) +
    geom_point() +
    geom_line() 
  
  ggplot(data = IL_total, aes(x= Week, y = Percentage, color = Anxiety_Level)) +
    geom_point() +
    geom_line()

# gender
  ggplot(data = US_sex, aes(x= Week, y = 100*(1-No_Anx), color = Category)) +
    geom_point() +
    geom_line() +
    labs(title = str_wrap("Though trends of anxiety by sex were similar, more females consistently reported having symptoms of anxiety than males.", 45), y = "% reporting some symptoms of anxiety", subtitle = "Data from Household Pulse Survey", color = "Sex")+
    theme(plot.title = element_text(size = 19, face ="bold" ),
          panel.background = element_blank(),
          axis.line = element_line(color = "black", size = .5),
          panel.grid.major.y = element_line(color = " grey", size = .25),
          panel.grid.minor.y = element_line(color = " grey", size = .25),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank()) +
    ylim(55,100) + 
    gghighlight(Category == "Female", keep_scales = TRUE)

# employment pt 2
  ggplot(data = US_Employment, aes(x= Week, y = 100*(1-No_Anx), color = Category)) +
    geom_point() +
    geom_line() +
    scale_color_manual(name = "Household Employment Status",
                       labels = c("Member lost employment",
                                  "No members lost employment"),
                       values = c("Employment_Loss_HH" = "#619CFF", "No_Employment_Loss_HH" = "#f8766D")) +
    labs(title = str_wrap("For those who had members of their household lose employment, reports of anxiety were much higher.", 60), y = "% reporting some symptoms of anxiety", subtitle = "Data from Household Pulse Survey")+
    theme(plot.title = element_text(size = 19, face ="bold" ),
          panel.background = element_blank(),
          axis.line = element_line(color = "black", size = .5),
          panel.grid.major.y = element_line(color = " grey", size = .25),
          panel.grid.minor.y = element_line(color = " grey", size = .25),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank()) +
    ylim(40,100) +
    gghighlight(Category == "No_Employment_Loss_HH", keep_scales = TRUE,  use_direct_label = FALSE)

# age
  ggplot(data = US_age_adjust, aes(x= Week, y = 100*(1-No_Anx), color = Category)) +
    geom_point() +
    geom_line() +
    labs(title = str_wrap("Reports of anxiety were much higher among younger age groups.", 45), y = "% reporting some symptoms of anxiety", subtitle = "Data from Household Pulse Survey") +
    scale_color_manual(name = "Age Group",
                       labels = c("18-29", "30-39", "40-49", "50-59", "60-69", "70-79","80+"),
                       values = c("18_29" = "#f8766D", "30_39" = "#bb9d00", "40_49" = "#00b81f", "50_59" = "#00c0b8", "60_69" = "#619CFF", "70_79" = "#e76bf3","80+" = "#ff6c90")) +
    theme(plot.title = element_text(size = 19, face ="bold" ),
          panel.background = element_blank(),
          axis.line = element_line(color = "black", size = .5),
          panel.grid.major.y = element_line(color = " grey", size = .25),
          panel.grid.minor.y = element_line(color = " grey", size = .25),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank()) +
    gghighlight(Category == "80+", keep_scales = TRUE,  use_direct_label = FALSE)

# overall anxiety
  Anxiety <- subset(Anxiety, !is.na(Value)) %>% mutate(`Time Period Start Date` = fct_reorder(`Time Period Start Date`, `Time Period`))
  ggplot(data = Anxiety, aes(x= `Time Period Start Date`, y = Value, group =1)) +
    geom_point(color = "#31708E") +
    geom_line(color = "#31708E") +
    labs(title = str_wrap("Reports of symptoms of anxiety disorders were much higher during the pandemic.", 45), x = "Week", y = "% reporting", subtitle = "Data from Household Pulse Survey") +
    theme(plot.title = element_text(size = 19, face ="bold" ),
          panel.background = element_blank(),
          axis.line = element_line(color = "black", size = .5),
          panel.grid.major.y = element_line(color = " grey", size = .25),
          panel.grid.minor.y = element_line(color = " grey", size = .25),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          axis.text.x =  element_text(angle = 90)) +
    ylim(0,40) +
    geom_hline(yintercept = 8.1, color = "#57bc90")

# illinois
  ggplot(data = IL_age_adjust, aes(x= Week, y = No_Anx, color = Category)) +
    geom_point() +
    geom_line()
  
  ggplot(data = IL_age, aes(x= Week, y = Every_Anx, color = Category)) +
    geom_point() +
    geom_line()
  #ggplot(data = IL_Employment, aes(x= Week, y = No_Anx, color = Category)) +
  #  geom_point() +
  #  geom_line()
  ggplot(data = IL_sex, aes(x= Week, y = No_Anx, color = Category)) +
    geom_point() +
    geom_line()

# recent anxiety
  recent_anxiety <- Anxiety[24:32,]
  mean(Anxiety$Value, na.rm = TRUE)
  mean(recent_anxiety$Value, na.rm = TRUE)
