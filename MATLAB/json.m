
%UTILICE ESTE SCRIP PARA CARGAR EL JSON DE COLOMBIA, Y ASÍ OBTENER LA
%LATITUD Y LONGITUD DE LOS DEPARTAMENTOS


    %Cargar Primero el file json
fid = fopen('Delitos Colombia\DANE\GeoColombia.json', 'r', 'n', 'UTF-8');
str = fread(fid, '*char')';
fclose(fid);
json_data = jsondecode(str);

    % Eliminar la columna innecesaria 'Tipo'
datos = rmfield(json_data, 'Tipo');

    %Cambia el nombre de algunas columnas
[datos.DEPARTAMENTO] = datos.Departamento;
datos = rmfield(datos, 'Departamento');
[datos.MUNICIPIO] = datos.Localidad;
datos = rmfield(datos, 'Localidad');

    %Convierte datos de tipo estructura a tipo tabla
datos = struct2table(datos);

%%%%%%%%%%%%%%

    %CREACIÓN DE UNA BASE DE DATOS MENSUALES "datmen"
 
    %Carga el dataset de los datos limpios
copia = readtable('Delitos Colombia\Datos Limpios.csv');

    %Funciona la tabla 'copia' con la tabla 'datos' 
union = innerjoin(copia, datos, 'Keys', {'DEPARTAMENTO', 'MUNICIPIO'});

    %Filtra solo las filas donde la captura corresponde al Artículo ingresado
filtro = strcmp(union.DESCRIPCION_CONDUCTA_CAPTURA, 'ARTÍCULO 376. TRÁFICO. FABRICACIÓN O PORTE DE ESTUPEFACIENTES');
filtered_data = union(filtro, :);

    %Obtener el año y mes (inicio de mes)
filtered_data.MES = dateshift(filtered_data.FECHA_HECHO, 'start', 'month');

    % Agrupar y sumar
varsAgrupar = {'MES', 'DEPARTAMENTO', 'MUNICIPIO', 'LATITUD', 'LONGITUD'};
[grupos,~,idx] = unique(filtered_data(:, varsAgrupar), 'rows');
cantidades = accumarray(idx, 1); % asumiendo que cada fila es 1 evento


    %Creación de la tabla "datmen"
datmen = [grupos, table(cantidades, 'VariableNames', {'CANTIDAD'})];
datmen = datmen(:, {'MES', 'LATITUD', 'LONGITUD', 'CANTIDAD'});

    %guarda a datmen como un CSV
writetable(datmen, 'datosespaciales.csv');

