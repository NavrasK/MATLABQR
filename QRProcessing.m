%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Course: ENCMP 100
% Assignment: Programming Contest
% Name: Navras Kamal
% CCID: navras
% U of A ID: 1505463
%
% Acknowledgements:
% Sources are acknowledged in the attached README
%
% Description:
% This program takes in a prepared image and performs image processing in
% order to convert a QR Code image embedded in another image into a logical
% matrix representing the visual data stored in the image of the Code image
%
% Input:
% Requires the proper image files to be in primary MATLAB directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2017, Navras Kamal, University of Alberta.
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without modi-
% fication, are permitted provided that the following conditions are met:
%  1. Redistributions of source code must retain the above copyright
%     notice, this list of conditions and the following disclaimer.
%  2. Redistributions in binary form must reproduce the above copyright
%     notice, this list of conditions and the following disclaimer in the
%     documentation and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
% QRScanner was designed to test out the capabilities of the image
% processing suite offered in MATLAB, as well as a way to understand how
% the Quick Response Code operates.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Primary Function
function QRProcessing()
%The primary function for the QR Code Reader.  No input is required from
%the user after the image is selected from the GUI provided the images are
%in the correct directory.  

    %Reset the workspace
    clc;
    clear;
    close all;

    %Imports the image into the script, then displays it
    choice = menu('Choose an Image', 'Small', 'Medium', 'Large', 'Massive','Square Colour', 'Beach',...
        'Mt. St. Helens', 'Gum Wall', 'Taxis', 'Bridge', 'Baseball Game', 'Market');
    switch choice                       
        %Program will exit if no image is selected
        case 0
            disp('EXITING'); 
            error('Program terminated by user');
            
                                        %Format:
                                        %Colour, Shape, Isolated or Embedded Image, Side of Code
                                        %Relevant testing information / purpose
                                        
        %Basic QR Codes with nothing special
        case 1
            filename = 'QRtest1.jpg';	%BW, Square, Isolated, Small (ver2)
        case 2
            filename = 'QRtest2.jpg';	%BW, Square, Isolated, Medium (ver4)
        case 3
            filename = 'QRtest3.jpg';   %BW, Square, Isolated, Large (ver16)
        case 4
            filename = 'QRtest4.jpg';   %BW, Square, Isolated, Massive (ver40)

        %A simple recoloured QR Code
        case 5
            filename = 'QRtestC1.jpg';  %CL, Square, Isolateed, Medium (ver4)

        %Codes Embedded in larger images (NOTE: All these images have the same QR Code)
        case 6
            filename = 'QRtestC2.jpg';  %CL, Rectangle, Embedded, Medium (ver3)
            %Beach: A large image, but without much pure white or
            %black.  This is more or less of a baseline, although the
            %image is somewhat busy in terms of colours.
        case 7
            filename = 'QRtestC3.jpg';  %CL, Rectangle, Embedded, Medium (ver3)
            %Mt. St. Helens: A picture heavy in gray and lighter shades
        case 8
            filename = 'QRtestC4.jpg';  %CL, Rectangle, Embedded, Medium (ver3)
            %Gum: A bright, colourful and visually busy image
        case 9
            filename = 'QRtestC5.jpg';  %CL, Rectangle, Embedded, Medium (ver3)
            %Taxis: A lighter image with a large dark spot in the top
            %right corner and a bright white spot in upper left area
        case 10
            filename = 'QRtestC6.jpg';  %CL, Rectangle, Embedded, Medium (ver3)
            %Bridge: A highly contrasting image with a large light spot
            %above the code.
        case 11
            filename = 'QRtestC7.jpg';  %CL, Rectangle, Embedded, Medium (ver3)
            %Baseball: Large sections of bright white, dark, and colours
        case 12
            filename = 'QRtestC8.jpg';  %CL, Rectangle, Embedded, Medium (ver3)
            %Market: This tests the code inside of a large, pure white area
            %of uneven size and shape
        otherwise
            error('ERROR IN IMAGE SELECT');
    end %Choose the Image
    [img,map] = imread(filename);
    figure(1);
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]); %Maximize the figure window.
    
    %Display the original image to be processed
    subplot(1, 3, 1);
    imshow(img,map);
    title('Original Image');
    drawnow; %Force it to display immediately
    
    %Turns image black and white with only the QR Code remaining
    img = processImage(img);
    subplot(3, 3, 5);
    imshow(img,map);
    title('Processed Image');
    drawnow;
    
    %Crops out the whitespace in the image
    img = cropImage(img);
    subplot(3, 3, 6);
    imshow(~img,map);
    title('Cropped Image');
    drawnow;
    
    %Converts the image into a true pixel representation of the cells of
    %the QR Code
    qr = cell2pix(img);
    subplot(3, 3, 9);
    imshow(~qr);
    title('Pixel Matrix of QR Code');
    drawnow;
    
    %Deterimines the data stored within the pixel matrix form of the QR
    %code
    % TODO
    % data = QRread(qr);
    % disp(data);%fix output obviously
end

%IMAGE PROCESSING
function imgProcessed = processImage(img)
%Turns the image into a black and white image containing only the QR Code

    if ~all(img == im2bw(img,0)) %Image is not black and white
        imgSize = size(img);
        if imgSize(1)/imgSize(2) ~= 1 %Image is coloured and non-square
            imgProcessed = isolateImage(img);
        else                          %Image is coloured and square
            imgProcessed = im2bw(img,0.5); %#ok<*IM2BW>
        end
    else                              %Image is BW and code only
        imgProcessed = ~imbinarize(img);
    end
end

function imgIsolated = isolateImage(img)
%Isolates a black and white QR code from a larger coloured image

    %Analyzes the region properties of all black/white shapes in the image 
    %and displays the seperate regions using different colours
    imgMask = img;
    M = repmat(all(imgMask<10,3),[1 1 3]); %mask values less than 10 in RGB
    imgMask(M) = 255; %turn them white
    M = repmat(all(imgMask>250,3),[1 1 3]); %mask values more than 250 in RGB
    imgMask(M) = 0; %turn them black
    imgMask = im2bw(imgMask,0.03);
    imgMask = ~imgMask;
    label = bwlabel(imgMask, 8);
    blobMeas = regionprops(label, imgMask, 'all'); 
    blobNum = size(blobMeas, 1);
    blobArea = zeros(1,blobNum);
    for n = 1:blobNum
        blobArea(n) = blobMeas(n).Area;
    end
    clabels = label2rgb (label, 'hsv', 'k', 'shuffle');
    subplot(3, 3, 2);
    imshow(clabels);
    title('Sectionalized Mask');
    drawnow;

    %Finds and displays the mask of the largest region of black and white 
    %after filling in the holes and edges
    [~, sortIndexes] = sort(blobArea, 'descend');
    QRind = sortIndexes(1);
    imgMask = label == QRind;
    imgMask = imfill(imgMask,'holes');
    sq = strel('square', 150);
    imgMask = imdilate(imgMask, sq);
    imgMask = imerode(imgMask, sq);
    subplot(3, 3, 3);
    imshow(imgMask);
    title('Cleaned Image Mask');
    drawnow;

    %Crops the image to the bounding box of the masked out area
    img = im2bw(img,0.03);
    bb=ceil(blobMeas(QRind).BoundingBox);
    idx_x=[bb(1)+5 bb(1)+bb(3)-5];
    idx_y=[bb(2)+5 bb(2)+bb(4)-5];
    img = img(idx_y(1):idx_y(2),idx_x(1):idx_x(2));
    img = bwareaopen(img,4);
    imgIsolated = uint8(img);
end

function imgCropped = cropImage(img)
%Crops out the whitespace around the code

    img = ~img;
    [tcrop,lcrop] = find(img,1,'first');
    rcrop = find(img(tcrop,:),1,'last');
    bcrop = find(img(:,lcrop),1,'last');
    imgCropped = img(tcrop:bcrop, lcrop:rcrop);
end

function qr = cell2pix(img)
%Converts the code into regions of similar colour in order to isolate the
%size of the cells

    label = bwlabel(img, 8);
    blobMeas = regionprops(label, img, 'all'); %#ok<*MRPBW>
    blobNum = size(blobMeas, 1);
    blobArea = zeros(1,blobNum);
    for n = 1:blobNum
        blobArea(n) = blobMeas(n).Area;
    end
    clabels = label2rgb (label, 'hsv', 'k', 'shuffle');
    subplot(3, 3, 8);
    imshow(clabels);
    title('Sectionalized Code');
    drawnow;
    pixDim = sqrt(min(blobArea));
    qr = img2pix(img, pixDim);
end

function imgPixelMat = img2pix(img, pixDim)
%Breaks apart the image into sections of X by X pixels, where X is the size
%of each cell of the code, then regroups them into a new image where
%each cell of the code is one actual pixel of the image.  This new
%matrix is what will be used for analyzing the data within.
    
    %Find the subdivisions between the cells on the QR Code
    imgSize = size(img);
    subdiv1 = zeros(1, imgSize(1)/pixDim)+pixDim;
    subdiv2 = zeros(1, imgSize(2)/pixDim)+pixDim;

    %Convert each cell into an individual pixel of the correct value
    qrsub = mat2cell(img, subdiv1, subdiv2);
    qrsize = size(qrsub);
    pixMat = zeros(qrsize(1), qrsize(2));
    for n = 1:qrsize(2)
        for k = 1: qrsize(1)
            if all(qrsub{n,k})
                pixMat(n, k) = 1;
            elseif any(qrsub{n,k})
                fprintf('ERROR IN CELL %i, %i\n', n, k); %error checking
                disp(qrsub{n,k});
            end
        end
    end
    imgPixelMat = uint8(pixMat);
end