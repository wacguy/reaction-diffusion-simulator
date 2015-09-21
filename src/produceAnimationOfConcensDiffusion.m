% Generates a figure, and produces a 2D animation of how the concentrations
% diffuse, both activator and inhibitor, across the root at a fixed moment.
function produceAnimationOfConcensDiffusion( ...
  titleSecondLineStr, ...
  actConcenSolutionsFromPdepe, ...
  inhConcenSolutionsFromPdepe, ...
  timeDomainSize, ...
  timeDomainStep, ...
  spatialDomainSize, ...
  spatialDomainStep, ...
  tipVelocity, ...
  initialRootLength)

centerFigure(500, 700); % Open up a figure of width 500, height 700, and center
                        % it at the middle of the screen.

fig = gcf;

rootWidth = 10; % unimportant width of the root, for visual purposes
gapBetweenRoots = 5; % similarly unimportant, for visual purposes

maxActConcen = max(actConcenSolutionsFromPdepe(:));
minActConcen = min(actConcenSolutionsFromPdepe(:));
maxInhConcen = max(inhConcenSolutionsFromPdepe(:));
minInhConcen = min(inhConcenSolutionsFromPdepe(:));

% The inside of the following `while` loop produces each frame of the animation.
curTime = 0;
frameIdx = 1;
prevMsgLen = 0; % This helps delete the previous line of console output.
while curTime <= timeDomainSize
  % Delete the previous line of console output, and write a new one.
  fprintf(repmat('\b', 1, prevMsgLen));
  prevMsgLen = fprintf('Movie: creating frame %d of %d \n', ...
    frameIdx, ...
    timeDomainSize / timeDomainStep);

  % If the user is watching any other figure window, make sure this new frame
  % gets drawn to this desired figure.
  figure(fig);

  % Erase everything that is in the previous frame, so that a new frame can be
  % painted.
  clf;

  % Prepare a new frame.
  axes = gca; % `gca` returns the current axes handle.
  axes.Color = 'none'; % We don't want any color on the back pane.
  axes.XColor = 'none'; % We don't want the x-axis to appear.
  axes.YLabel.String = 'Distance from top of root (micro-m)';
  axes.YDir = 'reverse'; % Since the label is 'distance from *top* of root,
                         % we want 0 to be at the top of the Y-axis.
  title([
    'Activator (left) and inhibitor (right) concentrations at', ...
    sprintf(' %.1f hrs\n', curTime / 60 / 60), ...
    titleSecondLineStr
  ]);

  timeIdx = int32((curTime - 0) / timeDomainStep + 1);
  howManySpatialStepsAreThere = int32(spatialDomainSize / spatialDomainStep);

  actConcensAtCurTime = actConcenSolutionsFromPdepe(timeIdx, :);
  drawConcensAtFixedTime( ...
    actConcensAtCurTime, ...
    maxActConcen, ...
    minActConcen, ...
    spatialDomainStep, ...
    howManySpatialStepsAreThere, ...
    rootWidth, ...
    0);  
  drawWhiteRectangleSimulatingGrowth( ...
    initialRootLength, ...
    tipVelocity, ...
    curTime, ...
    spatialDomainSize, ...
    rootWidth, ...
    0);

  inhConcensAtCurTime = inhConcenSolutionsFromPdepe(timeIdx, :);
  drawConcensAtFixedTime( ...
    inhConcensAtCurTime, ...
    maxInhConcen, ...
    minInhConcen, ...
    spatialDomainStep, ...
    howManySpatialStepsAreThere, ...
    rootWidth, ...
    rootWidth + gapBetweenRoots);
  drawWhiteRectangleSimulatingGrowth( ...
    initialRootLength, ...
    tipVelocity, ...
    curTime, ...
    spatialDomainSize, ...
    rootWidth, ...
    rootWidth + gapBetweenRoots);

  % Queue this frame so it can be played later
  movieFrames(frameIdx) = getframe(fig);
  frameIdx = frameIdx + 1;

  % Move on to the next frame.
  curTime = curTime + timeDomainStep;
end

movieSavePath = ...
  fullfile( ...
    fileparts(fileparts(mfilename('fullpath'))), ...
    strcat('movie-', datestr(datetime('now'), 'mm-dd-HH:MM:SS'), '.avi') ...
  );
fprintf('Saving the movie at %s \n', movieSavePath);
fprintf('Done! \n');
movie2avi(movieFrames, movieSavePath, ...
  'fps', 2);
