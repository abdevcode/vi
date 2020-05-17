clear all
close all
clc

PATH = "/home/abde/Escritorio/git-vi/vi/Florida (a processar)/";

array_correct = zeros(1, 7);
files = dir(fullfile(PATH, '*.jpg')); % pattern to match filenames.
for i = 1:numel(files)
    file = fullfile(PATH, files(i).name);
    
    
    
    image = imread(file);
    %imshow(image)

    plate_image = getPlateImage(image);
    
    % imshow(plate_image)
    plate_text = getPlateText(plate_image);

    %plate_text
    
    plate_text_real = files(i).name;
    
    
    correct = 1;
    % Recorremos todas las letras de la matricula
    for k = 1:6
        if plate_text_real(k) == plate_text(k)
            correct = correct + 1
        end 
    end
    
    array_correct(correct) = array_correct(correct) + 1;    
end


disp( ['En ', num2str(numel(files)),' imatges (', num2str(round((array_correct(7)/numel(files))*100, 2)),' %) s’han reconegut tots els caracters de la matricula'] ); 
disp( ['En ', num2str(numel(files)),' imatges (', num2str(round((array_correct(6)/numel(files))*100, 2)),' %) s’han reconegut 5 caracters de la matricula\n'] );
disp( ['En ', num2str(numel(files)),' imatges (', num2str(round((array_correct(6)/numel(files))*100, 2)),' %) s’han reconegut 4 caracters de la matricula'] );
disp( ['En ', num2str(numel(files)),' imatges (', num2str(round((array_correct(6)/numel(files))*100, 2)),' %) s’han reconegut 3 caracters de la matricula'] );
disp( ['En ', num2str(numel(files)),' imatges (', num2str(round((array_correct(6)/numel(files))*100, 2)),' %) s’han reconegut 2 caracters de la matricula'] );
disp( ['En ', num2str(numel(files)),' imatges (', num2str(round((array_correct(6)/numel(files))*100, 2)),' %) s’ha reconegut 1 caracter de la matricula'] );
disp( ['En ', num2str(numel(files)),' imatges (', num2str(round((array_correct(6)/numel(files))*100, 2)),' %) no s’ha reconegut cap caracter'] );



% A = imread('cameraman.tif'); B = imrotate(A,5,'bicubic','crop');