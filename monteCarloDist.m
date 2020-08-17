clear all

N = 100;
tic
% create the fake data object
for ii = 1:N
fakeData(ii) = FakeData(); %#ok<*SAGROW>

fakeData(ii).RotationRange = [-1., 1.];
fakeData(ii).NormalVecRange = [0, 0];
fakeData(ii).MeasNoiseRange = .001;

% operations on plunge trace
% create a plunge trace
fakeData(ii).CreatePlungeTrace();
% add cusps to plunge trace
% fakeData(ii).AddCusps();
% turn trace into phasemap
fakeData(ii).CreatePhaseMap();

% SHOULD ALSO SHIFT IT SOME RANDOM VALUE LEFT OR RIGHT

% operations on phasemap
% add rotation
fakeData(ii).AddRotation();
% add plane
% fakeData(ii).AddPlane();
% add noise
% fakeData(ii).AddNoise();
% add names
fakeData(ii).Name = 'Fake Data';
end
% fakeData.Plot();

processedData = PlungeProcessing(fakeData);
processedData.ResidCalcType = 'subtractPlungeZero';
processedData.UserSelect = 0;
processedData.TrimH = 7;
processedData.TrimZo = -2;
plungeFitOrder = 4;

%% process fake data
% change z scale from meters to um
processedData.ProcessPlunges();

meanResid = SurfAnalysis();
meanResid.Xscale = 'um';
meanResid.Zscale = 'nm';
meanResid.dx = processedData.dxInterp;
meanResid.Name = 'Average of N Residuals';

stdResid = SurfAnalysis();
stdResid.Xscale = 'um';
stdResid.Zscale = 'nm';
stdResid.dx = processedData.dxInterp;
stdResid.Name = 'Average of N Residuals';

%% calculate uncertainty
% outer loop moves along x axis
% inner loop moves from plunge to plunge
for jj = 1:length(processedData.ResidualData(2).X)
    for ii = 2:processedData.Nplunges
        % store value of each residual at x(jj)
        z(ii) = processedData.ResidualData(ii).Trace(jj);
    end
    meanResid.Trace(jj) = mean(z).*10^6;
    stdResid.Trace(jj)  = std(z).*10^6;
end

processedData.PlotResiduals();

figure
meanResid.Plot();
hold on
meanResid.Offset(stdResid.Trace);
meanResid.Plot();
meanResid.Offset(-2*stdResid.Trace);
meanResid.Plot();

legend('mean', 'std1', 'std2');
% plot(stdResid.*10^6)
% hold on
% plot(meanResid.*10^6)
% uncertaintyDistr = surfAnalysis
toc

