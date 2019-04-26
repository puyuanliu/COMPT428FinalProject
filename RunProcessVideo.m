%% Process live or saved video
% Invoke a per-frame algorithm on a series of video frames, and output the
% results as videos and CSV files.
%
% ## Usage
%   If you want to use a webcam, via the MATLAB Support Package for USB Webcams,
%   create a variable called `cam` in the current workspace that contains a
%   connection to the camera. For example, `cam = webcam();`.
%   
%   Otherwise, create an empty variable `cam`: `cam = [];`. If no input video
%   files are provided, Modular Tracking Framework
%   (https://webdocs.cs.ualberta.ca/~vis/mtf/) will be used to capture images.
%   In this case, you must set up Modular Tracking Framework in advance,
%   by calling: `mexMTF2('init', ...);`
%
%   If you want to use video file(s) as input, enter the appropriate wildcard
%   into the `input_video_wildcard` parameter below, and create an empty
%   variable `cam`.
%
%   Adjust the parameters and the paths to input/output data in the first code
%   section below, then run.
%
% ## Input
%
% This script can process either live video, or one or more saved videos.
% Refer to the MATLAB documentation for the 'vision.VideoFileReader' system
% object concerning compatible video file formats.
%
% ## Output
%
% One output file of each of the following types will be generated for each
% input video source, except in the case of CSV files, if 'concatenate_csv'
% is `true` (see below). Output files will be saved in the directories
% referred to by the 'output_*_directory' variables below. If an output
% directory variable is empty, no output data files of the corresponding
% type will be produced.
%
% ### Input videos
%
% Copies of the input videos, or videos captured from cameras, will be
% saved in the directory referred to by 'output_raw_video_directory'
% below.
%
% ### Annotated videos
%
% The input videos will be annotated, and saved in the directory referred to by
% 'output_annotated_video_directory' below.
%
% The annotations on the videos are those described in the documentation of
% 'processVideo()' (refer to 'processVideo.m').
%
% ### Numerical output
%
% A CSV file will be generated containing frame numbers and the corresponding
% frame processing data. Additionally, the first column of the CSV file will be
% the index of the video (starting from 1) in the list of videos processed by
% this script. For videos captured directly from cameras, the index is one
% greater than the variable 'video_index', if it exists, or is 1, if
% 'video_index' does not exist. 'video_index' is left in the workspace for use
% by future executions of this script.
%
% The CSV file will be saved in the directory referred to by
% 'output_data_directory' below. If 'concatenate_csv' is `true`, the CSV files
% for all input videos, or for live videos captured until the 'video_index'
% variable is cleared from the workspace, will be combined into one. The name of
% the combined CSV file will be the name ordinarily given to the CSV file for
% only the first video.
%
% The data output is also described in the documentation of the
% `out_filenames.out_csv` input argument of 'processVideo()' (refer to
% 'processVideo.m').
%
% ### Environment and MATLAB-format results
%
% '.mat' files containing the following variables will be saved in the directory
% referred to by 'output_data_directory' below:
%
% - 'frame_data': The `frame_data` output argument of
%   'processVideo()'. Refer to the documentation of 'processVideo.m' for
%   details.
%
% Additionally, the file contains the values of all parameters in the first
% section of the script below, for reference. (Specifically, those listed
% in `parameters_list`, which should be updated if the set of parameters is
% changed.)
%
% Bernard Llanos
% University of Alberta, Department of Computing Science
% File created January 19, 2018 for a research project under Dr. Y.-H. Yang
% Revised January 20, 2019 for the course CMPUT 428/615

%% Input data and parameters

% List of parameters to save with results
parameters_list = {
    'concatenate_csv',...
    'first_video_index',...
    'video_filenames',...
    'options'...
};
cam = [];
% Wildcard for 'ls()' to find the videos to process.
% Leave empty (`[]`) to read live video
input_video_wildcard = 'combine3_480.mp4';

% Output directory for raw videos
% Leave empty (`[]`) for no output raw video
output_raw_video_directory = [];

% Output directory for annotated videos
% Leave empty (`[]`) for no output annotated video
output_annotated_video_directory = "E:\428\finalProject";

% Output directory for CSV and MATLAB format data
% Leave empty (`[]`) for no output data
output_data_directory = "E:\428\finalProject";

% Combine CSV files into one file
concatenate_csv = true;

% Output video format (refer to the documentation of `vision.VideoFileWriter`)
% Please do not upload videos in uncompressed formats.
output_video_extension = '.avi';

% Video processing options
% Refer to the documentation of the `options` parameter of 'processVideo()'
% in 'processVideo.m'. Some fields of this parameter structure will be
% filled automatically later in this script.
options.silent = false;
options.frame_rate = 57;
options.record_only = false;
options.show_errors = true;
if strcmp(output_video_extension, '.mj2')
    options.format = 'MJ2000';
elseif strcmp(output_video_extension, '.avi')
    options.format = 'AVI';
elseif any(strcmp(output_video_extension, {'.mp4', '.m4v'}))
    options.format = 'MPEG4';
else
    error('Unrecognized output video format: %s', output_video_extension);
end

%% Find the videos

if isempty(input_video_wildcard)
    video_filenames = {[]};
    n_videos = 1;
else
    % Find all filenames
    video_filenames = listFiles(input_video_wildcard);
    n_videos = length(video_filenames);
end


%% Process each video (or live video)

save_variables_list = [ parameters_list, {...
        'frame_data'...
    } ];
any_output_files = ~all([
        isempty(output_raw_video_directory);
        isempty(output_annotated_video_directory);
        isempty(output_data_directory)
    ]);

if exist('video_index', 'var')
    video_index = video_index + 1;
else
    video_index = 1;
end
first_video_index = video_index;
if ~exist('csv_filename', 'var')
    csv_filename = [];
end

for i = 1:n_videos
    % Generate output filenames
    if any_output_files && isempty(video_filenames{i})
        cdate = replace(datestr(now, 31), {'-',' ',':'},'_');
    elseif any_output_files
        [filepath, name] = fileparts(video_filenames{i});
    end
    if isempty(output_raw_video_directory)
        raw_video_filename = [];
    else
        if isempty(video_filenames{i})
            raw_video_filename = ['live_' cdate output_video_extension];
        else
            raw_video_filename = [name '_copy' output_video_extension];
        end
        raw_video_filename = fullfile(output_raw_video_directory, raw_video_filename);
    end
    if isempty(output_annotated_video_directory)
        annotated_video_filename = [];
    else
        if isempty(video_filenames{i})
            annotated_video_filename = ['live_' cdate '_annotated' output_video_extension];
        else
            annotated_video_filename = [name '_annotated' output_video_extension];
        end
        annotated_video_filename = fullfile(output_annotated_video_directory, annotated_video_filename);
    end
    if isempty(output_data_directory)
        csv_filename = [];
    elseif ~concatenate_csv || isempty(csv_filename)
        if isempty(video_filenames{i})
            csv_filename = ['live_' cdate '.csv'];
        else
            csv_filename = [name '.csv'];
        end
        csv_filename = fullfile(output_data_directory, csv_filename);
    end
    if ~isempty(output_data_directory)
        if isempty(video_filenames{i})
            save_data_filename = ['live_' cdate '.mat'];
        else
            save_data_filename = [name '.mat'];
        end
        save_data_filename = fullfile(output_data_directory, save_data_filename);
    end

    out_filenames = struct(...
        'raw_video', raw_video_filename,...
        'out_video', annotated_video_filename,...
        'out_csv', csv_filename...
    );

    % Video processing
    options_i = options;
    options_i.video_index = video_index;
    options_i.append_csv = (video_index ~= 1) && concatenate_csv;
    if ~isempty(output_data_directory)
        frame_data = processVideo(...
            video_filenames{i}, out_filenames, cam, options_i...
        );
        save(save_data_filename, save_variables_list{:});
    else

        processVideo(...
            video_filenames{i}, out_filenames, cam, options_i...
        );
    end
    video_index = video_index + 1;
end
