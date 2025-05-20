
########## PREPARACIÓN DE LOS DATOS ########## 

  # Cargar librerías necesarias
library(tidyverse)
library(lubridate)


  # Lectura del Dataset
depto <- "Datos2010-2024.csv"                                                    # Nombre del dataset
data <- read_csv(file.path('C:/Users/monte/OneDrive/Desktop', depto));           # Tenga en cuenta que esta dirección puede cambiar 

  # Filtrar por delito
filter <- "ARTÍCULO 376. TRÁFICO. FABRICACIÓN O PORTE DE ESTUPEFACIENTES"        # Delito que desea filtrar
filtrado <- data %>%
  filter(str_detect(tolower(DESCRIPCION_CONDUCTA_CAPTURA), tolower(filter)))     # Datos Filtrados

  # Agrupación de los datos por mes
filtrado <- filtrado %>%
  mutate(MES = floor_date(as.Date(FECHA_HECHO), "month"))                        # Redondear hacia el inicio del mes

  # Agrupar por MES y sumar la CANTIDAD
df <- filtrado %>%
  group_by(MES) %>%
  summarise(CANTIDAD = sum(CANTIDAD, na.rm = TRUE), .groups = "drop")


  # Test de Dickey-Fuller
library(tseries)

serie_ts <- ts(df$CANTIDAD, start = c(2010, 1), frequency = 12)
plot(serie_ts)  # Visualización
adf.test(serie_ts, alternative = "stationary", k=0)


  # Periodograma
p = periodogram(serie_ts)
max(p$spec)
p$freq[match(max(p$spec),p$spec)]
1/p$freq[match(max(p$spec),p$spec)]

########## PARAMETROS ##########

library(forecast)

modelo1 = auto.arima(serie_ts)
summary(modelo1)

########## PREDICCIÓN ##########

pred = forecast(modelo1, h = 1)
plot(pred, col = "red")
prediccion <- pred$mean
prediccion
pred_error <- data.frame(predict(pred, n.ahead = 3))
pred_error
