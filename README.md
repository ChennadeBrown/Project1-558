
-   [Introduction](#introduction)
-   [Packages Required](#packages-required)
-   [Accessing the Data](#accessing-the-data)
-   [Data Analysis](#data-analysis)

# Introduction

This vignette will go through the steps of reading and summarizing data
from an API. We will utilize the Covid19 API.

# Packages Required

The following packages were used to utilize the functions needed for
interacting with the API and manipulating the retrieved data:  
\* `httr`: Used to retrieve data from APIs.  
\* `jsonlite`: Functions used to manipulate JSON data.  
\* `tidyverse`: Functions used to manipulate and reshape data.  
\* `dplyr`: Function that contains a set of tools for manipulating data
in R.

``` r
library(httr)
library(jsonlite)
library(tidyverse)
library(dplyr)
```

# Accessing the Data

First we will access data from the API regarding confirmed Covid 19
Cases for Norway and Switzerland during the time frame from March 1,
2020 - April 1, 2020 for comparison. This will be achieved using the GET
function from the `httr` package to return information from the API.

``` r
getCountry <- GET("https://api.covid19api.com/country/Switzerland/status/confirmed?from=2020-03-01T00:00:00Z&to=2020-04-01T00:00:00Z")

getCountry2 <- GET("https://api.covid19api.com/country/Norway/status/confirmed?from=2020-03-01T00:00:00Z&to=2020-04-01T00:00:00Z")
```

We will now review the contents of the returned data. The content
function with the text parameter converts the raw data to JSON.

``` r
getCountryText <- content(getCountry, "text")
getCountryText2 <- content(getCountry2, "text")
```

We will now covert the raw data into JSON format which will allow us to
PARSE the data and output a data frame using the jsonlite package that
was previously installed.

``` r
getCountryJs <- fromJSON(getCountryText, flatten = TRUE)
getCountryJs2 <- fromJSON(getCountryText2, flatten = TRUE)
```

We will convert the parsed JSON data for Norway & Switzerland into a
tibble for our analysis.

``` r
getCountryJsTb <- as_tibble(getCountryJs)
```

``` r
getCountryJs2Tb <- as_tibble(getCountryJs2)
```

We will now combine the data for Norway and Switzerland into one data
frame using the rbind function and remove the empty columns Province,
City, & CityCode.

``` r
NorSwiz <- function(df1, df2) {rbind(df1, df2)}
Combo <- NorSwiz(df1 = getCountryJsTb, df2 = getCountryJs2Tb)
Combo$Province <- NULL
Combo$City <- NULL
Combo$CityCode <- NULL
```

The following functions will allow the user to query the Norway and
Switzerland API by entering the column names or all.

``` r
ConfirmedSwiss <- function(type = "all"){
  OutputDatSwiss <- GET("https://api.covid19api.com/country/Switzerland/status/confirmed?from=2020-03-01T00:00:00Z&to=2020-04-01T00:00:00Z")
    DataSwiss <- fromJSON(rawToChar(OutputDatSwiss$content))
  if(type!="all"){DataSwiss <- DataSwiss %>% select(type, Country, CountryCode, Cases, Lat, Lon, Date, Status)}
  return(DataSwiss)}
ConfirmedSwiss("Country")
```

``` r
ConfirmedNor <- function(type = "all"){
  OutputDatNor <- GET("https://api.covid19api.com/country/Norway/status/confirmed?from=2020-03-01T00:00:00Z&to=2020-04-01T00:00:00Z")
    DataNor <- fromJSON(rawToChar(OutputDatNor$content))
  if(type!="all"){DataNor <- DataNor %>% select(type, Country, CountryCode, Cases, Lat, Lon, Date, Status)}
  return(DataNor)}
ConfirmedNor("CountryCode")
```

The following functions return Day One Data for Africa & Mexico for the
first recorded case. We will go through the same steps outlined above to
retrieve and parse the data from the API.

``` r
DayOneDataSa <- GET(
  url = "https://api.covid19api.com/dayone/country/south-africa/status/confirmed")
DayOneDataMex <- GET(
  url = "https://api.covid19api.com/dayone/country/mexico/status/confirmed")

DayOneDataText <- content(DayOneDataSa, "text")
DayOneDataTextMex <- content(DayOneDataMex, "text")

DayOneDataJson <- fromJSON(DayOneDataText, flatten = TRUE)
DayOneDataJsonMex <- fromJSON(DayOneDataTextMex, flatten = TRUE)

DayOneDfSa <- as_tibble(DayOneDataJson)
DayOneDfMex <- as_tibble(DayOneDataJsonMex)
```

We will combine the data sets for the analysis.

``` r
SaMex <- function(df1, df2) {rbind(df1, df2)}
Day1 <- SaMex(df1 = DayOneDfSa, df2 = DayOneDfMex)

Day1$Province <- NULL
Day1$City <- NULL
Day1$CityCode <- NULL
```

These functions will allow the user to query the Day One Mexico and Day
One South Africa APIs based on the columns entered by the user. The Day1
data set will be used in the analysis.

``` r
DayOneSa <- function(type = "all"){
  OutputDat <- GET("https://api.covid19api.com/dayone/country/south-africa/status/confirmed")
    DataSa <- fromJSON(rawToChar(OutputDat$content))
  if(type!="all"){DataSa <- DataSa %>% select(type, Country, CountryCode, Cases, Lat, Lon, Date)}
  return(DataSa)}
DayOneSa("CountryCode")
```

``` r
DayOneMex <- function(type = "all"){
  OutputDatMex <- GET("https://api.covid19api.com/dayone/country/mexico/status/confirmed")
    DataMex <- fromJSON(rawToChar(OutputDatMex$content))
  if(type!="all"){DataMex <- DataMex %>% select(type, Country, CountryCode, Cases, Lat, Lon, Date)}
  return(DataMex)}
DayOneMex("CountryCode")
```

We will now look at summary data which contains a summary of new and
total cases per country which is updated daily utilizing the steps
outlined above to retrieve and parse data from the API.

``` r
resp2 <- GET("https://api.covid19api.com/summary")

resp2Text <- content(resp2, "text")
resp2Json <- fromJSON(resp2Text, flatten = TRUE)

# Save data frame as resp1Df and remove the ID column.
resp2Df <- as.data.frame(resp2Json$Countries)

resp2Df$ID <- NULL
```

``` r
# This is a function allows the user to return NewDeaths, TotalDeaths,& NewRecovered, or all of the data based on inputs from the Summary API. We will use the above returned data set resp2Df for the analysis.

Summary <- function(type = "all"){
  OutputAPI <- GET("https://api.covid19api.com/summary")
    data <- fromJSON(rawToChar(OutputAPI$content))
    data2 <- data$Countries
  if(type!="all"){data2 <- data2 %>% select(type, Country, CountryCode,  NewDeaths, TotalDeaths, NewRecovered)}
  return(data2)}
Summary("Country")
```

# Data Analysis

We will create a contingency table that shows the occurrences of
confirmed cases between March - April 2020 for Switzerland and Norway.
Each country had a confirmed case during this time frame.

``` r
tbl <- table(Combo$Country, Combo$Status)
tbl
```

    ##              
    ##               confirmed
    ##   Norway             32
    ##   Switzerland        32

Below is a box plot representing confirmed cases in Norway and
Switzerland between March - April 2020. The output shows that
Switzerland had a higher number of confirmed cases.

``` r
ggplot(Combo, aes(x = Cases, y = Country)) +
geom_boxplot() + geom_jitter(aes(color = Status)) + ggtitle("Boxplot for Confirmed Cases")
```

![](README_files/figure-gfm/unnamed-chunk-17-1.png)<!-- --> The
following code calculates numerical summaries for daily cases confirmed
for the two countries. The mean case count per day for Norway was 1,759
cases and the mean case count per day for Switzerland was 5,402 cases.

``` r
Combo %>%
  group_by(Country) %>%
  summarize(Avg = mean(Cases), Sd = sd(Cases), Median = median(Cases), IQR =    IQR(Cases))
```

    ## # A tibble: 2 x 5
    ##   Country       Avg    Sd Median   IQR
    ##   <chr>       <dbl> <dbl>  <dbl> <dbl>
    ## 1 Norway      1760. 1590.   1398 2720.
    ## 2 Switzerland 5402. 5967.   2450 9767.

The following contingency table reports the number of confirmed case
statuses for south Africa and Mexico.

``` r
tbl2 <- table(Day1$Status, Day1$Country)
tbl2
```

    ##            
    ##             Mexico South Africa
    ##   confirmed    582          577

The following bar graph reports the number of confirmed case statuses
for South Africa and Mexico since day one which were similar.

``` r
ggplot(Day1, aes(x = Country)) + geom_bar(aes(fill = Status), position = "dodge") + xlab("Country") + scale_fill_discrete(name = "") + ggtitle("Confirmed Case Statuses")
```

![](README_files/figure-gfm/unnamed-chunk-20-1.png)<!-- -->

The following code calculates numerical summaries for daily cases
confirmed since Day 1 for the two countries. The mean case count for
Mexico was 1,418,233 cases and the mean case count for South Africa was
1,115,631 cases.

``` r
Day1 %>%
  group_by(Country) %>%
  summarize(Avg = mean(Cases), Sd = sd(Cases), Median = median(Cases), IQR =    IQR(Cases))
```

    ## # A tibble: 2 x 5
    ##   Country           Avg       Sd  Median      IQR
    ##   <chr>           <dbl>    <dbl>   <dbl>    <dbl>
    ## 1 Mexico       1422105. 1111133. 1261588 2001115.
    ## 2 South Africa 1118733.  867580.  901538 1146743

The following code creates a new variable (NewRatio = TotalDeaths/Total
Confirmed) that represents the ratio of total deaths to total confirmed
cases and appends to the Resp2Df which is based on total cases for
Countries that is updated daily.

``` r
resp2Df <- resp2Df %>% mutate(Ratio = TotalDeaths/TotalConfirmed)
```

The following code returns numerical summaries for total deaths among
all countries reported in this Summary API. The average total deaths was
24,941.

``` r
resp2Df %>%
    summarize(Avg = mean(TotalDeaths), Max = max(TotalDeaths), Sd = sd(TotalDeaths), Min = min(TotalDeaths))
```

    ## # A tibble: 1 x 4
    ##      Avg    Max     Sd   Min
    ##    <dbl>  <int>  <dbl> <int>
    ## 1 24951. 700285 81141.     0

The following code returns a scatter plot for the summary data set. The
plot shows there is minimal data on Newly Confirmed Cases and New
Deaths; however, the graph shows a positive correlation between newly
confirmed cases and new deaths.

``` r
g <- ggplot(resp2Df, aes(x = NewConfirmed, y = NewDeaths))+ labs(y="New Deaths", x = "New Confirmed")
g + geom_point() + ggtitle("Confirmed Cases vs Deaths")
```

![](README_files/figure-gfm/unnamed-chunk-24-1.png)<!-- -->
