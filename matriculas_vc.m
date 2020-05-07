clear all
close all

PATH = "/mnt/windows/Users/David/Desktop/Enginyeria-Informatica/VC/practiques/Imatges matricules/";
image = uint16(imread(PATH + "Imatge1-blau.jpg"));


avg = fspecial('gaussian', 5);
filtered = imfilter(image, avg);


hsv = rgb2hsv(filtered);
[h,s,v] = imsplit(hsv);
    
mask = h >= 0.33 & h <= 0.5;

se = strel('square', 2);

eroded = imerode(mask, se);

cleaned = bwareaopen(eroded, 200);

se2 = strel('square', 2);
dilated = imdilate(cleaned, se2);

ocr(cleaned).Text

S = regionprops(cleaned);

figure, imshowpair(uint8(image), cleaned, 'montage');

regions = crop(cleaned);

figure, imshow(regions{2},[]);

function c = crop(I)
    regions = regionprops(I);
    for x = 1: numel(regions)
        region = regions(x,:);
        c{x} = (imcrop(I,[region.BoundingBox(1),region.BoundingBox(2),region.BoundingBox(3),region.BoundingBox(4)]));
    end
end

