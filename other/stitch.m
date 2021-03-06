% function Ir = stitch(I1, I2)
% I1 = im2single(I1);
% I2 = im2single(I2);
% r = max(max(size(I1)),max(size(I2)));
I1 = uint8(I1);
I2 = uint8(I2);

rsize = size(I1, 1) + size(I2, 1); 
csize = size(I1, 2) + size(I2, 2); 

I1_ = zeros(rsize, csize);
% 
r1 = round(rsize / 2 - size(I1, 1) / 2);
c1 = round(csize / 2 - size(I1, 2) / 2);
% figure();
I1_(r1:r1 + size(I1, 1)-1, c1:c1+size(I1, 2)-1) = I1;
I1 = uint8(I1_);
% 
I2_ = zeros(rsize, csize);
r2 = round(rsize / 2 - size(I2, 1) / 2);
c2 = round(csize / 2 - size(I2, 2) / 2);
% 
I2_(r2:r2 + size(I2, 1)-1, c2:c2+size(I2, 2)-1) = I2;
I2 = uint8(I2_);

points1 = detectSURFFeatures(I1);
points1 = selectStrongest(points1, 1000);%keep 100 points
[features1, validPoints1] = extractFeatures(I1, points1);

points2 = detectSURFFeatures(I2);
points2 = selectStrongest(points2, 1000);%keep 100 points
[features2, validPoints2] = extractFeatures(I2, points2);

[indexPairs, matchmetric] = matchFeatures(features1,features2);

indexPairs = matchFeatures(features1,features2) ;
matchedPoints1 = validPoints1(indexPairs(:,1));
matchedPoints2 = validPoints2(indexPairs(:,2));

% HGEOTFORMEST = vision.GeometricTransformEstimator('Transform', 'Projective','InlierPercentage',60);
% H = HGEOTFORMEST.step(matchedPoints1.Location, matchedPoints2.Location);

% figure; showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2);
% title('Matched SURF points, including outliers');

% Compute the transformation matrix using RANSAC
gte = vision.GeometricTransformEstimator('Transform', 'Projective'); %,'DesiredConfidence',99.7, 'InlierPercentageSource', 60

[tform inlierIdx] = step(gte, matchedPoints2.Location,matchedPoints1.Location);
% figure; showMatchedFeatures(I1,I2,matchedPoints1(inlierIdx), matchedPoints2(inlierIdx));
% title('Matching inliers'); legend('inliersIn', 'inliersOut');
tform
% Recover the original image Iin from Iout
agt = vision.GeometricTransformer;
Ir = step(agt, im2single(I2), tform);

I1_ = im2single(I1);
% Ir = ((Ir+I1_)+abs(Ir-I1_))/2;
% Ir((Ir == 0)) = I1_(Ir == 0);
Ir(Ir > I1_) = Ir(Ir > I1_);
Ir(Ir <= I1_) = I1_(Ir <= I1_);
Ir( ~any(Ir,2), : ) = [];  %rows
Ir( :, ~any(Ir,1) ) = [];  %columns
Ir = uint8((Ir)*255);