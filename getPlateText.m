function plateText = getPlateText(image)
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
    %disp(string(plate_text));
    plateText = string(plate_text);
end


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
    I2 = I;
    
    figure, imshow(I);
    
    
    
    
    
    image = medfilt3(I, [3 3 3]);
    figure, imshow(image);
    
    image = histeq(image, 10);
    figure, imhist(image);
    
    figure, imshow(image);
    
    
    redChannel = image(:, :, 1);
    greenChannel = image(:, :, 2);
    blueChannel = image(:, :, 3);

    %figure, imshow(redChannel);
    %figure, imshow(greenChannel);
    %figure, imshow(blueChannel);
    

 %{
    
    
   [h s v] = rgb2hsv(I);
    
    %figure, imshow(s);
    %figure, imshow(v);
    
    %redChannel = I(:, :, 1);
    greenChannel = I(:, :, 2);
    %blueChannel = I(:, :, 3);

    greenChannel = medfilt2(greenChannel, [3 3]);
    
    greenChannel = histeq(greenChannel, 5);
    %imhist(greenChannel)
    
    %dualchannel = redChannel + blueChannel;
    %figure, imshow(redChannel);
    %figure, imshow(greenChannel);
    %figure, imshow(blueChannel);
    
    
    %
    
    figure, imshow(greenChannel);
    
    % SE = strel('line',len,deg)
    %se = strel('disk', 5); 
    %greenChannel = imdilate(greenChannel, se);
    %figure, imshow(greenChannel);
    
    
    thresh = multithresh(greenChannel, 1);
    seg_I = imquantize(greenChannel, thresh);
    RGB = label2rgb(seg_I);
    
    %RGB = bwareaopen(RGB, 90);
    
    figure, imshow(RGB);
    
    % bws = bwareaopen(bwv, 90);
    %rc =~ imbinarize(redChannel, 0.7);
    %gc =~ imbinarize(greenChannel, 0.7);
    %bc =~ imbinarize(blueChannel, 0.7);
    
    
%     gc = bwareaopen(gc, 500);
%     
%     figure, imshow(rc);
%     figure, imshow(gc);
%     figure, imshow(bc);
    
    thresh = multithresh(I, 7);
    seg_I = imquantize(I, thresh);
    RGB = label2rgb(seg_I);
    
    %level = graythresh(greenChannel)
    
    %seg_I = imquantize(greenChannel, level);
    
    %RGB = label2rgb(seg_I);
    
    %figure, imshow(RGB);
    
   
    % Convert to gray scale 
    yy = rgb2gray(I); 
    % axes(handles.axes2); 
    imshow(yy); title('CONVERSION TO GRAYSCALE');
    
    
    % median filter 
    nr=medfilt2(yy,[3 3]); 
    axes(handles.axes3); 
    imshow(nr); title('NOISE REMOVAL');
    
    % Image Dilation 
    se=strel('disk',1); 
    id=imdilate(nr,se); 
    axes(handles.axes4); 
    imshow(id); title('IMAGE DILATION');
    
    % Image Erosion 
    ie=imerode(id,se); 
    axes(handles.axes5); 
    imshow(ie); title('IMAGE EROSION');
    
    % Convert to BW 
    level = graythresh(ie); 
    bw = im2bw(ie, level); 
    axes(handles.axes6); 
    imshow(bw); title('CONVERSION TO BINARY');
    
    % Image Complement 
    ic =~bw; 
    axes(handles.axes7); 
    imshow(ic); title('PLATE COMPLEMENT');
    
    % Remove all object containing fewer than 300 pixels 
    rp = bwareaopen(ic,300); 
    axes(handles.axes8); 
    imshow(rp); title('PIXEL REMOVAL <300');
    
    % Selecting all the regions that are of pixel area more than 600 
    final=bwareaopen(rp,600); 
    axes(handles.axes9); 
    imshow(final); title('PIXEL SELECTION >600');

    
    
    
    
    
    
    

    % Dilatamos la imagen resultante.
    se2 = strel('disk', 1);
    eroded = imerode(I, se2);
    
    h = fspecial('gaussian',4);
    %dilated = imfilter(dilated,h);
    
    imgray = rgb2gray(eroded);
    
    J = adaptthresh(imgray,'Statistic','gaussian', 'ForegroundPolarity', 'dark');
    bw =~ imbinarize(imgray, J);
    
    
    
    % Eliminamos las regiones menores a 200 pixeles.
    bw = bwareaopen(bw, 200);
    
    I2 = bw;
    
    %}
    
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

