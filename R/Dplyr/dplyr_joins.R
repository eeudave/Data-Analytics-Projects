
# 1 - Joins ---------------------------------------------------------------

band_members
band_instruments

band_members %>% inner_join(band_instruments)
band_members %>% left_join(band_instruments)
band_members %>% right_join(band_instruments)
band_members %>% full_join(band_instruments)

band_members %>% semi_join(band_instruments)
band_members %>% anti_join(band_instruments)


# 2 - UNION (bind_rows) ---------------------------------------------------

tabla_1 <- data.frame(
  a = c(1,2,3),
  b = c("a", "b", "c")
)

tabla_2 <- data.frame(
  a = c(4,5,6),
  b = c("d", "e", "f")
)

tabla_1 %>% bind_rows(tabla_2)

# 3 - Ejemplo Real ---------------------------------------------------

productos <- data.frame(
  IdProducto = c(1:20),
  Descripcion = c("Manzana", "Banana", "Uva", "Pera", "Fresa",
                  "Naranja", "Kiwi", "Sandía", "Melón", "Mango",
                  "Papaya", "Piña", "Cereza", "Arándano", "Granada",
                  "Coco", "Pomelo", "Mandarina", "Frutilla", "Durazno"),
  Origen = sample(c("Europa", "Asia", "America", "Africa", "Oceania"), 20, replace = TRUE),
  Precio = round(runif(20, min = 1, max = 10), 2)
)

ventas <- data.frame(
  IdVenta = c(1:200),
  IdProducto = sample(unique(productos$IdProducto), 200, replace = TRUE),
  Cantidad = round(runif(200, min = 1, max = 10), 0)
)

ventas_anuladas <- data.frame(
  IdVentaAnulada = c(1:10),
  IdVenta = sample(unique(ventas$IdVenta), 10, replace = FALSE),
  Descripcion = sample(c("Devolucion", "Error Manual"), 10, replace = TRUE)
)


ventas %>% 
  left_join(
    productos,
    by = "IdProducto",
  ) %>%
  arrange(IdVenta) %>% 
  head()

ventas %>% 
  left_join(
    ventas_anuladas,
    by = "IdVenta",
  ) %>%
  arrange(IdVenta)

ventas %>% 
  right_join(
    ventas_anuladas,
    by = "IdVenta",
  ) %>%
  arrange(IdVenta)
