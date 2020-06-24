%Make Pipeline object to manage streaming
alpha = 0.5;
pointcloud = realsense.pointcloud();
pipe = realsense.pipeline();
colorizer = realsense.colorizer();
% Start streaming on an arbitrary camera with default settings
profile = pipe.start();
align_to = realsense.stream.color;
alignedFs = realsense.align(align_to);
% Get streaming device's name
dev = profile.get_device();
name = dev.get_info(realsense.camera_info.name);
% Get frames. We discard the first couple to allow the camera time to settle
for i = 1:5
    fs = pipe.wait_for_frames();
    %align the depth frames to the color stream
    aligned_frames = alignedFs.process(fs);
    depth = aligned_frames.get_depth_frame();
    depth2 = colorizer.colorize(depth);
    %pointcloud.map_to(color);
    points = pointcloud.calculate(depth);
    %Adjust frame CS to matlab CS
    vertices = points.get_vertices();
    X = vertices(:,1);
    Y = vertices(:,2);
    Z = vertices(:,3);
    depthData = [X, Y, Z];
    % get depth image parameters
    depthSensor = dev.first('depth_sensor');
    depthScale = depthSensor.get_depth_scale();
    depthWidth = depth2.get_width();
    depthHeight = depth2.get_height();
    % retrieve UINT8 depth vector
    depthVector = depth2.get_data();
    % reshape vector, and scale to depth in meters
    depthMap = permute(reshape(depthVector, [3, depth.get_width(), depth.get_height()]), [3, 2, 1]);
    %Select rgb frame
    color = fs.get_color_frame();
    colordata=color.get_data();
    img = permute(reshape(colordata',[3,color.get_width(),color.get_height()]),[3 2 1]);
    r = img(:, :, 1);
    g = img(:, :, 2);
    b = img(:, :, 3);
    mixt = alpha.*img + (1-alpha).*depthMap;
    imshow(mixt)
    title("Align");
    pause(0.01);
end
%Stop streaming
pipe.stop();
writematrix(X,"Xcoord.csv");
writematrix(Y,"Ycoord.csv");
writematrix(Z,"Zcoord.csv");
writematrix(r,"Red.csv");
writematrix(g,"Green.csv");
writematrix(b,"Blue.csv");
