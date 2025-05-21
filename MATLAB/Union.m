
    % CARGA DE LOS DATASETS QUE DESEA UNIR
ruta = 'C:\Users\monte\OneDrive\Desktop\Proyecto Alcaldía\Delitos Colombia\CAPTURAS';  % Ruta de la carpeta en la cual se encuentran los datasets
archivos = dir(fullfile(ruta, '*.csv'));                                               % Buscar todos los archivos tipo csv en la ruta
datos = cell(length(archivos), 1);                                                     % Celula vacia que va a contener los datos

for k = 1:length(archivos)                                                   % Lectura de cada file en la ruta
    nombre_Archivo = fullfile(ruta, archivos(k).name);                       % Lectura de la ruta de cada dataset de manera indicidual
    tabla = readtable(nombre_Archivo);                                       % Tabla con el dataset nombre_Archivo

    % Eliminar filas completamente vacías
    vacias = all(ismissing(tabla), 2);                                       % Encuentra filas en la tabla donde todos los elementos son NaN o estáns vacíos
    tabla(vacias, :) = [];                                                   % Elimina esas filas

    datos{k} = tabla;                                                        % Guarda la tabla limpia en la celula
end

    % UNIÓN DE LOS DATOS
union = vertcat(datos{:});                                                   % Une las filas que se encuentren en la variable datos

    % ALMACENAMIENTO DE LOS DATOS
writetable(union, 'C:\Users\monte\OneDrive\Desktop\Proyecto Alcaldía\Delitos Colombia\CAPTURAS\Datos_Unidos.csv');