
%UTILICE ESTE SCRIP PARA CARGAR SUS DATOS, LIMPIARLOS Y FILTRARLOS POR DEPARTAMENTOS

%%%%%%%%%%%%%%

    %Carga el archivo CSV con los datos completos y los almacena en la variable datos
datos = readtable("Delitos Colombia\Datos2010-2015.csv");

    % Limpia los datos eliminando departamentos que no pertenecen al país
datos = datos(~strcmpi(datos.DEPARTAMENTO, 'MADRID'), :);
datos = datos(~strcmpi(datos.DEPARTAMENTO, 'QUITO'), :);
datos = datos(~strcmpi(datos.DEPARTAMENTO, 'NEW YORK'), :);
datos = datos(~strcmpi(datos.DEPARTAMENTO, 'NEW JERSEY'), :);
datos = datos(~strcmpi(datos.DEPARTAMENTO, 'FLORIDA'), :);

    %Limpia el nombre de los municipios elminando '(CT)' de sus nombres 
datos.MUNICIPIO = regexprep(datos.MUNICIPIO, '\s*\(CT\)', '');

    %Convierte las fechas en datatiempos
%datos.FECHA_HECHO = datetime(datos.FECHA_HECHO, 'InputFormat', 'dd-MM-yyyy');

%%%%%%%%%%%%%%

    %Se crea una copia del dataframe para evitar modificar el original
copia = datos;

%%%%%%%%%%%%%%


    % Eliminar la columna innecesaria 'CODIGO_DANE'
copia.CODIGO_DANE = [];
    %Se corrigen errores en los nombres de algunos municipios
copia = conver_name(copia); %se aplica la funcion conver_name
    %Secorrigen el nombre de algunos departamentos
copia.DEPARTAMENTO(strcmp(copia.DEPARTAMENTO, 'VALLE')) = {'VALLE DEL CAUCA'};
copia.DEPARTAMENTO(strcmp(copia.DEPARTAMENTO, 'GUAJIRA')) = {'LA GUAJIRA'};


%%%%%%%%%%%%%%

% Separa a BOGOTA del conjunto de datos de CUNDINAMARCA y lo convierte en un departamento independiente

    %Identifica aquellos municipios que coincidan con BOGOTA
bogota_datos = copia(strcmp(copia.MUNICIPIO, "BOGOTÁ D.C."), :);
    %En bogota_datos, sustituye la palabra 'CUNDINAMARCA' por 'BOGOTÁ D.C.'
bogota_datos(:,1) = {'BOGOTÁ D.C.'};
    %Convierte a Bogotá como un departamento en el CSV 'Copia'
copia.DEPARTAMENTO(strcmp(copia.MUNICIPIO, 'BOGOTÁ D.C.')) = {'BOGOTÁ D.C.'};

%%%%%%%%%%%%%%

%Los delitos que estén por fuera del percentil 88 los coloca en otra categoeria llamada 'OTROS'

    %frecuencia de los delitos en la copia
frecuencia = groupcounts(copia, 'DESCRIPCION_CONDUCTA_CAPTURA');
    %Calcula el percentil 88 de la frecuencia
p80 = prctile(frecuencia.GroupCount, 88);
    %Identificar delitos por encima al percentil 88 y remplazarlos por 'OTROS'
DelFil = frecuencia.DESCRIPCION_CONDUCTA_CAPTURA(frecuencia.GroupCount <= p80);
    %Reemplazar en 'copia' los delitos encontrados en DelFil por 'OTROS'
for i = 1:length(DelFil)
    copia.DESCRIPCION_CONDUCTA_CAPTURA(strcmp(copia.DESCRIPCION_CONDUCTA_CAPTURA, DelFil{i})) = {'OTROS'};
end

%%

%ALMACENAMIENTO DE LOS DEPARTAMENTOS EN CSVS SEPARADOS

    % Obtiene los nombres de los dapartamentos que hacen parte del conjunto de datos
departamentos = unique(copia.DEPARTAMENTO);

    % Crea una carpeta llamada 'Datos por Departamentos' de salida si no existe
carpetaSalida = 'Datos por Departamentos';
if ~exist(carpetaSalida, 'dir')
    mkdir(carpetaSalida);
end

% Crea un csv para cada DEPARTAMENTO 
for i = 1:length(departamentos)
    depto = departamentos{i};
    datosDepto = copia(strcmp(copia.DEPARTAMENTO, depto), :);

    % Limpiar el nombre del archivo
    nombreArchivo = [regexprep(depto, '[^\w]', '_'), '.csv'];

    % Ruta completa al archivo dentro de la carpeta
    rutaCompleta = fullfile(carpetaSalida, nombreArchivo);

    % Guardar CSV
    writetable(datosDepto, rutaCompleta);
end

    %guarda a BOGOTA en un CSV a parte
writetable(bogota_datos, 'Datos por Departamentos\BOGOTA.csv');

    %guarada un CSV con los datos de COLOMBIA limpios
writetable(copia, 'Delitos Colombia\Datos Limpios.csv');
