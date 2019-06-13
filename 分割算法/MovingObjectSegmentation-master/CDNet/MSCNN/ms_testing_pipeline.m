method = 'manual';  % random, uniform, manual
frames = 200;       % 50 100 150 200 

ms_regular_testing('baseline/highway', method, frames);
ms_regular_testing('baseline/office', method, frames);
ms_regular_testing('baseline/pedestrians', method, frames);
ms_regular_testing('baseline/PETS2006', method, frames);

ms_regular_testing('badWeather/blizzard', method, frames);
ms_regular_testing('badWeather/skating', method, frames);
ms_regular_testing('badWeather/snowFall', method, frames); 
ms_regular_testing('badWeather/wetSnow', method, frames);


ms_regular_testing('cameraJitter/badminton', method, frames);
ms_regular_testing('cameraJitter/boulevard', method, frames);
ms_regular_testing('cameraJitter/sidewalk', method, frames);
ms_regular_testing('cameraJitter/traffic', method, frames);

ms_regular_testing('dynamicBackground/boats', method, frames);
ms_regular_testing('dynamicBackground/canoe', method, frames);
ms_regular_testing('dynamicBackground/fall', method, frames);
ms_regular_testing('dynamicBackground/fountain01', method, frames);
ms_regular_testing('dynamicBackground/fountain02', method, frames);
ms_regular_testing('dynamicBackground/overpass', method, frames);
% 
ms_regular_testing('intermittentObjectMotion/abandonedBox', method, frames);
ms_regular_testing('intermittentObjectMotion/parking', method, frames);
ms_regular_testing('intermittentObjectMotion/sofa', method, frames);
ms_regular_testing('intermittentObjectMotion/streetLight', method, frames);
ms_regular_testing('intermittentObjectMotion/tramstop', method, frames);
ms_regular_testing('intermittentObjectMotion/winterDriveway', method, frames);

ms_regular_testing('lowFramerate/port_0_17fps', method, frames);
ms_regular_testing('lowFramerate/tramCrossroad_1fps', method, frames);
ms_regular_testing('lowFramerate/tunnelExit_0_35fps', method, frames);
ms_regular_testing('lowFramerate/turnpike_0_5fps', method, frames);

ms_regular_testing('nightVideos/bridgeEntry', method, frames);
ms_regular_testing('nightVideos/busyBoulvard', method, frames);
ms_regular_testing('nightVideos/fluidHighway', method, frames);
ms_regular_testing('nightVideos/streetCornerAtNight', method, frames);
ms_regular_testing('nightVideos/tramStation', method, frames);
ms_regular_testing('nightVideos/winterStreet', method, frames);

ms_regular_testing('PTZ/continuousPan', method, frames);
ms_regular_testing('PTZ/intermittentPan', method, frames);
ms_regular_testing('PTZ/twoPositionPTZCam', method, frames);
ms_regular_testing('PTZ/zoomInZoomOut', method, frames);

ms_regular_testing('shadow/backdoor', method, frames);
ms_regular_testing('shadow/bungalows', method, frames);
ms_regular_testing('shadow/busStation', method, frames);
ms_regular_testing('shadow/copyMachine', method, frames);
ms_regular_testing('shadow/cubicle', method, frames);
ms_regular_testing('shadow/peopleInShade', method, frames);

ms_regular_testing('thermal/corridor', method, frames);
ms_regular_testing('thermal/diningRoom', method, frames);
ms_regular_testing('thermal/lakeSide', method, frames);
ms_regular_testing('thermal/library', method, frames);
ms_regular_testing('thermal/park', method, frames);

ms_regular_testing('turbulence/turbulence0', method, frames);
ms_regular_testing('turbulence/turbulence1', method, frames);
ms_regular_testing('turbulence/turbulence2', method, frames);
ms_regular_testing('turbulence/turbulence3', method, frames);
