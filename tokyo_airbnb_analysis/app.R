# NOTE: may need to run in R Studio
# currently not working in VS Code

# clear global environment using rm(list = ls())


# install and load package to use R in VS Code
library("languageserver")

# install and load packages for code
# comment out install.packages for shinyapp
library("tidyverse") # cleaning
library("ggplot2") # visualization
library("ggiraph") # interaction
library("dplyr") # manipulation
library("pillar") # because arrange is not working
library("patchwork") # plot layout
library("shiny")
library("shinydashboard")


# use read_csv if using kaggle - change path if in different folder
tokyo_airbnb_data <-
  read.csv("tokyo_airbnb_2019_data.csv")

# remove neighbourhood_groups column - empty and unnecessary
tokyo_airbnb_data <- tokyo_airbnb_data[, -5]


# which hosts are the most popular?
popularity <- tokyo_airbnb_data %>%
  group_by(host_id, host_name) %>%
  summarize(total_airbnbs = n(), total_reviews = sum(number_of_reviews),
            avg_monthly_reviews = round(mean(reviews_per_month), digits = 2),
            reviews_per_airbnb = round(total_reviews / total_airbnbs,
                                       digits = 2)) %>%
  arrange(desc(total_reviews)) %>%
  head(10)

# add new column for interaction
popularity <- popularity %>%
  mutate(tooltip_text = paste0(host_name, "\n", total_reviews,
                               " total reviews\n", avg_monthly_reviews,
                               " average monthly reviews\n", reviews_per_airbnb,
                               " ratio of total reviews to total airbnbs"))

# plot
p1 <- ggplot(data = popularity) +
  geom_col_interactive(mapping = aes(x = reorder(host_name, -total_reviews),
                                     y = total_reviews, tooltip = tooltip_text,
                                     data_id = host_name), fill = "#3296ed", size = 0.5) +
  labs(title = "Top Hosts and Reviews",
       subtitle = "(sorted by Total Airbnb Reviews)", x = "", y = "Total\n") +
  theme(axis.text.x = element_blank(), axis.text.y = element_text(size = 20),
        axis.title = element_text(size = 24, face = "bold"),
        plot.title = element_text(size = 30, face = "bold"),
        plot.subtitle = element_text(size = 24, face = "bold"),
        aspect.ratio = 1 / 6,
        panel.background = element_rect(fill = "#1B1B1B"))

p2 <- ggplot(data = popularity) +
  geom_col_interactive(mapping = aes(x = reorder(host_name, -total_reviews),
                                     y = avg_monthly_reviews, tooltip = tooltip_text,
                                     data_id = host_name), fill = "#77b9f2",
                       size = 0.5) + labs(x = "", y = "Average Monthly\n\n") +
  theme(axis.text.x = element_blank(), axis.text.y = element_text(size = 20),
        axis.title = element_text(size = 24, face = "bold"),
        aspect.ratio = 1 / 6,
        panel.background = element_rect(fill = "#1B1B1B"))

p3 <- ggplot(data = popularity) +
  geom_col_interactive(mapping = aes(x = reorder(host_name, -total_reviews),
                                     y = reviews_per_airbnb, tooltip = tooltip_text,
                                     data_id = host_name), fill = "#9d53f2",
                       size = 0.5) + labs(x = "\nHost Name",
                                          y = "Ratio of Reviews to Airbnbs\n") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, size = 20),
        axis.text.y = element_text(size = 20),
        axis.title = element_text(size = 24, face = "bold"),
        aspect.ratio = 1 / 6,
        panel.background = element_rect(fill = "#1B1B1B"))

plot1 <- girafe(code = print(p1 / p2 / p3),
                width_svg = 30, height_svg = 15) %>%
  girafe_options(opts_hover(css = "stroke-width:2;stroke:#ffffff"),
                 opts_hover_inv(css = ""),
                 opts_selection(css = ""),
                 opts_selection_inv(css = "opacity:0.6;"))


# which airbnbs only require at minimum 10 nights or less?
ten_night_duration <- tokyo_airbnb_data %>%
  filter(minimum_nights <= 10)

# group by host, neighborhood
ten_night_hosts <- ten_night_duration %>%
  group_by(host_id, host_name) %>%
  summarize(avg_duration = round(mean(minimum_nights), digits = 2)) %>%
  arrange(desc(avg_duration)) %>%
  head(10)

ten_night_neighbor <- ten_night_duration %>%
  group_by(neighbourhood) %>%
  summarize(avg_duration = round(mean(minimum_nights), digits = 2)) %>%
  arrange(desc(avg_duration)) %>%
  head(10)

# add new column for interaction
ten_night_hosts <- ten_night_hosts %>%
  mutate(tooltip_text = paste0(host_name, "\n", avg_duration,
                               " days"))

ten_night_neighbor <- ten_night_neighbor %>%
  mutate(tooltip_text = paste0(neighbourhood, "\n", avg_duration,
                               " days"))

# plot
t1 <- ggplot(data = ten_night_hosts, aes(x = reorder(host_name, -avg_duration),
                                         y = avg_duration,
                                         tooltip = tooltip_text,
                                         data_id = host_name)) +
  geom_col_interactive(fill = "#77b9f2") +
  labs(title = "Ten or Less Days Average Duration", subtitle = "(by Host)",
       x = "\nHost Name", y = "Average Duration\n") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, size = 20),
        axis.text.y = element_text(size = 20),
        axis.title = element_text(size = 24, face = "bold"),
        plot.title = element_text(size = 30, face = "bold"),
        plot.subtitle = element_text(size = 24, face = "bold"),
        panel.background = element_rect(fill = "#1B1B1B")) +
  scale_y_continuous(limits = c(0, 10))

t2 <- ggplot(data = ten_night_neighbor,
             aes(x = reorder(neighbourhood, -avg_duration),
                 y = avg_duration, tooltip = tooltip_text,
                 data_id = neighbourhood)) +
  geom_col_interactive(fill = "#9d53f2") +
  labs(subtitle = "(by Neighborhood)", x = "\nNeighborhood", y = "") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, size = 20),
        axis.text.y = element_blank(),
        axis.title = element_text(size = 24, face = "bold"),
        plot.subtitle = element_text(size = 24, face = "bold"),
        panel.background = element_rect(fill = "#1B1B1B"),
        plot.margin = unit(c(0.5, 0.5, 0.5, -0.5), "cm")) +
  scale_y_continuous(limits = c(0, 10))

plot2 <- girafe(code = print(t1 + t2), width_svg = 30, height_svg = 15) %>%
  girafe_options(opts_hover(css = "stroke-width:2;stroke:#ffffff"),
                 opts_hover_inv(css = ""),
                 opts_selection(css = ""),
                 opts_selection_inv(css = "opacity:0.6;"))


# which hosts have the cheapest airbnbs by room type?
cheap_hosts_e <- tokyo_airbnb_data %>%
  filter(room_type == "Entire home/apt") %>%
  group_by(host_id, host_name) %>%
  summarize(avg_price = mean(price)) %>%
  arrange(avg_price, host_name) %>%
  head(20)

cheap_hosts_p <- tokyo_airbnb_data %>%
  filter(room_type == "Private room") %>%
  group_by(host_id, host_name) %>%
  summarize(avg_price = mean(price)) %>%
  arrange(avg_price, host_name) %>%
  head(20)

cheap_hosts_s <- tokyo_airbnb_data %>%
  filter(room_type == "Shared room") %>%
  group_by(host_id, host_name) %>%
  summarize(avg_price = mean(price)) %>%
  arrange(avg_price, host_name) %>%
  head(20)

# how do prices vary based on neighborhood?
cheap_neighbor <- tokyo_airbnb_data %>%
  group_by(neighbourhood, room_type) %>%
  summarize(avg_price = mean(price)) %>%
  arrange(avg_price, neighbourhood)

c1 <- ggplot(data = cheap_neighbor, aes(neighbourhood, avg_price,
                                        fill = room_type)) + geom_col() +
  scale_fill_manual(values = c("#3296ed", "#77b9f2", "#9d53f2")) +
  labs(title = "Average Prices Per Neighborhood", x = "Average Price",
       y = "Neighborhood") +
  guides(fill = guide_legend(title = "Room Type")) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5),
        legend.position = "bottom", legend.box = "horizontal",
        panel.background = element_rect(fill = "#1B1B1B"))


# create interactive shiny dashboard
ui <- dashboardPage(dashboardHeader(disable = TRUE),
                    dashboardSidebar(disable = TRUE),
                    dashboardBody(
                      tags$head(tags$style(HTML("
                                                .content-wrapper, .right-side {
                                                background-color:#1B1B1B;
                                                }"))),
                      fluidRow(
                        box(width = 12, girafeOutput("reviewsPlot")),
                        box(width = 12, girafeOutput("durationPlot")))))
server <- function(input, output) {
  output$reviewsPlot <- renderGirafe({
    plot1
  })
  output$durationPlot <- renderGirafe({
    plot2
  })
}
shinyApp(ui, server)