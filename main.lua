local petriDish = {} -- table
local nextGenPetriDish = {} -- table
local scrWide = display.pixelWidth -- display screen width and height
local scrHigh = display.pixelHeight
local gameSpeed = 20
local xPetri = 20
local yPetri = 20
local scrMargin = 0.15 -- set a margin
local petriWide = scrWide - (scrMargin * 2 * scrWide) -- build petri matrix within screen (leaving margin)
local petriHigh = scrHigh - (scrMargin * 2 * scrHigh)
local cellWide = 20
local cellHigh = 20
local cellCenterX = cellWide / 2 -- anchoring cell in center
local cellCenterY = cellHigh / 2 -- anchoring cell in center
local zeroPointX = 0 + (scrWide * scrMargin) 
local zeroPointY = 0 + (scrHigh * scrMargin)
local function linearXY ( tempX, tempY ) -- setting up function to build petri dish
	local arrayPosition = (tempY*xPetri)+tempX
	return arrayPosition
end
local function twoDXY ( arrayPosition )
	local tempY = arrayPosition % xPetri -- percentage means provide remainder
	local tempX = arrayPosition - tempY
	return tempX, tempY
end
local function neighborCounter ( tempX, tempY ) -- function to set up how cells interact
	local lifeCount = 0 -- we didn't understand why this starts at 0
	local cellStatus
	local cellNumber
	if (tempX >1) and (tempX < xPetri-2) and (tempY>1) and (tempY<yPetri-2) then
		for x = -1, 1 do
			for y = -1, 1 do
				local neighborhoodWatch = linearXY(tempX + x, tempY+y)
				local cellStatus = petriDish [ neighborhoodWatch ]
				if cellStatus then
					lifeCount = lifeCount + 1
				end
			end
		end
	end
	if (lifeCount > 0) then
		lifeCount=lifeCount - 1 --we find this part confusing as well because it conflicts with the lifecount = lifeCount + 1w
	end
	return lifeCount
end
local function growPetriDish ( frequency ) -- rate at which petri dish grows
	local cellStatus
	local cellNumber
	for x = 0, xPetri - 1 do
		for y = 0, yPetri - 1 do
			if ( math.random () < frequency ) then -- something missing in parenthesis?
				cellStatus = true
			else
				cellStatus = false
			end
			cellNumber = linearXY ( x , y )
			petriDish [ cellNumber ] = cellStatus --calling cell number table
		end
	end
end
local function showPetriDish ( ) -- put matrix on screen (display cells)
	local myGroup = display.newGroup()
	local cellStatus = {}
	local cellNumber
	for x = 0, xPetri - 1 do -- for loop to set up matrix
		for y = 0, yPetri - 1 do
			cellNumber = linearXY ( x , y )
			if ( petriDish [ cellNumber ] ) then
				cellStatus [cellNumber] =  display.newRect(0,0,cellWide,cellHigh)
				cellStatus [cellNumber]:setFillColor(.85,.25,.6) 
			else
				cellStatus [cellNumber] = display.newRect(0,0,cellWide,cellHigh)
				cellStatus [cellNumber]:setFillColor(.1,.25,.2)
			end
			local nX = (cellWide * x) + (3*x) + zeroPointX
			local nY = (cellHigh * y) + (3*y) + zeroPointY
			cellStatus[cellNumber].x = nX
			cellStatus[cellNumber].y = nY
		end
	end
end
local function doGeneration ( ) -- setting up how cells live and die
	for x = 0, xPetri - 1 do -- for loop with if/then nested within to generate cell stageswew
		for y = 0, yPetri - 1 do
			local cellNumber = linearXY ( x , y )
			local cellState = petriDish[cellNumber]
			local population = neighborCounter(x,y)
			if petriDish[cellNumber] == true then
				if population < 2 then
					cellState = false
				elseif (population == 2) or (population == 3) then
					cellState = true
				elseif population > 3 then
					cellState = false
				end
			else
				if population == 3 then
					cellState = true
				else
					cellState = false
				end
			end
			nextGenPetriDish[cellNumber] = cellState
		end
	end
end

local function mainLoop()
	doGeneration()
	petriDish = nil
	
	petriDish = table.copy(nextGenPetriDish)
	showPetriDish()
end

growPetriDish(0.75)
showPetriDish()
nextGenPetriDish = table.copy(petriDish)


local timerid = timer.performWithDelay(1000, mainLoop,0)
