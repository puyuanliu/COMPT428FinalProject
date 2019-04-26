function test_decompose_H

model_A = [0, 0;0, 26.4;17, 0;17, 26.4];
intrin = [667.131291161426,0,423.476621145879;0,667.393235615043,234.764947254243;0,0,1];
imshow('test1.jpg')
A= ginput(4);
imshow('test2.jpg')
B= ginput(4);
Homography1 = cv.findHomography(model_A, A);
Homography2 = cv.findHomography(model_A, B);
Homography3 = cv.findHomography(A, B);
decomposed_H1 = cv.decomposeHomographyMat(Homography1, intrin);
decomposed_H2 = cv.decomposeHomographyMat(Homography2, intrin);
decomposed_H3 = cv.decomposeHomographyMat(Homography3, intrin);
n1 = decomposed_H1.n;
n2 = decomposed_H2.n;
n3 = decomposed_H3.n;
R1 = decomposed_H1.R;
R2 = decomposed_H2.R;
R3 = decomposed_H3.R;
angle_difference1 = zeros(4,1);
for n_i = 1:length(n1)
    temp_n1 = n1{n_i};
    temp_n2 = n2{n_i};
    temp_R1 = R1{n_i};
    temp_R2 = R2{n_i};
    temp_R3 = R3{n_i};
    temp_R3_angle = rotm2axang(temp_R3);
    temp_R1_angle = rotm2axang(temp_R1);
    temp_R2_angle = rotm2axang(temp_R2);
%     result_1 = abs(atan2(norm(cross(temp_n1,temp_n2)), dot(temp_n1,temp_n2)));
    angle_difference1(n_i)= rad2deg(temp_R1_angle(end) - temp_R2_angle(end));
end