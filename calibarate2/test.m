function test
% imshow("top2.jpg")
% A1 = ginput(4);
% imshow("front2.jpg")
% A2 = ginput(4);
K = [3201.29510621942,0,0;0,3166.82208431870,0;2001.66349573853,1132.92656143315,1];
K =K';
% H = cv.findHomography(A1,A2);
% result_H = cv.decomposeHomographyMat(H,K);
% R = result_H.R;
% R = R{1};
% rotm2eul(R)
% rotm2axang(R)

A1 = [1289,485.000000000000;2465,500.000000000000;1286,1667.00000000000;2474,1670.00000000000];
A2 = [1409,1028.00000000000;1919,1019.00000000000;1361,1340.00000000000;1937,1334.00000000000];
H = cv.findHomography(A1,A2);
result_H = cv.decomposeHomographyMat(H,K);
R = result_H.R;
fprintf("Result for R1");
temp_R = R{1};
rotm2eul(temp_R)
rotm2axang(temp_R)
fprintf("Result for R2");
temp_R = R{2};
rotm2eul(temp_R)
rotm2axang(temp_R)
fprintf("Result for R3");
temp_R = R{3};
rotm2eul(temp_R)
rotm2axang(temp_R)
fprintf("Result for R4");
temp_R = R{4};
rotm2eul(temp_R)
rotm2axang(temp_R)
