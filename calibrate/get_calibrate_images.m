function get_calibrate_images
 vid=VideoReader('calibrate.mp4');
 numFrames = vid.NumberOfFrames;
 n=numFrames;
 for i = 1:2:n
 frames = read(vid,i);
 imwrite(frames,['Image' int2str(i), '.jpg']);
 im(i)=image(frames);
 end