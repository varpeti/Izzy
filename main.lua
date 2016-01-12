local Izzy = require('Izzy')

function love.load()
	--ablak beállítások
	goFullscreen()
	Asz=love.graphics.getWidth()
	Am=love.graphics.getHeight()
	Aksz=Asz/2 Akm=Am/2
	love.window.setTitle("Xor")

	MI = Izzy:loadNetwork("brain.dna")

  	if MI==nil then
		MI = Izzy:new({2,3, 1}, 50)
		print("uj")
	else 
		print("betoltve")
	end

  	time = 0
  	tanper = 0

end

function love.update(dt)
	time=time+dt
	MI:bp({0,0},{0})
	MI:bp({1,0},{1})
	MI:bp({0,1},{1})
	MI:bp({1,1},{0})
	tanper=tanper+1
	if time>=10 then
		time=time-10
		Izzy:saveNetwork(MI,"brain.dna")
	end
end

function love.draw()
	local mag=0
	for j=0,1 do
			for i=0,1 do
			MI:activate({i,j})
			local t = MI:outputs()
			local text = "Output: "
			for a,v in ipairs(t) do
				if v>0.5 then
					text=text..a..":[1:"..v.."] "
				else
					text=text..a..":[0:"..v.."] "
				end
			end
			mag = mag+1
			love.graphics.print("Input: "..i.." "..j.." "..text,10,20*mag)
		end
	end
	love.graphics.print("0 0 |  0",350,20*1)
	love.graphics.print("1 0 |  1",350,20*2)
	love.graphics.print("0 1 |  1",350,20*3)
	love.graphics.print("1 1 |  0",350,20*4)
	love.graphics.print("Tanitási periódus: "..tanper,10,Am-20)


end

function love.keypressed(key)
   if key == "escape" then
      love.event.quit()
      Izzy:saveNetwork(MI,"brain.dna")
   end
  if key == "menu" or key=="space" then
  end
end

-- teljes képernyő

function getMaxResolution()
  local modes = love.window.getFullscreenModes()
  table.sort(modes, function(a, b) return a.width*a.height > b.width*b.height end) -- sort from largest to smallest
  return modes[1]
end

function goFullscreen()
  local maxRes = getMaxResolution()
  love.window.setMode(
    maxRes.width,
    maxRes.height,
    {
      fullscreen = true,
      vsync = true
    }
  )
end