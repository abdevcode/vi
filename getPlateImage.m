function plate_image = getPlateImage(image)
    real_image = image;


    %==> PREPROCESAMIENTO 
    % Transformamos la imagen en escala de grises
    % Se pierde tono y saturacion pero se mantiene luminancia
    image = rgb2gray(image);

    % Usamos un filtro para el suavizado (en este caso la mediana)
    image = medfilt2(image, [5 5]);

    %==> SEGMENTACION
    %corte = AumentarZonaMatricula(image); 
    %real_image = imcrop(real_image, corte);
    %image = imcrop(image, corte);
    
    

    % Aplicamos operacion morfologica de cierre en la imagen 
    se = strel('square', 20);
    image = imclose(image, se);
    
    
    
    image = imopen(image, se);
    %image = medfilt2(image, [5 5]);
    %figure, imshow(image);
    

    BW = imbinarize(image, 0.5);
    
    BW = bwareaopen(BW, 8000);

    %figure, imshow(BW);
    
    
    %Crea regiones
    [Etiquetas, N] = bwlabel(BW);

    MAP = [0 0 0; jet(N)];
    I = ind2rgb(Etiquetas+1, MAP);

    stats = regionprops(Etiquetas,'all');
    
    % Filtramos por la area que mas o menos tienen las matriculas de
    % nuestras imagenes
    plate_image = image;
    if size(stats) > 0
        corner_plate = stats(1).BoundingBox;


        for i = 1:size(stats)
            base = uint16(stats(i).BoundingBox(3));
            altura = uint16(stats(i).BoundingBox(4));

            if base > (altura*2)-20
                area_max = base*altura;
                area_min = area_max - 1500;

                if stats(i).Area > area_min & stats(i).Area < area_max 
                    corner_plate = stats(i).BoundingBox;

                    stats(i)

                    break
                end
            end
        end


    %     areaMaxima = sort([stats.Area],'descend');
    %     indiceLogo = find([stats.Area]==areaMaxima(1) ); % Coloca en orden de mayor a menor las áreas de la imagen
    % 
    %     corner_plate = stats(1).BoundingBox;

        X = corner_plate(1);
        Y = corner_plate(2);
        W = corner_plate(3);
        H = corner_plate(4);

        corte = [(X+2) (Y+5) (W-4) (H-10)]; %Determina coordenadas de corte

        plate_image = imcrop(real_image, corte);
    end
end