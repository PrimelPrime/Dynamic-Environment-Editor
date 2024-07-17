local worldProperties = {
	{key = "SpriteSize", values = {1.0}, step = 0.5},
	{key = "SpriteBrightness", values = {1.0}, step = 0.5},
	{key = "PoleShadowStrength", values = {50}, step = 10},
	{key = "ShadowStrength", values = {100}, step = 10},
	{key = "ShadowsOffset", values = {0.06}, step = 0.01},
	{key = "LightsOnGround", values = {1.0}, step = 0.5},
	-- {key = "TrafficLightsBrightness", values = {1.0}, step = 0.1},
	{key = "Illumination", values = {0.0}, step = 0.1},
	{key = "AmbientColor", values = {1, 1, 1}, step = 1},
	{key = "AmbientObjColor", values = {1, 1, 1}, step = 1},
	{key = "DirectionalColor", values = {255, 255, 255}, step = 1},
	{key = "LowCloudsColor", values = {120, 40, 40}, step = 1},
	{key = "BottomCloudsColor", values = {159, 142, 106}, step = 1},
	{key = "CloudsAlpha", values = {1}, step = 10},
	-- {key = "CloudsAlpha2", values = {1}, step = 1},
	-- {key = "CloudsAlpha3", values = {1}, step = 1},

	{key = "WetRoads", values = {0.0}, step = 0.1},
	{key = "Foggyness", values = {0.0}, step = 0.1},
	{key = "Fog", values = {0.0}, step = 0.1},
	{key = "RainFog", values = {0.0}, step = 0.1},
	{key = "WaterFog", values = {0.0}, step = 0.1},
	{key = "Sandstorm", values = {0.0}, step = 0.1},
	-- {key = "ExtraSunnyness", values = {0.0}, step = 0.1},
	-- {key = "CloudCoverage", values = {0.0}, step = 0.1},
	{key = "Rainbow", values = {0.0}, step = 0.1},
}

local worldPropInfo = {}
local guiFields = {}
for _, data in ipairs(worldProperties) do
	worldPropInfo[data.key] = {}
	for key, value in pairs(data) do
		if key ~= "key" then
			worldPropInfo[data.key][key] = value
		end
	end
end

local freezePropUpdate = true
function onWorldPropertyChanged()
	if freezePropUpdate then return end
	local args = {}
	local key = getElementData(source, "key", false)
	for eIdx, element in ipairs(guiFields[key]) do
		args[eIdx] = tonumber(guiGetText(element)) or 0
	end
	setWorldProperty(key, unpack(args))
end

function onWorldPropertyQuickClick()
	local key, dir = unpack(getElementData(source, "data", false))
	local step = worldPropInfo[key].step or 1
	freezePropUpdate = true
	for eIdx, element in ipairs(guiFields[key]) do
		guiSetText(element, (tonumber(guiGetText(element)) or 0) + step*dir)
	end
	freezePropUpdate = false
	triggerEvent("onClientGUIChanged", guiFields[key][1])
end

function onWorldPropertyResetClick()
	local key = getElementData(source, "data", false)
	resetWorldProperty(key)
	setTimer(function()
		freezePropUpdate = true
		local values = {getWorldProperty(key)}
		for eIdx, element in ipairs(guiFields[key]) do
			guiSetText(element, values[eIdx] or "")
		end
		freezePropUpdate = false
	end, 50, 1)
end

function saveWorldProperty(key)
	local values = {getWorldProperty(key)}
	for eIdx, element in ipairs(guiFields[key]) do
		guiSetText(element, values[eIdx] or "")
	end
end

function onUpdateAllPropertiesClick()
	updateColorFilter()
	updateSkyGradient()
	updateWaterColor()
	updateWeather()
	updateTime()
	updateMoonsize()
	updateSunsize()
	updateFogDistance()
	updateFarClipDistance()
	updateNearClipDistance()
	updateRainLevel()
	updateGrainLevel()
	updateHeatHaze()
	updateWindVelocity()
	updateSunColor()
	freezePropUpdate = true
	for key, data in pairs(guiFields) do
		local values = {getWorldProperty(key)}
		for eIdx, element in ipairs(data) do
			guiSetText(element, values[eIdx] or "")
		end
	end
	freezePropUpdate = false
end

function onResetAllPropertiesClick()
	resetColorFilterHandler()
	resetSkyGradientHandler()
	resetWaterColorHandler()
	resetWeatherHandler()
	resetTimeHandler()
	resetMoonSize()
	resetSunSize()
	resetFogDistance()
	resetFarClipDistance()
	resetNearClipDistance()
	resetRainLevel()
	resetGrainLevel()
	resetHeatHazeHandler()
	resetWindVelocityHandler()
	resetSunColorHandler()
	for key in pairs(guiFields) do
		resetWorldProperty(key)
	end
	setTimer(onUpdateAllPropertiesClick, 50, 1)
end

local HeatHazeInputs, HeatHazeSliders = {}, {}
local heatHaze = {}

function updateHeatHaze()
    local inputs = {"Intensity", "Random Shift", "SpeedMin", "SpeedMax", "ScanSizeX", "ScanSizeY", "RenderSizeX", "RenderSizeY"}
    local values = {}
    for _, input in ipairs(inputs) do
        table.insert(values, tonumber(guiGetText(HeatHazeInputs[input])) or 0)
    end
    local bShowInside = false
    setHeatHaze(values[1], values[2], values[3], values[4], values[5], values[6], values[7], values[8], bShowInside)
end

local function getHeatHazeCall()
    heatHaze = {getHeatHaze()}
	for i, label in ipairs({"Intensity", "Random Shift", "SpeedMin", "SpeedMax", "ScanSizeX", "ScanSizeY", "RenderSizeX", "RenderSizeY"}) do
		local value = heatHaze[i]
		guiSetText(HeatHazeInputs[label], tostring(value))
		local scrollPos = math.ceil((value / 255) * 100)
		guiScrollBarSetScrollPosition(HeatHazeSliders[label], scrollPos)
	end
    local heatHazeStr = ""
		for i = 1, #heatHaze - 1 do
			heatHazeStr = heatHazeStr .. tostring(heatHaze[i]) .. ", "
		end
    heatHazeStr = heatHazeStr .. tostring(heatHaze[#heatHaze])
    outputDebugString("Saved Heat Haze: " .. heatHazeStr)
    return heatHaze
end

function resetHeatHazeHandler()
    setHeatHaze(unpack(heatHaze))
	for i, label in ipairs({"Intensity", "Random Shift", "SpeedMin", "SpeedMax", "ScanSizeX", "ScanSizeY", "RenderSizeX", "RenderSizeY"}) do
		local value = heatHaze[i]
		guiSetText(HeatHazeInputs[label], tostring(value))
		local scrollPos = math.ceil((value / 255) * 100)
		guiScrollBarSetScrollPosition(HeatHazeSliders[label], scrollPos)
	end
    updateHeatHaze()
end

local sunColorInputs, sunColorSliders, sunColor = {}, {}, {}

function updateSunColor()
	local sunColorRA = tonumber(guiGetText(sunColorInputs["Red A"])) or 0
	local sunColorGA = tonumber(guiGetText(sunColorInputs["Green A"])) or 0
	local sunColorBA = tonumber(guiGetText(sunColorInputs["Blue A"])) or 0
	local sunColorRB = tonumber(guiGetText(sunColorInputs["Red B"])) or 0
	local sunColorGB = tonumber(guiGetText(sunColorInputs["Green B"])) or 0
	local sunColorBB = tonumber(guiGetText(sunColorInputs["Blue B"])) or 0

	setSunColor(sunColorRA, sunColorGA, sunColorBA, sunColorRB, sunColorGB, sunColorBB)
end

local function getSunColorCall()
	sunColor = {getSunColor()}
	for i, label in ipairs({"Red A", "Green A", "Blue A", "Red B", "Green B", "Blue B"}) do
		local value = sunColor[i]
		guiSetText(sunColorInputs[label], tostring(value))
		local scrollPos = math.ceil((value / 255) * 100)
		guiScrollBarSetScrollPosition(sunColorSliders[label], scrollPos)
	end
	outputDebugString("Saved Sun Color: " .. table.concat(sunColor, ", "))
	return sunColor
end

function resetSunColorHandler()
	setSunColor(unpack(sunColor))
	for i, label in ipairs({"Red A", "Green A", "Blue A", "Red B", "Green B", "Blue B"}) do
		local value = sunColor[i]
		guiSetText(sunColorInputs[label], tostring(value))
		local scrollPos = math.ceil((value / 255) * 100)
		guiScrollBarSetScrollPosition(sunColorSliders[label], scrollPos)
	end
	updateSunColor()
end

local WindVelocityInputs, WindVelocitySliders, windVelocity = {}, {}, {}

function updateWindVelocity()
    local velocityX = tonumber(guiGetText(WindVelocityInputs["VelocityX"])) or 0
    local velocityY = tonumber(guiGetText(WindVelocityInputs["VelocityY"])) or 0
    local velocityZ = tonumber(guiGetText(WindVelocityInputs["VelocityZ"])) or 0
    setWindVelocity(velocityX, velocityY, velocityZ)
end

local function getWindVelocityCall()
    windVelocity = {getWindVelocity()}
    for i, label in ipairs({"VelocityX", "VelocityY", "VelocityZ"}) do
		local value = windVelocity[i]
		guiSetText(WindVelocityInputs[label], tostring(value))
		local scrollPos = math.ceil((value / 255) * 100)
		guiScrollBarSetScrollPosition(WindVelocitySliders[label], scrollPos)
	end
    outputDebugString("Saved Wind Velocity: " .. table.concat(windVelocity, ", "))
    return windVelocity
end

function resetWindVelocityHandler()
    setWindVelocity(unpack(windVelocity))
	for i, label in ipairs({"VelocityX", "VelocityY", "VelocityZ"}) do
		local value = windVelocity[i]
		guiSetText(WindVelocityInputs[label], tostring(value))
		local scrollPos = math.ceil((value / 255) * 100)
		guiScrollBarSetScrollPosition(WindVelocitySliders[label], scrollPos)
	end
    updateWindVelocity()
end

local skygradientInputs, skygradientSliders = {}, {}

function updateSkyGradient()
	local skygradient = {tonumber(guiGetText(skygradientInputs["topRed"])) or 0, tonumber(guiGetText(skygradientInputs["topGreen"])) or 0, tonumber(guiGetText(skygradientInputs["topBlue"])) or 0, tonumber(guiGetText(skygradientInputs["bottomRed"])) or 0, tonumber(guiGetText(skygradientInputs["bottomGreen"])) or 0, tonumber(guiGetText(skygradientInputs["bottomBlue"])) or 0}
	setSkyGradient(unpack(skygradient))
end

local function getSkyGradientCall()
	skygradient = {getSkyGradient()}
	for i, label in ipairs({"topRed", "topGreen", "topBlue", "bottomRed", "bottomGreen", "bottomBlue"}) do
		local value = skygradient[i]
		guiSetText(skygradientInputs[label], tostring(value))
		local scrollPos = math.ceil((value / 255) * 100)
		guiScrollBarSetScrollPosition(skygradientSliders[label], scrollPos)
	end
	outputDebugString("Saved Sky Gradient: " .. table.concat(skygradient, ", "))
	return skygradient
end

function resetSkyGradientHandler()
	setSkyGradient(unpack(skygradient))
	for i, label in ipairs({"topRed", "topGreen", "topBlue", "bottomRed", "bottomGreen", "bottomBlue"}) do
		local value = skygradient[i]
		guiSetText(skygradientInputs[label], tostring(value))
		local scrollPos = math.ceil((value / 255) * 100)
		guiScrollBarSetScrollPosition(skygradientSliders[label], scrollPos)
	end
	updateSkyGradient()
end

local watercolorInputs, watercolorSliders = {}, {}

function updateWaterColor()
	local watercolor = {tonumber(guiGetText(watercolorInputs["Red"])) or 0, tonumber(guiGetText(watercolorInputs["Green"])) or 0, tonumber(guiGetText(watercolorInputs["Blue"])) or 0, tonumber(guiGetText(watercolorInputs["Alpha"])) or 0}
	setWaterColor(unpack(watercolor))
end

function getWaterColorCall()
	watercolor = {getWaterColor()}
	for i, label in ipairs({"Red", "Green", "Blue", "Alpha"}) do
		local value = watercolor[i]
		guiSetText(watercolorInputs[label], tostring(value))
		local scrollPos = math.ceil((value / 255) * 100)
		guiScrollBarSetScrollPosition(watercolorSliders[label], scrollPos)
	end
	outputDebugString("Saved Water Color: " .. table.concat(watercolor, ", "))
	return watercolor
end

function resetWaterColorHandler()
	setWaterColor(unpack(watercolor))
	for i, label in ipairs({"Red", "Green", "Blue", "Alpha"}) do
		local value = watercolor[i]
		guiSetText(watercolorInputs[label], tostring(value))
		local scrollPos = math.ceil((value / 255) * 100)
		guiScrollBarSetScrollPosition(watercolorSliders[label], scrollPos)
	end
	updateWaterColor()
end

local weatherInputs, weatherSliders = {}, {}

function getWeatherCall()
	weatherARG = getWeather()
	outputDebugString("Saved Weather: " .. weatherARG)
	for _, label in ipairs({"Weather"}) do
		local value = tonumber(weatherARG) or 0
		guiSetText(weatherInputs[label], tostring(value))
		local scrollPos = math.ceil((value / 255) * 100)
		guiScrollBarSetScrollPosition(weatherSliders[label], scrollPos)
	end
	return weatherARG
end

function updateWeather()
	local weather = tonumber(guiGetText(weatherInputs["Weather"])) or 0
	setWeather(weather)
end

function resetWeatherHandler()
	setWeather(weatherARG)
	for _, label in ipairs({"Weather"}) do
		local value = tonumber(weatherARG) or 0
		guiSetText(weatherInputs[label], tostring(value))
		local scrollPos = math.ceil((value / 255) * 100)
		guiScrollBarSetScrollPosition(weatherSliders[label], scrollPos)
	end
	updateWeather()
end

local timeInputs, timeSlider = {}, {}
function getTimeCall()
    timehour, timeminute = getTime()
    outputDebugString("Saved Time: " .. timehour .. ":" .. timeminute)
    for _, label in ipairs({"Hour", "Minute"}) do
        local value
        if label == "Hour" then
            value = tonumber(timehour) or 0
        elseif label == "Minute" then
            value = tonumber(timeminute) or 0
        end
        guiSetText(timeInputs[label], tostring(value))
        local max_value = (label == "Hour") and 23 or 59
        local scrollPos = (value / max_value) * 100
        scrollPos = math.floor(scrollPos + 1)
        guiScrollBarSetScrollPosition(timeSlider[label], scrollPos)
    end
    return timehour, timeminute
end


function updateTime()
	local hour = tonumber(guiGetText(timeInputs["Hour"])) or 0
	local minute = tonumber(guiGetText(timeInputs["Minute"])) or 0
	setTime(hour, minute)
end

function resetTimeHandler()
	setTime(timehour, timeminute)
	for _, label in ipairs({"Hour", "Minute"}) do
        local value
        if label == "Hour" then
            value = tonumber(timehour) or 0
        elseif label == "Minute" then
            value = tonumber(timeminute) or 0
        end
        guiSetText(timeInputs[label], tostring(value))
        local max_value = (label == "Hour") and 23 or 59
        local scrollPos = (value / max_value) * 100
        scrollPos = math.floor(scrollPos + 1)
        guiScrollBarSetScrollPosition(timeSlider[label], scrollPos)
    end
	updateTime()
end

local inputs, sliders = {}, {}
local savedColorFilter = {}

local function saveCurrentColorFilter()
	local aR,aG,aB,aA,bR,bG,bB,bA = getColorFilter(false)
	savedColorFilter = {aR, aG, aB, aA, bR, bG, bB, bA}
	outputDebugString("Saved Color Filter: " .. table.concat(savedColorFilter, ", "))
	for i, label in ipairs({"Red A", "Green A", "Blue A", "Alpha A", "Red B", "Green B", "Blue B", "Alpha B"}) do
		local value = savedColorFilter[i]
		guiSetText(inputs[label], tostring(value))
		local scrollPos = (value / 255) * 100
		scrollPos = math.floor(scrollPos + 0.5)
		guiScrollBarSetScrollPosition(sliders[label], scrollPos)
	end
end

function updateColorFilter()
	local aR = tonumber(guiGetText(inputs["Red A"])) or 0
	local aG = tonumber(guiGetText(inputs["Green A"])) or 0
	local aB = tonumber(guiGetText(inputs["Blue A"])) or 0
	local aA = tonumber(guiGetText(inputs["Alpha A"])) or 0
	local bR = tonumber(guiGetText(inputs["Red B"])) or 0
	local bG = tonumber(guiGetText(inputs["Green B"])) or 0
	local bB = tonumber(guiGetText(inputs["Blue B"])) or 0
	local bA = tonumber(guiGetText(inputs["Alpha B"])) or 0

	setColorFilter(aR, aG, aB, aA, bR, bG, bB, bA)
end

function resetColorFilterHandler()
	if #savedColorFilter > 0 then
		setColorFilter(unpack(savedColorFilter))
		outputDebugString("Reset to Saved Color Filter: " .. table.concat(savedColorFilter, ", "))
	else
		resetColorFilter()
		outputDebugString("Reset to Default Color Filter")
	end

	local labels = {"Red A", "Green A", "Blue A", "Alpha A", "Red B", "Green B", "Blue B", "Alpha B"}
	for i, label in ipairs(labels) do
		if savedColorFilter[i] then
			local value = savedColorFilter[i]
			guiSetText(inputs[label], tostring(value))
			local scrollPos = (value / 255) * 100
			scrollPos = math.floor(scrollPos + 0.5)
			guiScrollBarSetScrollPosition(sliders[label], scrollPos)
		else
			guiSetText(inputs[label], "0")
			guiScrollBarSetScrollPosition(sliders[label], 0)
		end
	end

	updateColorFilter()
end


local MSLabel = {"Moon Size", "Sun Size", "Fog Distance", "Far Clip Distance", "Near Clip Distance", "Rain Level", "Grain Level"}
local MS = {}
local MSInput = {}
local incrementButtons = {}
local decrementButtons = {}

function updateMoonsize()
	local size = tonumber(guiGetText(MSInput["Moon Size"])) or 0
	setMoonSize(size)
end

function resetMoonSize()
	setMoonSize(normalMoonSize)
	guiSetText(MSInput["Moon Size"], normalMoonSize)
end

function saveMoonSize()
	normalMoonSize = getMoonSize()
	guiSetText(MSInput["Moon Size"], getMoonSize())
end

function updateSunsize()
    local size = tonumber(guiGetText(MSInput["Sun Size"]))
    setSunSize(tonumber(size))
end

function resetSunSize()
	setSunSize(normalSunSize)
	guiSetText(MSInput["Sun Size"], normalSunSize)
end

function saveSunSize()
	normalSunSize = getSunSize()
	guiSetText(MSInput["Sun Size"], normalSunSize)
end

function updateFogDistance()
	local distance = tonumber(guiGetText(MSInput["Fog Distance"]))
	setFogDistance(tonumber(distance))
end

function resetFogDistance()
	setFogDistance(normalFogDistance)
	guiSetText(MSInput["Fog Distance"], normalFogDistance)
end

function saveFogDistance()
	normalFogDistance = getFogDistance()
	guiSetText(MSInput["Fog Distance"], normalFogDistance)
end

function updateFarClipDistance()
	local distance = tonumber(guiGetText(MSInput["Far Clip Distance"]))
	setFarClipDistance(tonumber(distance))
end

function resetFarClipDistance()
	setFarClipDistance(normalFarClipDistance)
	guiSetText(MSInput["Far Clip Distance"], normalFarClipDistance)
end

function saveFarClipDistance()
	normalFarClipDistance = getFarClipDistance()
	guiSetText(MSInput["Far Clip Distance"], normalFarClipDistance)
end

function updateRainLevel()
	local level = tonumber(guiGetText(MSInput["Rain Level"]))
	setRainLevel(tonumber(level))
end

function resetRainLevel()
	setRainLevel(normalRainLevel)
	guiSetText(MSInput["Rain Level"], normalRainLevel)
end

function saveRainLevel()
	normalRainLevel = getRainLevel()
	guiSetText(MSInput["Rain Level"], normalRainLevel)
end

function updateNearClipDistance()
	local distance = tonumber(guiGetText(MSInput["Near Clip Distance"]))
	setNearClipDistance(tonumber(distance))
end

function resetNearClipDistance()
	setNearClipDistance(normalNearClipDistance)
	guiSetText(MSInput["Near Clip Distance"], normalNearClipDistance)
end

function saveNearClipDistance()
	normalNearClipDistance = getNearClipDistance()
	guiSetText(MSInput["Near Clip Distance"], normalNearClipDistance)
end

local savedGrainLevel

function updateGrainLevel()
	local level = tonumber(guiGetText(MSInput["Grain Level"]))
	setGrainLevel(tonumber(level))
end

function resetGrainLevel()
	setGrainLevel(0)
	guiSetText(MSInput["Grain Level"], "0")
end


function saveGrainLevel()
    savedGrainLevel = guiGetText(MSInput["Grain Level"])
    guiSetText(MSInput["Grain Level"], savedGrainLevel)
end

function incrementValue(label)
    return function()
        local currentValue = tonumber(guiGetText(MSInput[label])) or 0
        currentValue = currentValue + 1
        guiSetText(MSInput[label], tostring(currentValue))
        if label == "Moon Size" then
            updateMoonsize()
        elseif label == "Sun Size" then
            updateSunsize()
        elseif label == "Fog Distance" then
            updateFogDistance()
        elseif label == "Far Clip Distance" then
            updateFarClipDistance()
		elseif label == "Near Clip Distance" then
			updateNearClipDistance()
		elseif label == "Rain Level" then
			updateRainLevel()
		else
			updateGrainLevel()
        end
    end
end

-- Funktion zum Dekrementieren der Werte
function decrementValue(label)
    return function()
        local currentValue = tonumber(guiGetText(MSInput[label])) or 0
        currentValue = currentValue - 1
        guiSetText(MSInput[label], tostring(currentValue))
        if label == "Moon Size" then
            updateMoonsize()
        elseif label == "Sun Size" then
            updateSunsize()
        elseif label == "Fog Distance" then
            updateFogDistance()
        elseif label == "Far Clip Distance" then
            updateFarClipDistance()
		elseif label == "Near Clip Distance" then
			updateNearClipDistance()
		elseif label == "Rain Level" then
            updateRainLevel()
		else
			updateGrainLevel()
        end
    end
end


local outputFile = false

function getCurrentDirectory()
    local str = debug.getinfo(1, "S").source:sub(2)
    return str:match("(.*/)") or ""
end

scriptPath = getCurrentDirectory()
outputPath = scriptPath .. "outputs/"

function fileOpen2()
    fileClose2()
    local fileCounts = 1
    while fileExists(outputPath.."output"..tostring(fileCounts)..".lua") do
        fileCounts = fileCounts + 1
    end
    outputFile = fileCreate(outputPath.."output"..tostring(fileCounts)..".lua")
    return outputFile
end

function fileWrite2(data)
    if outputFile then
        fileWrite(outputFile, data.."\n")
        fileFlush(outputFile)
		getCurrentDirectory()
    end
end

function fileClose2()
    if outputFile then
        fileClose(outputFile)
    end
    outputFile = false
    return true
end


addEventHandler("onClientResourceStart", resourceRoot, function()
	local sw, sh = guiGetScreenSize()
	mainWindow = guiCreateWindow((sw - 800) / 2, (sh - 800) / 2, 800, 720, "Settings", false)
	guiSetAlpha(mainWindow, 0.75)
	local x, y, w, h = 10, 27, 55, 18
	-- Create a tab panel inside mainWindow
	local tabPanel = guiCreateTabPanel(10, 30, 780, 650, false, mainWindow)

	-- Create a tab (world_props_window) inside the tab panel
	local world_props_window = guiCreateTab("World Properties", tabPanel)

	x, y = 10, 20
	for _, data in ipairs(worldProperties) do
		guiFields[data.key] = {}
		x = 10
		guiCreateLabel(x, y, 130, h, data.key, false, world_props_window)
		x = x + 130
		local cValues = {getWorldProperty(data.key)}
		for idx, val in ipairs(data.values) do
			guiFields[data.key][idx] = guiCreateEdit(x, y, w, h, cValues[idx] or val, false, world_props_window)
			if guiFields[data.key][idx] then
				setElementData(guiFields[data.key][idx], "key", data.key)
				addEventHandler("onClientGUIChanged", guiFields[data.key][idx], onWorldPropertyChanged, false)
				x = x + w + 4
			end
		end
		local prevBtn = guiCreateButton(x, y, w, h, "<", false, world_props_window)
		setElementData(prevBtn, "data", {data.key, -1})
		addEventHandler("onClientGUIClick", prevBtn, onWorldPropertyQuickClick, false)
		x = x + w + 4
		local nextBtn = guiCreateButton(x, y, w, h, ">", false, world_props_window)
		setElementData(nextBtn, "data", {data.key, 1})
		addEventHandler("onClientGUIClick", nextBtn, onWorldPropertyQuickClick, false)
		x = x + w + 4
		local resetBtn = guiCreateButton(x, y, w, h, "reset", false, world_props_window)
		setElementData(resetBtn, "data", data.key)
		addEventHandler("onClientGUIClick", resetBtn, onWorldPropertyResetClick, false)
		x = x + w + 4
		local outputBtn = guiCreateButton(x, y, w, h, "output", false, world_props_window)
		addEventHandler("onClientGUIClick", outputBtn, function()
			outputChatBox("setWorldProperty(\"" .. data.key .. "\", " .. table.concat({getWorldProperty(data.key)}, ", ") .. ")")
		end, false)
		x = x + w + 4
		y = y + h + 4
		maxW = math.max(maxW or x, x)
	end
	x = 10
	y = y + 10
	w = 100
	h = 30
	local xM, yM, yMS = 0, 0, 0
	for _, label in ipairs(MSLabel) do
		MS[label] = guiCreateLabel(x + xM, y - 10 + yM, w, 18, label, false, world_props_window)
		MSInput[label] = guiCreateEdit(140 + xM, y - 10 + yM, 55, 18, "0", false, world_props_window)
		
		decrementButtons[label] = guiCreateButton(200 + xM, y - 10 + yM, 55, 18, "<", false, world_props_window)
		incrementButtons[label] = guiCreateButton(258 + xM, y - 10 + yM, 55, 18, ">", false, world_props_window)
		
		local resetBtn = guiCreateButton(316 + xM, y - 10 + yM, 55, 18, "reset", false, world_props_window)
		local outputBtn = guiCreateButton(376 + xM, y - 10 + yM, 55, 18, "output", false, world_props_window)
		
		addEventHandler("onClientGUIClick", incrementButtons[label], incrementValue(label), false)
		addEventHandler("onClientGUIClick", decrementButtons[label], decrementValue(label), false)
		addEventHandler("onClientGUIClick", resetBtn, function()
			if label == "Moon Size" then
				resetMoonSize()
			elseif label == "Sun Size" then
				resetSunSize()
			elseif label == "Fog Distance" then
				resetFogDistance()
			elseif label == "Far Clip Distance" then
				resetFarClipDistance()
			elseif label == "Near Clip Distance" then
				resetNearClipDistance()
			elseif label == "Rain Level" then
				resetRainLevel()
			else
				resetGrainLevel()
			end
		end, false)
		addEventHandler("onClientGUIClick", outputBtn, function()
			if label == "Moon Size" then
				outputChatBox("setMoonSize(" .. guiGetText(MSInput[label]) .. ")")
			elseif label == "Sun Size" then
				outputChatBox("setSunSize(" .. guiGetText(MSInput[label]) .. ")")
			elseif label == "Fog Distance" then
				outputChatBox("setFogDistance(" .. guiGetText(MSInput[label]) .. ")")
			elseif label == "Far Clip Distance" then
				outputChatBox("setFarClipDistance(" .. guiGetText(MSInput[label]) .. ")")
			elseif label == "Near Clip Distance" then
				outputChatBox("setNearClipDistance(" .. guiGetText(MSInput[label]) .. ")")
			elseif label == "Rain Level" then
				outputChatBox("setRainLevel(" .. guiGetText(MSInput[label]) .. ")")
			else
				outputChatBox("setGrainLevel(" .. guiGetText(MSInput[label]) .. ")")
			end
		end, false)
		
		if label == "Moon Size" then
			addEventHandler("onClientGUIChanged", MSInput[label], updateMoonsize)
		elseif label == "Sun Size" then
			addEventHandler("onClientGUIChanged", MSInput[label], updateSunsize)
		elseif label == "Fog Distance" then
			addEventHandler("onClientGUIChanged", MSInput[label], updateFogDistance)
		elseif label == "Far Clip Distance" then
			addEventHandler("onClientGUIChanged", MSInput[label], updateFarClipDistance)
		elseif label == "Near Clip Distance" then
			addEventHandler("onClientGUIChanged", MSInput[label], updateNearClipDistance)
		elseif label == "Rain Level" then
			addEventHandler("onClientGUIChanged", MSInput[label], updateRainLevel)
		else
			addEventHandler("onClientGUIChanged", MSInput[label], updateGrainLevel)
		end
		
		xM = 0
		yM = yM + 24
	end
	saveNearClipDistance()
	saveRainLevel()
	saveNearClipDistance()
	saveFarClipDistance()
	saveFogDistance()
	saveMoonSize()
	saveSunSize()
	saveGrainLevel()
	updateAllBtn = guiCreateButton(x, y+215, w, h, "update values", false, mainWindow)
	addEventHandler("onClientGUIClick", updateAllBtn, onUpdateAllPropertiesClick, false)
	x = x + w + 10
	resetAllBtn = guiCreateButton(x, y+215, w, h, "reset values", false, mainWindow)
	addEventHandler("onClientGUIClick", resetAllBtn, onResetAllPropertiesClick, false)
	x = x + w + 10
	saveAllBtn = guiCreateButton(x, y+215, w, h, "save values", false, mainWindow)
	addEventHandler("onClientGUIClick", saveAllBtn, function()
		for key, data in pairs(guiFields) do
			saveWorldProperty(key)
		end
		saveCurrentColorFilter()
		saveMoonSize()
		saveSunSize()
		saveFogDistance()
		saveFarClipDistance()
		saveNearClipDistance()
		saveRainLevel()
		saveGrainLevel()
		getHeatHazeCall()
		getWindVelocityCall()
		getSunColorCall()
		getSkyGradientCall()
		getWaterColorCall()
		getWeatherCall()
		getTimeCall()
	end, false)
	x = x + w + 10
	outputAllBtn = guiCreateButton(x, y+215, w, h, "output lua", false, mainWindow)
	addEventHandler("onClientGUIClick", outputAllBtn, function()
		outputChatBox("File has been created.")
		fileOpen2()
		fileWrite2("addEventHandler(\"onClientResourceStart\", resourceRoot, function()")
			for key, data in pairs(guiFields) do
				fileWrite2("\tsetWorldProperty(\"" .. key .. "\", " .. table.concat({getWorldProperty(key)}, ", ") .. ")")
			end
			fileWrite2("\tsetColorFilter("..guiGetText(inputs["Red A"])..", "..guiGetText(inputs["Green A"])..", "..guiGetText(inputs["Blue A"])..", "..guiGetText(inputs["Alpha A"])..", "..guiGetText(inputs["Red B"])..", "..guiGetText(inputs["Green B"])..", "..guiGetText(inputs["Blue B"])..", "..guiGetText(inputs["Alpha B"])..")")
			fileWrite2("\tsetSkyGradient("..guiGetText(skygradientInputs["topRed"])..", "..guiGetText(skygradientInputs["topGreen"])..", "..guiGetText(skygradientInputs["topBlue"])..", "..guiGetText(skygradientInputs["bottomRed"])..", "..guiGetText(skygradientInputs["bottomGreen"])..", "..guiGetText(skygradientInputs["bottomBlue"])..")")
			fileWrite2("\tsetWaterColor("..guiGetText(watercolorInputs["Red"])..", "..guiGetText(watercolorInputs["Green"])..", "..guiGetText(watercolorInputs["Blue"])..", "..guiGetText(watercolorInputs["Alpha"])..")")
			fileWrite2("\tsetWeather("..guiGetText(weatherInputs["Weather"])..")")
			fileWrite2("\tsetTime("..guiGetText(timeInputs["Hour"])..", "..guiGetText(timeInputs["Minute"])..")")
			fileWrite2("\tsetMoonSize("..guiGetText(MSInput["Moon Size"])..")")
			fileWrite2("\tsetSunSize("..guiGetText(MSInput["Sun Size"])..")")
			fileWrite2("\tsetFogDistance("..guiGetText(MSInput["Fog Distance"])..")")
			fileWrite2("\tsetFarClipDistance("..guiGetText(MSInput["Far Clip Distance"])..")")
			fileWrite2("\tsetNearClipDistance("..guiGetText(MSInput["Near Clip Distance"])..")")
			fileWrite2("\tsetRainLevel("..guiGetText(MSInput["Rain Level"])..")")
			fileWrite2("\tsetGrainLevel("..guiGetText(MSInput["Grain Level"])..")")
			fileWrite2("\tsetHeatHaze("..guiGetText(HeatHazeInputs["Intensity"])..", "..guiGetText(HeatHazeInputs["Random Shift"])..", "..guiGetText(HeatHazeInputs["SpeedMin"])..", "..guiGetText(HeatHazeInputs["SpeedMax"])..", "..guiGetText(HeatHazeInputs["ScanSizeX"])..", "..guiGetText(HeatHazeInputs["ScanSizeY"])..", "..guiGetText(HeatHazeInputs["RenderSizeX"])..", "..guiGetText(HeatHazeInputs["RenderSizeY"])..", false)")
			fileWrite2("\tsetWindVelocity("..guiGetText(WindVelocityInputs["VelocityX"])..", "..guiGetText(WindVelocityInputs["VelocityY"])..", "..guiGetText(WindVelocityInputs["VelocityZ"])..")")
			fileWrite2("\tsetSunColor("..guiGetText(sunColorInputs["Red A"])..", "..guiGetText(sunColorInputs["Green A"])..", "..guiGetText(sunColorInputs["Blue A"])..", "..guiGetText(sunColorInputs["Red B"])..", "..guiGetText(sunColorInputs["Green B"])..", "..guiGetText(sunColorInputs["Blue B"])..")")
			fileWrite2("end)")
			fileClose2()
	end, false)
	x = x + w + 10
	outputChAllBtn = guiCreateButton(x, y+215, w, h, "output chatbox", false, mainWindow)
	addEventHandler("onClientGUIClick", outputChAllBtn, function()
		for key, data in pairs(guiFields) do
			outputChatBox("setWorldProperty(\"" .. key .. "\", " .. table.concat({getWorldProperty(key)}, ", ") .. ")")
		end
		outputChatBox("\tsetColorFilter("..guiGetText(inputs["Red A"])..", "..guiGetText(inputs["Green A"])..", "..guiGetText(inputs["Blue A"])..", "..guiGetText(inputs["Alpha A"])..", "..guiGetText(inputs["Red B"])..", "..guiGetText(inputs["Green B"])..", "..guiGetText(inputs["Blue B"])..", "..guiGetText(inputs["Alpha B"])..")")
		outputChatBox("\tsetSkyGradient("..guiGetText(skygradientInputs["topRed"])..", "..guiGetText(skygradientInputs["topGreen"])..", "..guiGetText(skygradientInputs["topBlue"])..", "..guiGetText(skygradientInputs["bottomRed"])..", "..guiGetText(skygradientInputs["bottomGreen"])..", "..guiGetText(skygradientInputs["bottomBlue"])..")")
		outputChatBox("\tsetWaterColor("..guiGetText(watercolorInputs["Red"])..", "..guiGetText(watercolorInputs["Green"])..", "..guiGetText(watercolorInputs["Blue"])..", "..guiGetText(watercolorInputs["Alpha"])..")")
		outputChatBox("\tsetWeather("..guiGetText(weatherInputs["Weather"])..")")
		outputChatBox("\tsetTime("..guiGetText(timeInputs["Hour"])..", "..guiGetText(timeInputs["Minute"])..")")
		outputChatBox("\tsetMoonSize("..guiGetText(MSInput["Moon Size"])..")")
		outputChatBox("\tsetSunSize("..guiGetText(MSInput["Sun Size"])..")")
		outputChatBox("\tsetFogDistance("..guiGetText(MSInput["Fog Distance"])..")")
		outputChatBox("\tsetFarClipDistance("..guiGetText(MSInput["Far Clip Distance"])..")")
		outputChatBox("\tsetNearClipDistance("..guiGetText(MSInput["Near Clip Distance"])..")")
		outputChatBox("\tsetRainLevel("..guiGetText(MSInput["Rain Level"])..")")
		outputChatBox("\tsetGrainLevel("..guiGetText(MSInput["Grain Level"])..")")
		outputChatBox("\tsetHeatHaze("..guiGetText(HeatHazeInputs["Intensity"])..", "..guiGetText(HeatHazeInputs["Random Shift"])..", "..guiGetText(HeatHazeInputs["SpeedMin"])..", "..guiGetText(HeatHazeInputs["SpeedMax"])..", "..guiGetText(HeatHazeInputs["ScanSizeX"])..", "..guiGetText(HeatHazeInputs["ScanSizeY"])..", "..guiGetText(HeatHazeInputs["RenderSizeX"])..", "..guiGetText(HeatHazeInputs["RenderSizeY"])..", false)")
		outputChatBox("\tsetWindVelocity("..guiGetText(WindVelocityInputs["VelocityX"])..", "..guiGetText(WindVelocityInputs["VelocityY"])..", "..guiGetText(WindVelocityInputs["VelocityZ"])..")")
		outputChatBox("\tsetSunColor("..guiGetText(sunColorInputs["Red A"])..", "..guiGetText(sunColorInputs["Green A"])..", "..guiGetText(sunColorInputs["Blue A"])..", "..guiGetText(sunColorInputs["Red B"])..", "..guiGetText(sunColorInputs["Green B"])..", "..guiGetText(sunColorInputs["Blue B"])..")")
	end, false)
	x = x + w + 10
	guiCreateLabel(x, y + 220, 255, h, "mouse2 - show / hide window + cursor", false, mainWindow)
	x = x + 250
	y = y + h + 4


	local x, y, w, h = 125, 27, 55, 18
	freezePropUpdate = false
	showCursor(true)
	-- Sky Gradient Tab
	skyGradientTab = guiCreateTab("Sky Gradient, Water Color, Weather & Time", tabPanel)
	local labels = {"topRed", "topGreen", "topBlue", "bottomRed", "bottomGreen", "bottomBlue"}

	for _, label in ipairs(labels) do
		guiCreateLabel(x, y, 130, h, label, false, skyGradientTab)
		skygradientInputs[label] = guiCreateEdit(x, y + 20, w, h, "0", false, skyGradientTab)
		skygradientSliders[label] = guiCreateScrollBar(x + 60, y, 15, 150, false, false, skyGradientTab)
		incrementButtons[label] = guiCreateButton(x, y + 40, 20, 20, "+", false, skyGradientTab)
		decrementButtons[label] = guiCreateButton(x, y + 60, 20, 20, "-", false, skyGradientTab)
		for _, button in ipairs({incrementButtons[label], decrementButtons[label]}) do
			addEventHandler("onClientGUIClick", button, function()
				local value = tonumber(guiGetText(skygradientInputs[label])) or 0
				if source == incrementButtons[label] then
					value = value + 1
				else
					value = value - 1
				end
				guiSetText(skygradientInputs[label], tostring(value))
				updateSkyGradient()
			end, false)
		end
		guiScrollBarSetScrollPosition(skygradientSliders[label], 0)
		x = x + w + 25
	end

	for key, slider in pairs(skygradientSliders) do
		addEventHandler("onClientGUIScroll", slider, function()
			local value = math.floor(guiScrollBarGetScrollPosition(slider) * 255/100)
			guiSetText(skygradientInputs[key], tostring(value))
			updateSkyGradient()
		end, false)
	end

	guiCreateLabel(30, y, 150, h, "Sky Gradient", false, skyGradientTab)
	local applyButton = guiCreateButton(10, y + 20, 110, 25, "Save Sky Gradient", false, skyGradientTab)
	addEventHandler("onClientGUIClick", applyButton, getSkyGradientCall, false)

	local resetButton = guiCreateButton(10, y + 60, 110, 25, "Reset Sky Gradient", false, skyGradientTab)
	addEventHandler("onClientGUIClick", resetButton, resetSkyGradientHandler, false)

	local outputButton = guiCreateButton(10, y + 100, 110, 25, "Output", false, skyGradientTab)
	addEventHandler("onClientGUIClick", outputButton, function()
		outputChatBox("setSkyGradient("..guiGetText(skygradientInputs["topRed"])..", "..guiGetText(skygradientInputs["topGreen"])..", "..guiGetText(skygradientInputs["topBlue"])..", "..guiGetText(skygradientInputs["bottomRed"])..", "..guiGetText(skygradientInputs["bottomGreen"])..", "..guiGetText(skygradientInputs["bottomBlue"])..")")
	end, false)
	getSkyGradientCall()

	-- Water Color Tab
	x, y = 125, 27
	labels = {"Red", "Green", "Blue", "Alpha"}

	for _, label in ipairs(labels) do
		guiCreateLabel(x, y+220, 130, h, label, false, skyGradientTab)
		watercolorInputs[label] = guiCreateEdit(x, y + 240, w, h, "0", false, skyGradientTab)
		watercolorSliders[label] = guiCreateScrollBar(x + 60, y+240, 15, 150, false, false, skyGradientTab)
		incrementButtons[label] = guiCreateButton(x, y + 260, 20, 20, "+", false, skyGradientTab)
		decrementButtons[label] = guiCreateButton(x, y + 280, 20, 20, "-", false, skyGradientTab)
		for _, button in ipairs({incrementButtons[label], decrementButtons[label]}) do
			addEventHandler("onClientGUIClick", button, function()
				local value = tonumber(guiGetText(watercolorInputs[label])) or 0
				if source == incrementButtons[label] then
					value = value + 1
				else
					value = value - 1
				end
				guiSetText(watercolorInputs[label], tostring(value))
				updateWaterColor()
			end, false)
		end
		guiScrollBarSetScrollPosition(watercolorSliders[label], 0)
		x = x + w + 25
	end

	for key, slider in pairs(watercolorSliders) do
		addEventHandler("onClientGUIScroll", slider, function()
			local value = math.floor(guiScrollBarGetScrollPosition(slider) * 255/100)
			guiSetText(watercolorInputs[key], tostring(value))
			updateWaterColor()
		end, false)
	end

	guiCreateLabel(35, y+220, 150, h, "Water Color", false, skyGradientTab)
	applyButton = guiCreateButton(10, y + 240, 110, 25, "Save Water Color", false, skyGradientTab)
	addEventHandler("onClientGUIClick", applyButton, getWaterColorCall, false)

	resetButton = guiCreateButton(10, y + 280, 110, 25, "Reset Water Color", false, skyGradientTab)
	addEventHandler("onClientGUIClick", resetButton, resetWaterColorHandler, false)

	outputButton = guiCreateButton(10, y + 320, 110, 25, "Output", false, skyGradientTab)
	addEventHandler("onClientGUIClick", outputButton, function()
		outputChatBox("setWaterColor("..guiGetText(watercolorInputs["Red"])..", "..guiGetText(watercolorInputs["Green"])..", "..guiGetText(watercolorInputs["Blue"])..", "..guiGetText(watercolorInputs["Alpha"])..")")
	end, false)
	getWaterColorCall()

	-- Weather Tab
	x, y = 125, 27
	labels = {"Weather"}

	for _, label in ipairs(labels) do
		guiCreateLabel(x, y+420, 130, h, "ID", false, skyGradientTab)
		weatherInputs[label] = guiCreateEdit(x, y + 440, w, h, "0", false, skyGradientTab)
		weatherSliders[label] = guiCreateScrollBar(x + 60, y+440, 15, 150, false, false, skyGradientTab)
		incrementButtons[label] = guiCreateButton(x, y + 460, 20, 20, "+", false, skyGradientTab)
		decrementButtons[label] = guiCreateButton(x, y + 480, 20, 20, "-", false, skyGradientTab)
		for _, button in ipairs({incrementButtons[label], decrementButtons[label]}) do
			addEventHandler("onClientGUIClick", button, function()
				local value = tonumber(guiGetText(weatherInputs[label])) or 0
				if source == incrementButtons[label] then
					value = value + 1
				else
					value = value - 1
				end
				guiSetText(weatherInputs[label], tostring(value))
				updateWeather()
			end, false)
		end
		guiScrollBarSetScrollPosition(weatherSliders[label], 0)
		x = x + w + 25
	end

	for key, slider in pairs(weatherSliders) do
		addEventHandler("onClientGUIScroll", slider, function()
			local value = math.floor(guiScrollBarGetScrollPosition(slider)*255/100)
			guiSetText(weatherInputs[key], tostring(value))
			updateWeather()
		end, false)
	end

	guiCreateLabel(45, y+420, 150, h, "Weather", false, skyGradientTab)
	applyButton = guiCreateButton(10, y + 440, 110, 25, "Save Weather", false, skyGradientTab)
	addEventHandler("onClientGUIClick", applyButton, getWeatherCall, false)

	resetButton = guiCreateButton(10, y + 480, 110, 25, "Reset Weather", false, skyGradientTab)
	addEventHandler("onClientGUIClick", resetButton, resetWeatherHandler, false)

	outputButton = guiCreateButton(10, y + 520, 110, 25, "Output", false, skyGradientTab)
	addEventHandler("onClientGUIClick", outputButton, function()
		outputChatBox("setWeather("..guiGetText(weatherInputs["Weather"])..")")
	end, false)
	getWeatherCall()

	-- Time Tab
	local x, y = 325, 27
	local labels = {"Hour", "Minute"}

	for _, label in ipairs(labels) do
		guiCreateLabel(x, y+420, 130, h, label, false, skyGradientTab)
		timeInputs[label] = guiCreateEdit(x, y + 440, w, h, "0", false, skyGradientTab)
		timeSlider[label] = guiCreateScrollBar(x + 60, y+440, 15, 150, false, false, skyGradientTab)
		incrementButtons[label] = guiCreateButton(x, y + 460, 20, 20, "+", false, skyGradientTab)
		decrementButtons[label] = guiCreateButton(x, y + 480, 20, 20, "-", false, skyGradientTab)
		for _, button in ipairs({incrementButtons[label], decrementButtons[label]}) do
			addEventHandler("onClientGUIClick", button, function()
				local value = tonumber(guiGetText(timeInputs[label])) or 0
				if source == incrementButtons[label] then
					value = value + 1
				else
					value = value - 1
				end
				guiSetText(timeInputs[label], tostring(value))
				updateTime()
			end, false)
		end
		guiScrollBarSetScrollPosition(timeSlider[label], 0)
		x = x + w + 25
	end

	addEventHandler("onClientGUIScroll", timeSlider["Hour"], function()
		local hourValue = math.floor(guiScrollBarGetScrollPosition(timeSlider["Hour"]) * 23/100)  -- Stunde von 0 bis 23
		guiSetText(timeInputs["Hour"], tostring(hourValue))
		updateTime()
	end, false)

	addEventHandler("onClientGUIScroll", timeSlider["Minute"], function()
		local minuteValue = math.floor(guiScrollBarGetScrollPosition(timeSlider["Minute"]) * 59/100)  -- Minute von 0 bis 59
		guiSetText(timeInputs["Minute"], tostring(minuteValue))
		updateTime()
	end, false)

	guiCreateLabel(253, y+420, 150, h, "Time", false, skyGradientTab)
	local applyButton = guiCreateButton(210, y + 440, 110, 25, "Save Time", false, skyGradientTab)
	addEventHandler("onClientGUIClick", applyButton, getTimeCall, false)

	local resetButton = guiCreateButton(210, y + 480, 110, 25, "Reset Time", false, skyGradientTab)
	addEventHandler("onClientGUIClick", resetButton, resetTimeHandler, false)

	local outputButton = guiCreateButton(210, y + 520, 110, 25, "Output", false, skyGradientTab)
	addEventHandler("onClientGUIClick", outputButton, function()
		outputChatBox("setTime("..guiGetText(timeInputs["Hour"])..", "..guiGetText(timeInputs["Minute"])..")")
	end, false)

	--Checkbox Minute Duration Lock
	local lockCheckBox = guiCreateCheckBox(210, y + 560, 150, 25, "Time Locked", true, false, skyGradientTab)
	setMinuteDuration(2147483647)
	addEventHandler("onClientGUIClick", lockCheckBox, function()
		local isChecked = guiCheckBoxGetSelected(lockCheckBox, false)
		if isChecked then
			local hour = tonumber(guiGetText(timeInputs["Hour"])) or 0
        	local minute = tonumber(guiGetText(timeInputs["Minute"])) or 0
        	setTime(hour, minute)
			setMinuteDuration(2147483647)
		else 
			local hour = tonumber(guiGetText(timeInputs["Hour"])) or 0
        	local minute = tonumber(guiGetText(timeInputs["Minute"])) or 0
			setTime(hour, minute)
			setMinuteDuration(1000)
		end
	end, false)

	getTimeCall()
	-- Color Filter Tab
	local colorFilterTab = guiCreateTab("Color Filter, Heat Haze & Wind Velocity", tabPanel)
	local x, y = 125, 27
	local labels = {"Red A", "Green A", "Blue A", "Alpha A", "Red B", "Green B", "Blue B", "Alpha B"}

	for _, label in ipairs(labels) do
		guiCreateLabel(x, y, 130, h, label, false, colorFilterTab)
		inputs[label] = guiCreateEdit(x, y + 20, w, h, "0", false, colorFilterTab)
		sliders[label] = guiCreateScrollBar(x + 60, y, 15, 150, false, false, colorFilterTab)
		incrementButtons[label] = guiCreateButton(x, y + 40, 20, 20, "+", false, colorFilterTab)
		decrementButtons[label] = guiCreateButton(x, y + 60, 20, 20, "-", false, colorFilterTab)
		for _, button in ipairs({incrementButtons[label], decrementButtons[label]}) do
			addEventHandler("onClientGUIClick", button, function()
				local value = tonumber(guiGetText(inputs[label])) or 0
				if source == incrementButtons[label] then
					value = value + 1
				else
					value = value - 1
				end
				guiSetText(inputs[label], tostring(value))
				updateColorFilter()
			end, false)
		end
		guiScrollBarSetScrollPosition(sliders[label], 0)
		x = x + w + 25
	end

	for key, slider in pairs(sliders) do
		addEventHandler("onClientGUIScroll", slider, function()
			local value = math.floor(guiScrollBarGetScrollPosition(slider) * 255/100)
			guiSetText(inputs[key], tostring(value))
			updateColorFilter()
		end, false)
	end

	guiCreateLabel(35, y, 150, h, "Color Filter", false, colorFilterTab)
	local applyButton = guiCreateButton(10, y + 20, 100, 25, "Save Filter", false, colorFilterTab)
	addEventHandler("onClientGUIClick", applyButton, function()
		saveCurrentColorFilter()
	end, false)

	local resetButton = guiCreateButton(10, y + 60, 100, 25, "Reset Filter", false, colorFilterTab)
	addEventHandler("onClientGUIClick", resetButton, resetColorFilterHandler, false)

	local outputButton = guiCreateButton(10, y + 100, 100, 25, "Output", false, colorFilterTab)
	addEventHandler("onClientGUIClick", outputButton, function()
		outputChatBox("setColorFilter("..guiGetText(inputs["Red A"])..", "..guiGetText(inputs["Green A"])..", "..guiGetText(inputs["Blue A"])..", "..guiGetText(inputs["Alpha A"])..", "..guiGetText(inputs["Red B"])..", "..guiGetText(inputs["Green B"])..", "..guiGetText(inputs["Blue B"])..", "..guiGetText(inputs["Alpha B"])..")")
	end, false)

	saveCurrentColorFilter()
	--Heat Haze Tab
	local x, y = 125, 27
	local heatlabels = {"Intensity", "Random Shift", "SpeedMin", "SpeedMax", "ScanSizeX", "ScanSizeY", "RenderSizeX", "RenderSizeY"}
	
	for _, label in ipairs(heatlabels) do
		guiCreateLabel(x, y + 220, 130, 20, label, false, colorFilterTab)
		HeatHazeInputs[label] = guiCreateEdit(x, y + 240, w, 20, "0", false, colorFilterTab)
		HeatHazeSliders[label] = guiCreateScrollBar(x + 60, y + 240, 15, 150, false, false, colorFilterTab)
		incrementButtons[label] = guiCreateButton(x, y + 260, 20, 20, "+", false, colorFilterTab)
		decrementButtons[label] = guiCreateButton(x, y + 280, 20, 20, "-", false, colorFilterTab)
		for _, button in ipairs({incrementButtons[label], decrementButtons[label]}) do
			addEventHandler("onClientGUIClick", button, function()
				local value = tonumber(guiGetText(HeatHazeInputs[label])) or 0
				if source == incrementButtons[label] then
					value = value + 1
				else
					value = value - 1
				end
				guiSetText(HeatHazeInputs[label], tostring(value))
				updateHeatHaze()
			end, false)
		end
		guiScrollBarSetScrollPosition(HeatHazeSliders[label], 0)
		x = x + w + 25
	end

	for key, slider in pairs(HeatHazeSliders) do
		addEventHandler("onClientGUIScroll", slider, function()
			local value = math.floor(guiScrollBarGetScrollPosition(slider) * 255/100)
			guiSetText(HeatHazeInputs[key], tostring(value))
			updateHeatHaze()
		end, false)
	end

	guiCreateLabel(40, y + 220, 150, 20, "Heat Haze", false, colorFilterTab)

	local applyButton = guiCreateButton(10, y + 240, 110, 25, "Save Heat Haze", false, colorFilterTab)
	addEventHandler("onClientGUIClick", applyButton, function()
		getHeatHazeCall()
	end, false)

	local resetButton = guiCreateButton(10, y + 280, 110, 25, "Reset Heat Haze", false, colorFilterTab)
	addEventHandler("onClientGUIClick", resetButton, resetHeatHazeHandler, false)

	local outputButton = guiCreateButton(10, y + 320, 110, 25, "Output", false, colorFilterTab)
	addEventHandler("onClientGUIClick", outputButton, function()
		outputChatBox("setHeatHaze(" .. guiGetText(HeatHazeInputs["Intensity"]) .. ", " .. guiGetText(HeatHazeInputs["Random Shift"]) .. ", " .. guiGetText(HeatHazeInputs["SpeedMin"]) .. ", " .. guiGetText(HeatHazeInputs["SpeedMax"]) .. ", " .. guiGetText(HeatHazeInputs["ScanSizeX"]) .. ", " .. guiGetText(HeatHazeInputs["ScanSizeY"]) .. ", " .. guiGetText(HeatHazeInputs["RenderSizeX"]) .. ", " .. guiGetText(HeatHazeInputs["RenderSizeY"]) .. ")")
	end, false)

	getHeatHazeCall()
	--Wind Velocity Tab
	local x, y = 125, 27
	local windLabels = {"VelocityX", "VelocityY", "VelocityZ"}

	for _, label in ipairs(windLabels) do
		guiCreateLabel(x, y + 420, 130, 20, label, false, colorFilterTab)
		WindVelocityInputs[label] = guiCreateEdit(x, y + 440, w, 20, "0", false, colorFilterTab)
		WindVelocitySliders[label] = guiCreateScrollBar(x + 60, y + 440, 15, 150, false, false, colorFilterTab)
		incrementButtons[label] = guiCreateButton(x, y + 460, 20, 20, "+", false, colorFilterTab)
		decrementButtons[label] = guiCreateButton(x, y + 480, 20, 20, "-", false, colorFilterTab)
		for _, button in ipairs({incrementButtons[label], decrementButtons[label]}) do
			addEventHandler("onClientGUIClick", button, function()
				local value = tonumber(guiGetText(WindVelocityInputs[label])) or 0
				if source == incrementButtons[label] then
					value = value + 1
				else
					value = value - 1
				end
				guiSetText(WindVelocityInputs[label], tostring(value))
				updateWindVelocity()
			end, false)
		end
		guiScrollBarSetScrollPosition(WindVelocitySliders[label], 0)
		x = x + w + 25
	end
	for key, slider in pairs(WindVelocitySliders) do
		addEventHandler("onClientGUIScroll", slider, function()
			local value = math.floor(guiScrollBarGetScrollPosition(slider) * 255/100)
			guiSetText(WindVelocityInputs[key], tostring(value))
			updateWindVelocity()
		end, false)
	end

	guiCreateLabel(27, y + 420, 150, 20, "Wind Velocity", false, colorFilterTab)
	local applyButton = guiCreateButton(10, y + 440, 110, 25, "Save Wind Velocity", false, colorFilterTab)
	addEventHandler("onClientGUIClick", applyButton, function()
		getWindVelocityCall()
	end, false)

	local resetButton = guiCreateButton(10, y + 480, 110, 25, "Reset Wind Velocity", false, colorFilterTab)
	addEventHandler("onClientGUIClick", resetButton, resetWindVelocityHandler, false)

	local outputButton = guiCreateButton(10, y + 520, 110, 25, "Output", false, colorFilterTab)
	addEventHandler("onClientGUIClick", outputButton, function()
		outputChatBox("setWindVelocity(" .. guiGetText(WindVelocityInputs["VelocityX"]) .. ", " .. guiGetText(WindVelocityInputs["VelocityY"]) .. ", " .. guiGetText(WindVelocityInputs["VelocityZ"]) .. ")")
	end, false)

	getWindVelocityCall()
	--Sun Color Tab
	local sunColorTab = guiCreateTab("Sun Color", tabPanel)
	local x, y = 125, 27
	local sunColorLabels = {"Red A", "Green A", "Blue A", "Red B", "Green B", "Blue B"}

	for _, label in ipairs(sunColorLabels) do
		guiCreateLabel(x, y, 130, h, label, false, sunColorTab)
		sunColorInputs[label] = guiCreateEdit(x, y + 20, w, h, "0", false, sunColorTab)
		sunColorSliders[label] = guiCreateScrollBar(x + 60, y, 15, 150, false, false, sunColorTab)
		incrementButtons[label] = guiCreateButton(x, y + 40, 20, 20, "+", false, sunColorTab)
		decrementButtons[label] = guiCreateButton(x, y + 60, 20, 20, "-", false, sunColorTab)
		for _, button in ipairs({incrementButtons[label], decrementButtons[label]}) do
			addEventHandler("onClientGUIClick", button, function()
				local value = tonumber(guiGetText(sunColorInputs[label])) or 0
				if source == incrementButtons[label] then
					value = value + 1
				else
					value = value - 1
				end
				guiSetText(sunColorInputs[label], tostring(value))
				updateSunColor()
			end, false)
		end
		guiScrollBarSetScrollPosition(sunColorSliders[label], 0)
		x = x + w + 25
	end

	for key, slider in pairs(sunColorSliders) do
		addEventHandler("onClientGUIScroll", slider, function()
			local value = math.floor(guiScrollBarGetScrollPosition(slider) * 255/100)
			guiSetText(sunColorInputs[key], tostring(value))
			updateSunColor()
		end, false)
	end

	guiCreateLabel(35, y, 150, h, "Sun Color", false, sunColorTab)
	local applyButton = guiCreateButton(10, y + 20, 100, 25, "Save Sun Color", false, sunColorTab)
	addEventHandler("onClientGUIClick", applyButton, function()
		getSunColorCall()
	end, false)

	local resetButton = guiCreateButton(10, y + 60, 100, 25, "Reset Sun Color", false, sunColorTab)
	addEventHandler("onClientGUIClick", resetButton, resetSunColorHandler, false)

	local outputButton = guiCreateButton(10, y + 100, 100, 25, "Output", false, sunColorTab)
	addEventHandler("onClientGUIClick", outputButton, function()
		outputChatBox("setSunColor("..guiGetText(sunColorInputs["Red A"])..", "..guiGetText(sunColorInputs["Green A"])..", "..guiGetText(sunColorInputs["Blue A"])..", "..guiGetText(sunColorInputs["Red B"])..", "..guiGetText(sunColorInputs["Green B"])..", "..guiGetText(sunColorInputs["Blue B"])..")")
	end, false)

	getSunColorCall()

	local windowWidth, windowHeight = guiGetSize(mainWindow, false)
	local imagePath = "nova.png"
	local imageX, imageY, imageW, imageH = 0, 0, windowWidth-25, windowHeight-100
	local imageElement = guiCreateStaticImage(imageX+13, imageY+57, imageW, imageH, imagePath, false, mainWindow)
	guiSetAlpha(imageElement, 0.5)
	guiBringToFront(world_props_window)

end)

bindKey("mouse2", "down", function()
	local isVisible = not isCursorShowing()
	showCursor(isVisible)
	guiSetVisible(mainWindow, isVisible)
end)
