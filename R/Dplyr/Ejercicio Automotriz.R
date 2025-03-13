
#install.packages("dplyr")
library(dplyr)
#install.packages('readr')
library(readr)

#Parte 1

# 1.Importar datasets ventas.csv, clientes.csv y modelos.csv

ventas <- read_csv('Dplyr/ventas.csv')
modelos <- read_csv('Dplyr/modelos.csv')
clientes <- read_csv('Dplyr/clientes.csv')

# 2.Generar un dataframe con las columnas Fecha, Estado y Precio de las ventas ordenadas de mayor a menor en función del precio.

#ventas %>% select(Fecha,Estado,Precio) %>% arrange(desc(Precio)) 

ventas_df <- data.frame(
  ventas %>% select(Fecha,Estado,Precio) %>% arrange(desc(Precio)) 
)

# 3.Ordenar el dataframe anterior por Fecha de más antiguo a mas reciente, y en caso de que dos registros tengan la misma fecha, ordenarlos por Precio de mayor a menor.

ventas_df %>% arrange(Fecha,desc(Precio))

# 4.Mostrar una tabla con todos los Estados e IdModelos diferentes.

ventas %>% distinct(Estado,IdModelo) %>% arrange(Estado,IdModelo) %>% View()

# 5.Mostrar todos los registros de ventas de coches nuevos.

ventas %>% filter(Estado == 'Nuevo')

# 6.Mostrar la cantidad de coches vendidos por estado.

ventas %>% 
  group_by(Estado) %>% 
  summarise(
    Cantidad = n()
  ) 

ventas %>% count(Estado, name = 'Coches Vendidos')

# 7.Mostrar la cantidad de coches vendidos y facturación por año de fabricación de coche y por estado.

ventas %>% 
  group_by(Year,Estado) %>% 
  summarise(
    Cantidad = n(),
    Facturacion = sum(Precio)
  )

# 8.Mostrar todas las ventas de coches de segunda mano que sean modelo 2020, o coches Nuevos que hayan sido comprados antes del “2019-12-31” y que se hayan vendido por un precio mayor a 40000 euros.

ventas %>% filter((Estado == 'Segunda Mano' & Year == 2020) | 
                  (Estado == 'Nuevo' & Fecha < '2019-12-31' & Precio > 40000)) %>% 
View()

# 9.Agregar una columna que se llame “Gama” que compare el precio de venta del auto frente al promedio general que sea:
  #a.“Gama baja” si el precio de venta es inferior al 75% del precio promedio.
  #b.“Gama alta” si el precio de venta es superior al 125% del precio promedio.
  #c.“Gama media” en caso contrario.

ventas %>% 
  mutate(
    Promedio = mean(Precio),
    Gama = case_when(
      Precio < Promedio*0.75 ~ 'Gama baja',
      Precio > Promedio*1.25 ~ 'Gama alta',
      .default = 'Gama media'
    )
  ) %>% 
  View()

#10.Agregar una columna que se llame “Gama” que compare el precio de venta del auto 
#   frente al promedio de los autos fabricados en su mismo año que sea:
  #a.“Gama baja” si el precio de venta es inferior al 75% del precio promedio.
  #b.“Gama alta” si el precio de venta es superior al 125% del precio promedio.
  #c.“Gama media” en caso contrario.

ventas %>% 
  group_by(Year) %>% 
  mutate(
    AvgYear = mean(Precio),    
    Gama = case_when(
      Precio < AvgYear*0.75 ~ 'Gama baja',
      Precio > AvgYear*1.25 ~ 'Gama alta',
      .default = 'Gama media'
    )
  ) %>% 
  View()

#11.Crear un dataframe que sea igual a la tabla ventas, pero que todas las columnas que empiecen con “Id” sean del tipo de dato integer.

ventas2_df <- data.frame(
  ventas %>% mutate(
    across(starts_with('Id'),as.integer)
  )
) %>% View()

ventas2_df <- data.frame(
  ventas %>% mutate(
    IdVehiculo = as.integer(IdVehiculo) ....
  )
) %>% View()

str(ventas)
str(ventas2_df)

#Parte 2

#1.Mostrar la cantidad de ventas realizadas por cada marca.

ventas %>% left_join(modelos, by = 'IdModelo') %>% 
  group_by(
    Marca
  ) %>% 
  summarise(
    Ventas = n()
  )

#2.Mostrar el precio promedio de venta y la cantidad de autos vendidos para cada modelo.

ventas %>% left_join(modelos, by = 'IdModelo') %>% 
  group_by(
    Modelo
  ) %>% 
  summarise(
    Cantidad = n(),
    PrecioAvg = mean(Precio)
  )

#3.Identificar el cliente que ha realizado la compra más cara y mostrar sus detalles (IdCliente, Nombre, Precio).

clientes %>% left_join(ventas, by = 'IdCliente') %>% 
  select(IdCliente, Nombre, Precio) %>% 
  arrange(desc(Precio)) %>% 
  head(1)

ventas %>%
  inner_join(clientes, by= "IdCliente") %>%
  filter(Precio == max(Precio)) %>%
  select(IdCliente, Nombre, Precio)

#4.Mostrar el precio promedio de venta para autos nuevos y usados por cada marca.

ventas %>% left_join(modelos, by = 'IdModelo') %>% 
  group_by(
    Marca, Estado
  ) %>% 
  summarise(
    PrecioAvg = mean(Precio, na.rm = TRUE)
  )

#5.Contar cuantos coches modelo Corolla fueron vendidos.

ventas %>% left_join(modelos, by = 'IdModelo') %>% 
  filter(Modelo == 'Corolla') %>% 
  group_by( Modelo ) %>% 
  summarise(
    Cantidad = n()
  )

#6.Mostrar en una tabla cual fue el fue el coche vendido más caro por cada marca y a quien fue vendido.

ventas %>% left_join(modelos, by = 'IdModelo') %>% 
  left_join(clientes, by = 'IdCliente') %>% 
  select(Modelo,Marca,Precio, Nombre) %>% 
  group_by(Marca) %>% 
  filter(Precio == max(Precio)) 

#7.Mostrar el top 5 de las provincias con más facturado en la historia.

ventas %>% 
  left_join(clientes, by = 'IdCliente') %>%  
  left_join(modelos, by = 'IdModelo') %>% 
  select(ProvinciaResidencia, Precio) %>% 
  group_by(ProvinciaResidencia) %>% 
  summarise(
    Precio = sum(Precio) 
  ) %>% 
  arrange(desc(Precio)) %>% 
  head( n=5)

#8.Mostrar el top 5 de las provincias con más facturado en la historia de clientes que no sean españoles 
#  y que no hayan comprado coches de la marca Chevrolet.

ventas %>% 
  inner_join(modelos, by= "IdModelo") %>% 
  inner_join(clientes, by = "IdCliente") %>% 
  filter(Nacionalidad != "ES" & Marca != "Chevrolet") %>% 
  group_by(ProvinciaResidencia) %>% 
  summarise(
    Precio=sum(Precio)
    ) %>% 
  arrange(desc(Precio)) %>%
  head(n=5)

#9.Mostrar la cantidad de clientes diferentes que compraron coches Toyota en Zaragoza, desglosado por modelo, 
#  y la diferencia entre el precio promedio de venta vs el precio de lista promedio de los coches.

ventas %>% 
  left_join(modelos, by= "IdModelo") %>% 
  left_join(clientes, by = "IdCliente") %>% 
  filter(Marca == "Toyota", ProvinciaResidencia == "Zaragoza") %>% 
  group_by(Modelo) %>% 
  summarise(
    ClientesDiferentes = n_distinct(IdCliente),
    DiferenciaPrecio = mean(Precio, na.rm = TRUE)-mean(PrecioLista, na.rm = TRUE)
    )

#10.Mostrar la cantidad de clientes por provincia que nunca compraron un coche.

clientes %>% 
  anti_join(ventas, by = "IdCliente") %>% 
  group_by(ProvinciaResidencia) %>% 
  summarise(
    nClientes = n()
    ) %>% 
  arrange(desc(nClientes))

#11.Cual fue la venta con menor margen (Precio / PrecioLista - 1) y que modelo de coche y cliente fue.

clientes %>% 
  anti_join(ventas, by = "IdCliente") %>% 
  group_by(ProvinciaResidencia) %>% 
  summarise(
    nClientes = n()
    ) %>% 
  arrange(desc(nClientes))

#12.Mostrar los clientes que hayan comprado la mayor cantidad de coches.

ventas %>% 
  left_join(clientes, by = "IdCliente") %>% 
  group_by(IdCliente) %>% 
  summarise(
    nVentas = n()
    ) %>% 
  filter(nVentas == max(nVentas))

#13.Para cada cliente que haya realizado más de una compra, mostrar cuantos coches compró de cada modelo.

ventas %>% 
  left_join(modelos, by= "IdModelo") %>% 
  group_by(IdCliente) %>% 
  mutate(
    total_compras = n()
    ) %>% 
  filter(total_compras >1) %>% 
  group_by(IdCliente, Modelo) %>% 
  summarise(nCompras = n()) 
