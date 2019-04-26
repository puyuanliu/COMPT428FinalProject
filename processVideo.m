function [ frame_data ] = processVideo(...
    in_filename, out_filenames, cam, options...
    )
warning off
% processVideo  Process, display, and output each frame of video data
%
% ## Syntax

% processVideo(...
%     in_filename, out_filenames, cam, options...
% )
% frame_data = processVideo(...
%     in_filename, out_filenames, cam, options...
% )
%
% ## Description
% processVideo(...
%     in_filename, out_filenames, cam, options...
% )
%   Process video frames, and output results to files.
%
% frame_data = processVideo(...
%     in_filename, out_filenames, cam, options...
% )
%   Additionally return numerical results from the video frames.
%
% ## Input Arguments
%
% in_filename -- Input video
%   A character vector containing the name and path of the input video file. If
%   empty (`[]`), the function will attempt to read live video from either a
%   webcam, using the MATLAB Support Package for USB Webcams, or a more general
%   camera, using Modular Tracking Framework
%   (https://webdocs.cs.ualberta.ca/~vis/mtf/). The choice of camera is
%   determined by the `cam` input argument (see below).
%
% out_filenames -- Output filepaths
%   A structure with the following fields. Each field is a character vector
%   containing a file name and path. If a field is empty (`[]`), the
%   corresponding file will not be produced:
%   - raw_video: A copy of the input video (not useful except for live
%     video capture).
%   - out_video: An annotated version of the input video. All frames
%     which are in the input video, or which were captured from live video will
%     be output. Frames for which processing was successful will be annotated.
%   - out_csv: A CSV file with the following columns. One row is generated
%     for each frame in which processing was successful.
%     - Video index (the value of `options.video_index`)
%     - Frame index (the first frame has index `1`)
%     - x-coordinate of the centre of the rectangle annotation
%     - y-coordinate of the centre of the rectangle annotation
%
% cam -- Camera
%   When video input is loaded from files, this argument is ignored. In the case
%   of live video input, if this argument is empty (`[]`), the function will
%   capture images using Modular Tracking Framework
%   (https://webdocs.cs.ualberta.ca/~vis/mtf/) by calling:
%   `mexMTF2('get_frame');`. Otherwise the function will attempt to capture
%   images from a USB webcam using the MATLAB Support Package for USB Webcams by
%   calling: `snapshot(cam);`.
%
%   The camera is expected to be initialized and deallocated (e.g. using
%   `mexMTF2('quit')`) by the caller.
%
% options -- Processing options
%   A structure with the following fields:
%   - silent: If `true`, a figure will not be opened to show the
%     video frames as they are processed. If 'silent' is `false`, video
%     capture/processing can be stopped by closing the figure. Otherwise,
%     use Ctrl + C on the command line.
%   - frame_rate: The output videos' framerate.
%   - record_only: If `true`, just copy the video to the output file without
%     processing. In this case, `frame_data` will be empty (`[]`), and the only
%     output file that can be generated is a copy of the input video. For live
%     video, more frames can be captured per unit time than if processing was
%     enabled.
%   - show_errors: Output exceptions that are thrown by the per-frame processing
%     as warnings.
%   - format: The format of the output videos. (Refer to the documentation of
%     'vision.VideoFileWriter' for supported formats.) The format must match the
%     video filenames in `out_filenames`.
%   - video_index: The value to be output in the first column for each row
%     of any output CSV file. This field is not required if
%     `out_filenames.out_csv` is empty.
%   - append_csv: A Boolean value indicating whether to overwrite the
%     output CSV file (`false`) or append to it (`true`). This field is not
%     required if `out_filenames.out_csv` is empty.
%
% ## Output Arguments
%
% frame_data -- Per-frame data
%   An n x 2 matrix, where the columns contain the frame numbers, and the x and
%   y-coordinates of the centre of the rectangle annotation in frames of the
%   video. There are no rows for video frames in which processing failed.
%   
% ## References
% - MATLAB Example: Face Detection and Tracking Using Live Video
%   Acquisition
%
% See also vision.VideoFileReader, vision.VideoPlayer, vision.VideoFileWriter, webcam, videoinput
%
% Bernard Llanos
% University of Alberta, Department of Computing Science
% File created January 19, 2018 for a research project under Dr. Y.-H. Yang
% Revised January 20, 2019 for the course CMPUT 428/615



nargoutchk(0, 1)
narginchk(4, 4)
model_points = zeros(4,3,3);
% model_points_3d = zeros(4,3,3);
model_points(:,:,1) = [0, 0, 0; 0, 13.6, 0; 3.7, 0, 0; 3.7, 12.6, 0]; % coordinates of the first plane
model_points(:,:,2) = [0, 0, 0; 0, 13, 0; 4, 0, 0; 4, 13, 0];
model_points(:,:,3) = [13, 0, 0; 0, 0, 0; 13, 13, 0; 0, 13, 0];
% model_points_3d(:,:,1) = [0, 13, 4; 0, 0, 4; 0, 13, 0; 0, 0, 0];
% model_points_3d(:,:,2) = [0, 0, 4; 13, 0, 4; 0, 0, 0; 13, 0, 0];
% model_points_3d(:,:,3) = [0, 13, 4; 13, 13, 4; 0, 0, 4; 13, 0, 4];

intrin = [666.919954349067,0,422.604374020977;0,667.238833836374,236.200771017983;0,0,1]; 
% For test, we provided the real intrinsic matrix for the camera, however,
% program has the ability to compute the intrinsic matrix
% Connect to video source
use_live_video = isempty(in_filename);
if use_live_video
    use_webcam = ~isempty(cam);
else
    inputVideo = vision.VideoFileReader(in_filename);
end

if options.silent && use_live_video
    warning('As the video is not being played in a figure during live capture, stop video capture using Ctrl + C, then manually release the camera.')
end

% Initialize output streams
raw_video_output_enabled = ~isempty(out_filenames.raw_video);
if raw_video_output_enabled
    outputRawVideo = vision.VideoFileWriter(...
        out_filenames.raw_video, 'FrameRate', options.frame_rate,...
        'FileFormat', options.format...
    );
end
if ~options.record_only
    annotated_video_output_enabled = ~isempty(out_filenames.out_video);
    annotate_video = annotated_video_output_enabled || ~options.silent; 
    if annotated_video_output_enabled
        outputAnnotatedVideo = VideoWriter('result_fix_point_angle2');
        outputAnnotatedVideo.FrameRate = 30;
        open(outputAnnotatedVideo);
    end
    csv_output_enabled = ~isempty(out_filenames.out_csv);
    if csv_output_enabled
        if options.append_csv
            outputCSV = fopen(out_filenames.out_csv, 'a');
        else
            outputCSV = fopen(out_filenames.out_csv, 'w');
        end
    end
end

% Special processing for the first frame
if use_live_video
    if use_webcam
        I = snapshot(cam);
    else
        [success, I] = mexMTF2('get_frame');
        if ~success
            error('Failed to capture frame from mexMTF2 video pipeline.');
        end
    end
else
    I = step(inputVideo);
end

fg = figure;
cameraParams = importdata('calibrate.mat');
[I,newOrigin] = undistortImage(I,cameraParams);
imshow(I);
title('Select the four points of the first plane according to order');
% 'drawrectangle()' is a newer function than 'getrect()', but is not
% available in MATLAB R2017a.
rect = ginput(4);
title('Select the four points of the second plane according to order');
rect2 = ginput(4);
title('Select the four points of the third plane according to order');
rect3 = ginput(4);
%rect = rectObject.Position;
%delete(rectObject);

image_size = size(I);
image_size = image_size(1:2);
frame_index = 1;
past_frame_index = 0;
console_output_interval = 2;

% Process video
runLoop = true;
    function onFigureClose(varargin)
        runLoop = false;
    end
fg.DeleteFcn = @onFigureClose;

if ~options.record_only
    return_data = (nargout > 0);
    if return_data
        frame_data = zeros(0, 3);
    end

    if annotate_video
        line_width = ceil(max(2, 0.005 * max(image_size)));
    end
end
tic;
relase = false;        
I_out = I;

calib = struct();
imagePoints = cell(3,1);
objectPoints = cell(3,1);
imagePoints{1} = rect;
imagePoints{2} = rect2;
imagePoints{3} = rect3;
objectPoints{1} = model_points(:,:,1);
objectPoints{2}= model_points(:,:,2);
objectPoints{3}= model_points(:,:,3);

%% Some flags
    opts = struct();
    opts.aspectRatio = 1;                 % aspect ratio (ar = fx/fy)
    opts.flags.UseIntrinsicGuess = true; % how to initize camera matrix
    opts.flags.FixAspectRatio = true;     % fix aspect ratio (ar = fx/fy)
    opts.flags.FixFocalLength = false;    % fix fx and fy
    opts.flags.FixPrincipalPoint = false; % fix principal point at the center
    opts.flags.ZeroTangentDist = false;   % assume zero tangential distortion
    opts.flags.RationalModel = false;     % enable (k4,k5,k6)
    opts.flags.ThinPrismModel = false;    % enable (s1,s2,s3,s4)
    opts.flags.TiltedModel = false;       % enable (taux,tauy)

    
params = {'AspectRatio',1};
calib.M = cv.initCameraMatrix2D(objectPoints, imagePoints, ...
    [image_size(2), image_size(1)], params{:});
calib.D = zeros(1,2);
params = st2kv(opts.flags);
params = [params, 'CameraMatrix',calib.M, 'DistCoeffs',calib.D, ...
        'UseIntrinsicGuess',opts.flags.UseIntrinsicGuess];

[calib.M, calib.D, calib.rms, calib.R, calib.T] = cv.calibrateCamera(...
            objectPoints, imagePoints, [image_size(2), image_size(1)],params{:});

%[new_camera_matrix, roi] = cv.getOptimalNewCameraMatrix(calib.M, calib.D, [image_size(2), image_size(1)]);
% I_out = cv.undistort(I_out,new_camera_matrix,calib.D);
% imshow(I_out)
% rect = ginput(4);
% rect2 = ginput(4);
% rect3 = ginput(4);
% intrin = calib.M;

initial_frame = rgb2gray(im2double(I_out));
initial_A = int32(rect);
initial_A2 = int32(rect2);
initial_A3 = int32(rect3);
X1 = get_X(rect);
X2 = get_X(rect2);
X3 = get_X(rect3);
initial_region_1 = interp2(initial_frame,X1(1,:), X1(2,:),'cubic');
initial_region_2 = interp2(initial_frame,X2(1,:), X2(2,:),'cubic');
initial_region_3 = interp2(initial_frame,X3(1,:), X3(2,:),'cubic');
initial_affine_guess = zeros(12,2); % 4row per plane
while runLoop
    if ~options.record_only
%         try
%             I = cv.undistort(I,intrin,calib.D);
            cameraParams = importdata('calibrate.mat');
            [I,~] = undistortImage(I,cameraParams);
            grey_I = rgb2gray(im2double(I));
            success =true;
            optims = optimoptions(@lsqnonlin,'Algorithm','trust-region-reflective', 'Display', 'iter-detailed',...
                'StepTolerance', 1e-4, 'FunctionTolerance', 1e-4,'OptimalityTolerance', 1e-8, 'UseParallel', true,'PlotFcn' ,'optimplotfval');
            if relase == false
                affine_f = @(new_A)get_affine_error(new_A, initial_A, initial_A2, initial_A3, initial_region_1',...
                initial_region_2', initial_region_3', grey_I, X1, X2, X3, intrin, model_points); % Get function handle
                [noraml_points_result,resnorm] = lsqnonlin(affine_f,initial_affine_guess, [],[],optims); % solve for normalized points
                pre_error = resnorm;
                int_normal_points_result = int32(noraml_points_result);
                points_result = int_normal_points_result(1:4,:) + initial_A; % denormalize
                points_result2 = int_normal_points_result(5:8,:) + initial_A2;
                points_result3 = int_normal_points_result(9:12,:) + initial_A3;
                calculate_angle_2(intrin, model_points, initial_A, initial_A2, initial_A3) % calculate the angle for test
                relase = true;
            else
                pass = false;
                record_point = zeros(12,2);
                affine_f = @(new_A)get_affine_error(new_A, initial_A, initial_A2, initial_A3, initial_region_1',...
                    initial_region_2', initial_region_3', grey_I, X1, X2, X3,intrin, model_points);
                while ~pass
                    fprintf(...
                        '%d frames processed, %g FPS for the last %g seconds.\n',...
                        frame_index, (frame_index - past_frame_index) / elapsed, elapsed...
                    );
%                     lb = noraml_points_result - 20;
%                     ub = noraml_points_result + 20;
                    if resnorm/pre_error >90
                        record_point = noraml_points_result+ normrnd(0,1.5, [12,2]);
                        [~,resnorm] = lsqnonlin(affine_f,record_point, [],[],optims);
                    else
                        if record_point ~= 0
                            noraml_points_result = record_point;
                        end
                        [noraml_points_result,resnorm] = lsqnonlin(affine_f,noraml_points_result, [],[],optims);
                        pass = true;
                    end
                    int_normal_points_result = int32(noraml_points_result);
                    points_result = int_normal_points_result(1:4,:) + initial_A;
                    points_result2 = int_normal_points_result(5:8,:) + initial_A2;
                    points_result3 = int_normal_points_result(9:12,:) + initial_A3;
                    fprintf("The current summation of residual is %f \n", resnorm)
                end
            end
                %points_result
%             if success == false
%                 fprintf("lost track 1")
%             end
%             if success2 == false
%                 fprintf("lost track 2")
%             end
            my_line = [points_result(1,:), points_result(2,:), points_result(4,:), points_result(3,:), points_result(1,:)];
            my_line2 = [points_result2(1,:), points_result2(2,:), points_result2(4,:), points_result2(3,:), points_result2(1,:)];
            my_line3 = [points_result3(1,:), points_result3(2,:), points_result3(4,:), points_result3(3,:), points_result3(1,:)];
            I_out = I;
            
            if return_data
                % Frame number, top-left x coordinate, top-left y coordinate
                frame_data(end + 1, :) = [frame_index, rect(1), rect(2)]; %#ok<AGROW>
            end

            if csv_output_enabled
                fprintf(...
                    outputCSV, '%d, %d, %g, %g\n',...
                    options.video_index, frame_index, rect(1), rect(2)...
                );
            end            

            if annotate_video && success
                I_out = insertShape(...
                    I_out, 'Line', my_line, 'Color', 'red', 'LineWidth', line_width...
                );
               I_out = insertShape(...
                    I_out, 'Line', my_line3, 'Color', 'red', 'LineWidth', line_width...
                );
               I_out = insertShape(...
                    I_out, 'Line', my_line2, 'Color', 'red', 'LineWidth', line_width...
                );
            end
            
        if annotated_video_output_enabled
            I_out = im2uint8(I_out);
            writeVideo(outputAnnotatedVideo, I_out);
        end
    else
        I_out = I;
    end
    
    if ~options.silent
        %try
            figure(fg);
            imshow(I_out);
%         catch
%             runLoop = false;
%         end
    end
    
    if raw_video_output_enabled
        step(outputRawVideo, I);
    end
    
    % Check whether to end processing
    if ~use_live_video
        runLoop = runLoop && ~isDone(inputVideo);
    end

    if runLoop
        if use_live_video
            if use_webcam
                I = snapshot(cam);
            else
                [success, I] = mexMTF2('get_frame');
                if ~success
                    error('Failed to capture frame from mexMTF2 video pipeline.');
                end
            end
        else
            I = step(inputVideo);
        end
        
        elapsed = toc;
        if elapsed >= console_output_interval
            fprintf(...
                '%d frames processed, %g FPS for the last %g seconds.\n',...
                frame_index, (frame_index - past_frame_index) / elapsed, elapsed...
            );
            past_frame_index = frame_index;
            tic;
        end
        frame_index = frame_index + 1;
    end
end

% Cleanup
if ~use_live_video
    release(inputVideo);
end
if raw_video_output_enabled
    release(outputRawVideo);
end
if ~options.record_only
    if annotated_video_output_enabled
        close(outputAnnotatedVideo);
    end
    if csv_output_enabled
        fclose(outputCSV);
    end
end

if options.record_only
    frame_data = [];
end

function kv = st2kv(st)
    % convert struct to cell-array of key/value params
    k = fieldnames(st);
    v = struct2cell(st);
    kv = [k(:) v(:)]';
    kv = kv(:)';
end

end