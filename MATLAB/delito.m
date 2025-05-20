
    % Carga del dataset con todos los delitos
depto = 'Datos Limpios.csv'; %Nombre del departamento
data = readtable(fullfile('C:\Users\monte\OneDrive\Desktop\Proyecto Alcaldía\Delitos Colombia', depto)); %Tenga en cuenta que esta dirección puede cambiar 

    % Delito que desea filtrar
filter = 'ARTÍCULO 376. TRÁFICO. FABRICACIÓN O PORTE DE ESTUPEFACIENTES';

    % Nombre de la columna en la cual se desea buscar el delito
col = data.DESCRIPCION_CONDUCTA_CAPTURA;

    % Creación del nuevo dataset
filtrado = data(contains(lower(col), lower(filter)), :);

    % Guardado del nuevo dataset
writetable(filtrado, 'C:\Users\monte\OneDrive\Desktop\Proyecto Alcaldía\Delitos por Departamento\Colombia\Narcotrafico_Colombia.csv');