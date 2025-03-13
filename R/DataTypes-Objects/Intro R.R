
#1.A partir de los siguientes vectores de nombres y apellidos, crear un vector llamado "nombre_completo” que sea la unión de ambos vectores separados por una coma y un espacio (“<APELLIDO>, <NOMBRE>”).

nombres <- c("Juan","María","Carlos","Laura","Pedro","Ana","David","Elena","José","Sofía","Miguel","Isabel","Javier","Carmen","Alejandro","Beatriz","Francisco","Luis","Raquel","Roberto","Verónica","Diego","Silvia","Manuel","Patricia","Gabriel","Rocío","Antonio","Martina","Daniel","Victoria", "Rafael", "Eva", "Alberto", "Lucía", "Fernando", "Natalia", "Adrián", "Paula", "Emilio", "Clara", "Óscar", "Nerea", "Héctor", "Alicia", "Iván", "Lourdes", "Juan", "María", "Carlos") 
apellidos <- c("Gómez", "Fernández", "Rodríguez", "López", "Martínez", "Sánchez", "Pérez", "González", "Giménez", "Díaz", "Alonso", "Ruiz", "Torres", "Vega", "Hernández", "Moreno", "Navarro", "Serrano", "Jiménez", "Romero", "Soto", "Vargas", "Morales", "Ortega", "Flores", "Cabrera", "Campos", "Molina", "Fuentes", "Blanco", "Iglesias", "Ramos", "Castillo", "Santos", "Serrano", "Delgado", "Peña", "Rojas", "Ortiz", "Núñez", "Vázquez", "Cruz", "Reyes", "Mendoza", "Ferrer", "Cortés", "Lara", "Vidal", "Aguilar", "Navarro")

nombres[1:10]
apellidos[1:10]

nombrecompleto <- paste(nombres,apellidos, sep = ', ')

nombrecompleto

#2.Crear un vector con 50 elementos aleatorios que contenga números entre 22 y 60, y asignarlo en la variable “edades”

edades <- round(runif(50,22,60),0)

edades

#3.Crear un vector con 50 elementos aleatorios que contenga las palabras “Masculino”, “Femenino” u “Otro”, y asignarlo en la variable “genero”

genero <- sample(c('Masculino','Femenino','Otro'),50,TRUE)

genero

#4.Idem anterior con las palabras "Ventas", "Marketing", "Finanzas", "Recursos Humanos", "Desarrollo" o "Producción", y asignarlo en la variable “puestos”

puestos <- sample(c('Ventas','Marketing','Finanzas','Recursos Humanos','Desarrollo','Produccion'),50,TRUE)

puestos

#5.Idem anterior con las palabras "Jr", "Sr" o "Gerente", y asignarlo en la variable “jerarquia”

jerarquia <- sample(c('Jr','Sr','Gerente'),50,TRUE)

jerarquia

#6.Crear un vector de 50 elementos aleatorios entre 25000 y 70000 y asignarlo en la variable “salario”

salario <- round(runif(50,25000,70000),0)

salario

#7.Crear la variable “antiguedad”
#Crear variable con 50 números aleatorios entre 0 y 1 llamada “random”.

random <- runif(50,0,1)
random

#Calcular antiguedad como: (“edad” – 18) * “random”. Redondear el resultado a 0 decimales.

antiguedad <- round((edades-18)*random,0)
antiguedad

#8.Crear un dataframe llamado “empleados” que contenga las siguientes columnas a partir de las variables creadas anteriormente:

empleados <- data.frame(
  'Nombre' = nombres,
  'Apellido' = apellidos,
  'NombreCompleto' = nombrecompleto,
  'Edad' = edades,
  'Genero' = genero,
  'PuestoTrabajo' = puestos,
  'Jerarquia' = jerarquia,
  'Antiguedad' = antiguedad,
  'Salario' = salario
)

View(empleados)

#### SUBSETTING

#1.Seleccionar 3er observación de la columna Edad

empleados[3,'Edad'] # tercera fila cuarta columna
empleados$Edad[3]

#Observacion = Filas
#Variable = Columnas

#2.Seleccionar 4ta y 5ta observación de columnas Nombre y Antiguedad

empleados[c(4,5),c('Nombre','Antiguedad')] 

#3.Seleccionar todas las observaciones de la última columna

empleados[,'Salario'] 
empleados[,ncol(empleados)]

#4.Seleccionar todas las observaciones de la última columna y mostrarlos como un vector en vez de un dataframe

vectorsalario <- empleados$Salario
vectorsalario

#5.Seleccionar las observaciones de empleados mayores a 34 años

filtro34 <- empleados$Edad > 34
empleados[filtro34,]

#6.Seleccionar todos los empleados que cumplan con la condición de que los años de antigüedad sea un número par.

fantiguedad <- empleados$Antiguedad%%2 == 0
empleados[fantiguedad,]

#7.Seleccionar todos los empleados que hayan trabajado más de la mitad de su vida en la empresa

ftrabajo <- empleados$Antiguedad > (empleados$Edad/2)
empleados[ftrabajo,]

#8.Calcular el promedio de antigüedad para los empleados de género masculino

fmasculino <- empleados$Genero == 'Masculino'
mean(empleados[fmasculino,'Antiguedad']) 
mean(antiguedad[fmasculino])

#9.Sumar el salario total de los gerentes

fgerente <- empleados$Jerarquia == 'Gerente'
sum(empleados[fgerente,'Salario'])
sum(empleados$Salario[empleados$Jerarquia == 'Gerente'])

#10.Contar la cantidad de empleados que sean gerentes y tengan menos de 40 años

fgerentes <- empleados$Jerarquia == 'Gerente' & empleados$Edad < 40
length(empleados[fgerentes,'Jerarquia']) 
sum(fgerentes)

#11.Contar la cantidad de empleados que trabajan en marketing que tengan entre 20 y 40 años

fmarketing <- empleados$PuestoTrabajo == 'Marketing' & (empleados$Edad >= 20 & empleados$Edad <= 40)
length(empleados[fmarketing,'PuestoTrabajo']) 

#12.Sumar el salario de los empleados con edad impar que tengan una antigüedad par

fsalario <- empleados$Edad%%2 != 0  & empleados$Antiguedad%%2 == 0 
sum(empleados[fsalario,'Salario'])

#13.Seleccionar las observaciones de los empleados Sr que tengan más de 6 años de antigüedad o que tengan entre 30 y 50 años

fempleados1 <- empleados$Jerarquia == 'Sr' & empleados$Antiguedad > 6 | (empleados$Edad >= 30 & empleados$Edad <= 50)
empleados[fempleados1,] 

#14.Crear un dataframe llamado “empleados_na” que sea igual a “empleados”, con la diferencia que los empleados que trabajen en Marketing y tengan más de 3 años de antigüedad, tengan el valor “NA” en la columna “Edad”

fedadna <- empleados$PuestoTrabajo == 'Marketing' & empleados$Antiguedad > 3
empleados[fedadna,'Edad'] 

edadna <- ifelse(empleados$PuestoTrabajo == 'Marketing' & empleados$Antiguedad > 3,'NA',empleados$Edad) 
edadna

empleados_na <- data.frame(
  'Nombre' = empleados[,'Nombre'],
  'Apellido' = empleados[,'Apellido'],
  'NombreCompleto' = empleados[,'NombreCompleto'],
  'Edad' = ifelse(empleados$PuestoTrabajo == 'Marketing' & empleados$Antiguedad > 3,NA,empleados$Edad),
  'Genero' = empleados[,'Genero'],
  'PuestoTrabajo' = empleados[,'PuestoTrabajo'],
  'Jerarquia' = empleados[,'Jerarquia'],
  'Antiguedad' = empleados[,'Antiguedad'],
  'Salario' = empleados[,'Salario']
)

#otra forma de asignar los NA

empleados_na <- empleados
empleados_na[
  empleados_na$PuestoTrabajo == 'Marketing' & empleados_na$Antiguedad > 3,'Edad'
] <- NA

#15.Contar la cantidad de empleados Jr y Sr que no tengan NA en la columna “Edad”

fjrsr <- (empleados_na$Jerarquia == 'Jr' | empleados_na$Jerarquia == 'Sr') & !is.na(empleados_na$Edad)
length(empleados_na[fjrsr,'Jerarquia']) 
nrow(empleados_na[fjrsr,]) 

#16.Contar la cantidad de empleados que no se llamen “Juan”, “Diego” o “Eva” que trabajen en “Ventas” o “Finanzas” con una antigüedad mayor a 7 años que cumplan alguna de las siguientes características:

ffinal <- !(empleados_na$Nombre %in% c('Juan','Diego','Eva')) & empleados_na$PuestoTrabajo %in% c('Ventas','Finanzas') & empleados_na$Antiguedad > 7
#length(empleados_na[ffinal,'Jerarquia']) 

#  a.Jr con salario mayor a 40000
sum(ifelse(empleados_na[ffinal,'Jerarquia'] == 'Jr' & empleados_na[ffinal,'Salario'] > 40000,1,0))
#  b.Sr con salario entre 35000 y 50000
sum(ifelse(empleados_na[ffinal,'Jerarquia'] == 'Sr' & (empleados_na[ffinal,'Salario'] >= 35000 & empleados_na[ffinal,'Salario'] < 50000),1,0))
#  c.Gerente con salario menor a 40000
sum(ifelse(empleados_na[ffinal,'Jerarquia'] == 'Gerente' & empleados_na[ffinal,'Salario'] < 40000,1,0))


ffinal2 <- !(empleados_na$Nombre %in% c('Juan','Diego','Eva')) & 
  empleados_na$PuestoTrabajo %in% c('Ventas','Finanzas') & 
  empleados_na$Antiguedad > 7 &
  (
    (empleados_na$Jerarquia == 'Jr' & empleados_na$Salario > 40000) |
    (empleados_na$Jerarquia == 'Sr' & (empleados_na$Salario >= 35000 & empleados_na$Salario < 50000)) |
    (empleados_na$Jerarquia == 'Gerente' & empleados_na$Salario < 40000)
  )
nrow(empleados_na[ffinal2,])
