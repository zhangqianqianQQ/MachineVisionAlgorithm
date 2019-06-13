function [data,sphere_normal]=Generate_Ground_Truth(data_type,nPoints)
%%%Generate Ground Truth Function
%%%% Data types: Shpere: 'sphere'====
%%====Circle:'circle'===Sinus : 'sin_wavelet'==Swiss_Roll =='Swiss_Roll';
%%====Helix: 'helix '===Swiss with hole: 'Swiss_with_hole'====
%%=== Sinus in high dimension: 'sin_wavelet_high_dim'==Fishbowl:'fishbowl'
%%===elipse 'elipse'===
% data_type = 'sphere';
switch data_type
    case 'eight_fig'
        [data] = eight_fig(nPoints);
    case  'sphere'
        [data] = sphere(nPoints);
    case 'circle'
        [data, normal]=circle(nPoints,1);
    case 'sin_wavelet'
        type_d=4;dim=2;
        [data,data_noise,labels] = md_create_points(type_d, nPoints, dim);
    case 'Swiss_Roll'
        dataparams=struct('n',nPoints,'dataset',-1','noise',0,'state',0);
        r=create_synthetic_dataset(dataparams);
        %data=rescale_center(r.x);
        data=4*data;
    case 'hole'
        dataparams=struct('n',nPoints,'dataset',5','noise',0,'state',0);
        r=create_synthetic_dataset(dataparams);
         data=(r.x);
    case 'sin_wavelet_high_dim'
        dim=200;
         type_d=4;
        [data,data_noise,labels] = md_create_points(type_d, nPoints, dim);
    case 'helix'
        [data]=helix(nPoints);
    case 'Swiss_with_hole'
        dataparams=struct('n',nPoints,'dataset',0','noise',0,'state',0);
        r=create_synthetic_dataset(dataparams);
        data=rescale_center(r.x);
        data=4*data;
    case 'fishbowl'
        dataparams=struct('n',nPoints,'dataset',7','noise',0,'state',7);
        r=create_synthetic_dataset(dataparams);
        data=r.x;
       % data=rescale_center(r.x);
        %data=x;
         %data=4*data;
    case 'intersecting_mobius'
       % [data]=intersecting_mobius(nPoints);
        [data] = generate.mobius_rotate(nPoints);
    case 'elipse'
        [data,r,curvature]=elipse(nPoints);
    case 'square'
        [data]=square(nPoints);
    case 'cube'
        [plane2, data] = cube(nPoints);
    case 'Heavy_sine'
        [data]=Heavy_sine(nPoints);
    case 'intersecting_spheres'
        [data,sphere_normal]=intersecting_spheres(nPoints);
    case 'intersecting_mobius'
        [data]=intersecting_mobius(nPoints);
       case 'sphere_helix'
        data=generate.sphere_helix(); 
    case 'intersecting_planes'
        [data3, data] = intersecting_planes(nPoints);
end


