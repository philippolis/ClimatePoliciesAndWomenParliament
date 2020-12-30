library(tidyverse)
library(tabulizer)
library(purrr)


gw2015 <- "https://germanwatch.org/sites/germanwatch.org/files/publication/10333.pdf" %>% extract_tables(pages = c(28:31)) 
gw2016 <- "https://germanwatch.org/sites/germanwatch.org/files/publication/13503.pdf" %>% extract_tables(pages = c(27:31))  
gw2017 <- "https://germanwatch.org/sites/germanwatch.org/files/publication/16411.pdf" %>% extract_tables(pages = c(26:30))  
gw2018 <- "https://germanwatch.org/sites/germanwatch.org/files/publication/20432.pdf" %>% extract_tables(pages = c(27:30))  
gw2019 <- "https://germanwatch.org/sites/germanwatch.org/files/Global%20Climate%20Risk%20Index%202019_2.pdf" %>% extract_tables(pages = c(28:31)) 


for (j in c("gw2015", "gw2016", "gw2017", "gw2018", "gw2019")){
  
  l <- eval(parse(text = j))
  n <- length(l)
  for (i in 1:n){
    assign(paste0(j, ".", i), map(l, as.data.frame) %>% 
             `[[`(i) %>% 
             `[`(-1,c(1,2)))
  }
}
for (i in 2:4){
  assign(paste0("gw2019", ".", i), map(gw2019, as.data.frame) %>% 
           `[[`(i) %>% 
           `[`(-1,c(2,3)))
}
assign(paste0("gw2016", ".", 2), map(gw2016, as.data.frame) %>% 
         `[[`(2) %>% 
         `[`(-1,c(1)) %>% 
         as.data.frame())
assign(paste0("gw2016", ".", 4), map(gw2016, as.data.frame) %>% 
         `[[`(4) %>% 
         `[`(-1,c(1,2)) %>% 
         as.data.frame())
rm(gw2016.1, gw2017.1)
colnames(gw2016.2) <- "V1"
colnames(gw2019.2) <- c("V1", "v2")
colnames(gw2019.3) <- c("V1", "v2")
colnames(gw2019.4) <- c("V1", "v2")
gw2016.2 <- gw2016.2 %>% 
  separate(V1, into = c("V1", "V2"))
for (i in c("gw2015.1", "gw2015.2", "gw2015.3", "gw2015.4", 
            "gw2016.2", "gw2016.3", "gw2016.4", "gw2016.5", "gw2016.6",
            "gw2017.2", "gw2017.3", "gw2017.4", "gw2017.5",
            "gw2018.1", "gw2018.2", "gw2018.3", "gw2018.4",
            "gw2019.1", "gw2019.2", "gw2019.3", "gw2019.4")){
  
  df <- eval(parse(text = i))
  
  if (df[1,1] == "Rank" | df[1,1] == "Total"){
    assign(i, df[-1,] %>% 
             as.data.frame() %>% 
             filter(V1 != "")
    )
  } else {
    assign(i, df %>%
             filter(V1 != "")
    )
  }
}
for (j in c("gw2015.1", "gw2015.2", "gw2015.3", "gw2015.4", 
            "gw2016.2", "gw2016.3", "gw2016.4", "gw2016.5", "gw2016.6",
            "gw2017.2", "gw2017.3", "gw2017.4", "gw2017.5",
            "gw2018.1", "gw2018.2", "gw2018.3", "gw2018.4",
            "gw2019.1", "gw2019.2", "gw2019.3", "gw2019.4")) {
  df <- eval(parse(text = j))
  colnames(df) <- c("CRI_ranking", "pais")
  assign(j, df)
}



assign("gw2015_final", 
       bind_rows(eval(parse(text = "gw2015.1")),
                 eval(parse(text = "gw2015.2")),
                 eval(parse(text = "gw2015.3")),
                 eval(parse(text = "gw2015.4"))
       )
)  
assign("gw2016_final", 
       bind_rows(eval(parse(text = "gw2016.2")),
                 eval(parse(text = "gw2016.3")),
                 eval(parse(text = "gw2016.4")),
                 eval(parse(text = "gw2016.5")),
                 eval(parse(text = "gw2016.6"))
       )
)
assign("gw2017_final", 
       bind_rows(eval(parse(text = "gw2017.2")),
                 eval(parse(text = "gw2017.3")),
                 eval(parse(text = "gw2017.4")),
                 eval(parse(text = "gw2017.5"))
       )
)
assign("gw2018_final", 
       bind_rows(eval(parse(text = "gw2018.1")),
                 eval(parse(text = "gw2018.2")),
                 eval(parse(text = "gw2018.3")),
                 eval(parse(text = "gw2018.4"))
       )
)
assign("gw2019_final", 
       bind_rows(eval(parse(text = "gw2019.1")),
                 eval(parse(text = "gw2019.2")),
                 eval(parse(text = "gw2019.3")),
                 eval(parse(text = "gw2019.4"))
       )
)

rm(gw2015.1, gw2015.2, gw2015.3, gw2015.4,
   gw2016.2, gw2016.3, gw2016.4, gw2016.5, gw2016.6,
   gw2017.2, gw2017.3, gw2017.4, gw2017.5,
   gw2018.1, gw2018.2, gw2018.3, gw2018.4,
   gw2019.1, gw2019.2, gw2019.3, gw2019.4)
gw2016_final <- gw2016_final[-20,]



for (i in c("gw2015_final", "gw2016_final", "gw2017_final", "gw2018_final", "gw2019_final")){
  df <- eval(parse(text = i))
  assign(i, df %>% 
           mutate(CRI_ranking = as.numeric(CRI_ranking)))
}



setdiff(gw2015_final$pais, gw2016_final$pais)
setdiff(gw2015_final$pais, gw2017_final$pais)
setdiff(gw2015_final$pais, gw2018_final$pais)
