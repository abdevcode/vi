

function [result] = AumentarZonaMatricula(image)
    
    % Aplicamos el algoritmo de canny para obtener los bordes
    %   > Con esto conseguimos remarcar la zona donde "es posible" que se
    %   encuentre la matricula
    image_edge = edge(image, 'canny', 0.5);
    
    % Obtenemos el tamaño de la imagen
    [X, Y] = size(image_edge);
    
    % Creamos un vector de ceros con el numero de filas
    %   > Con esto se pretende contar el numero de discontinuidades de cada fila
    %   > La zona de la matricula tendra muchas discontinuidades generadas
    %   por los numeros
    B = zeros(X, 1);
    
    % Recorremos la imagen
    for i = 1:1:X
        aux = 1;
        pixel = zeros(3, 1);
        for j = 1:1:Y
            pixel(aux) = image_edge(i, j);
            aux = aux + 1;

            if aux > 3
                aux = 1;
                
                % Buscamos el patron [0 0 1]
                if ( pixel(1) == 0 && pixel(2) == 0 && pixel(3) == 1)
                    B(i) = B(i) + 1;
                end
                
                % Buscamos el patron [1 0 1]
                if ( pixel(1) == 1 && pixel(2) == 0 && pixel(3) == 1)
                    B(i) = B(i) + 1;
                end
                
                pixel = zeros(3, 1);
            end
        end
    end
    
    % La funcion max nos devuelve el maximo y la fila donde se encuentra
    % ese maximo
    [M, fila] = max(B)
    Lindex = fila - 80;
    Hindex = fila + 80;
    
    % A partir de la fila con mayor discontinuidad, recortamos la imagen 
    corte = [0 Lindex Y Hindex]; % Determina coordenadas de corte
    
    result = corte;
    % result = imcrop(image, corte);
end