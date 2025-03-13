
# 1 - Instalación librerías -----------------------------------------------

install.packages("dplyr")
library(dplyr)


# 2 - Funciones Dplyr -----------------------------------------------------

iris %>% head()
iris %>% tail()
iris %>% slice(3:5)

# 3 - dplyr analogo a SQL -------------------------------------------------

# Seleccionar columnas (SELECT) ----
iris %>% select(Species) %>% head()
iris %>% select(Species,Petal.Width) %>% head()
iris %>% select(starts_with("Sepal")) %>% head()
iris %>% select(ends_with("Length")) %>% head()

# Seleccionar distintos (SELECT DISTINCT) ----

iris %>% distinct(Species)

# Ordenar (ORDER BY) ----
max(iris$Petal.Width)
min(iris$Petal.Width)

iris %>% 
  select(Species,Petal.Width) %>% 
  arrange(Petal.Width) %>% 
  head()

iris %>% 
  select(Species,Petal.Width) %>% 
  arrange(desc(Petal.Width)) %>% 
  head()

# Filtros (WHERE) ----

iris %>% 
  filter(Species == "virginica") %>% 
  head()

iris %>% 
  filter(Species == "virginica" & Sepal.Length > 7)

iris %>% 
  filter(Species == "virginica" & (Sepal.Length > 7 | Sepal.Width < 3))

iris %>% 
  filter(Species %in% c("virginica", "setosa"))

iris %>%
  filter(between(Sepal.Width, 2.5, 3.0))

iris %>%
  filter(grepl("^v", Species)) %>% 
  distinct(Species)

iris %>%
  filter(grepl("a$", Species)) %>% 
  distinct(Species)


# Agregar columnas ----
iris %>% 
  mutate(
    Proporcion_largo_ancho = Petal.Length/Petal.Width
  ) %>% 
  head()

iris %>% 
  mutate(
    Proporcion_largo_ancho = Petal.Length/Petal.Width,
    Es_mayor_a_5_cm = case_when(
      Petal.Length > 5 ~ "Si",
      TRUE ~ "No" # analogo a poner todo lo que no sea 5
    )
  ) %>% 
  View()

# CASE WHEN ----
iris %>% 
  mutate(
    Proporcion_largo_ancho = Petal.Length/Petal.Width,
    Es_mayor_a_5_cm = case_when(
      Petal.Length > 5 ~ "Si",
      TRUE ~ "No" # analogo a poner todo lo que no sea 5
    )
  ) %>% 
  View()

iris %>% 
  mutate(
    Proporcion_largo_ancho = Petal.Length/Petal.Width,
    Promedio_general = mean(Proporcion_largo_ancho),
    Caracteristica = case_when(
      Proporcion_largo_ancho > mean(Proporcion_largo_ancho) ~ "Mayor a Promedio General",
      TRUE ~ "Menor a Promedio General"
    )
  ) %>% 
  View()

# if_else ----
iris %>% 
  mutate(
    Proporcion_largo_ancho = Petal.Length/Petal.Width,
    Promedio_general = mean(Proporcion_largo_ancho),
    Caracteristica = if_else(
      Proporcion_largo_ancho > mean(Proporcion_largo_ancho),
      "Mayor a Promedio General",
      "Menor a Promedio General"
    )
  ) %>% 
  View()

# Group By ----
iris %>% 
  group_by(Species) %>% 
  summarise(
    PromedioSepalLenght = mean(Sepal.Length),
    SumaPetalLenght = sum(Petal.Length),
    MaxPetalWidth = max(Petal.Width), 
    MinPetalWidth = min(Petal.Width),
    Cantidad = n(),
    CantidadDiferentes = n_distinct(Sepal.Length)
  )

iris %>% 
  group_by(Species) %>% 
  mutate(
    Proporcion_largo_ancho = Petal.Length/Petal.Width,
    Promedio_x_especie = mean(Proporcion_largo_ancho)
  ) %>% 
  View()

iris %>% 
  group_by(Species) %>% 
  mutate(
    Proporcion_largo_ancho = Petal.Length/Petal.Width,
    Promedio_x_especie = mean(Proporcion_largo_ancho),
    Caracteristica = case_when(
      Proporcion_largo_ancho > Promedio_x_especie ~ "Mayor a Promedio de la especie",
      TRUE ~ "Menor a Promedio de la especie"
    )
  ) %>% 
  View()

iris %>% 
  group_by(Species) %>% 
  mutate(
    Proporcion_largo_ancho = Petal.Length/Petal.Width,
    Promedio_x_especie = mean(Proporcion_largo_ancho)
  ) %>% 
  ungroup() %>% 
  mutate(
    Promedio_general = mean(Proporcion_largo_ancho)
  ) %>% 
  View()

iris %>% 
  group_by(Species) %>% 
  mutate(
    Contador = 1,
    Contador_Acumulado = cumsum(Contador)
  ) %>% 
  View()

# ACROSS ----

iris %>%
  mutate(across(c(Sepal.Length, Sepal.Width), round))

cols <- c("Sepal.Length", "Petal.Width")
iris %>%
  mutate(across(all_of(cols), round))

iris %>%
  mutate(across(where(is.double), round))

iris %>%
  mutate(across(where(is.double) & !c(Petal.Length, Petal.Width), round))
         

iris %>%
  group_by(Species) %>%
  summarise(
    across(starts_with("Sepal"), list(mean, sd), .names = "{.col}.fn{.fn}")
  )

# if_any() and if_all() ----

iris %>%
  filter(if_any(starts_with("Sepal"), ~ . > 4))

iris %>%
  filter(if_all(starts_with("Sepal"), ~ . > 4))
