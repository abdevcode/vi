function [plateText, segmentedPlate] = getPlateText(image, mdl)
    % Segmentamos la matricula.
    segmented = segment(image);

    % Cortamos cada caracter de la matricula y lo guardamos en un array.
    number_plate = crop(segmented);
    
    cleaned = clean_plate(number_plate);

    % Mostramos la imagen segmentada.
    %figure, imshowpair(uint8(image), segmented, 'montage');
        
    % Llamamos a la funcion para detectar cada caracter de la matricula
    plate_text = detect(mdl, cleaned);

    
    
    % Mostramos el resultado por el terminal.
    %disp(string(plate_text));
    %plateText = string(plate_text);
    
    [f c]= size(convertStringsToChars(plate_text));
    
    % Si no detecta los 6 caracteres rellenamos con 0 al prinicpio
    if(c < 6)
        complete_text = "";
        for i = 1 : 6-c
            plate_text=append(plate_text,"0");
        end
    end
    plateText = convertStringsToChars(plate_text);
end




% Funci贸n que a partir de una imagen detecta el caracter que le
% correpsonde.
function result = detect(model, plate)
    result = "";
    for i = 1 : size(plate,1)
        % Extraemos el vector con el histograma de gradientes 
        featureVector = double(extractHOGFeatures(plate{i}));
        character = predict(model, featureVector);
        result = result + string(character);
    end
end



% Funcion para cargar las letras que serviran de modelo.
function [props, class] = load_properties(models)
    class = ["A";"B";"C";"D";"E";"F";"G";"H";"I";"J";"K";"L";"M";"N";"O"];
    class = [class ; "P";"Q";"R";"S";"T";"U";"V";"W";"X";"Y";"Z"];
    class = [class ; "0";"1";"2";"3";"4";"5";"6";"7";"8";"9"];
    
    
    featureVector = double(extractHOGFeatures(models{1}));
    [r, c] = size(featureVector);
    
    props = double(zeros(size(models,1), c)); % Inicializamos la matriz
    props(1, :) = featureVector;
    for i = 2 : size(models, 1)
        % Guardamos el vector de HOG de la imagen 
        featureVector = double(extractHOGFeatures(models{i}));
        props(i, :) = featureVector;
        
    end
end


% Funci贸n para segmentar los caracteres de la matricula.
function I2 = segment(I)

% Dilatamos la imagen resultante.
    se2 = strel('square', 2);
    eroded = imerode(I, se2);
    
    h = fspecial('gaussian',4);
    %dilated = imfilter(dilated,h);
    
    imgray = rgb2gray(eroded);
    
    J = adaptthresh(imgray,'Statistic','gaussian', 'ForegroundPolarity', 'dark');
    bw =~ imbinarize(imgray, J);
    
    
    
    % Eliminamos las regiones menores a 200 pixeles.
    bw = bwareaopen(bw, 200);
    
    I2 = bw;


% 
%     im_r = I(:, :, 1);
%     im_g = I(:, :, 2);
%     im_b = I(:, :, 3);
%     
%     I = im_g + im_b - im_r;
%     
%     
%     J = adaptthresh(I,'Statistic','gaussian', 'ForegroundPolarity', 'dark');
%     bw = imbinarize(I, J);
%     
%     se = strel('square', 3);
%     
%     bw = imerode(bw, se);
%     
%     bw = bwareaopen(bw, 100);
%     
%     %imshow(bw);
%     
%     I2 = bw;
end

function cleaned = clean_plate(segmented)
    cleaned = cell(6);
    
    [f c] = size(segmented);
    if(f == 7)
        cleaned{1} = segmented{1};
        cleaned{2} = segmented{2};
        cleaned{3} = segmented{3};
        cleaned{4} = segmented{5};
        cleaned{5} = segmented{6};
        cleaned{6} = segmented{7};

    else
       cleaned = segmented;
    end
end

% Funci贸n para recortar los caracteres de la matricula y guardarlos en un
% array, como imagenes de un tama帽o fijo.
function words_array = crop(I)
    % Obtenemos la propiedad boundingbox de cada region.
    regions = regionprops(I, 'boundingbox');
    words_array = cell(numel(regions)); % Inicializamos word_array.
    for i = 1: numel(regions)
        % Recortamos el caracter segun su BoundingBox i cambiamos su tama帽o
        % por uno fijo.
        words_array{i} = imresize(imcrop(I,regions(i).BoundingBox), [42, 32]);
    end
end

