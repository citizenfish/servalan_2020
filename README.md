# Servalan GPX Route Editor

I've been tinkering around with maps and routes for years and thought it was high time I had a go at writing my own route creation package.

This is an experiment in QtQuick/QML to see what is possible. This is by no means a production ready package, simply a few tinkerings

## Servalan

If you don't know who Servalan was then you are too young for this project (or not every good at searching). This project is dedicated to the memory of Jaqueline Pearce

## Code structure

The majority of functionality is provided in QML. Start with mainAppWindow.qml and find your way around from there. The project uses a model written in C++ to interface with GPX files and provide a data store for the GPX line and marker points.
