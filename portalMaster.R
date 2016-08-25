library(tidyr)
library(dplyr)
library(stringr)
library(RCurl)
library(jsonlite)
library(aws.s3)

datasets <- fromJSON(
   "http://data.sandiego.gov/api/3/action/current_package_list_with_resources", 
   ##"~/Downloads/current_package_list_with_resources.json", 
   simplifyDataFrame = TRUE,
   flatten = TRUE,
   NULL)
datasets <- datasets$result[[1]]

dfs <- list(
  datasets = datasets,
  resources = data.frame(),
  tags = data.frame(),
  groups = data.frame()
)
 
for (i in 1:nrow(datasets)) {
    keys <- names(datasets)
    for (k in keys) {
        if (class(datasets[i, k]) == "list") {
            activeDF <- dfs[[k]]
            activeData <- datasets[i, k][[1]]
            activeData$ds_id <- datasets[i, "id"]
            activeDF <- bind_rows(activeDF, activeData)
            dfs[[k]] <- activeDF
        }
    }
}

## Essentials Only:
dfs$datasets <- select(dfs$datasets, 
                       -log_message,
                       -creator_user_id,
                       -resources,
                       -groups,
                       -tags)

dfs$resources <- select(dfs$resources,
                        -revision_id)

names(dfs$datasets) <- paste0("ds_", names(dfs$datasets))
names(dfs$resources) <- paste0("rs_", names(dfs$resources))
names(dfs$tags) <- paste0("tg_", names(dfs$tags))
names(dfs$groups) <- paste0("gr_", names(dfs$groups))


