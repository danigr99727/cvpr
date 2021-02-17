% Auto-generated by stereoCalibrator app on 08-Feb-2021
%-------------------------------------------------------
clear all
close all

% Define images to process
imageFileNames1 = {'StereoImages\left\l1.jpg',...
    'StereoImages\left\l2.jpg',...
    'StereoImages\left\l3.jpg',...
    'StereoImages\left\l4.jpg',...
    'StereoImages\left\l5.jpg',...
    };
imageFileNames2 = {'StereoImages\right\r1.jpg',...
    'StereoImages\right\r2.jpg',...
    'StereoImages\right\r3.jpg',...
    'StereoImages\right\r4.jpg',...
    'StereoImages\right\r5.jpg',...
    };

% Detect checkerboards in images
[imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints(imageFileNames1, imageFileNames2);

% Generate world coordinates of the checkerboard keypoints
squareSize = 25;  % in units of 'millimeters'
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Read one of the images from the first stereo pair
I1 = imread(imageFileNames1{5});
[mrows, ncols, ~] = size(I1);

% Calibrate the camera
[stereoParams, pairsUsed, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
    'EstimateSkew', false, 'EstimateTangentialDistortion', false, ...
    'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'millimeters', ...
    'InitialIntrinsicMatrix', [], 'InitialRadialDistortion', [], ...
    'ImageSize', [mrows, ncols]);

save('stereoParams.mat','stereoParams');

% View reprojection errors
h1=figure; showReprojectionErrors(stereoParams);

% Visualize pattern locations
h2=figure; showExtrinsics(stereoParams, 'CameraCentric');

% Display parameter estimation errors
displayErrors(estimationErrors, stereoParams);

% You can use the calibration data to rectify stereo images.
I2 = imread(imageFileNames2{5});
[J1, J2] = rectifyStereoImages(I1, I2, stereoParams, 'OutputView','Full');

% See additional examples of how to use the calibration data.  At the prompt type:
%showdemo('StereoCalibrationAndSceneReconstructionExample')
% showdemo('DepthEstimationFromStereoVideoExample')

%tmp = getframe(fig1);
%[i1, Map] = frame2im(tmp);
%tmp = getframe(fig2);
%[i2, Map] = frame2im(tmp);

x = load('l5.mat');
x = x.l5;
y = load('r5.mat');
y = y.r5;
showMatchedFeatures(I1, I2,x,y,'montage');

fig3 = figure;
a3 = axes;
imshow(J1, 'Parent', a3);

fig45 = figure;
a4 = axes;
imshow(J2, 'Parent', a4);
