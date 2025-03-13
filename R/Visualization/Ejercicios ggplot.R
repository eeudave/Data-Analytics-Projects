

library(readr)


ventas <- read_csv('ggplot/ventas.csv')
modelos <- read_csv('ggplot/modelos.csv')
clientes <- read_csv('ggplot/clientes.csv')
comisiones <- read_csv('ggplot/comisiones.csv')

library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)
library(ggplot2)

install.packages('scales')
library(scales)

#1. Crear un gráfico de barras que muestre la facturación total por Marca.

ventas %>% 
  inner_join(modelos, by = 'IdModelo') %>% 
  group_by(Marca) %>% 
  summarize(
    Facturacion = sum(Precio)
  ) %>% 
  ggplot(
    mapping = aes( x=reorder(Marca, -Facturacion), y=Facturacion)
  ) +
  geom_col(fill = 'darkblue', color='orange') +
  scale_y_continuous(labels = label_number(scale = 1e-6, suffix = "M")) + # Añade la etiqueta M a los millones en el eje
  theme_classic()

#scale_y_continuous()

#2. Crear un gráfico de barras que muestre el total facturado por Marca y en cada barra se segregue la contribución de cada modelo.

ventas %>% 
  inner_join(modelos, by = 'IdModelo') %>% 
  group_by(Marca,Modelo) %>% 
  summarize(
    Facturacion = sum(Precio)
  ) %>% 
  ggplot(
    mapping = aes( x=reorder(Marca, -Facturacion), y=Facturacion, fill=Modelo)
  ) +
  geom_col() +
  scale_y_continuous(labels = label_number(scale = 1e-6, suffix = "M")) +
  theme_classic()  +
  scale_fill_ordinal()

  ggplot(
    ventas %>% 
    inner_join(modelos, by = 'IdModelo') %>% 
    group_by(Marca,Modelo) %>% 
    summarize( Facturacion = sum(Precio)), 
    aes(x = reorder(Marca, -Facturacion), y = Facturacion, fill = Modelo)
    ) + 
  geom_bar(stat = 'identity') +
    scale_y_continuous(labels = label_number(scale = 1e-6, suffix = "M")) +
  scale_fill_ordinal()
  
    
#3. Mostrar en un gráfico de líneas la evolución de la facturación mensual a lo largo del tiempo.

ventas %>% 
  select(FechaVenta, Precio) %>% 
  mutate(
      Yearg = year(FechaVenta),
      Mesg = month(FechaVenta, label = TRUE, abbr = TRUE),
      MesYear = str_c(Mesg,Yearg, sep='-')
  )  %>% 
  group_by(Yearg,Mesg,MesYear) %>% 
  summarize( Facturacion = sum(Precio)) %>% 
  arrange(Yearg,Mesg) %>%  
  ggplot(
    mapping = aes( x=MesYear, y=Facturacion, fill=Yearg) # kinea group = 1
  ) +
  geom_col() +
  scale_y_continuous(labels = label_number(scale = 1e-6, suffix = "M")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# lineas por año

ventas %>% 
  select(FechaVenta, Precio) %>% 
  mutate(
    Yearg = year(FechaVenta),
    Mesg = month(FechaVenta, label = TRUE, abbr = TRUE)
  )  %>% 
  group_by(Yearg,Mesg) %>% 
  summarize( Facturacion = sum(Precio)) %>% 
  arrange(Yearg,Mesg) %>%  
  ggplot(
    mapping = aes( x=Mesg, y=Facturacion, group=Yearg, color=Yearg)
  ) +
  geom_line(size = 1) +
  scale_y_continuous(labels = label_number(scale = 1e-6, suffix = "M")) +
  geom_point(size = 2) +
  theme_minimal() +
  labs(title = "Evolución de la Facturación Mensual por Año",
       x = "Mes",
       y = "Facturación ($)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#4. Mostrar en un gráfico la facturación mensual por modelo, pero que cada Marca sea un recuadro diferente.

df_fmesmodelo <- ventas %>% 
  left_join(modelos, by='IdModelo') %>% 
  select(FechaVenta,Marca,Modelo,Precio) %>% 
  mutate(
    Yearg = year(FechaVenta),
    Mesg = month(FechaVenta, label = TRUE, abbr = TRUE)
  )  %>% 
  group_by(Yearg,Mesg,Marca,Modelo) %>% 
  summarize( Facturacion = sum(Precio)) %>% 
  arrange(Yearg,Mesg,Marca,Modelo)  

ggplot(df_fmesmodelo, aes(x = Mesg, y = Facturacion, fill=Modelo)) +
  geom_col() +
  facet_wrap(~Marca, scales = "free_y") +  # Facetas por marca
  theme_minimal() +
  labs(title = "Evolución de la Facturación Mensual por Año",
       x = "Mes",
       y = "Facturación ($)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(labels = label_number(scale = 1e-6, suffix = "M"))


#5. Mostrar un histograma de la cantidad de coches vendidos en función del precio. ¿Qué patrón observa?

ggplot(ventas, aes(x = Precio)) + 
  geom_histogram( bins=100 ) +
  scale_y_continuous(labels = label_number(scale = 1e-3, suffix = "K")) +
  scale_x_continuous(labels = label_number(scale = 1e-3, suffix = "K")) +
  xlim(0,100000)

hist(ventas$Precio)

# Calcular los puntos de corte
breaks <- pretty(range(ventas$Precio),n = nclass.Sturges(ventas$Precio),min.n = 1)

# Histograma con el método de Sturges
ggplot(ventas, aes(x = Precio)) + 
  geom_histogram(color = 1, fill = "white",
                 breaks =  pretty(range(ventas$Precio),n = nclass.Sturges(ventas$Precio),min.n = 1)) +
  ggtitle("Método de Sturges")

#6. Mostrar la facturación por:
#   a. Año
#   b. Mes
#   c. Día del mes
#   d. Día de la semana
#¿Observa algún patrón de estacionalidad? ¿Por qué ocurre esto?
  
# Año
ventas %>% 
  select(FechaVenta,Precio) %>% 
  mutate( Year = year(FechaVenta)) %>% 
  group_by(Year) %>% 
  summarize( Facturacion = sum(Precio)) %>% 
  arrange(Year) %>% ggplot(
  aes( x=Year, y=Facturacion, group =1)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  theme_minimal() +
  labs(title = "Evolución de la Facturación Anual",
       x = "Year",
       y = "Facturación ($)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(labels = label_number(scale = 1e-6, suffix = "M"))
  
# Mes
ventas %>% 
  select(FechaVenta,Precio) %>% 
  mutate( Mes = month(FechaVenta, label = TRUE, abbr = TRUE)) %>% 
  group_by(Mes) %>% 
  summarize( Facturacion = sum(Precio)) %>% 
  arrange(Mes) %>% ggplot(
    aes( x=Mes, y=Facturacion, group =1)) +
    geom_line(size = 1) +
    geom_point(size = 2) +
   theme_minimal() +
   labs(title = "Evolución de la Facturación Mensual",
       x = "Year",
       y = "Facturación ($)") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(labels = label_number(scale = 1e-6, suffix = "M"))

# Dia Mes
ventas %>% 
  select(FechaVenta,Precio) %>% 
  mutate( Dia = day(FechaVenta)) %>% 
  group_by(Dia) %>% 
  summarize( Facturacion = sum(Precio)) %>% 
  arrange(Dia) %>% ggplot(
    aes( x=Dia, y=Facturacion, group =1)) +
    geom_line(size = 1) +
    geom_point(size = 2) +
    theme_minimal() +
    labs(title = "Evolución de la Facturación por Dia del Mes",
       x = "Year",
       y = "Facturación ($)") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(labels = label_number(scale = 1e-6, suffix = "M"))

# Dia Semana
ventas %>% 
  select(FechaVenta,Precio) %>% 
  mutate( Dias = weekdays(FechaVenta)) %>% 
  group_by(Dias) %>% 
  summarize( Facturacion = sum(Precio)) %>% 
  ggplot(
    aes( x=Dias, y=Facturacion, group =1)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  theme_minimal() +
  labs(title = "Evolución de la Facturación por Dia de la Semana",
       x = "Year",
       y = "Facturación ($)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(labels = label_number(scale = 1e-6, suffix = "M"))

