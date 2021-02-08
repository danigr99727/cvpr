clear all;

%imageDir = fullfile(toolboxdir('vision'),'visiondata', ...
%    'calibration','stereo');
rightImages = imageDatastore('20210204_160141.jpg');
leftImages = imageDatastore('20210204_160143.jpg');

boardSize = [8,7];

pointsLeft = load('savePointsA.mat'); %might be wrong way around and wrong File
pointsLeft = pointsLeft.fixedPoints;
pointsRight = load('savePointsB.mat');
pointsRight = pointsRight.movingPoints;
imagePoints = zeros(size(pointsLeft,1),size(pointsLeft,2),1,2);
imagePoints(:,:,1,1) = pointsLeft;
imagePoints(:,:,1,2) = pointsRight;
%imagePoints(:,:,2,1) = pointsLeft;
%imagePoints(:,:,2,2) = pointsRight;
%imagePoints(:,:,3,1) = pointsLeft;
%imagePoints(:,:,3,2) = pointsRight;

squareSizeInMillimeters = 25;
worldPoints = generateCheckerboardPoints(boardSize,squareSizeInMillimeters);

I1 = readimage(leftImages,1);
I2 = readimage(rightImages,1);
imageSize = [size(I1,1),size(I1,2)];

stereoParams = estimateCameraParameters(imagePoints,worldPoints, ...
                                        'ImageSize',imageSize);
                                    
[J1_full,J2_full] = rectifyStereoImages(I1,I2,stereoParams, ...
  'OutputView','full');
