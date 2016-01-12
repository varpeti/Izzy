-- Based on: https://github.com/wixico/luann | <Josh Rowe> | MIT license

local ser = require('ser')

math.randomseed(os.time())

local Izzy = {}
local Layer = {}
local Cell = {}

--We start by creating the cells.
--The cell has a structure containing weights that modify the input from the previous layer.
--Each cell also has a signal, or output.
function Cell:new(numInputs)
	local cell = {delta = 0, weights = {}, signal = 0}
		for i = 1, numInputs do
			cell.weights[i] = math.random() * .1
		end
		setmetatable(cell, self)
		self.__index = self
	return cell
end

function Cell:activate(inputs, bias)
		local signalSum = bias
		local weights = self.weights
		for i = 1, #weights do
			signalSum = signalSum + (weights[i] * inputs[i])
		end
	self.signal = 1/(1+math.exp(1)^-(signalSum))
end

--Next we create a Layer of cells. The layer is a table of cells.
function Layer:new(numCells, numInputs)
	numCells = numCells or 1
	numInputs = numInputs or 1
	local cells = {}
		for i = 1, numCells do cells[i] = Cell:new(numInputs) end
		local layer = {cells = cells, bias = math.random()}
		setmetatable(layer, self)
		self.__index = self
	return layer
end

--layers = {table of layer sizes from input to output}
function Izzy:new(layers, learningRate)
	local network = {learningRate = learningRate}
	--initialize the input layer
	network[1] = Layer:new(layers[1], layers[1])
	--initialize the hidden layers and output layer
	for i = 2, #layers do
		network[i] = Layer:new(layers[i], layers[i-1])
	end
	setmetatable(network, self)
	self.__index = self
	return network
end

function Izzy:activate(inputs)
	for i = 1, #inputs do
		self[1].cells[i].signal = inputs[i]
	end
	for i = 2, #self do
		local passInputs = {}
		local cells = self[i].cells
		local prevCells = self[i-1].cells
		for m = 1, #prevCells do
			passInputs[m] = prevCells[m].signal
		end
		local passBias = self[i].bias
		for j = 1, #cells do
			--activate each cell
			cells[j]:activate(passInputs, passBias)
		end
	end
end

function Izzy:decode(hiddenSignal)

	--iterate over the hidden layer and set their signals to hiddenInputs
	for i = 1, #self[2].cells do
		self[2].cells[i].signal = hiddenSignal[i]
	end

	for i = 3, #self do
		local passInputs = {}
		local cells = self[i].cells
		local prevCells = self[i-1].cells
		for m = 1, #prevCells do
			passInputs[m] = prevCells[m].signal
		end
		local passBias = self[i].bias
		for j = 1, #cells do
			--activate each cell
			cells[j]:activate(passInputs, passBias)
		end
	end

end


function Izzy:bp(inputs, outputs)
	self:activate(inputs) --update the internal inputs and outputs
	local numSelf = #self
	local learningRate = self.learningRate
	for i = numSelf, 2, -1 do --iterate backwards (nothing to calculate for input layer)
		local numCells = #self[i].cells
		local cells = self[i].cells
		for j = 1, numCells do
			local signal = cells[j].signal
			if i ~= numSelf then --special calculations for output layer
				local weightDelta = 0
				local layer = self[i+1].cells
				for k = 1, #self[i+1].cells do
					weightDelta = weightDelta + layer[k].weights[j] * layer[k].delta
				end
				cells[j].delta = signal * (1 - signal) * weightDelta
			else
				cells[j].delta = (outputs[j] - signal) * signal * (1 - signal)
			end
		end
	end

	for i = 2, numSelf do
		self[i].bias = self[i].cells[#self[i].cells].delta * learningRate
		for j = 1, #self[i].cells do
			for k = 1, #self[i].cells[j].weights do
				local weights = self[i].cells[j].weights
				weights[k] = weights[k] + self[i].cells[j].delta * learningRate * self[i-1].cells[k].signal
			end
		end
	end
end

function Izzy:loadNetwork(file) -- beolvassa a hálót és aktiválja
	local ann = ser.load(file)
	if ann==nil then return nil end
		ann.bp = Izzy.bp
		ann.activate = Izzy.activate
		for i = 1, #ann do
			for j = 1, #ann[i].cells do
				ann[i].cells[j].activate = Cell.activate
			end
		end
		ann.outputs = Izzy.outputs
	return(ann)
end

function Izzy:saveNetwork(network,file) -- Lementi az hálót
	ser.store(file,network)
	return true
end

function Izzy:outputs() -- Output
	local signals = {}
	for i,v in ipairs(self[#self].cells) do
		signals[i]=v.signal
	end
	return signals
end

return(Izzy)