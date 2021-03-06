classdef FakeData < SurfAnalysis
    properties
        RotationRange(1,2) double
        NormalVecRange(1,2) double
        MeasNoiseRange(1,1) double
        FeedRate double = 2; % um/rev
        PlungeDepth double = 10; % um
        SpindleSpeed double = 1000; % rpm
        CuspWidth double
    end
    
    methods
        function obj = FakeData()
            dx = PlungeProcessing.FOV/PlungeProcessing.Pixels;            
            obj = obj@SurfAnalysis([], dx, 'um', 'um');
        end % constructor        

        % methods for Traces
        function obj = CreatePlungeTrace(obj)
            % anonymous function for circle formula
            % k = y offset |  h = x offset            
            y = @(r, x, h, k) -sqrt(r.^2 - (x - h).^2) + k;
            xLim = PlungeProcessing.FOV/2;
            x = linspace(-xLim, xLim, PlungeProcessing.Pixels); 
            hCirc = 0; % circle has no shift in the x direction
            kCirc = PlungeProcessing.R; % shift the circle center up to y = tool radius              
            zTrace = real(y(PlungeProcessing.R, x, hCirc, kCirc));
            % create flat spots on either side of plunge
            % this step also sets the DOC
            zTrace( zTrace >= (obj.PlungeDepth) ) = obj.PlungeDepth;
            % adjust y offset so that flats are at 0
            zTrace = zTrace - obj.PlungeDepth;
            obj.Trace = zTrace;
        end

        function obj = CreatePhaseMap(obj)
            mustBeNonempty(obj)
            obj.PhaseMap = repmat(obj.Trace, PlungeProcessing.Pixels, 1)';            
        end
        
        function obj = AddCusps(obj)
            mustBeNonempty(obj.Trace); 
            % anonymous function for circle formula
            % k = y offset |  h = x offset                    
            y = @(r, x, h, k) -sqrt(r.^2 - (x - h).^2) + k;
            % cusp width is one feed/rev
            xCusp = 0:obj.dx:obj.FeedRate;
            % cusp depth comes from the sag equation
            cuspDepth = (obj.FeedRate^2)/8/PlungeProcessing.R;   
            % the 'round' code makes the x position modulo with the SWLI resolution so
            % everything lines up better. 
            % source: http://phrogz.net/round-to-nearest-via-modulus-division
            hCirc = round((obj.FeedRate/2)/obj.dx)*obj.dx;
            % shift the circle center up to y = tool radius - cuspDepth           
            kCirc = PlungeProcessing.R - cuspDepth; 
            % create z array for the cusp
            zCusp = real(y(PlungeProcessing.R, xCusp, hCirc, kCirc));
            % replicate cusp to create surface equal to length of x input
            N = 2*ceil(obj.X(end)/xCusp(end));
            zCusp = repmat(zCusp(1:end-1), 1, N);
            % not sure what this step does
%             zCusp = zCusp + abs(mean(zCusp));
            % trim z array to length
            zCusp = zCusp(1:length(obj.X));
%             plot(obj.X(1:20), zCusp(1:20));
            obj.Trace = obj.Trace + zCusp;
            % shift to y = 0
            obj.Trace = obj.Trace - obj.Trace(1);            
        end % add cusps
        
        function obj = AddNoseWear(obj)
            mustBeNonempty(obj.Trace);            
        end % INCOMPLETE 
        
        function obj = AddEdgeWear(obj)
            mustBeNonempty(obj.Trace);             
        end % INCOMPLETE 
        
        % methods for PhaseMaps      
        function obj = AddNoise(obj)
            mustBeNonempty(obj.PhaseMap);            
            obj.PhaseMap = obj.PhaseMap ...
                         + normrnd(0, obj.MeasNoiseRange,...
                         [obj.Nrows, obj.Ncols]);
            
        end % add noise to the map             
        
        function obj = AddRotation(obj)
            rotTheta = boundedUniformDistr(obj.RotationRange, 1);
            % pad to rotate
            padDim = 1400;
            padSize = (padDim-PlungeProcessing.Pixels)/2;
            obj.PhaseMap = padarray(obj.PhaseMap, [padSize padSize], 'replicate', 'both');            
            % rotate
            obj.RotateSurf(rotTheta);
            % crop back to size
            cropInd = [padSize,...
                       padSize,...
                       PlungeProcessing.Pixels-1,...
                       PlungeProcessing.Pixels-1];
            obj.PhaseMap = imcrop(obj.PhaseMap, cropInd);
            % cropInd is a vector with form [XMIN YMIN WIDTH HEIGHT];                        
        end
        
        function obj = AddPlane(obj)
            vectorAngles = nan(1,3);
            for ii = 1:3
                vectorAngles(ii) = boundedUniformDistr(obj.NormalVecRange, 1);
            end
            % vector normal to the plane being added
            normalVector = makeNormalVector(vectorAngles(1), vectorAngles(2), vectorAngles(3));
            [~, ~, Z] = planeFromNormalVec(obj.XY{1}, obj.XY{2}, normalVector);
            obj.PhaseMap = obj.PhaseMap + Z; 
        end
    end
        
end

function vr = makeNormalVector(alpha, beta, gamma)
% rotate a vector using rotation matrices
% euler angles!
% can't rotate about Z first, because the vector is normal to Z!
v = [0 0 1];
% 1: rotate about X (pitch)
% 2: rotate about Y (roll)
% 3. rotate about z (yaw)

sv = size(v);
if sv(1) == 1
    v = v';
end
% this function assumes the input vector originates at [0, 0, 0]

Rx = @(alpha) [1   0              0          ;
               0   cosd(alpha)   -sind(alpha) ;
               0   sind(alpha)    cosd(alpha)];
           
Ry = @(beta) [cosd(beta)    0   -sind(beta) ;
               0            1    0          ;
              sind(beta)    0    cosd(beta)];
           
Rz = @(gamma) [cosd(gamma)   -sind(gamma)   0 ;
               sind(gamma)    cosd(gamma)   0 ;
               0             0              1];

vr = Rz(gamma)*Ry(beta)*Rx(alpha)*v;
end

function [X, Y, Z] = planeFromNormalVec(x, y, normalVector)

[X, Y] = meshgrid(x, y);

planeFun = @(x, y, a, b, c) (-a/c).*x + (-b/c).*y;

Z = planeFun(X, Y, normalVector(1), normalVector(2), normalVector(3));

end

function val = boundedUniformDistr(limits, N)
% limits = [ min, max ]
val = limits(1) + (limits(2) - limits(1)).*rand(N);
end