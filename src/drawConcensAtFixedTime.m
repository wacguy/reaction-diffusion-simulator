% Paints each spatial step across the root with a color between blue and yellow
% representing how high the concentration there is compared to
% `maxConcenAcrossTheRoot` and `minConcenAcrossTheRoot`.
% Yellow means highest, and blue means lowest.
% Recall that every spatial step is best described by a rectangle taking up a
% height defined by `howHighIsEachStep`.
function drawConcensAtFixedTime( ...
  concensAtEachStepFromBottomOfRootToTop, ...
  maxConcenAcrossTheRoot, ...
  minConcenAcrossTheRoot, ...
  howHighIsEachStep, ...
  howManySpatialStepsAreThereAcrossTheRoot, ...
  rootWidth, ...
  rootLowerLeftOffsetFromLowerLeftOfFigure)

for posIdxFromBottom = 1:howManySpatialStepsAreThereAcrossTheRoot
  % We want the first iteration to appear at the top of the figure.
  concen = concensAtEachStepFromBottomOfRootToTop( ...
    howManySpatialStepsAreThereAcrossTheRoot - posIdxFromBottom + 1);

  howFarFromBlueTowardYellow = ...
    (concen - minConcenAcrossTheRoot) / ...
      (maxConcenAcrossTheRoot - minConcenAcrossTheRoot);

  rectLowerLeftX = rootLowerLeftOffsetFromLowerLeftOfFigure;
  rectLowerLeftY = (posIdxFromBottom - 1) * howHighIsEachStep;
  rectangle( ...
    'Position', [rectLowerLeftX rectLowerLeftY ...
      rootWidth howHighIsEachStep], ...
    'EdgeColor', gradientFromBlueToYellow(howFarFromBlueTowardYellow), ...
    'FaceColor', gradientFromBlueToYellow(howFarFromBlueTowardYellow));
end
