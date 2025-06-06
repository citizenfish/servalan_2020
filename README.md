# Servalan GPX Route Editor

I've been tinkering around with maps and routes for years and thought it was high time I had a go at writing my own route creation package.

This is an experiment in QtQuick/QML to see what is possible. This is by no means a production ready package, simply a few tinkerings. I am using it to discover what can/cannot be done in QtQuick. There will be some real programming crimes and anti-patterns within as I'm really an SQL kind of chap.

## Servalan

If you don't know who Servalan was then you are too young for this project (or not every good at searching). This project is dedicated to the memory of Jaqueline Pearce

## Code structure

The majority of functionality is provided in QML. Start with mainAppWindow.qml and find your way around from there. The project uses a model written in C++ to interface with GPX files and provide a data store for the GPX line and marker points. The structure is relatively straightforward:-

### C++
- main.cpp is (of course) the entry point. It simply registers C++ types with QML and starts the QML engine
- gpxmode.cpp is a model used by QML to hold and display a GPX file. It's a bit of a hack TBH as it has multiple data structures and implements a lot of invokable methods for what should be standard model functions. But this is necessary to make the UI performant as a track with 10,000 points will perform horribly with 10,000 drag handles.
- gisfunctions.cpp holds a series of utility functions for processing poistional data, mainly distance and bearings NOTE WELL you will need to create your own SRTM file and change the path to it in gpxModel.h. I'll sort this out in a future version

### QML
- mainAppWindow.qml is the container for the user interface
- MapView.qml holds the map elements
  - GPXLine.qml creates and manages events for the line drawn on the map
  - GPXDragMarker.qml implements a map marker used for editing the line
  - MapChooserWindow.qml is a pop up window for choosing the map type. Sadly QML does not allow us to flip between types without killing the map
  - MapViewProfileWindow.qml shows a height profile for the GPX file imported
- MapAppWindowFooterBar.qml is our on screen footer
- MapAppWindowMenuBar.qml is the menuing system
- MapAppWindowSideMar.qml is a popout side bar for configuration controls
- MapChooserWindow.qml is a blocking window forcing user to choose map type on application entry

### Javascript

- storageFunctions.js holds code linked to storing data and handling undo/redo
- mapFunctions.js code for map user interface and location operations

## Building Servalan

You need to install Qt 5.14 and then clone the repository to a local directory. You should be able to open the project in QtCreator and run it without any changes. To date I have only tested Servalan on OSX and would welcome any help building and checking on Windows

## Stability

This is NOT a stable release. It is primarily a learning exercise as I work out how to do various bits and pieces. But please feel free to raise any issues or chuck up any ideas for development.
