-- ImageSlicer.lua - v2.0 (2015-05)
-- Copyright (c) 2015 Gerard Castro López
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

local UPPER_LEFT	= 1
local UPPER_CENTER	= 2
local UPPER_RIGHT	= 3
local MIDDLE_LEFT	= 4
local MIDDLE_CENTER	= 5
local MIDDLE_RIGHT	= 6
local LOWER_LEFT	= 7
local LOWER_CENTER	= 8
local LOWER_RIGHT	= 9

local sheetInfoDictionary = {}


function display.unloadSlicedImage(filename)
	local sheetInfo = sheetInfoDictionary[filename]

	if sheetInfo == nil then
		return
	end

	sheetInfo.sheet = nil
	sheetInfo = nil
end

function display.registerSlicedImage(filename, up, left, right, down)
	if sheetInfoDictionary[filename] ~= nil then
		return
	end

	local img = display.newImage(filename)
	local frames = {}

	-- upper left
	frames[UPPER_LEFT] =
	{
		width = left,
		height = up,
		x = 0,
		y = 0
	}

	-- upper center
	frames[UPPER_CENTER] =
	{
		width = (img.width - left - right),
		height = up,
		x = left,
		y = 0
	}

	-- upper right
	frames[UPPER_RIGHT] =
	{
		width = right,
		height = up,
		x = (img.width - left),
		y = 0
	}

	-- middle left
	frames[MIDDLE_LEFT] =
	{
		width = left,
		height = (img.height - up - down),
		x = 0,
		y = up
	}

	-- middle center
	frames[MIDDLE_CENTER] =
	{
		width = frames[UPPER_CENTER].width,
		height = frames[MIDDLE_LEFT].height,
		x = left,
		y = up
	}

	-- middle right
	frames[MIDDLE_RIGHT] =
	{
		width = right,
		height = frames[MIDDLE_LEFT].height,
		x = frames[UPPER_RIGHT].x,
		y = up
	}

	-- lower left
	frames[LOWER_LEFT] =
	{
		width = left,
		height = down,
		x = 0,
		y = img.height - down
	}

	-- lower center
	frames[LOWER_CENTER] =
	{
		width = frames[UPPER_CENTER].width,
		height = down,
		x = left,
		y = frames[LOWER_LEFT].y
	}

	-- lower right
	frames[LOWER_RIGHT] =
	{
		width = right,
		height = down,
		x = frames[UPPER_RIGHT].x,
		y = frames[LOWER_LEFT].y
	}

	local sheetInfo = {}
	sheetInfo.sheet = graphics.newImageSheet(filename, { frames = frames })
	sheetInfo.originalWidth, sheetInfo.originalHeight = img.width, img.height

	img:removeSelf()
	img = nil

	sheetInfoDictionary[filename] = sheetInfo
end

function display.newSlicedImage(filename, params)
	local sheetInfo = sheetInfoDictionary[filename]

	assert(sheetInfo, "You must call the function 'display.registerSlicedImage' to register the image '".. filename .."' before use it as an sliced image!")

	local instance = display.newGroup()
	instance.originalWidth = sheetInfo.originalWidth
	instance.originalHeight = sheetInfo.originalHeight

	instance:insert(display.newImage(sheetInfo.sheet, UPPER_LEFT))
	instance[UPPER_LEFT].anchorX, instance[UPPER_LEFT].anchorY = 1, 1

	instance:insert(display.newImage(sheetInfo.sheet, UPPER_CENTER))
	instance[UPPER_CENTER].anchorX, instance[UPPER_CENTER].anchorY = 0.5, 1
	
	instance:insert(display.newImage(sheetInfo.sheet, UPPER_RIGHT))
	instance[UPPER_RIGHT].anchorX, instance[UPPER_RIGHT].anchorY = 0, 1
	
	instance:insert(display.newImage(sheetInfo.sheet, MIDDLE_LEFT))
	instance[MIDDLE_LEFT].anchorX, instance[MIDDLE_LEFT].anchorY = 1, 0.5
	
	instance:insert(display.newImage(sheetInfo.sheet, MIDDLE_CENTER))
	instance[MIDDLE_CENTER].anchorX, instance[MIDDLE_CENTER].anchorY = 0.5, 0.5
	
	instance:insert(display.newImage(sheetInfo.sheet, MIDDLE_RIGHT))
	instance[MIDDLE_RIGHT].anchorX, instance[MIDDLE_RIGHT].anchorY = 0, 0.5
	
	instance:insert(display.newImage(sheetInfo.sheet, LOWER_LEFT))
	instance[LOWER_LEFT].anchorX, instance[LOWER_LEFT].anchorY = 1, 0
	
	instance:insert(display.newImage(sheetInfo.sheet, LOWER_CENTER))
	instance[LOWER_CENTER].anchorX, instance[LOWER_CENTER].anchorY = 0.5, 0
	
	instance:insert(display.newImage(sheetInfo.sheet, LOWER_RIGHT))
	instance[LOWER_RIGHT].anchorX, instance[LOWER_RIGHT].anchorY = 0, 0

	sheetInfo = nil

-- GETTER FUNCTIONS
	function instance.getMinWidth()
		return instance[UPPER_LEFT].width + instance[UPPER_RIGHT].width
	end

	function instance.getMinHeight()
		return instance[UPPER_LEFT].height + instance[LOWER_LEFT].height
	end

	function instance.getWidth()
		return instance.getMinWidth() + instance[UPPER_CENTER].width
	end

	function instance.getHeight()
		return instance.getMinHeight() + instance[MIDDLE_CENTER].width
	end

	function instance.getSize()
		return instance.getWidth(), instance.getHeight()
	end

-- SETTER FUNCTIONS
	function instance.setWidth(w)
		local minW = instance.getMinWidth()
		w = math.max(w, minW) - minW
		local _w = w *0.5

		instance[UPPER_LEFT].x = -_w
		instance[MIDDLE_LEFT].x = -_w
		instance[LOWER_LEFT].x = -_w
		instance[UPPER_RIGHT].x = _w
		instance[MIDDLE_RIGHT].x = _w
		instance[LOWER_RIGHT].x = _w

		instance[UPPER_CENTER].width = w
		instance[MIDDLE_CENTER].width = w
		instance[LOWER_CENTER].width = w
	end

	function instance.setHeight(h)
		local minH = instance.getMinHeight()
		h = math.max(h, minH) - minH
		local _h = h *0.5

		instance[UPPER_LEFT].y = -_h
		instance[UPPER_CENTER].y = -_h
		instance[UPPER_RIGHT].y = -_h
		instance[LOWER_LEFT].y = _h
		instance[LOWER_CENTER].y = _h
		instance[LOWER_RIGHT].y = _h

		instance[MIDDLE_LEFT].height = h
		instance[MIDDLE_CENTER].height = h
		instance[MIDDLE_RIGHT].height = h
	end

	function instance.setSize(w, h)
		instance.setWidth(w)
		instance.setHeight(h)
	end

	params = params or {}

	params.w = params.w or instance.originalWidth
	params.h = params.h or instance.originalHeight
	instance.setSize(params.w, params.h)

	instance.x, instance.y = params.x or 0, params.y or 0

	return instance
end