clear all
close all

PATH = "Florida (a processar)/";

image = imread(PATH + "074YDR.jpg");
%image = imread(PATH + "112TBC.jpg");
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
%{
se = strel('disk', 5);

erosion = imerode(image, se);
apertura = imdilate(erosion, se);
image = apertura - erosion;

image = edge(image, 'canny', 0.5);
%}

se = strel('disk', 20);
image = imclose(image, se);
image = imopen(image, se);

%figure, imshow(image);

BW = imbinarize(image);

% L = bwlabel(image,8);
%figure; imshow(L); title(‘l’);
%Rellena áreas de conjuntos conexos con pixeles en blanco
%d2 = imfill(BW, 'holes');
%figure; imshow(d2); title(‘fill’);

%Crea regiones
[Etiquetas, N]=bwlabel(BW);

MAP = [0 0 0; jet(N)];
I = ind2rgb(Etiquetas+1,MAP);
%figure; imshow(I);title('I');


stats=regionprops(Etiquetas,'all');
areaMaxima=sort([stats.Area],'descend');
indiceLogo=find([stats.Area]==areaMaxima(1) ); % Coloca en orden de mayor a menor las áreas de la imagen


for i = 1:size(indiceLogo,2)
    % Dibujar rectangulo 
    % rectangle('Position',stats(indiceLogo(i)).BoundingBox,'EdgeColor','r','LineWidth',3);
    
    % Obtenemos todas las esquinas
    corner_plate = stats(indiceLogo(i)).BoundingBox;
end


X = corner_plate(1);
Y = corner_plate(2);
W = corner_plate(3);
H = corner_plate(4);


corte = [X Y (W-2) (H-7)]; %Determina coordenadas de corte

plate_image = imcrop(real_image, corte);

% I1 = plate_image(:,:,1);
% [M,N] = size(IMF);

% figure, imshow(plate_image);
% figure; imagesc(IMF);colormap gray; axis equal;

plate_text = getPlateText(plate_image);

plate_text
