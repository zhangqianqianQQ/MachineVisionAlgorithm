method = 'manual';
num_frames = 200;

training('baseline/highway',method, num_frames);
training('baseline/office',method, num_frames);
training('baseline/pedestrians',method, num_frames);
training('baseline/PETS2006',method, num_frames);

training('badWeather/blizzard',method, num_frames);
training('badWeather/skating',method, num_frames);
training('badWeather/snowFall',method, num_frames); 
training('badWeather/wetSnow',method, num_frames);

training('cameraJitter/badminton',method, num_frames);
training('cameraJitter/boulevard',method, num_frames);
training('cameraJitter/sidewalk',method, num_frames);
training('cameraJitter/traffic',method, num_frames);

training('dynamicBackground/boats',method, num_frames);
training('dynamicBackground/canoe',method, num_frames);
training('dynamicBackground/fall',method, num_frames);
training('dynamicBackground/fountain01',method, num_frames);
training('dynamicBackground/fountain02',method, num_frames);
training('dynamicBackground/overpass',method, num_frames);

training('intermittentObjectMotion/abandonedBox',method, num_frames);
training('intermittentObjectMotion/parking',method, num_frames);
training('intermittentObjectMotion/sofa',method, num_frames);
training('intermittentObjectMotion/streetLight',method, num_frames);
training('intermittentObjectMotion/tramstop',method, num_frames);
training('intermittentObjectMotion/winterDriveway',method, num_frames);

training('lowFramerate/port_0_17fps',method, num_frames);
training('lowFramerate/tramCrossroad_1fps',method, num_frames);
training('lowFramerate/tunnelExit_0_35fps',method, num_frames);
training('lowFramerate/turnpike_0_5fps',method, num_frames);

training('nightVideos/bridgeEntry',method, num_frames);
training('nightVideos/busyBoulvard',method, num_frames);
training('nightVideos/fluidHighway',method, num_frames);
training('nightVideos/streetCornerAtNight',method, num_frames);
training('nightVideos/tramStation',method, num_frames);
training('nightVideos/winterStreet',method, num_frames);

training('PTZ/continuousPan',method, num_frames);
training('PTZ/intermittentPan',method, num_frames);
training('PTZ/twoPositionPTZCam',method, num_frames);
training('PTZ/zoomInZoomOut',method, num_frames);

training('shadow/backdoor',method, num_frames);
training('shadow/bungalows',method, num_frames);
training('shadow/busStation',method, num_frames);
training('shadow/copyMachine',method, num_frames);
training('shadow/cubicle',method, num_frames);
training('shadow/peopleInShade',method, num_frames);

training('thermal/corridor',method, num_frames);
training('thermal/diningRoom',method, num_frames);
training('thermal/lakeSide',method, num_frames);
training('thermal/library',method, num_frames);
training('thermal/park',method, num_frames);

training('turbulence/turbulence0',method, num_frames);
training('turbulence/turbulence1',method, num_frames);
training('turbulence/turbulence2',method, num_frames);
training('turbulence/turbulence3',method, num_frames);
