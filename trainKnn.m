
function mdl = trainKnn()

    [props, class] = load_models("matriculas", 32);

    X = props;
    Y = class;
    % Entrena a un clasificador de vecinos 3 más cercanos.
    mdl = fitcknn(X,Y,'NumNeighbors', 3, 'Standardize', 1);
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

% Función para recortar los caracteres de la matricula y guardarlos en un
% array, como imagenes de un tamaño fijo.
function words_array = crop(I)
    % Obtenemos la propiedad boundingbox de cada region.
    regions = regionprops(I, 'boundingbox');
    words_array = cell(numel(regions)); % Inicializamos word_array.
    for i = 1: numel(regions)
        % Recortamos el caracter segun su BoundingBox i cambiamos su tamaño
        % por uno fijo.
        words_array{i} = imresize(imcrop(I,regions(i).BoundingBox), [42, 32]);
    end
end

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