library(tidyverse)
library(sf)
library(stars)

tif_fpaths <- fs::dir_ls(path = here::here(), glob = "*.tif")

hcmc_dists <- read_rds(here::here("gadm/gadm41_VNM_2_pk.rds")) %>% terra::unwrap() %>% st_as_sf() %>% filter(GID_1 == "VNM.25_1")

temp <- read_stars(tif_fpaths[[1]]) %>% setNames("lulc")

map(st_geometry(hcmc_dists %>% filter(GID_2 == "VNM.25.1_1")), \(district){
  d <- st_sfc(district, crs = st_crs(4326))
  temp %>% st_crop(d) %>% as_tibble() %>% filter(lulc!=0) %>% count(lulc) %>% mutate(n = n/sum(n))
})

d <- st_sfc(st_geometry(hcmc_dists %>% filter(GID_2 == "VNM.25.1_1")), crs = st_crs(4326))
temp %>% st_crop(d)


map(tif_fpaths, \(fpath) {
  year <- str_extract(fpath, "(\\d{4})-\\d{2}-\\d{2}", group = 1)
  tif <- read_stars(fpath) %>% setNames("lulc")
  tif %>% as_tibble() %>% filter(lulc!=0) %>% count(lulc) %>% mutate(n = n/sum(n))
})
