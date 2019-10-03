function [ID, CP, HP, stardust, level, cir_center] = pokemon_stats (img, model)
% Please DO NOT change the interface
% INPUT: image; model(a struct that contains your classification model, detector, template, etc.)
% OUTPUT: ID(pokemon id, 1-201); level(the position(x,y) of the white dot in the semi circle); cir_center(the position(x,y) of the center of the semi circle)

categoryClassifier = model.pokemon;
classifier = model.text;

CP = 0;
HP = 0;
level = 0;
cir_center = 0;

% Classify pokemon ID
height = size(img,1);
width = size(img,2);
pokecrop = img(round(height*.15):round(height*.50),round(width*.25):round(width*.85),:);
pokecrop = imresize(pokecrop, [250 250]);

[ID, scores] = predict(categoryClassifier, pokecrop);
ID = string(categoryClassifier.Labels(ID));

cellSize = [4 4];

%Clasify stardust
stardust = '';
dustcrop = img(round(height*.75):round(height*.85),round(width*.50):round(width*.70),:);
dustcrop = localize(dustcrop);
dustcrop = im2bw(dustcrop,.90);
dustcrop = imcomplement(dustcrop);

s = regionprops(dustcrop,'BoundingBox');
for k = 1 : length(s)
    thisBB = s(k).BoundingBox;
    bx = thisBB(1);
    by = thisBB(2);
    bw = thisBB(3);
    bh = thisBB(4);
    char = dustcrop(round(by):round(min(by+bh,size(dustcrop,1))),round(bx):round(min(bx+bw,size(dustcrop,2))));
    
    %Preprocess region to match training data
    char = imresize(char, [32 20]);
    
    % Make class predictions using the test features.
    features = extractHOGFeatures(char, 'CellSize', cellSize);
    label = predict(classifier, features);
    
    %Remove erroneous findings
    if(~strcmp(string(label),'x') && ~strcmp(string(label),'dust'))
        stardust = strcat(stardust, string(label));
    end
end

% Classify HP
hp = '';
hpcrop = img(round(height*.50):round(height*.55),round(width*.40):round(width*.60),:);
hpcrop = localize(hpcrop);
hpcrop = im2bw(hpcrop,.90);
hpcrop = imcomplement(hpcrop);

s = regionprops(hpcrop,'BoundingBox');
for k = 1 : length(s)
    thisBB = s(k).BoundingBox;
    bx = thisBB(1);
    by = thisBB(2);
    bw = thisBB(3);
    bh = thisBB(4);
    char = hpcrop(round(by):round(min(by+bh,size(hpcrop,1))),round(bx):round(min(bx+bw,size(hpcrop,2))));
    
    %Preprocess the region to match training data
    char = imresize(char, [32 20]);
    
    % Make class predictions using the test features.
    features = extractHOGFeatures(char, 'CellSize', cellSize);
    label = predict(classifier, features);
    
    %Remove erroneous findings
    if(~strcmp(string(label),'x') && ~strcmp(string(label),'h') && ~strcmp(string(label),'p'))
        hp = strcat(hp, string(label));
    end
end

% Classify CP
cp = '';
cpcrop = img(round(height*.02):round(height*.15),round(width*.30):round(width*.60),:);
cpcrop = im2bw(cpcrop,.90);
s = regionprops(cpcrop,'BoundingBox');
for k = 1 : length(s)
    thisBB = s(k).BoundingBox;
    bx = thisBB(1);
    by = thisBB(2);
    bw = thisBB(3);
    bh = thisBB(4);
    char = cpcrop(round(by):round(min(by+bh,size(cpcrop,1))),round(bx):round(min(bx+bw,size(cpcrop,2))));
    
    %Preprocess the region to match training data
    char = imresize(char, [32 20]);
    
    % Make class predictions using the test features.
    features = extractHOGFeatures(char, 'CellSize', cellSize);
    label = predict(classifier, features);
    
    %Remove erroneous findings
    if(~strcmp(string(label),'x') && ~strcmp(string(label),'C') && ~strcmp(string(label),'p'))
        cp = strcat(cp, string(label));
    end
end

% -Getting the level of the Pokemon
%Obtain grayscale representation.
if ~ismatrix(img)
    gimg = rgb2gray(img);
else
    gimg = img;
end
bw = imbinarize(gimg,.99);
bw(1:round(size(img,1)*.10),:) = 0;
bw(round(size(img,1)*.50):end,:) = 0;
[centers, radii, metric] = imfindcircles(bw,[round((size(img,2) * .009)) round((size(img,2) * .02))],'ObjectPolarity','bright');
if(size(centers,1) ~= 0)
    level = [centers(1,1) centers(1,2)];
else
    level = [50,50];
end

CP = str2double(cp);
if hp ~= ''
    HP = str2double(hp{1}(end-ceil(length(hp{1})/2)+1:end));
else
    HP = 10;
end

if stardust ~= ''
    if strcmp(stardust{1}(1),'5')
        stardust = str2double(stardust{1}(2:end));
    else
        stardust = str2double(stardust);
    end
else
    stardust = 10;
end


% Third of the image down and in the center
cir_center = [round(width*.50),round(height*.33)];


end