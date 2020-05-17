clear all
close all
clc

PATH = "/media/david/729A72279A71E84D/Users/David/Desktop/Enginyeria-Informatica/VC/practiques/Imatges matricules/";
image = uint16(imread(PATH + "Imatge1-rosa.jpg"));



% Segmentamos la matricula.
segmented = segment(image);

% Cortamos cada caracter de la matricula y lo guardamos en un array.
number_plate = crop(segmented);

% Mostramos la imagen segmentada.
figure, imshowpair(uint8(image), segmented, 'montage');

[props, class] = load_models("matriculas", 11);

X = props;
Y = class;
% Entrena a un clasificador de vecinos 3 más cercanos.
Mdl = fitcknn(X,Y,'NumNeighbors', 4);

% Llamamos a la funcion para detectar cada caracter de la matricula
plate_text = detect(Mdl, number_plate);

% Mostramos el resultado por el terminal.
disp(string(plate_text));

% Función que a partir de una imagen detecta el caracter que le
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

function [props, class] = load_models(folder, num_models)
    I = imread(folder + "/fuente"+1+"_matricula.png"); % Leemos la imagen.
    % Binarizamos la imagen y obtenemos su complementaria.
    bw = imcomplement(imbinarize(rgb2gray(I)));
    % Recortamos cada caracter de la imagen y los guardamos en un array
    % ademas cargamos todas las propiedades y sus clases en dos matrices.
    [props, class] = load_properties(crop(bw));
    
    for i = 2 : num_models
        I = imread(folder + "/fuente"+i+"_matricula.png"); % Leemos la imagen.
        % Binarizamos la imagen y obtenemos su complementaria.
        bw = imcomplement(imbinarize(rgb2gray(I)));
        % Recortamos cada caracter de la imagen y los guardamos en un array
        % ademas cargamos todas las propiedades y sus clases en dos matrices.
        [p, c] = load_properties(crop(bw));
        props = [props ; p];
        class = [class ; c];
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


% Función para segmentar los caracteres de la matricula.
function I2 = segment(I)
    % Creamos un filtro gaussiano y filtramos la imagen para suabizarla 
    gauss = fspecial('gaussian', 10);
    filtered = imfilter(I, gauss);
    
    % Pasamos la imagen filtrada a el espacio de color HSV.
    hsv = rgb2hsv(filtered);
    [h,s,v] = imsplit(hsv); % Separamos matiz, saturación y valor.
    mask = h >= 0.15 & h <= 0.37; % Filtramos por matiz verde.
    
    % Erosionamos la imagen filtrada.
    se = strel('square', 2);
    eroded = imerode(mask, se);
    
    % Eliminamos las regiones menores a 200 pixeles.
    cleaned = bwareaopen(eroded, 200);
    
    % Dilatamos la imagen resultante.
    se2 = strel('square', 3);
    dilated = imdilate(cleaned, se2);
    
    I2 = dilated;
end

% Función para recortar los caracteres de la matricula y guardarlos en un
% array, como imagenes de un tamaño fijo.
function words_array = crop(I)
    % Obtenemos la propiedad boundingbox de cada region.
    regions = regionprops(I, 'boundingbox');
    words_array = cell(numel(regions)); % Inicializamos word_array.
    for i = 1: numel(regions)
        % Recortamos el caracter segun su BoundingBox i cambiamos su tamaño
        % por uno fijo.
        words_array{i} = imresize(imcrop(I,regions(i).BoundingBox), [52, 42]);
    end
end

