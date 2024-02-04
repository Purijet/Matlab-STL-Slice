clear; close all; clc;
sliceSTL(15);

% AN 82 LINE 3D SLICE STL CODE BY PEI-HSU CHUNG (FEB 2024)
function sliceSTL(layer)
% READ STL FILE
figure
gm = stlread('Sphere.stl'); 
model = createpde();
geometryFromMesh(model,gm.Points',gm.ConnectivityList')
pdegplot(model,"FaceLabels","on","FaceAlpha",0.5)
title('Imported STL')
% ADJUST COORDINATE AND FIND THE HEIGHT OF GEOMETRY
Points = []; Points(:,end+1) = gm.Points(:,3);  Points(:,end+1) = gm.Points(:,1); Points(:,end+1) = gm.Points(:,2);
upper = ceil(max(Points(:,3)));
below = floor(min(Points(:,3)));
% PLOT THE SURFACE FACETS
figure
trimesh(gm.ConnectivityList', Points(:,1)', Points(:,2)', Points(:,3)')
title('Triangular Facets')
xlabel('x')
ylabel('y')
zlabel('z')
axis equal
% CALCULATE THE INTERSECTING POINTS OF FACETS AND SLICING PLANES
Vert = []; Count = [];
for i = below:(upper-below)/layer:upper
    fprintf('The height of layer = %5.4f\n',i);
    for j = 1:length(gm.ConnectivityList)
        vertid1 = gm.ConnectivityList(j,1); vertid2 = gm.ConnectivityList(j,2); vertid3 = gm.ConnectivityList(j,3);
        vertz1 = Points(vertid1,3); vertz2 = Points(vertid2,3); vertz3 = Points(vertid3,3);
        if ((vertz1 > i) && (vertz2 > i) && (vertz3 > i)) || ((vertz1 < i) && (vertz2 < i) && (vertz3 < i))
            continue;
        elseif (vertz1-i)*(vertz2-i) > 0 && (vertz2-i)*(vertz3-i) < 0 && (vertz1-i)*(vertz3-i) < 0
            point1x = (i-Points(vertid3,3))*(Points(vertid2,1)-Points(vertid3,1))/(Points(vertid2,3)-Points(vertid3,3))-Points(vertid3,1);
            point1y = (i-Points(vertid3,3))*(Points(vertid2,2)-Points(vertid3,2))/(Points(vertid2,3)-Points(vertid3,3))-Points(vertid3,2);
            point2x = (i-Points(vertid3,3))*(Points(vertid1,1)-Points(vertid3,1))/(Points(vertid1,3)-Points(vertid3,3))-Points(vertid3,1);
            point2y = (i-Points(vertid3,3))*(Points(vertid1,2)-Points(vertid3,2))/(Points(vertid1,3)-Points(vertid3,3))-Points(vertid3,2);
            Vert(end+1,:) = [point1x point1y i]; Vert(end+1,:) = [point2x point2y i];
        elseif (vertz1-i)*(vertz2-i) < 0 && (vertz2-i)*(vertz3-i) > 0 && (vertz1-i)*(vertz3-i) < 0
            point1x = (i-Points(vertid2,3))*(Points(vertid1,1)-Points(vertid2,1))/(Points(vertid1,3)-Points(vertid2,3))-Points(vertid2,1);
            point1y = (i-Points(vertid2,3))*(Points(vertid1,2)-Points(vertid2,2))/(Points(vertid1,3)-Points(vertid2,3))-Points(vertid2,2);
            point2x = (i-Points(vertid3,3))*(Points(vertid1,1)-Points(vertid3,1))/(Points(vertid1,3)-Points(vertid3,3))-Points(vertid3,1);
            point2y = (i-Points(vertid3,3))*(Points(vertid1,2)-Points(vertid3,2))/(Points(vertid1,3)-Points(vertid3,3))-Points(vertid3,2);
            Vert(end+1,:) = [point1x point1y i]; Vert(end+1,:) = [point2x point2y i];
        elseif (vertz1-i)*(vertz2-i) < 0 && (vertz2-i)*(vertz3-i) < 0 && (vertz1-i)*(vertz3-i) > 0
            point1x = (i-Points(vertid2,3))*(Points(vertid1,1)-Points(vertid2,1))/(Points(vertid1,3)-Points(vertid2,3))-Points(vertid2,1);
            point1y = (i-Points(vertid2,3))*(Points(vertid1,2)-Points(vertid2,2))/(Points(vertid1,3)-Points(vertid2,3))-Points(vertid2,2);
            point2x = (i-Points(vertid3,3))*(Points(vertid2,1)-Points(vertid3,1))/(Points(vertid2,3)-Points(vertid3,3))-Points(vertid3,1);
            point2y = (i-Points(vertid3,3))*(Points(vertid2,2)-Points(vertid3,2))/(Points(vertid2,3)-Points(vertid3,3))-Points(vertid3,2);
            Vert(end+1,:) = [point1x point1y i]; Vert(end+1,:) = [point2x point2y i];
        end
    end
end
% COUNT THE INTERSECTING POINTS IN EACH LAYER
for i = below:(upper-below)/layer:upper
    Count(end+1) = sum(Vert(:,3) == i);
end
% PLOT THE INTERSECTING POINTS OF FACETS AND SLICING PLANES
figure
count = 1;
for i = 1:length(Count)
    scatter3(Vert(count:count + Count(i)-1,1),Vert(count:count + Count(i)-1,2),Vert(count:count + Count(i)-1,3),'.')
    count = count + Count(i);
    hold on
end
title('Intersecting Points')
xlabel('x')
ylabel('y')
zlabel('z')
axis equal; view([30,30]);
% PLOT THE SLICING CONTOURS
figure
count = 1;
for i = 1:length(Count)
    fill3(Vert(count:count + Count(i)-1,1),Vert(count:count + Count(i)-1,2),Vert(count:count + Count(i)-1,3), i/length(Count))
    count = count + Count(i);
    hold on
end
title('Slicing Contours')
xlabel('x')
ylabel('y')
zlabel('z')
axis equal; view([30,30]);
end