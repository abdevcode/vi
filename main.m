clear all
close all

PATH = "/home/abde/URV/VC/prac/Florida (a processar)/";

image = imread(PATH + "074YDR.jpg");
% image = imread(PATH + "112TBC.jpg");


%==> PREPROCESAMIENTO 
% Transformamos la imagen en escala de grises
% Se pierde tono y saturacion pero se mantiene luminancia
image = rgb2gray(image);

% Usamos un filtro para el suavizado (en este caso la mediana)
image = medfilt2(image, [5 5]);



%==> SEGMENTACION
image = AumentarMatricula(image); 
orig = image;





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

for i=1:size(indiceLogo,2)
rectangle('Position',stats(indiceLogo(i)).BoundingBox,'EdgeColor','r','LineWidth',3);
E = stats(indiceLogo(i)).BoundingBox;
end


X=E.*[1 0 0 0]; X=max(X); %Determina eje X esquina superior Izq. Placa
Y=E.*[0 1 0 0]; Y=max(Y); %Determina eje Y esquina superior Der. Placa
W=E.*[0 0 1 0]; W=max(W); %Determina Ancho Placa
H=E.*[0 0 0 1]; H=max(H); %Determina Altura placa
Corte=[X Y (W-2) (H-7)]; %Determina coordenadas de corte
IMF=imcrop(orig,Corte);
I1 = orig(:,:,1);
[M,N] = size(IMF);

figure, imshow(IMF);
%figure; imagesc(IMF);colormap gray; axis equal;


