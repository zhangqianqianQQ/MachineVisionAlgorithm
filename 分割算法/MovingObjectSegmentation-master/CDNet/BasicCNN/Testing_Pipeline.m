method = 'manual';  % random, uniform, manual
frames = 200;       % 50 100 150 200 

regular_testing('baseline/highway', method, frames);
regular_testing('baseline/office', method, frames);
regular_testing('baseline/pedestrians', method, frames);
regular_testing('baseline/PETS2006', method, frames);

regular_testing('badWeather/blizzard', method, frames);
regular_testing('badWeather/skating', method, frames);
regular_testing('badWeather/snowFall', method, frames); 
regular_testing('badWeather/wetSnow', method, frames);


regular_testing('cameraJitter/badminton', method, frames);
regular_testing('cameraJitter/boulevard', method, frames);
regular_testing('cameraJitter/sidewalk', method, frames);
regular_testing('cameraJitter/traffic', method, frames);

regular_testing('dynamicBackground/boats', method, frames);
regular_testing('dynamicBackground/canoe', method, frames);
regular_testing('dynamicBackground/fall', method, frames);
regular_testing('dynamicBackground/fountain01', method, frames);
regular_testing('dynamicBackground/fountain02', method, frames);
regular_testing('dynamicBackground/overpass', method, frames);

regular_testing('intermittentObjectMotion/abandonedBox', method, frames);
regular_testing('intermittentObjectMotion/parking', method, frames);
regular_testing('intermittentObjectMotion/sofa', method, frames);
regular_testing('intermittentObjectMotion/streetLight', method, frames);
regular_testing('intermittentObjectMotion/tramstop', method, frames);
regular_testing('intermittentObjectMotion/winterDriveway', method, frames);

regular_testing('lowFramerate/port_0_17fps', method, frames);
regular_testing('lowFramerate/tramCrossroad_1fps', method, frames);
regular_testing('lowFramerate/tunnelExit_0_35fps', method, frames);
regular_testing('lowFramerate/turnpike_0_5fps', method, frames);

regular_testing('nightVideos/bridgeEntry', method, frames);
regular_testing('nightVideos/busyBoulvard', method, frames);
regular_testing('nightVideos/fluidHighway', method, frames);
regular_testing('nightVideos/streetCornerAtNight', method, frames);
regular_testing('nightVideos/tramStation', method, frames);
regular_testing('nightVideos/winterStreet', method, frames);

regular_testing('PTZ/continuousPan', method, frames);
regular_testing('PTZ/intermittentPan', method, frames);
regular_testing('PTZ/twoPositionPTZCam', method, frames);
regular_testing('PTZ/zoomInZoomOut', method, frames);

regular_testing('shadow/backdoor', method, frames);
regular_testing('shadow/bungalows', method, frames);
regular_testing('shadow/busStation', method, frames);
regular_testing('shadow/copyMachine', method, frames);
regular_testing('shadow/cubicle', method, frames);
regular_testing('shadow/peopleInShade', method, frames);

regular_testing('thermal/corridor', method, frames);
regular_testing('thermal/diningRoom', method, frames);
regular_testing('thermal/lakeSide', method, frames);
regular_testing('thermal/library', method, frames);
regular_testing('thermal/park', method, frames);

regular_testing('turbulence/turbulence0', method, frames);
regular_testing('turbulence/turbulence1', method, frames);
regular_testing('turbulence/turbulence2', method, frames);
regular_testing('turbulence/turbulence3', method, frames);
