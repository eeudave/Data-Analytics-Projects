
# EJERCICIOS IF

#1.Básico: Crear un condicional que compare dos números y muestre un mensaje indicando cuál es mayor.

a <- 30
b <- 50

if (a == b) {
  print('los numeros son iguales')
} else if(a > b) {
  print('a es mayor que b')
} else if(b > a) {
  print('b es mayor que a')
}

#2.Condicionales Anidados: Crear un condicional que en función del color y la edad devuelva un mensaje con la categoría correspondiente. 
#  En caso de ingresar una edad mayor a 40, la categoría es “master” y si es menor o igual a 40, en caso de que el color sea verde la categoría es “inicial” y en caso contrario la categoría es “intermedio”.

color <- 'Verde'    
edad <- '40'    

if(edad > 40) {
  print('Master')
} else if(edad <= 40) {
  if(color == 'Verde') {
    print('Inicial')
  } else {
    print('Intermedio')
  }
} 

#3.Operadores Lógicos: Crear un condicional que determine si un número es positivo, negativo o cero.

numero <- 1

if(numero < 0) {
  print('Numero negativo')
} else if(numero > 0) {
  print('Numero positivo')
} else {
  print('El numero es 0')
}


#4.Múltiples Condiciones: Crear un condicional que compare tres números y verifique si al menos dos de ellos son iguales.

numero1 <- 20 
numero2 <- 30 
numero3 <- 30 

if(numero1 == numero2) {
  if(numero1 == numero3) { 
    print('Los 3 numeros son iguales') 
  } else { 
    print('Numero1 igual Numero2') 
  }
} else if (numero1 == numero3) {
  print('Numero1 igual Numero3')
} else if (numero2 == numero3) {
  print('Numero2 igual Numero3')
} else {
  print('No hay numeros iguales')
}

if(numero1 == numero2 | numero1 == numero3 | numero2 == numero3) {
  print('Al menos 2 numeros son iguales')
} else {
  print('Todos los numeros son diferentes')
}

#5.Condiciones con Strings: Crear un condicional que verifique si una palabra contiene la letra "a" o "A". (puede que la función grepl sea de utilidad)

palabra <- 'MatruscA'

if(grepl('a',palabra,TRUE) == TRUE) {
  print('La palabra contiene la letra a o A')
} else {
  print('La palabra NO contiene la letra a o A')
}


#6.Condiciones con Vectores: Crear un condicional que determine si un vector de números contiene algún valor negativo.

numeros <- c(2,4,6,8,10,12,14,16,-1)

if(any(numeros < 0)) {
  print('Hay algun nuemro negativo')
} else {
  print('No hay numeros negativos')
}

#7.Crear un condicional que determine si un alumno aprueba, desaprueba u obtiene título de honor en una asignatura de la universidad. 
#La misma contiene 3 módulos y, para aprobar la asignatura, los 3 módulos deben tener una nota mayor a 70. 
#Si el alumno tiene un promedio mayor a 80 entre los 3 módulos, se le entrega título de honor. 

modulo1 <- 83
modulo2 <- 80
modulo3 <- 80

if(modulo1 > 70 & modulo2 > 70 & modulo3 > 70) {
  if(mean(c(modulo1,modulo2,modulo3)) > 80) {
    print('Titulo de Honor')
  } else {
    print('Aprobado')   
  }
} else {
  print('No Aprobado')
}

# EJERCICIOS FOR

#1.Bucle Simple: Utiliza un bucle for para imprimir los números del 1 al 5.

numeros <- c(1,2,3,4,5)

for(x in numeros) {
  print(x)
}

#2.Bucle con Vectores: Crear un bucle for que recorra un vector de nombres e imprima cada nombre junto con su longitud. (ver función nchar)

nombres <- c('Erik','Niko','Andrea','Ana','Angel','Ivan','Miriam')

for(nombre in nombres) {
  long <-  nchar(nombre)
  print(paste(nombre,'-',long))
}

#3.Bucle con Suma Acumulativa: Utiliza un bucle for para calcular la suma de los primeros 10 números naturales.

naturales <- c(1:10)
suma <- 0

for(n in naturales) {
  suma <- suma + n 
  print(paste('numero:',n,'suma:',suma))
}

#4.Bucle con Condicional: Crea un bucle for que itere sobre una secuencia de números del 1 al 10 e imprima "par" o "impar" para cada número.

for(num in 1:10) {
  if(num%%2 == 0) {
    print(paste(num,':numero par'))
  } else {
    print(paste(num,':numero impar'))
  }
}

#5.Bucle Anidado: Utiliza un bucle for anidado para imprimir una tabla de multiplicar del 1 al 5.

for(a in 1:5) {
  for(b in 1:5) {
    c <- a*b
    print(paste(a,'por',b,'=',c))
    #cat(a,'por',b,'=',c,'\n')
  }
}

#6.Bucle con Suma Condicional: Escribe un bucle for que sume los números pares dentro de un rango de 1 a 20.

suma <- 0

for(numero in 1:20) {
  if(numero%%2 == 0) {
    print(paste('numero:',numero))
    suma <- suma + numero
    print(paste('suma acumulada:',suma))
  }
}


# EJERCICIOS WHILE

#1.Bucle Simple: Implementar un bucle while que imprima los números del 1 al 5.

x <- 1
while (x <= 5) {
  print(x)
  x <- x+1
}

#2.Bucle con Condicional: Utilizar un bucle while para imprimir los números pares hasta el 10.

x <- 1
while (x <= 10) {
  if(x%%2 == 0) {
    print(paste('Numero Par:',x)) 
  }
  x <- x+1
}

#3.Bucle con Suma Acumulativa: Crear un bucle while para calcular la suma de los primeros 10 números naturales.

suma <- 0
n <- 1

while(n <= 10){
  suma <- suma + n
  print(paste('Numero:',n,'Suma:',suma))
  n <-  n+1
}

#4.Bucle con Condiciones Combinadas: Utiliza un bucle while para imprimir los números que son múltiplos de 3 y 5 en un rango del 1 al 100.

numeros <- c(1:100)
n <- 1

while(n <= 100) {
  if(numeros[n]%%3 == 0) {
    print(paste('Numero:',numeros[n],'multiplo de 3'))
  } else if(numeros[n]%%5 == 0) {
    print(paste('Numero:',numeros[n],'multiplo de 5'))
  }
  n <- n+1
}

#5.Bucle con Cambio de Condición: Implementa un bucle while que imprima los cuadrados de los números hasta que el cuadrado sea mayor que 100.

numeros <- c(1:20)
cuadrado <- 0
n <- 1

while(n <= 20) {
  cuadrado <- numeros[n] * numeros[n]
  if(cuadrado > 100) {
    print('Cuadrado mayor a 100')
    break
  } else {
    print(paste('Numero:',numeros[n],'Cuadrado:',cuadrado))
  }
  n <- n+1
}

# EJERCICIO FUNCIONES

#1.Función Básica: Crea una función que acepte dos números como parámetros y devuelva su suma.

suma <- function(num1,num2) {
  sum <- num1 + num2
  return(sum)
}

suma(33,5)

#2.Función con Argumentos Predeterminados: Diseña una función que calcule el área de un círculo en función del radio ingresado (recuerda que el área de un círculo se calcula como pi * radio^2, “pi” es una variable conocida para R).

area_circulo <- function(radio) {
  area <- pi * (radio^2)
  return(area)
}

area_circulo(5)


#3.Función con Bucle Interno: Desarrolla una función que tome un número como parámetro y devuelva la suma de todos los números naturales hasta ese número.

suma_bucle <- function(numero) {
  x <- 1
  suma <- 0
  while(x < numero) {
    #print(x)
    suma <- suma + x
    x <- x+1
  }
  return(suma)
}

suma_bucle(6)

#4.Crear una función que tome como parámetro un vector de palabras y devuelva cual es la palabra más larga del vector.

longitudp <- function(nombres) {
  maxlong <- 0
  maxnom <- '' 
  for(nombre in nombres) {
    long <-  nchar(nombre)
    if(long > maxlong) {
      maxlong <- long
      maxnom <- nombre
    }
  }
  return(maxnom)
}

nombres <- c('Erikberto','Niko','Andrea','Ana','Angel','Ivan','Miriam')
longitudp(nombres)

#5.Crea una función que tome un vector de números y devuelva la suma de los cuadrados de esos números.

cuadrados <- function(...) {
  valores <- c(...)
  cuadrado <- 0
  sumacuad <- 0
  for(x in valores) {
    cuadrado = x^2
    sumacuad = sumacuad + cuadrado
  }
  return(sumacuad)
}

cuadrados(3,3,3)

#6.Crear una función que tome como input un dataframe con las columnas Nombre y Edad y devuelva un vector con los nombres de las personas con edades mayores a 50 años (puedes tomar como base la tabla de empleados generada en el ejercicio anterior)

View(empleados)

mayores50 <- function(empleados) {
  personas <- empleados[,c('Nombre','Edad')]
  mayores <- c()
  
  for(pe in 1:nrow(personas)){
    fila <- personas[pe, ]
    if(fila$Edad > 50) {
      mayores <- c(mayores,fila$Nombre)
    }
  }
  return(mayores)
}

mayores50(empleados)

#7.Crear una función que tome como input una tabla con columnas de valores numéricos y devuelva una tabla con la misma cantidad de columnas y filas, pero con todos sus valores multiplicados por 2

numericos <- data.frame(
  Edad = c(20,23,30,39,44,50),
  Atiguedad = c(1,5,8,10,15,25)
)

pordos <- function(numeros) {
  numeros2 <- numeros
  for (i in 1:nrow(numeros)) {
    for (j in 1:ncol(numeros)) {
      numeros2[i, j] <- numeros[i, j]*2
    }
    return(numeros2)
  }
}  

pordos(numericos)
