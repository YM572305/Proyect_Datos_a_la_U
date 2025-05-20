%%%%%%% PREPARACIÓN DE LOS DATOS DE LOS DATOS LIMPIOS %%%%%%%

    %Dataset
depto = 'Datos2010-2024.csv';                                               % Nombre del dataset
data = readtable(fullfile('C:\Users\monte\OneDrive\Desktop', depto));       % Tenga en cuenta que esta dirección puede cambiar 

    % Filtrado de delito
filter = 'ARTÍCULO 376. TRÁFICO. FABRICACIÓN O PORTE DE ESTUPEFACIENTES';   % Delito que desea filtrar
col = data.DESCRIPCION_CONDUCTA_CAPTURA;                                    % Nombre de la columna en la cual se desea buscar el delito
filtrado = data(contains(lower(col), lower(filter)), :);                    % Creación del nuevo dataset

    %Agrupación de los datos mensualmente
filtrado.MES = dateshift(filtrado.FECHA_HECHO, 'end', 'month');             % Obtener el año y mes (inicio de mes)
df = groupsummary(filtrado, 'MES', 'sum', 'CANTIDAD');                      % Agrupar por MES y sumar la CANTIDAD correspondiente
df.GroupCount = [];                                                         % Eliminar la columna innecesaria
df.Properties.VariableNames(2) = "CANTIDAD";                                % Modificación del nombre de la columna sum_CANTIDAD

% --- Gráfico de los datos ---
figure;
plot(df.MES, df.CANTIDAD, '-', 'LineWidth', 1.5);
title('Serie Original');
xlabel('Fecha'); ylabel('Cantidad');
grid on;

    % Test de Dickey-Fuller
[h,pValue,stat,cValue] = adftest(df.CANTIDAD, 'Model','ARD'); 
disp('el p_valor de sus datos es de ')
disp(pValue)

%%%%%%%______%%%%%%%

%%

%%%%%%% OBTENCIÓN DE LOS PARAMETRO AR-I-MA %%%%%%%

    % Diferenciación de los datos
cantidad_diff = diff(df.CANTIDAD);                                          % Diferenciación de la columna CANTIDAD
fechas_diff = df.MES(2:end);                                                % Al diferenciar, se reduce una fila

% --- Gráfico de serie diferenciada ---
subplot(3,1,1);
plot(fechas_diff, cantidad_diff, '-', 'LineWidth', 1.5, 'Color', [0.85 0.33 0.1]);
title('Serie Diferenciada (1ª orden)');
xlabel('Fecha'); ylabel('Diferencia');
grid on;

% --- Autocorrelación de la serie diferenciada ---
subplot(3,1,2);
autocorr(cantidad_diff);
title('Autocorrelación de la Serie Diferenciada');

% --- Autocorrelación Parcial de la serie diferenciada ---
subplot(3,1,3);
parcorr(cantidad_diff);
title('Autocorrelación Parcial (PACF) de la Serie Diferenciada');

    % Test de Dickey-Fuller para los datos diferenciados
[h, pValue, stat, cValue] = adftest(cantidad_diff);
disp('el p_valor de sus datos es de ')
disp(pValue)

warning('SI SU P_VALOR OBTENIDO ES SUPERIOR A 0.05, DEBE DE DIFERENCIAR NUEVAMENTE LOS DATOS');

%%%%%%%______%%%%%%%

%%

%%%%%%% CONSTRUCCIÓN DEL MODELO ARIMA %%%%%%%


Mdl = arima(11,1,1)

%%%%%%%______%%%%%%%