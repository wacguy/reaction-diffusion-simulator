% Inside this function, you can define the initial distribution of activators
% across the spatial domain.
%
% Think of it like this: "In the very beginning of the simulation, at a certain
% x, there is this much activator."
%
% The return value must be a constant number.
%
% Unit of x is micrometers.
% Unit of return value must be co (the imaginary unit of concentration).

function rtn = act_init(x)

  % 1 co everywhere in the beginning.
  rtn = 1; % co

end
