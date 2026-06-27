library(vegan)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

dataX1 <- read.csv("X1.csv", header = FALSE, row.names = NULL)
dataX2 <- read.csv("X2.csv", header = FALSE, row.names = NULL)



D1 <- dist(dataX1)
D2 <- dist(dataX2)

print(D1)

# 执行 Mantel 检验
result <- mantel(D1, D2, method = "pearson", permutations = 999)
print(result)

library(linkET)

library(ggplot2)
library(dplyr)
#> 
#> 载入程辑包：'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
data("varechem", package = "vegan")
data("varespec", package = "vegan")

write.csv(varechem, file = "varechem.csv", row.names = FALSE)
write.csv(varespec, file = "varespec.csv", row.names = FALSE)

mantel <- mantel_test(varespec, varechem,
                      spec_select = list(Spec01 = 1:7,
                                         Spec02 = 8:18,
                                         Spec03 = 19:37,
                                         Spec04 = 38:44)) %>% 
  mutate(rd = cut(r, breaks = c(-Inf, 0.2, 0.4, Inf),
                  labels = c("< 0.2", "0.2 - 0.4", ">= 0.4")),
         pd = cut(p, breaks = c(-Inf, 0.01, 0.05, Inf),
                  labels = c("< 0.01", "0.01 - 0.05", ">= 0.05")))
#> `mantel_test()` using 'bray' dist method for 'spec'.
#> `mantel_test()` using 'euclidean' dist method for 'env'.
#> 
print(mantel)

qcorrplot(correlate(varechem), type = "lower", diag = FALSE) +
  geom_square() +
  geom_couple(aes(colour = pd, size = rd), 
              data = mantel, 
              curvature = nice_curvature()) +
  scale_fill_gradientn(colours = RColorBrewer::brewer.pal(11, "RdBu")) +
  scale_size_manual(values = c(0.5, 1, 2)) +
  scale_colour_manual(values = color_pal(3)) +
  guides(size = guide_legend(title = "Mantel's r",
                             override.aes = list(colour = "grey35"), 
                             order = 2),
         colour = guide_legend(title = "Mantel's p", 
                               override.aes = list(size = 3), 
                               order = 1),
         fill = guide_colorbar(title = "Pearson's r", order = 3))



