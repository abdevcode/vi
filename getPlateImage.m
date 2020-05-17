function plate_image = getPlateImage(image)
    real_image = image;


    %==> PREPROCESAMIENTO 
    % Transformamos la imagen en escala de grises
    % Se pierde tono y saturacion pero se mantiene luminancia
    image = rgb2gray(image);

    % Usamos un filtro para el suavizado (en este caso la mediana)
    image = medfilt2(image, [5 5]);

    %==> SEGMENTACION
    corte = AumentarZonaMatricula(image); 
    real_image = imcrop(real_image, corte);
    image = imcrop(image, corte);

    % Aplicamos operacion morfologica de cierre en la imagen 
    se = strel('disk', 20);
    image = imclose(image, se);
    image = imopen(image, se);

    BW = imbinarize(image);

    %Crea regiones
    [Etiquetas, N] = bwlabel(BW);

    MAP = [0 0 0; jet(N)];
    I = ind2rgb(Etiquetas+1, MAP);

    stats = regionprops(Etiquetas,'all');
    areaMaxima = sort([stats.Area],'descend');
    indiceLogo = find([stats.Area]==areaMaxima(1) ); % Coloca en orden de mayor a menor las áreas de la imagen

    for i = 1:size(indiceLogo,2)
        % Obtenemos todas las esquinas
        corner_plate = stats(indiceLogo(i)).BoundingBox;
    end

    X = corner_plate(1);
    Y = corner_plate(2);
    W = corner_plate(3);
    H = corner_plate(4);

    corte = [(X+2) (Y+5) (W-4) (H-10)]; %Determina coordenadas de corte

    plate_image = imcrop(real_image, corte);
end