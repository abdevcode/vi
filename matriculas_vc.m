clear all
close all

PATH = "/media/david/729A72279A71E84D/Users/David/Desktop/Enginyeria-Informatica/VC/practiques/Imatges matricules/";
image = uint16(imread(PATH + "Imatge2-blau.jpg"));


segmented = segment(image);

number_plate = crop(segmented);

%figure, imshow(number_plate{6},[]);

models = load_models();
% figure, imshow(models{27}, []);

figure, imshow(segmented, []);

for i = 1: size(number_plate)
    plate_text(i) = detect(models, number_plate{i});
end

disp(string(plate_text));

function character = detect(models, letter)
    comp = zeros(1,36);

    for i = 1 : 36
        comp(i) = corr2(models{i}, letter);
    end

    winer=find(comp==max(comp));

    if(winer <= 26) 
        character = char(winer+64);
    else
        character = char(winer-26+47);
    end
end


function models = load_models()
    I = imread("./fuente1_matriculak.png");
    bw = imcomplement(imbinarize(rgb2gray(I)));
    
    models = crop(bw);
end

function I2 = segment(I)
    avg = fspecial('gaussian', 5);
    filtered = imfilter(I, avg);
    
    hsv = rgb2hsv(filtered);
    [h,s,v] = imsplit(hsv);
    mask = h >= 0.33 & h <= 0.5;

    se = strel('square', 2);
    eroded = imerode(mask, se);

    cleaned = bwareaopen(eroded, 200);

    se2 = strel('square', 5);
    dilated = imdilate(cleaned, se2);
    
    I2 = dilated;
end


function words_array = crop(I)
    regions = regionprops(I, 'boundingbox');
    words_array = cell(numel(regions));
    for i = 1: numel(regions)
        region = regions(i,1); % Agafem la fila corresponent a i.
        % Tallem la imatge corresponent a la seva BoudingBox i canviem el
        % seu tamany per un de fixe.
        words_array{i} = imresize(imcrop(I,region.BoundingBox), [128, 64]);
    end
end

