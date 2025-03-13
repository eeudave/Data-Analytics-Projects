# Limpiar data ------------------------------------------------------------
library("dplyr")
library("tidyr")
library("stringr")
library("lubridate")
library("forcats")
library("readr")

clientes <- read_csv("clientes_dirty.csv")
comisiones <- read_csv("comisiones_dirty.csv")
modelos <- read_csv("modelos_dirty.csv")
ventas <- read_csv("ventas_dirty.csv")

# 1. En tabla clientes, cambiar la columna provincia para que no hayan 
# provincias iguales escritas de forma diferente (ej, con y sin tilde, mayúsculas, 
# caracteres especiales, etc)

#clientes_limpia %>% distinct(ProvinciaResidencia) %>% arrange(ProvinciaResidencia)

clientes_limpia <- clientes %>% 
  mutate(ProvinciaResidencia = str_to_lower(ProvinciaResidencia, locale = "es_ES"),
         ProvinciaResidencia = str_replace_all(ProvinciaResidencia, c("á" = "a", "é" = "e", "í" = "i", "ó" = "o", "ú" = "u",  "balears" = "baleares")))


# 2. En tabla clientes, cambiar la columna Nacionalidad para que no hayan 
# nacionalidades iguales escritas de forma diferente.

clientes_limpia %>% distinct(Nacionalidad) %>% arrange(Nacionalidad)

clientes_limpia <- clientes_limpia %>% 
  mutate(
    Nacionalidad = str_to_upper(Nacionalidad, locale = "es_ES"),
    Nacionalidad = str_replace_all(Nacionalidad, c("á" = "a", "é" = "e", "í" = "i", "ó" = "o", "ú" = "u")),
    Nacionalidad = str_replace_all(Nacionalidad, "\\.", "")
    )


# 3. En tabla clientes, cambiar la columna Genero para que no hayan generos 
# iguales escritos de forma diferente.

clientes_limpia %>% distinct(Genero) %>% arrange(Genero)

clientes_limpia <- clientes_limpia %>% 
  mutate(Genero = str_to_upper(Genero, locale = "es_ES"))

# 4. En tabla Ventas, cambiar la columna Estado para que no hayan estados iguales
# escritos de forma diferente.

ventas %>% distinct(Estado) %>% arrange(Estado)

ventas_limpia <- ventas %>% 
  mutate(Estado = str_to_title(Estado, locale = "es_ES"),
         Estado = str_replace_all(Estado, c("-" = " ", "/" = " ", "\\\\" = " ")))


ventas %>%
  mutate(
    Estado = str_to_lower(Estado),
    Estado = str_squish(Estado),
    Estado = str_replace_all(Estado, "[/\\\\-]", " ")
  )


  ventas %>% 
  mutate(
    Estado = str_replace_all(
      Estado,
      c(
        "^[Ss].*[Oo]$" = "Segunda Mano",   
        "^[Nn].*[OoAa]$" = "Nuevo"
      )
    ) 
  ) 

# 5. En tabla clientes, reemplazar todos los valores faltantes en columna nacionalidad 
# para que sean de nacionalidad española (ES)

clientes_limpia %>% distinct(Nacionalidad) %>% arrange(Nacionalidad)

clientes_limpia <- clientes_limpia %>% 
  mutate(Nacionalidad = str_replace_na(Nacionalidad, "ES"))

#clientes_NEW$Nacionalidad[is.na(clientes_NEW$Nacionalidad)] <- "ES"

# 6. En tabla clientes, convertir columna Estudios en un factor para que el orden sea 
# el siguiente: Universitario, Preuniversitario, Secundario, Primario

clientes_limpia %>% distinct(Estudios) %>% arrange(Estudios)

clientes_limpia <- clientes_limpia %>% 
  mutate(Estudios = factor(Estudios, c("Universitario", "PreUniversitario", "Secundario", "Primario"))) %>% 
  arrange(Estudios)

# 7. En tabla clientes, convertir columna TipoCliente en un factor para que el orden 
# sea el siguiente: VIP, Nuevo, Comun. Verificar que no hayan errores de carga

clientes_limpia %>% distinct(TipoCliente) %>% arrange(TipoCliente)

clientes_limpia <- clientes_limpia %>% 
  mutate(TipoCliente = str_to_title(TipoCliente, locale = "es_ES"),
         TipoCliente = str_replace_all(TipoCliente, c("nuebo" = "Nuevo", "ú" = "u", "\\." = "", " " = "","Vip" = "VIP" )),
         TipoCliente = factor(TipoCliente, c("VIP", "Nuevo", "Comun"))
         ) %>% 
  arrange(TipoCliente)

# 8. Transformar tabla Comisiones para que quede con el siguiente formato de columnas:
      # a. Marca
      # b. Modelo
      # c. Year (año de fabricación de vehículo)
      # d. ComisionVariable
      # e. ComisionFija

comisiones_limpia <- comisiones %>% 
  separate(Coche, c("Marca", "Modelo"), " - ") %>% 
  pivot_longer(
    cols = -c("Marca", "Modelo"), # c(3:27) -c(1:2)
    names_to = "Año",
    values_to = "Comision") %>% 
  separate(Comision, c("ComisionVariable", "ComisionFija"), "/") %>% 
  mutate(
    Año=as.integer(Año),
    ComisionFija = as.double(ComisionFija),
    ComisionVariable = as.double(ComisionVariable)
    )

# 9. En tabla clientes, reemplazar todos los valores faltantes en columna genero 
# para que sean “Otro”

clientes_limpia <- clientes_limpia %>% 
  mutate(Genero = str_replace_na(Genero, "Otro"))
  
clientes_limpia %>% distinct(Genero) %>% arrange(Genero)



# Analisis ----------------------------------------------------------------

# 1. Agregar una columna a la tabla Ventas que sea la comisión calculada como 
# “ComisionFija + Precio * ComisionVariable”

ventas_analisis <- ventas_limpia %>% 
  left_join(modelos, by = "IdModelo") %>% 
  left_join(comisiones_limpia, by = c("Modelo", "Marca", "Year"="Año")) %>% 
  mutate(Comision_calculada = (ComisionFija + Precio * ComisionVariable))


comisiones_limpia %>% 
  left_join(modelos, by = c("Marca", "Modelo")) %>% 
  right_join(ventas_limpia, by = c("IdModelo", "Año"="Year")) %>% 
  mutate(Comision_calculada = (ComisionFija + Precio * ComisionVariable))



# 2. Calcular la comisión generada por Clientes cuyo nombre comience y termine 
# con la letra “s”

ventas_analisis %>%
  left_join(clientes_limpia, by = "IdCliente") %>% 
  filter(grepl("^S", Nombre) & grepl("s$", Nombre)) %>% #grepl("^S.*s$")
  summarise(Comision_generada = sum(Comision_calculada, na.rm = TRUE))
  

# 3. Armar una tabla con las comisiones que tenga en filas la marca de los vehículos 
# y en columnas la comisión generada por Modelo

ventas_analisis %>% 
  select(Marca, Modelo, Comision_calculada) %>% 
  group_by(Marca, Modelo) %>%
  summarise(Comision_calculada = sum(Comision_calculada)) %>% 
  pivot_wider(
    names_from  = Modelo,
    values_from = Comision_calculada) 


# 4. Armar una tabla que muestre la cantidad de vehículos vendidos. En filas tendrá 
# las marcas y en columnas el género

ventas_analisis %>% 
  left_join(clientes_limpia, by= "IdCliente") %>% 
  group_by(Marca.x, Genero) %>% 
  summarise(nCoches = n()) %>% 
  pivot_wider(
    names_from  = Genero,
    values_from = nCoches)


# 5. Generar una columna que sea Nombre Completo que muestre primero el/los nombres, 
# seguido de un espacio, y después el/los apellidos.

clientes_limpia %>% 
  separate(Nombre, c("Apellido", "Nombre"), sep = ", ") %>% 
  mutate(NombreCompleto = str_c(Nombre," ", Apellido))


# 6. Calcular cuánto fue la facturación promedio por año.

ventas_analisis %>% 
  mutate(AñoVenta = year(Fecha)) %>% 
  group_by(AñoVenta) %>% 
  summarise(Facturacion = mean(Precio))


# 7. Calcular cual es la facturación promedio por mes (dic-19, ene-20, ..., dic-20, ene-21, etc.)

ventas_analisis %>% 
  mutate(fecha_facturacion = floor_date(Fecha, "month")) %>% 
  group_by(fecha_facturacion) %>% 
  summarise(facturacion = mean(Precio)) %>% 
  mutate(fecha_facturacion = format(fecha_facturacion, "%b-%y")) #%m -> Mes con nº, %b -> mes con letra
  








# Extras ------------------------------------------------------------------

# 1. Contar las unidades vendidas clientes cuyo apellido empiece con la letra “A”

ventas_analisis %>% 
  left_join(clientes_limpia, by = "IdCliente") %>% 
  filter(grepl("^A", Apellido)) %>% 
  group_by(IdCliente, NombreCompleto) %>% 
  summarise(UnidadesVendidas = n()) %>% 
  arrange(IdCliente)

# 2. Contar la cantidad de vehículos Toyota vendidos a clientes cuyo nombre empiece
# con la letra “E”.

ventas_analisis %>% 
  left_join(clientes_limpia, by = "IdCliente") %>% 
  filter(grepl("^E", Nombre)) %>% 
  filter(Marca.x == "Toyota") %>% 
  group_by(Nombre) %>% 
  summarise(nCoches = n())

# 3. Contar cuantos clientes VIP tienen 2 o más apellidos

clientes_limpia %>% 
  filter(TipoCliente == "VIP") %>% 
  mutate(Apellidos_count = str_count(Apellido, " ")) %>% 
  filter(Apellidos_count >= 1) %>%
  summarise(VIP_2_apellidos = n())

# 4. Contar cuantos clientes tienen 2 o más nombres y 2 o más apellidos

clientes_limpia %>% 
  mutate(Apellidos_count = str_count(Apellido, " ")) %>%
  mutate(Nombre_count = str_count(Nombre, " ")) %>% 
  filter((Nombre_count >= 1) & (Apellidos_count >= 1))  %>%
  summarise(apellidos_nombres_2 = n())

# 5. Contar cuantos clientes tienen la misma cantidad de caracteres en su nombre 
# y en su apellido (no cuentan los espacios entre nombres)

clientes_limpia %>% 
  select(c(Nombre, Apellido)) %>% 
  mutate(
    Num_caracteres_nombre = nchar(str_replace_all(Nombre, "\\W", "")),
    Num_caracteres_apellido = nchar(str_replace_all(Apellido, "\\W", ""))
    ) %>%
  filter(Num_caracteres_nombre == Num_caracteres_apellido)

# 6. Contar cuantos clientes tienen algún caracter especial en su nombre y en su apellido

clientes_limpia %>% 
  select(c(Nombre, Apellido)) %>% 
  mutate(
    Num_especiales_nombre = str_count(Nombre, "\\W"),
    Num_especiales_apellido = str_count(Apellido, "\\W")
  ) %>% 
  filter((Num_especiales_nombre >= 1) & (Num_especiales_apellido >= 1)) %>% 
  select(Nombre, Apellido)

# 7. Generar una columna que cuente la cantidad de vocales que tiene una persona
# entre su nombre y su apellido

# 8. Buscar las provincias que comiencen y terminen con consonantes

# 9. Buscar las provincias que tengan más vocales que consonantes

# 10. Agrupar los clientes en función de si su nombre empieza con vocal o no y 
# contar cuantos coches compró cada grupo.

# 11. Calcular la facturación promedio por día de la semana (mostrar los días de 
# la semana en formato de texto)

# 12. Armar un cuadro que muestre en filas la Marca y el Modelo y en columnas el 
# nivel de Estudios alcanzado que muestre el total facturado