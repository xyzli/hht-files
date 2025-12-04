function [ sharpstuff ] = sharpstuff( img1 )
%% first pass of sharp stuff

%img1 = rgb2gray(imread('img1.tif')); pass img1 instead
%img1=imcrop(img1, [92 40 542 427]);
img1=img1(50:584,115:792); 
%img1=img1(32:374,74:507); % old blue HHT
%img2 = rgb2gray(imread('img2.tif'));
imshow(img1)

mfilt1 = medfilt2(img1);

gauss1 = imgaussfilt(mfilt1, 3); %% bigger value gets rid of less* - width of the gaussian
% harder edge =higher frequency, - size of airbrush tool
 figure
 imagesc(gauss1);
 title('Gaussian');
diff1 = img1 - gauss1;
 figure
 imagesc(diff1);
 title('diff1');
mfilt2=medfilt2(img1, [8 8]);

sharpstuff = (diff1).*10+mfilt2;
 figure
 imagesc(sharpstuff);
 title('Difference plus median filter');
 sum1 = sharpstuff+img1;
 figure
 imagesc(sum1);
 title('Add back the original image');

b = imsharpen(sharpstuff,'Radius',2,'Amount',2);%sharpstuff or sum1
 figure
 imagesc(b);
 title('Sharpened');

 figure, imshow(b)
 title('Sharpened Image');


%% Unsharp Masking Method
c = imsharpen(sharpstuff,'Radius',2,'Amount',1);
figure, imshow(c)
title('Sharpened Image');

%% Laplacian Filter Sharpen Method
c = im2double(c);
lap = [-1 -1 -1; -1 8 -1; -1 -1 -1];
resp = imfilter(c, lap, 'conv');

%// Change - Normalize the response image
minR = min(resp(:));
maxR = max(resp(:));
resp = (resp - minR) / (maxR - minR);

%// Change - Adding to original image now
sharpened = c + resp;

%// Change - Normalize the sharpened result
minA = min(sharpened(:));
maxA = max(sharpened(:));
sharpened = (sharpened - minA) / (maxA - minA);

%// Change - Perform linear contrast enhancement
sharpened = imadjust(sharpened, [60/255 200/255], [0 1]);

 figure; 
 imshow(c); title('Original image');
 figure;
 imagesc(resp); title('Laplacian filtered image');
 figure;
 imshow(sharpened); title('Sharpened image');

end

