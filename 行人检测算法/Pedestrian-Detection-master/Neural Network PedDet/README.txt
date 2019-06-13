We've saved the trained model as proj_model.mat
You can run function Final_project with : Final_project(0,0) or Final_project(false,false)
The first parameter indicates whether we want to retrain the model, true means retrain the model, false means using the existing model.
Usually you should use false;

The second parameter indicates that whether we want to use the scaling algorithm to resize the image, false means use the original image with only fixed size window to scan the image(no resizing), true means use the scaling algorithm to scan the image at different scale(create different figures with different size of windows).

In Final_project.m file, you can specify the file name,
we provide img2.jpg and Capture.jpg here

The detections will be circled by the green rectangle
