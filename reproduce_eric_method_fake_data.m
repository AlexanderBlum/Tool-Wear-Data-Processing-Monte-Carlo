clear all
l_fit = 270000;
r_fit = 300000;

x = linspace(-210,210,420000);

[x, z] = unworn_fake_plunge_1d(x, 500, 10);

dx = x(2) - x(1);

shift = [100 200 300 400 500 600 700 800 900 1000];

z_shift = nan(length(shift), length(x));
res = nan(length(shift), length(x));
fitlines = nan(length(shift), 2);
for ii = 1:length(shift)
    z_shift(ii,:) = circshift(z, shift(ii));
    res(ii, :) = z - z_shift(ii, :);
    fitlines(ii,:) = polyfit(x(l_fit:r_fit), res(ii, l_fit:r_fit), 1);
    slopes(ii) = fitlines(ii, 1);
    slopefit(ii) = atand(slopes(ii))/shift(ii);
    shift_calc(ii) = round(atand(slopes(ii))/slopefit(ii));
end


