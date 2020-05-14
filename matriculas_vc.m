clear all
close all

PATH = "/media/david/729A72279A71E84D/Users/David/Desktop/Enginyeria-Informatica/VC/practiques/Imatges matricules/";
image = uint16(imread(PATH + "Imatge1-blau.jpg"));

% Segmentamos la matricula.
segmented = segment(image);

% Cortamos cada caracter de la matricula y lo guardamos en un array.
number_plate = crop(segmented);

%figure, imshow(number_plate{3},[]);

% Cargamos los modelos de letras para comparar.
models = load_models();
%figure, imshow(models{28}, []);

% Mostramos la imagen segmentada.
figure, imshow(segmented, []);

% Identificamos cada uno de los caracteres de la matricula.
for i = 1: size(number_plate)
    plate_text(i) = detect(models, number_plate{i});
end

% Mostramos el resultado por el terminal.
disp(string(plate_text));

% Función que a partir de una imagen detecta el caracter que le
% correpsonde.
function character = detect(models, letter)
    comp = zeros(1, size(models, 1)); % Inicializamos el vector.
    
    % Por cada elemento del vector comp
    for i = 1 : size(models,1)
        % Comparamos las dos matrices mediante su coeficiente de
        % correlación
        comp(i) = corr2(models{i}, letter); 
    end
    
    % Buscamos la mayor igualdad de las almacenadas.
    winer=find(comp==max(comp));
    
    % Comprovamos a que caracter ascii pertenece.
    if(winer <= 26) 
        character = char(winer+64);
    else
        character = char(winer-26+47);
    end
end

% Funcion para cargar las letras que serviran de modelo.
function models = load_models()
    I = imread("./fuente1_matriculak.png"); % Leemos la imagen.
    % Binarizamos la imagen y obtenemos su complementaria.
    bw = imcomplement(imbinarize(rgb2gray(I)));
    
    % Recortamos cada caracter de la imagen y los guardamos en un array.
    models = crop(bw);
end

% Función para segmentar los caracteres de la matricula.
function I2 = segment(I)
    % Creamos un filtro gaussiano y filtramos la imagen para suabizarla 
    gauss = fspecial('gaussian', 5);
    filtered = imfilter(I, gauss);
    
    % Pasamos la imagen filtrada a el espacio de color HSV.
    hsv = rgb2hsv(filtered);
    [h,s,v] = imsplit(hsv); % Separamos matiz, saturación y valor.
    mask = h >= 0.33 & h <= 0.5; % Filtramos por matiz verde.

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
        % Guardamos la fila correspondiente a i de la matriz regions.
        region = regions(i,:);
        % Recortamos el caracter segun su BoundingBox i cambiamos su tamaño
        % por uno fijo.
        words_array{i} = imresize(imcrop(I,region.BoundingBox), [128, 64]);
    end
end

