
library(dplyr)
library(readr)
library(tidyr)
library(lubridate)
library(stringr)

#La empresa NeoCar se dedica a la venta de autos nuevos y de segunda mano. Cuenta con la
#información de la base de clientes, ventas, comisiones y modelos para responder las siguientes preguntas. 
#Podrá utilizar cualquier función que se encuentre en dplyr, tidyr, stringr, lubridate o
#forcats. Este es un caso de uso más real dado que muchas veces la información no viene en el formato deseado:

clientes_dirt <- read_csv('Tidyr String Lubridate/clientes_dirty.csv')
ventas_dirt <- read_csv('Tidyr String Lubridate/ventas_dirty.csv')
comisiones_dirt <- read_csv('Tidyr String Lubridate/comisiones_dirty.csv')
modelos_dirt <- read.csv('Tidyr String Lubridate/modelos_dirty.csv')

#clientes_clean <-  as.data.frame()

#Limpiar data  -------------------------------------

#1. En tabla clientes, cambiar la columna provincia para que no hayan provincias iguales
#   escritas de forma diferente (ej, con y sin tilde, mayúsculas, caracteres especiales, etc)

clientes_dirt$ProvinciaResidencia <- str_to_title(clientes_dirt$ProvinciaResidencia)

clientes_dirt$ProvinciaResidencia <- str_replace_all(
  clientes_dirt$ProvinciaResidencia, 
    c(
      'á' = 'a',
      'é' = 'e',
      'í' = 'i',
      'ó' = 'o',
      'ú' = 'u'
     )
)

clientes_dirt$ProvinciaResidencia <- str_replace_all(
  clientes_dirt$ProvinciaResidencia, 
  c(
    'Á' = 'A',
    'É' = 'E',
    'Í' = 'I',
    'Ó' = 'O',
    'Ú' = 'U'
  )
)

clientes_dirt$ProvinciaResidencia <- str_replace_all(clientes_dirt$ProvinciaResidencia, '[^a-zA-Z0-9\\s]', '')

clientes_dirt %>% distinct(ProvinciaResidencia) %>%  View()

#2. En tabla clientes, cambiar la columna Nacionalidad para que no hayan nacionalidades
#   iguales escritas de forma diferente.

clientes_dirt$Nacionalidad <- str_to_upper(clientes_dirt$Nacionalidad)

clientes_dirt$Nacionalidad <- str_replace_all(clientes_dirt$Nacionalidad, '[^a-zA-Z0-9\\s]', '')

clientes_dirt %>% distinct(Nacionalidad) %>%  arrange(Nacionalidad) %>% View()

#3. En tabla clientes, cambiar la columna Genero para que no hayan generos iguales
#   escritos de forma diferente.

clientes_dirt$Genero <- str_to_upper(clientes_dirt$Genero)

clientes_dirt$Genero <- str_replace_all(clientes_dirt$Genero, '[^a-zA-Z0-9\\s]', '')

clientes_dirt %>% distinct(Genero)

#4. En tabla Ventas, cambiar la columna Estado para que no hayan estados iguales escritos de forma diferente.

ventas_dirt$Estado <- str_to_title(ventas_dirt$Estado)

ventas_dirt$Estado <- str_replace_all(ventas_dirt$Estado, '[^a-zA-Z0-9\\s]', ' ')

ventas_dirt %>% distinct(Estado)

#5. En tabla clientes, reemplazar todos los valores faltantes en columna nacionalidad para
#   que sean de nacionalidad española (ES)

clientes_dirt$Nacionalidad <- str_replace_na(clientes_dirt$Nacionalidad,'ES')

#6. En tabla clientes, convertir columna Estudios en un factor para que el orden sea el
#   siguiente: Universitario, Preuniversitario, Secundario, Primario

clientes_dirt %>% distinct(Estudios) %>% arrange(Estudios)

sort(clientes_dirt$Estudios)

factor_estudios <- c('Universitario' ,'PreUniversitario','Secundario' ,'Primario')

clientes_dirt$Estudios <-  factor(
  clientes_dirt$Estudios,
  factor_estudios
)

#7. En tabla clientes, convertir columna TipoCliente en un factor para que el orden sea el
#   siguiente: VIP, Nuevo, Comun. Verificar que no hayan errores de carga

clientes_dirt %>% distinct(TipoCliente) %>% arrange(TipoCliente)

clientes_dirt$TipoCliente <- str_to_title(clientes_dirt$TipoCliente)
clientes_dirt$TipoCliente <- str_replace_all(
  clientes_dirt$TipoCliente, 
  c('á' = 'a','é' = 'e','í' = 'i','ó' = 'o','ú' = 'u' )
)
clientes_dirt$TipoCliente <- str_replace_all(clientes_dirt$TipoCliente, '[^a-zA-Z0-9\\s]', '')
clientes_dirt$TipoCliente <- str_replace_all(clientes_dirt$TipoCliente, '\\s+', '') #remueve espacios
clientes_dirt$TipoCliente <- str_replace_all(clientes_dirt$TipoCliente, 'Vip', 'VIP')
clientes_dirt$TipoCliente <- str_replace_all(clientes_dirt$TipoCliente, 'Nuebo', 'Nuevo')

sort(clientes_dirt$TipoCliente)

factor_cliente <- c('VIP','Nuevo','Comun')

clientes_dirt$TipoCliente <-  factor(
  clientes_dirt$TipoCliente,
  factor_cliente
)

#8. Transformar tabla Comisiones para que quede con el siguiente formato de columnas:
#   a. Marca
#   b. Modelo
#   c. Year (año de fabricación de vehículo)
#   d. ComisionVariable
#   e. ComisionFija

comisiones_dirt

comisiones_dirt <- comisiones_dirt %>% 
  pivot_longer(
    cols = c(2:26),
    names_to = 'Year',
    values_to = 'Cases'
  ) %>% 
  separate_wider_delim(
    cols = Coche,
    names = c('Marca','Modelo'),
    delim = ' - '
  ) %>%
  separate_wider_delim(
    cols = Cases,
    names = c('ComisionVariable','ComisionFija'),
    delim = '/'
  ) 

comisiones_dirt <- comisiones_dirt %>% mutate(
  Year=as.integer(Year),
  ComisionFija = as.double(ComisionFija),
  ComisionVariable = as.double(ComisionVariable)
)

#
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
#

#9. En tabla clientes, reemplazar todos los valores faltantes en columna genero para que sean “Otro”

clientes_dirt %>% distinct(Genero)

clientes_dirt$Genero <- str_replace_na(clientes_dirt$Genero,'Otro')

# ----------------------  creamos las tablas limpias

clientes_clean <- clientes_dirt
ventas_clean <- ventas_dirt
comisiones_clean <- comisiones_dirt 
modelos_clean <- modelos_dirt 

#  Análisis  ------------------------

#1. Agregar una columna a la tabla Ventas que sea la comisión calculada como
#   “ComisionFija + Precio * ComisionVariable”

ventas_clean <- ventas_clean %>% 
  left_join(modelos_clean, by = 'IdModelo') %>% 
  left_join(comisiones_clean, by = c('Marca','Modelo','Year')) %>% 
  mutate(
    ComisionCalculada =  ComisionFija + Precio * ComisionVariable
  ) %>% 
select(Fecha, IdVehiculo, IdModelo, IdCliente, Estado, Year, Precio, ComisionCalculada) 


#2. Calcular la comisión generada por Clientes cuyo nombre comience y termine con la letra “s”

ventas_clean %>% 
  left_join(clientes_clean, by = 'IdCliente') %>% 
  filter(str_detect(Nombre, '^S.*s$')) %>% 
  select(Nombre, ComisionCalculada) %>% 
  View()

#3. Armar una tabla con las comisiones que tenga en filas la marca de los vehículos y en
#columnas la comisión generada por Modelo

ventas_clean %>% 
  left_join(modelos_clean, by = 'IdModelo') %>% 
  group_by(Marca, Modelo) %>% 
  summarise(
    ComisionTotal = sum(ComisionCalculada)
  ) %>% 
  pivot_wider(
    names_from = Modelo,
    values_from = ComisionTotal
  )
  

#4. Armar una tabla que muestre la cantidad de vehículos vendidos. En filas tendrá las
#marcas y en columnas el género

ventas_clean %>% 
  left_join(modelos_clean, by = 'IdModelo') %>% 
  left_join(clientes_clean, by = 'IdCliente') %>% 
  group_by(Marca, Genero) %>% 
  summarise(
    VehiculosTotal = n()
  ) %>% 
  pivot_wider(
    names_from = Genero,
    values_from = VehiculosTotal
  )


#5. Generar una columna que sea Nombre Completo que muestre primero el/los nombres,
#seguido de un espacio, y después el/los apellidos.

clientes_clean %>% 
  separate(
    Nombre, 
    into = c('Apellido', 'Nombre'), 
    sep = ", ") %>% 
  mutate(
    NombreCompleto =  paste(Nombre,Apellido) # str_c(Nombre, Apellido, sep = " ")
  ) %>% 
  select(NombreCompleto) %>% 
  View()
  

#  ?cat() concatenate + print


#6. Calcular cuánto fue la facturación promedio por año.


ventas_clean %>% 
  mutate(
    Year_venta = year(Fecha)
  ) %>% 
  group_by(Year_venta) %>% 
  summarise(
    Facturacion = mean(Precio)
  )

#7. Calcular cual es la facturación promedio por mes (dic-19, ene-20, …, dic-20, ene-21,etc.)

ventas_clean %>% 
  mutate(
    Mes = floor_date(Fecha, "month")
  ) %>% 
  group_by(Mes) %>% 
  summarise(
    Facturacion = mean(Precio)
  )
