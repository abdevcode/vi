clear all
close all

PATH = "/mnt/windows/Users/David/Desktop/Enginyeria-Informatica/VC/practiques/Imatges matricules/";
image = imread(PATH + "imatge2-gris-n.jpg");
imgray = rgb2gray(image);


h = fspecial('average', 5);


filtered = imfilter(imgray,h);



edged = edge(histeq(filtered), 'canny');

filled = imfill(edged,'holes');

filtered2 = medfilt2(filled,[3 3]);

cleaned = bwareaopen(filtered2, 350);


S = regionprops(cleaned)


figure, imshowpair(image ,cleaned , 'montage');
    