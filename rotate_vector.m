function vr = rotate_vector(alpha, beta, gamma)
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

%% plot vectors
% close all
% fig_h = figure;
% %% plot original vector
% plot3([0 v(1)], [0 v(2)], [0 v(3)],...
%     'LineWidth', 2,...
%     'Color', [237,177,32]./255);
% hold on
% plot3(v(1), v(2), v(3),...
%      'Marker', 'o',...
%      'MarkerSize', 8,...
%      'MarkerEdgeColor', [0,114,189]./255,...
%      'MarkerFaceColor', [0,114,189]./255);
% grid on
% 
% %% plot rotated vector
% plot3([0 vr(1)], [0 vr(2)], [0 vr(3)],...
%     'LineWidth', 2,...
%     'Color', [237,177,32]./255);
% hold on
% plot3(vr(1), vr(2), vr(3),...
%      'Marker', '*',...
%      'MarkerSize', 8,...
%      'MarkerEdgeColor', [0,114,189]./255,...
%      'MarkerFaceColor', [0,114,189]./255);
% grid on
% 
% axis([-1 1 -1 1 -1 1]);
% xlabel('x axis');
% ylabel('y axis');
% zlabel('z axis');
% 
% try creating plane
% xy = linspace(-1, 1, 1024);
% % z  = linspace(-1, 1, 1024);
% [X, Y] = meshgrid(xy, xy);
% % z = zeros(1024);
% % plane = x.*v_rot(2) + y.*v_rot(1) + z.*v_rot(3);
% % z = (-v_rot(1)/v_rot(3)).*x + (-v_rot(2)/v_rot(3)).*y;
% z = @(x, y, a, b, c) (-a/c).*x + (-b/c).*y;
% % plane = x.*v_rot(1) + y.*v_rot(2) + z.*v_rot(3);
% zp = z(X, Y, vr(1), vr(2), vr(3));
% hold on
% surf(X, Y, zp, 'LineStyle', 'none');
% 
% % check orthogonality
% zi = zp(X == X(500, 500) & Y == Y(500,500));
% isnorm = sum(vr'.*[X(500,500) Y(500,500) zi])
end

