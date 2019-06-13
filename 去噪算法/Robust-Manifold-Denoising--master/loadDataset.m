switch dataName
    case 'circle'
        [data4, data] = curves_with_angles(300);
        
         [data_noise, noise, temp_max_index] = addnoise(data, 0.4);    
        feats = data_noise;
    
    case  'square'
          [data]=square(200);
           [data_noise, noise, temp_max_index] = addnoise(data, 0.05);
           feats=data_noise;
    case 'hole'
        [data] = generate.Generate_Ground_Truth(dataName,1000);
        [data_noise, noise, temp_max_index] = generate.addnoise(data, 0.1);
        feats = data_noise;
    case 'fishbowl'
        [data] = generate.Generate_Ground_Truth(dataName,600);
        [data_noise, noise, temp_max_index] = generate.addnoise(data, 0.1);%0.1
        feats = data_noise;
        [feats]=double(outlier_generation(feats));
       case 'sphere_helix'
        [data]=generate.Generate_Ground_Truth(dataName);
        [data_noise, noise, temp_max_index] = generate.addnoise(data, 0.4);
        feats = data_noise;  
  
     case 'box_plane'
        box_plane;
        feats=data;
    case 'Hemisphere_plane'
        [data,data_clean]=Hemisphere_plane;
        feats=data;
       

 
    case 'planes'
    [feats,data]=pctest5 ();
   
case 'cyclo'
        load('test_cyclo.mat');
        data=X_iso;
        data=data(:,1:6000);
       var_noise=0.2;
       [data_noise,noise,temp_max_index] = generate.addnoise(data, var_noise);
       feats=data_noise;
   
end

