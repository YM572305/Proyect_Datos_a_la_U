% Paso 1: Cargar el shapefile o TopoJSON de la región
disp('Leyendo Archivo de mapa.');
colombia_shp = "C:\Users\monte\OneDrive\Desktop\Proyecto Alcaldía\Shapefile de Colombia\MGN_ADM_MPIO_GRAFICO.shp"; % Cambia el nombre del archivo según corresponda
S = shaperead(colombia_shp);

% Obtener los límites del shapefile para todo Colombia
long_min = min([S.X]);
long_max = max([S.X]);
lat_min = min([S.Y]);
lat_max = max([S.Y]);

% Convertir shapefile a polyshape para facilitar la máscara
poligono_colombia = polyshape([S.X], [S.Y]);

% Cargar los datos desde un archivo CSV
disp('Cargando datos desde el archivo CSV...');
df = readtable('C:\Users\monte\OneDrive\Desktop\Proyecto Alcaldía\JULIAN.csv'); % Cambia el nombre del archivo si es necesario
%df = readtable('C:\Users\monte\OneDrive\Desktop\Proyecto Alcaldía\Delitos por Departamento\Colombia\COLOMBIA.csv');
disp('Datos cargados correctamente.');

% Variables de latitud, longitud y cantidad
latitudes = df.LATITUD;
longitudes = df.LONGITUD;
cantidad_crimenes = df.CANTIDAD;
meses = df.MES;

disp('Variables cargadas: Latitudes, Longitudes, Cantidad de crímenes, Meses.');

% Convertir 'MES' al formato de fecha si es necesario y extraer año y mes
disp('Convirtiendo los meses a formato de fecha...');
fechas = datetime(meses, 'InputFormat', 'yyyy-MM');
meses = month(fechas);
anios = year(fechas);
disp('Meses convertidos correctamente.');

% Definir el mes y año que deseas filtrar
mes_filtrar = 1;
anio_filtrar = 2012;

% Filtrar los datos para el mes y año seleccionados
disp(['Filtrando datos para el mes ', num2str(mes_filtrar), ' y año ', num2str(anio_filtrar), '...']);
idx_filtr = (meses == mes_filtrar) & (anios == anio_filtrar);

% Aplicar el filtro a las variables
lat_filtr = latitudes(idx_filtr);
lon_filtr = longitudes(idx_filtr);
cant_filtr = cantidad_crimenes(idx_filtr);

% Paso 1: Agregar puntos ficticios en las esquinas del mapa
corner_lats = [lat_min, lat_min, lat_max, lat_max];
corner_lons = [long_min, long_max, long_min, long_max];
corner_crimes = [0,0,0,0]; % Usar 0 delitos en las esquinas

disp(['Se han filtrado ', num2str(sum(idx_filtr)), ' registros para el mes y año seleccionados.']);
% Ejemplo de interpolación IDW

p25 = prctile(cant_filtr,50);
disp(p25)
i = find(cant_filtr>p25);
lat_filtr = lat_filtr(i);
lon_filtr = lon_filtr(i);
cant_filtr = log(cant_filtr(i) + 1);
a = min(cant_filtr);
b = max(cant_filtr);
cant_filtr = (cant_filtr - a)/(b - a);

% Combinar los puntos reales con los puntos ficticios de las esquinas
lat_filtr = [lat_filtr; corner_lats'];
lon_filtr = [lon_filtr; corner_lons'];
cant_filtr = [cant_filtr; corner_crimes'];

% Crear la malla de puntos en las coordenadas deseadas (todo Colombia)
[long_grid, lat_grid] = meshgrid(linspace(long_min, long_max, 100), ...
                                 linspace(lat_min, lat_max, 100));
xi = long_grid(:);
yi = lat_grid(:);

% Crear interpolación IDW
F = scatteredInterpolant(lon_filtr, lat_filtr, cant_filtr, 'natural', 'none');
zi_idw = F(xi, yi);

% Crear máscara para los puntos fuera del shapefile
dentro_shapefile = inpolygon(xi, yi, poligono_colombia.Vertices(:,1), poligono_colombia.Vertices(:,2));
zi_idw(~dentro_shapefile) = NaN;
zi_grid_idw = reshape(zi_idw, size(long_grid));

% Graficar el resultado de IDW
figure;
mapshow(S, 'FaceColor', [0.95, 0.95, 0.95], 'EdgeColor', 'k'); % Muestra los bordes del mapa en negro
hold on;
disp("Se cargó el mapa");

% Ajustar el número de niveles y el colormap con transparencia
contourf(long_grid, lat_grid, zi_grid_idw, 800, 'LineColor', 'none', 'FaceAlpha', 0.95); % FaceAlpha para transparencia

% Ajustar el rango de la barra de colores y aplicar un colormap
colormap(turbo); % Cambia a 'jet', 'hot', o cualquier otro colormap para más variedad

colorbar;
clim([0,1]);

% Agregar título con más espaciado superior
title_handle = title(['  TRÁFICO. FABRICACIÓN O PORTE DE ESTUPEFACIENTES en ', num2str(mes_filtrar), '/', num2str(anio_filtrar)]);

% Ajustar el espaciado superior
set(title_handle, 'Units', 'normalized', 'Position', [0.5, 1.01, 0]); % Aumenta el valor 1.1 para más espaciado

% Agregar texto "IDW" al lado izquierdo del mapa
text(long_min + 0.03*(long_max - long_min), lat_max - 0.05*(lat_max - lat_min), 'IDW', 'FontSize', 18, 'FontWeight', 'bold', 'Color', 'black');

xlabel('Longitud');
ylabel('Latitud');
xlim([long_min, long_max]);
ylim([lat_min, lat_max]);

% Eliminar los ejes
axis off;

hold off;
