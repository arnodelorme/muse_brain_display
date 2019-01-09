% muse_brain - plot saved data (Musemonitor app available for Android and
%              iPhone) or stream data using the lab-streaming layer.
%
% Example:
% muse_brain('musemonitor_example_data_file.csv');

function muse_brain(fileName, command, param)

color1  = [1 0 0]; color1str = 'Red';
color2  = [0 0 1]; color2str = 'Blue'; 
neutral = [0.2 0.2 0.2]; % for the sphere
colorFactor = 1/3; %1/3 very focal; 1/2 focal; 1 average; 2 spread out; 3 very spread out
startView = [180 50];
path3dnstep = 60;   % rotation speed
pathAmplitude = 20; % rotation amplitude
stepSizeMovie   = 15; % number of image per second
gamma = 3;
meshResolution = 'hi'; % or 'low'

% different zoom for different Matlab versions
v = version;
camZoomVal = 1; % change for different Matlab version

if nargin < 1
    [fileName, pathName] = uigetfile({ '*.csv' }, 'Pick a file');
    if isempty(fileName), return; end
    fileName = fullfile(pathName, fileName);
end

if isstr(fileName)
    
    % getting data from the data file
    M = importdata(fileName);
    headerNames = M.textdata{1};
    headerNames = textscan(headerNames,'%s','delimiter',',');
    headerNames = headerNames{1}(2:end-1);
    headerNames{end+1} = 'All Delta';
    headerNames{end+1} = 'All Theta';
    headerNames{end+1} = 'All Alpha';
    headerNames{end+1} = 'All Beta';
    headerNames{end+1} = 'All Gamma';
    headerNames{end+1} = 'None';
    M.data = bsxfun(@rdivide, bsxfun(@minus, M.data, min(M.data)), (max(M.data) - min(M.data))); % bound all values from 0 to 1
    
    % apply sigmoid function
    M.data = 1./(1+exp(-5*(M.data-0)));
    M.data = bsxfun(@rdivide, bsxfun(@minus, M.data, min(M.data)), (max(M.data) - min(M.data))); % bound all values from 0 to 1
    
    % creating brain axis
    fig = figure('position', [560   228   946   720], 'color', [1 1 1], 'menubar', 'none');
    userDat.axisBrain = axes('position', [0.029    0.342    0.943    0.633], 'tag', 'museBrainAxis', 'color', [0.2 0.2 0.2]);
    warning off;
    orifold = fileparts(which(mfilename));
    if strcmpi(meshResolution, 'hi')
         data3d = load('-mat', fullfile(orifold, 'resources', 'head3d.mat'));
         userDat.vertIndices = [ 25900 74300 72900 23600 ]; % vertices closest to electrodes TP9 AF7 AF8 TP10
    else data3d = load('-mat', fullfile(orifold, 'resources', 'head3d_2.mat'));
         userDat.vertIndices = [  400 30000 9300  38800 ]; % vertices closest to electrodes TP9 AF7 AF8 TP10
    end
    posElectrodes = [  -65  -38   18;
                       30   60   13;
                      -30   60   13;
                       65  -38   18 ];
    
    warning on;
    head3d = data3d.head3d;
    theme  = data3d.theme;
    curlayer = 'cortex';
    Surface = head3d.(curlayer).mesh;
    theme   = theme.(curlayer);
    theme.FaceAlpha = 1;
    
    % get pairwise distance to all vertices
    pairwiseDist = zeros(size(Surface.vertices,1),4);
    for iInd = 1:length(userDat.vertIndices)
        pairwiseDist(:,iInd) = sum((Surface.vertices-repmat(Surface.vertices(userDat.vertIndices(iInd),:), size(Surface.vertices,1),1)).^2,2);
    end
    pairwiseDist = pairwiseDist.^(colorFactor);
    pairwiseDist = pairwiseDist./repmat(max(pairwiseDist), size(Surface.vertices,1),1); % normalize
    pairwiseDist = 1-pairwiseDist;
    %figure; hist(pairwiseDist(:)); figure(fig); % plot pairWise distance histogram
    
    % compute color
    colors = pairwiseDist(:,4)*color1; % some initial color (erased below)
    %colors = repmat( [.8 .55 .35]*1.1, size(Surface.vertices,1),1);
    
    userDat.meshBrain = patch('vertices',Surface.vertices,'faces',Surface.faces, 'LineStyle','none','parent',userDat.axisBrain,'FaceVertexCdata',colors,'facecolor','interp','edgecolor','none',theme);
%    patch('vertices',Surface.vertices,'faces',Surface.faces, 'LineStyle','none','parent',userDat.axisBrain,'facecolor','interp','edgecolor','none',theme);
%    p1 = hlp_plotAtlas(head3d.(curlayer).mesh,userDat.axisBrain,head3d.(curlayer).color.arg_selection,head3d.(curlayer).color.colormapping,hlp_struct2varargin(theme));
%    Handle = hlp_plotAtlas(head3d.(curlayer).mesh,userDat.axisBrain,head3d.(curlayer).color.arg_selection,head3d.(curlayer).color.colormapping,hlp_struct2varargin(theme));
%    Handle = hlp_plotmesh(head3d.(curlayer).mesh.faces, head3d.(curlayer).mesh.vertices,[],false,userDat.axisBrain,head3d.(curlayer).color,hlp_struct2varargin(theme.(curlayer)));
%    Handle = hlp_plotmesh(head3d.(curlayer).mesh.faces, head3d.(curlayer).mesh.vertices,[],false,userDat.axisBrain,'flat',hlp_struct2varargin(theme.(curlayer)));
    %set(p1, theme);
    axis equal;
    axis off;
    hold on;
    
    % change lighting
    set(fig, 'renderer', 'opengl');
    lighting(userDat.axisBrain, 'phong');
    hlights = findobj(userDat.axisBrain,'type','light');
    delete(hlights)
    hlights = [];
    camlight(0,0);
    camlight(90,0);
    camlight(180,0);
    camlight(270,0);
    camproj orthographic
    axis vis3d
    view(startView);
    camzoom(camZoomVal);

    % plot spheres
    if 1
        [x y z] = sphere(15);
        l=sqrt(x.*x+y.*y+z.*z);
        normals = reshape([x./l y./l z./l],[16 16 3]);
        fact = 10;
        sphereColors   = { [1 0 0] [0 1 0] [0 0 1] [1 1 0] [0 1 1] [1 0 1] };
        sphereColors   = { [0.2 0.2 0.2] [0.2 0.2 0.2] [0.2 0.2 0.2] [0.2 0.2 0.2] };
        userDat.sphereSize = size(x);
        for iVert = 1:length(userDat.vertIndices)
            posSphere = posElectrodes(iVert,:); %Surface.vertices(userDat.vertIndices(iVert),:);
            userDat.sphereColorNone = repmat(reshape( [0.2 0.2 0.2], 1,1,3),size(x,1), size(x,2));
            userDat.sphereColorCol1 = repmat(reshape( color1*0.7, 1,1,3),size(x,1), size(x,2));
            userDat.sphereColorCol2 = repmat(reshape( color2*0.7, 1,1,3),size(x,1), size(x,2));
            userDat.elecSphere(iVert) = surf(x*fact+posSphere(1), y*fact+posSphere(2), z*fact+posSphere(3), userDat.sphereColorNone);
            set(userDat.elecSphere(iVert), 'edgecolor', 'none', 'facecolor', 'interp', 'vertexnormals', normals, 'facelighting', 'phong');
        end
    end
         
    % plot vertices indices
    if 0
        for iVert = 100:100:length(Surface.vertices)
            posSphere = Surface.vertices(iVert,:);
            h = text(posSphere(1)*1.2, posSphere(2)*1.2, posSphere(3)*1.2, int2str(iVert/100));
            set(h, 'fontsize', 12); 
        end
    end
    
    % trace axis
    userDat.axisTrace = axes('position', [0.029 0.073 0.943 0.24], 'tag', 'museTraceAxis', 'color', [0.9 0.9 0.9]);

    % draw GUI components
    ax3 = axes('position', [0 0 1 1]); axis off; % invisible axis
    h = text( 0.032, 0.8, [ 'This is an art' 10 'project. Colors may' 10 'not reflect localized' 10 'brain activity.' ]);
    set(h, 'fontsize', 14, 'fontweight', 'bold');
    h = text( 0.032, 0.033,[color1str ' trace:']); set(h, 'color', color1*0.7, 'fontsize', 16);
    h = text( 0.39 , 0.033,[color2str ' trace:']); set(h, 'color', color2*0.7, 'fontsize', 16);
    userDat.ui_col1   = uicontrol('style', 'popupmenu' , 'string', headerNames, 'unit', 'normalized', 'position', [0.132 0.013 0.217 0.032], 'value', 21, 'callback', 'muse_brain( gcbf, ''cb_col1'')');
    userDat.ui_col2   = uicontrol('style', 'popupmenu' , 'string', headerNames, 'unit', 'normalized', 'position', [0.478 0.013 0.217 0.032], 'value', 22, 'callback', 'muse_brain( gcbf, ''cb_col2'')');
    userDat.ui_play   = uicontrol('style', 'pushbutton', 'string', 'Play',       'unit', 'normalized', 'position', [0.882 0.013 0.077 0.032], 'callback', 'muse_brain( gcbf, ''cb_play'', false)');
    userDat.ui_movie  = uicontrol('style', 'pushbutton', 'string', 'Make movie', 'unit', 'normalized', 'position', [0.782 0.013 0.077 0.032], 'callback', 'muse_brain( gcbf, ''cb_play'', true)');
    userDat.ui_rotate = uicontrol('style', 'pushbutton', 'string', 'Rotate',    'unit', 'normalized', 'position', [0.882 0.957 0.077 0.032], 'callback', 'muse_brain( gcbf, ''cb_rotate'')');

    % copy paramters to user data structure
    userDat.pairwiseDist = pairwiseDist;
    userDat.data = M.data;
    userDat.color1 = color1;
    userDat.color2 = color2;
    userDat.colNeutral = neutral;
    userDat.verttLinePlot = [];
    userDat.currentPos = 1;
    userDat.playing = false;
    userDat.currentCount = 1;
    set(fig, 'userdata', userDat);

    % initial drawing
    muse_brain(fig, 'cb_col1');
    muse_brain(fig, 'cb_col2');
    axes(userDat.axisBrain);
    muse_brain( fig, 'cb_click_trace')
    set(fig, 'windowbuttondownfcn', 'muse_brain( gcbf, ''cb_click_trace'')');
    
else
    fig = fileName;
    userDat = get(fig, 'userdata');
    
    switch command
        case 'cb_col1'
            % draw first trace on the curve
            try, delete(userDat.plot_col1); catch, end
            axes(userDat.axisTrace);
            pos = get(userDat.ui_col1, 'value');
            data = getMuseData(userDat.data, pos);
            if ~isempty(data)
                userDat.plot_col1 = plot(mean(data,2));
                hold on;
                xlim([1 size(userDat.data,1)])
                set(userDat.plot_col1, 'color', color1*0.7, 'linewidth', 1);
            end
            userDat = redrawCortex( userDat, userDat.currentPos, gamma);
            
        case 'cb_col2'
            % draw second trace on the curve
            try, delete(userDat.plot_col2); catch, end
            axes(userDat.axisTrace);
            pos = get(userDat.ui_col2, 'value');
            data = getMuseData(userDat.data, pos);
            if ~isempty(data)
                userDat.plot_col2 = plot(mean(data,2));
                hold on;
                xlim([1 size(userDat.data,1)])
                set(userDat.plot_col2, 'color', color2*0.7, 'linewidth', 1);            
            end
            userDat = redrawCortex( userDat, userDat.currentPos, gamma);
            
        case 'cb_click_trace'
            % callback when user clicks on the trace
            if userDat.playing
                userDat.playing = false;
            end
            tmppos = get(userDat.axisTrace, 'currentpoint');
            userDat.currentPos = round(tmppos(1));
            userDat = redrawCortex( userDat, userDat.currentPos, gamma);
            set(userDat.ui_play , 'string', 'Play'      , 'callback', 'muse_brain( gcbf, ''cb_play'', false)');
            set(userDat.ui_movie, 'string', 'Make movie', 'callback', 'muse_brain( gcbf, ''cb_play'', true)');

        case 'cb_stop'
            % callback when user press the stop button
            set(userDat.ui_play , 'string', 'Play'      , 'callback', 'muse_brain( gcbf, ''cb_play'', false)');
            set(userDat.ui_movie, 'string', 'Make movie', 'callback', 'muse_brain( gcbf, ''cb_play'', true)');
            userDat.playing = 2;
            
        case 'cb_play'
            % callback for playing or recording
            
            % toggle button
            set(userDat.ui_play , 'string', 'Stop', 'callback', 'muse_brain( gcbf, ''cb_stop'')');
            set(userDat.ui_movie, 'string', 'Stop', 'callback', 'muse_brain( gcbf, ''cb_stop'')');
            userDat.playing = true;
            set(fig, 'userdata', userDat);
            
            % Prepare the new movie file.
            if param
                vidObj = VideoWriter( [ 'Muse movie ' datestr(now) ]);
                open(vidObj);
            end
            
            % view parameters
            count = userDat.currentCount;
            pathVals = linspace(0, 2*pi, path3dnstep);
            pathVals(end) = [];
            
            % play movie
            xl = xlim(userDat.axisTrace);
            for xPos = userDat.currentPos:stepSizeMovie:xl(end)
                userDat = redrawCortex( userDat, xPos, gamma);
                
                % change view
                axes(userDat.axisBrain);
                xPos2 = sin(pathVals(count))*pathAmplitude;
                yPos2 = cos(pathVals(count))*pathAmplitude;
                view([startView(1)+xPos2 startView(2)+yPos2])
                count = mod(count, path3dnstep-1)+1;
                
                % test if we need to stop playing
                drawnow;
                if param
                    currFrame = getframe(fig);
                    writeVideo(vidObj,currFrame);
                end
                userDat = get(fig, 'userdata');
                if userDat.playing == 0 || userDat.playing == 2
                    break;
                end
            end
            if param, close(vidObj); end
            
            userDat.currentCount = count;
            if userDat.playing == 2 % stop
                userDat.currentPos = xPos;
            end
            
        case 'cb_rotate'
            % callback for rotating 3-D view
            rotate3d;
            if strcmpi(get( userDat.ui_rotate, 'string'), 'Rotate')
                 set(userDat.ui_rotate, 'string', 'Stop rot.');
            else set(userDat.ui_rotate, 'string', 'Rotate');
                 set(fig, 'windowbuttondownfcn', 'muse_brain( gcbf, ''cb_click_trace'')');
            end
    end
    set(fig, 'userdata', userDat);
end

% function to get the Muse data
% -----------------------------
function [data, elec] = getMuseData(oriData, cpos, rpos)

    elec = [];
    data = [];
    nCols = size(oriData,2);
    if cpos <= nCols
        data = oriData(:,cpos);
        elec  = mod(cpos-1,4)+1;
    else
        switch cpos
            case nCols+1 % Delta
                data = oriData(:,1:4); elec = [1:4];
            case nCols+2 % Theta
                data = oriData(:,5:8); elec = [1:4];
            case nCols+3 % Alpha 
                data = oriData(:,9:12); elec = [1:4];
            case nCols+4 % Beta
                data = oriData(:,13:16); elec = [1:4];
            case nCols+5 % Gamma
                data = oriData(:,17:20); elec = [1:4];
        end
    end
    if nargin == 3 && rpos > 0 && rpos <= length(data) && ~isempty(data)
        data = data(rpos,:);
    end

% function to draw the Cortex
% ---------------------------
function userDat = redrawCortex( userDat, xpos, gamma)

    % get electrode being plotted
    pos1 = get(userDat.ui_col1, 'value');
    pos2 = get(userDat.ui_col2 , 'value');
            
    [data1, elec1] = getMuseData(userDat.data, pos1, xpos);
    [data2, elec2] = getMuseData(userDat.data, pos2, xpos);

    % plot vertical line
    xl = xlim(userDat.axisTrace);
    if xpos > 0 && xpos <= xl(2)
        if ~isempty(userDat.verttLinePlot)
            try
                set(userDat.verttLinePlot, 'xdata', [xpos xpos]);
            catch
            end
        else
            userDat.verttLinePlot = plot([xpos xpos], [0 1], 'k--');
        end
    end            
    
    % set mesh color
    colors = zeros(size(userDat.pairwiseDist,1), length(userDat.color1));
    for iElec = 1:length(elec1), colors = colors + userDat.pairwiseDist(:,elec1(iElec))*userDat.color1*data1(iElec); end
    for iElec = 1:length(elec2), colors = colors + userDat.pairwiseDist(:,elec2(iElec))*userDat.color2*data2(iElec); end
    colors = 1-(1-colors).^gamma;
    
    % set ball colors
    set(userDat.meshBrain, 'FaceVertexCdata', colors);
    for iElec = 1:4
        if any(iElec == elec1) || any(iElec == elec2)
             col = colors(userDat.vertIndices(iElec),:);
        else col = userDat.colNeutral;
        end
        set(userDat.elecSphere(iElec), 'cdata', repmat(reshape(col, 1,1,3),userDat.sphereSize(1), userDat.sphereSize(2)));
    end
                