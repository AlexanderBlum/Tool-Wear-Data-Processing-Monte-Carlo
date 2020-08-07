function z = add_cusps(x, z, fr, tr, S)

% Oct 2 2019
% Alex Blum
%
% Simulates the addition of tool marks to a surface
% 
%   x   : array of x position [   um   ]
%   z   : array of z position [   um   ]
%   fr  : tool feed rate      [ mm/min ]
%   tr  : tool radius         [   um   ]
%   S   : spindle speed       [  rpm   ]

res = 420/1024;
% cusp width is feed per rev, the 1000 converts to micrometers
w = 1000*fr/S;   % cusp width [ um/rev ]
% x array for one cusp
% xcusp = linspace(0, w, floor(w/res));
xcusp = 0:res:w;
% cusp depth comes from the sag equation
h = (w^2)/8/tr;

% anonymous function for circle formula
% k = y offset |  h = x offset
y = @(r, x, h, k) -sqrt(r.^2 - (x - h).^2) + k;

% create one cusp
% the 'round' code makes the x position modulo with the SWLI resolution so
% everything lines up better. 
% source: http://phrogz.net/round-to-nearest-via-modulus-division
h_circ = round((w/2)/res)*res; 
k_circ = tr - h; % shift the circle center up to y = tool radius - h
zcusp = real(y(tr, xcusp, h_circ, k_circ)) ;

% replicate cusp to create surface equal to length of x input
% N = ceil(length(x)/length(xcusp));
N = 2*ceil(x(end)/xcusp(end));

zcusp = repmat(zcusp(1:end-1), 1, N);
zcusp = zcusp + abs(mean(zcusp));
zcusp = zcusp(1:length(x));
plot(x, zcusp);

z = z + zcusp;
end

