require "ImageSlicer"

display.registerSlicedImage("square.png", 50, 50, 50, 50)
local slicedImage = display.newSlicedImage("square.png", { w = 200, h = 150, x = display.contentCenterX, y = display.contentCenterY })
display.unloadSlicedImage("square.png")