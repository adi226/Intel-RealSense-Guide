alpha = 0.5;
pipe = realsense.pipeline();
colorizer = realsense.colorizer();
profile = pipe.start();
align_to = realsense.stream.color;
alignedFs = realsense.align(align_to);
%Initialiazing UI slider
fig = uifigure;
im = uiimage(fig);
sld = uislider(fig,'Value',0.5, 'ValueChangedFcn', @(sld, event) updatesld(sld, alpha));
sld.Limits = [0 1];
while(True)
    fs = pipe.wait_for_frames();
    aligned_frames = alignedFs.process(fs);
    depth = aligned_frames.get_depth_frame();
    depth2 = colorizer.colorize(depth);
    depthSensor = dev.first('depth_sensor');
    depthScale = depthSensor.get_depth_scale();
    depthWidth = depth2.get_width();    
    depthHeight = depth2.get_height();
    depthVector = depth2.get_data();
    depthMap = permute(reshape(depthVector, [3, depth.get_width(), depth.get_height()]), [3, 2, 1]);
    color = fs.get_color_frame();
    colordata=color.get_data();
    img = permute(reshape(colordata',[3,color.get_width(),color.get_height()]),[3 2 1]);
    mixt = alpha.*img + (1-alpha).*depthMap;
    im.ImageSource = mixt;
    pause(0.01);
end
% Stop streaming
pipe.stop();
writematrix(r,"R.csv");
writematrix(g,"G.csv");
writematrix(b,"B.csv");
function updatesld(sld, alpha)
alpha = sld.Value;
%disp(alpha);
end