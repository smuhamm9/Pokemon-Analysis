function [processed] = localize(image)

%getting size of the input image
R = size(image,1);
C = size(image,2);

%This is how many columns/rows that the intensity slope is measured.
edgeSensitivity = 50;
%This is how much the contrast will be multiplied by
contrastMod = 1.5;

%Obtain grayscale representation.
if ~ismatrix(image)
    gimg = rgb2gray(image);
else
    gimg = image;
end

 
%Column mean vector
cmv = mean( gimg, 1 );
%Row mean vector
rmv = mean( gimg, 2 );


%Left and Right Edges
cmaxdiff = 0;
cEndDiff = 0;
cEndindex = 1;
cmaxindex = C;
for i=edgeSensitivity+1 : C
    diff = cmv(1,i) - cmv(1,i-edgeSensitivity);
    if diff > cmaxdiff
        %Find the max difference ( Left Edge )
        cmaxdiff = diff;
        cmaxindex = i;
    end
    if diff < cEndDiff
        %Find the min difference ( Right Edge )
        cEndDiff = diff;
        cEndindex = i;
    end
end

%Top and Bottom Edge
rmaxdiff = 0;
rEndDiff = 0;
rEndindex = 1;
rmaxindex = R;
for i=edgeSensitivity+1 : R
    diff = rmv(i,1) - rmv(i-edgeSensitivity,1);
    if diff > rmaxdiff
        %Find the max difference ( Top Edge )
        rmaxdiff = diff;
        rmaxindex = i;
    end
    if diff < rEndDiff
        %Find the max difference ( Bottom Edge )
        rEndDiff = diff;
        rEndindex = i;
    end
end


if(rEndindex - rmaxindex > 0 && cEndindex - cmaxindex > 0)
  %Crop out the result based on the indexes found above.
  result = gimg(rmaxindex:rEndindex,cmaxindex:cEndindex);  
else
  %This is temp
  result = gimg;   
end

processed = result;

%Point Transformation for multiplication contrast enhancement.
for r=1 : size(result,1)
    for c=1 : size(result,2)
        processed(r,c) = min(255,result(r,c) * contrastMod);
    end
end

%Convert the processed greyscale image into RGB.
processed = cat ( 3, processed, processed, processed );
% g = imresize ( processed, x );
