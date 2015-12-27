local MI = {}
math.randomseed(os.time())

--[[
MI (Lista)
	EGYED (Tábal)
		NEURONOK (Lista)
			NEURON (Tábla)
				Kapcs (Lista)
					suly (-3<x<3)
				Ertek (0<x<1)
				Tipus (0 Erzekelo 1 Vegrehajto 2 Szamolo)
		FITNES (x>=0 or x=-1, -1=végtelen, kisebb-jobb)
]]


local function UjEgyed(NEURONOK) --NEURONOK ból hoz létre EGYED-et
	local EGYED = {}
	EGYED.NEURONOK=NEURONOK
	EGYED.FITNES=-1
	table.insert(MI,EGYED)
	return #MI
end

function MIUjEgyed(Erzekelo,Szamolo,Vegrehajto) --Egy random EGYED-et hoz létre, paraméterei: mennyi ijen típusú neuron legyen (INPUT, HIDEN, OUTPUT)
	local NEURONOK = {}
	local nsz = Szamolo+Erzekelo+Vegrehajto --nsz maximális neuronszám
	for i=1,nsz do
		local NEURON = {}
		NEURON.Ertek = 0
		NEURON.Kapcs = {}
		if i<=Erzekelo then --elejére input
			NEURON.Tipus = 0
		elseif nsz-i<Vegrehajto then --végére output
			NEURON.Tipus = 1
		else
			NEURON.Tipus = 2 --egyébként hiden
		end

		for j=1,#NEURONOK do --csak az elötte létrejött neuronokkal lehet kapcsolata
			--(lentebb) bejövő kapcsolatok: input: nincs | output: input,hiden | hiden: input  
			if NEURON.Tipus~=0 and ( (NEURON.Tipus==1 and NEURONOK[j].Tipus~=1) or (NEURON.Tipus==2 and NEURONOK[j].Tipus==0) ) then 
				if math.random(0,2)==0 then 
					table.insert(NEURON.Kapcs,math.random(-30,30)/10) -- j+1 ID-jű kapcsolat, suly: [-3;3] 
				else
					table.insert(NEURON.Kapcs,0) --1/2-ed esélyel 0 lesz a kapcs súlya ergo mintha nem lenne kapcsolat
				end
			end
		end

		if NEURON.Tipus~=0 then
				table.insert(NEURON.Kapcs,math.random(-10,20)/10)-- Az "utolsó kapcsolat" ergo önsúly (értéke = -1)
		end

		table.insert(NEURONOK,NEURON)
	end
	UjEgyed(NEURONOK)
end

function MIkiir() --Kigyüjti egy stringbe az összes egyed információit, rendezve
	local text = ""
	for esz,EGYED in ipairs(MI) do
		text=text.."EGYED: "..esz.."\n	NEURONOK:"
		for nsz,NEURON in ipairs(EGYED.NEURONOK) do
			text=text.."\n		NEURON: "..nsz
			text=text.."\n		 	Ertek: "..NEURON.Ertek.."\n		 	Tipus: "..NEURON.Tipus.."\n			"
			for Kapcs,suly in pairs(NEURON.Kapcs) do
				text=text.." Kapcs: "..Kapcs.." Suly: "..suly
			end
		end
		text=text.."\n	FITNES: "..EGYED.FITNES.."\n"
	end
	return text
end

function MIegyedDrawCircle(esz,x,y) --Körbe rajzolja egy egyed  neuronjait és kapcsolatait
	if esz>#MI or esz<0 then return end

	local NEURONOK = MI[esz].NEURONOK
	local coords = {}
	local sz = (3.141592653589793238462643383279/180) * (-90)
	local h = #NEURONOK+1

	for i=1,h*2,2 do 
		coords[i]=math.cos(sz)*h*10+x
		coords[i+1]=math.sin(sz)*h*10+y
		sz=sz- (3.141592653589793238462643383279*2/h)
	end
	for nsz,NEURON in ipairs(NEURONOK) do
		for i,suly in ipairs(NEURON.Kapcs) do
			if i==#NEURON.Kapcs then break end
			if suly>0 then
				love.graphics.setColor(0,255,0,255)
				love.graphics.line(coords[nsz*2-1],coords[nsz*2],coords[i*2-1],coords[i*2]) 
			elseif suly<0 then
				love.graphics.setColor(255,0,0,255)
				love.graphics.line(coords[nsz*2-1],coords[nsz*2],coords[i*2-1],coords[i*2]) 
			--else
			--	love.graphics.setColor(99,99,99,255)
			--	love.graphics.line(coords[nsz*2-1],coords[nsz*2],coords[i*2-1],coords[i*2])
			end
		end
		if NEURON.Tipus==0 then
			love.graphics.setColor(0,128,255,255)
		elseif NEURON.Tipus==1 then
			love.graphics.setColor(255,255,0,255)
		else
			love.graphics.setColor(255,128,0,255)
		end
		love.graphics.circle("fill",coords[nsz*2-1],coords[nsz*2],10,15)
		love.graphics.setColor(255,255,255,255)
		local Ertek = 0
		if NEURON.Ertek>0.5 then Ertek=1 else Ertek=0 end
		if NEURON.Tipus~=0 then 
			love.graphics.print("Id: "..nsz.."\nErtek: "..Ertek.."\nÖnsuly: "..NEURON.Kapcs[#NEURON.Kapcs],coords[nsz*2-1],coords[nsz*2]) 
		else
			love.graphics.print("Id: "..nsz.."\nErtek: "..Ertek,coords[nsz*2-1],coords[nsz*2])
		end
	end
end

function MIegyedDrawType(esz,x,y)
	if esz>#MI or esz<0 then return end

	local NEURONOK = MI[esz].NEURONOK
	local coords = {}
	local h = #NEURONOK
	local ly = {0,0,-50} 

	for i=1,#NEURONOK*2,2 do 
		if NEURONOK[(i+1)/2].Tipus==0 then
			coords[i]=x-200
			coords[i+1]=ly[1]+y
			ly[1]=ly[1]+50
		elseif NEURONOK[(i+1)/2].Tipus==1 then
			coords[i]=x+200
			coords[i+1]=ly[2]+y
			ly[2]=ly[2]+50
		else
			coords[i]=x
			coords[i+1]=ly[3]+y
			ly[3]=ly[3]-50
		end
	end
	for nsz,NEURON in ipairs(NEURONOK) do
		for i,suly in ipairs(NEURON.Kapcs) do
			if i==#NEURON.Kapcs then break end
			if suly>0 then
				love.graphics.setColor(0,255,0,255)
				love.graphics.line(coords[nsz*2-1],coords[nsz*2],coords[i*2-1],coords[i*2]) 
			elseif suly<0 then
				love.graphics.setColor(255,0,0,255)
				love.graphics.line(coords[nsz*2-1],coords[nsz*2],coords[i*2-1],coords[i*2]) 
			--else
			-- 	love.graphics.setColor(99,99,99,255)
			--	love.graphics.line(coords[nsz*2-1],coords[nsz*2],coords[i*2-1],coords[i*2])
			end
		end
		if NEURON.Tipus==0 then
			love.graphics.setColor(0,128,255,255)
		elseif NEURON.Tipus==1 then
			love.graphics.setColor(255,255,0,255)
		else
			love.graphics.setColor(255,128,0,255)
		end
		love.graphics.circle("fill",coords[nsz*2-1],coords[nsz*2],10,15)
		love.graphics.setColor(255,255,255,255)
		local Ertek = 0
		if NEURON.Ertek>0.5 then Ertek=1 else Ertek=0 end
		if NEURON.Tipus~=0 then 
			love.graphics.print("Id: "..nsz.."\nErtek: "..Ertek.."\nÖnsuly: "..NEURON.Kapcs[#NEURON.Kapcs],coords[nsz*2-1],coords[nsz*2]) 
		else
			love.graphics.print("Id: "..nsz.."\nErtek: "..Ertek,coords[nsz*2-1],coords[nsz*2])
		end
	end
end

function MIupdate(esz) --Értéket számol
	local EGYED = MI[esz]
	local NEURONOK = EGYED.NEURONOK
	for nsz,NEURON in ipairs(NEURONOK) do
		if NEURON.Tipus~=0 then  -- Érzékelőnek nincs számított értéke
			local osz = NEURON.Kapcs[#NEURON.Kapcs]
			local sza = -1 * osz -- -1 az alapértéke * önsúlya
			for Kapcs,suly in ipairs(NEURON.Kapcs) do --Számláló és nevező kiszámolása (súlyozottátlaghoz)
				if Kapcs==#NEURON.Kapcs then break end --itt Szummázok
				sza = sza + NEURONOK[Kapcs].Ertek*suly  --számláló
				osz = osz + suly --nevező
			end

			if NEURON.Tipus==1 then 
				if (sza/osz)>0 then NEURON.Ertek=1 else NEURON.Ertek=0 end --Ha output akkor 1 vagy 0 a végeredmény
			else --Ha hidden akkor 1 és 0 közötti érték a végeredmény
				if osz~=0 then NEURON.Ertek = 1/(1+math.exp(1)^-(sza/osz)) else NEURON.Ertek=0 end --Képlet:  1/(1+e^-(Szumma(érték*súly)/Szumma(súly))) | ÉT: R | ÉK: [0;1]
			end
		end
	end
end

function MIinput(esz,id,et) -- Az input neuron értékét állítja
	local i = 1
	local NEURONOK = MI[esz].NEURONOK
	for nsz,NEURON in ipairs(NEURONOK) do
		if NEURON.Tipus==0 then 
			if i==id then NEURON.Ertek = et break end
			i=i+1
		else 
			break
		end
	end
end

function MIoutput(esz,id) --Visszaadja az output neuron értékét
	local i = 1
	local NEURONOK = MI[esz].NEURONOK
	for nsz=#NEURONOK,1,-1 do
		if NEURONOK[nsz].Tipus==1 then 
			if i==id then return NEURONOK[nsz].Ertek end
			i=i+1
		else 
			return -1
		end
	end
end

function MIsetFitnes(esz,FITNES) --Beállítja az egyed fitneszét
	MI[esz].FITNES=FITNES
end

function MIgetFitnes(esz) --Vissza adja az egyed fitneszét
	return MI[esz].FITNES
end

--Nem enyim: (http://lua-users.org/wiki/SaveTableToFile)

   local function exportstring( s )
      return string.format("%q", s)
   end

   --// The Save Function
   local function tablesave(  tbl,filename )
      local charS,charE = "   ","\n"
      local file,err = io.open( filename, "wb" )
      if err then return err end

      -- initiate variables for save procedure
      local tables,lookup = { tbl },{ [tbl] = 1 }
      file:write( "return {"..charE )

      for idx,t in ipairs( tables ) do
         file:write( "-- Table: {"..idx.."}"..charE )
         file:write( "{"..charE )
         local thandled = {}

         for i,v in ipairs( t ) do
            thandled[i] = true
            local stype = type( v )
            -- only handle value
            if stype == "table" then
               if not lookup[v] then
                  table.insert( tables, v )
                  lookup[v] = #tables
               end
               file:write( charS.."{"..lookup[v].."},"..charE )
            elseif stype == "string" then
               file:write(  charS..exportstring( v )..","..charE )
            elseif stype == "number" then
               file:write(  charS..tostring( v )..","..charE )
            end
         end

         for i,v in pairs( t ) do
            -- escape handled values
            if (not thandled[i]) then
            
               local str = ""
               local stype = type( i )
               -- handle index
               if stype == "table" then
                  if not lookup[i] then
                     table.insert( tables,i )
                     lookup[i] = #tables
                  end
                  str = charS.."[{"..lookup[i].."}]="
               elseif stype == "string" then
                  str = charS.."["..exportstring( i ).."]="
               elseif stype == "number" then
                  str = charS.."["..tostring( i ).."]="
               end
            
               if str ~= "" then
                  stype = type( v )
                  -- handle value
                  if stype == "table" then
                     if not lookup[v] then
                        table.insert( tables,v )
                        lookup[v] = #tables
                     end
                     file:write( str.."{"..lookup[v].."},"..charE )
                  elseif stype == "string" then
                     file:write( str..exportstring( v )..","..charE )
                  elseif stype == "number" then
                     file:write( str..tostring( v )..","..charE )
                  end
               end
            end
         end
         file:write( "},"..charE )
      end
      file:write( "}" )
      file:close()
   end
   
   --// The Load Function
   local function tableload( sfile )
      local ftables,err = loadfile( sfile )
      if err then return _,err end
      local tables = ftables()
      for idx = 1,#tables do
         local tolinki = {}
         for i,v in pairs( tables[idx] ) do
            if type( v ) == "table" then
               tables[idx][i] = tables[v[1]]
            end
            if type( i ) == "table" and tables[i[1]] then
               table.insert( tolinki,{ i,tables[i[1]] } )
            end
         end
         -- link indices
         for _,v in ipairs( tolinki ) do
            tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
         end
      end
      return tables[1]
   end

-- EnnyiM:

function MIlement(nev) --lemeti az összes egyed információit
	tablesave(MI,nev)
end

function MIbeolvas(nev) --vissza olvassa az összes egyed információját
	if not io.open(nev,"r") then return 0 end
	MI = tableload(nev)
	return #MI
end

function MIszelektal(megmarad) --elitista szelektálás

	table.sort(MI, function(a,b) return a.FITNES<b.FITNES end) -- növekvő sorba rendezés

	
	while megmarad<#MI do
		table.remove(MI,#MI)
	end

	return #MI
end

function MImutal(ennyit) -- Mutálás (új egyedet hoz létre)

	while ennyit>0 do
		local esz = math.random(1,#MI)
		local nsz = math.random(1,#MI[esz].NEURONOK)
		local ksz = math.random(1,#MI[esz].NEURONOK[nsz].Kapcs)

		MI[UjEgyed(MI[esz].NEURONOK)].NEURONOK[nsz].Kapcs[ksz] = math.random(-30,30)/10
		ennyit=ennyit-1
	end
	return #MI
end

function MIkeresztez(ennyit) -- Kersztez random egyedet random egyeddel (fele-fele kapcsolat alapon)
	local mesz = #MI
	while ennyit>0 do
		local esz1 = math.random(1,mesz)
		local esz2 = math.random(1,mesz)
		local UJNEURONOK = {}
		for nsz=1,#MI[esz1].NEURONOK do
			UJNEURONOK[nsz]= {}
			UJNEURONOK[nsz].Kapcs = {}
			UJNEURONOK[nsz].Ertek = 0
			UJNEURONOK[nsz].Tipus = MI[esz1].NEURONOK[nsz].Tipus
			for Kapcs=1,#MI[esz1].NEURONOK[nsz].Kapcs do
				if Kapcs<(#MI[esz1].NEURONOK[nsz].Kapcs/2) then
					table.insert(UJNEURONOK[nsz].Kapcs,MI[esz1].NEURONOK[nsz].Kapcs[Kapcs]) --első egyed kapcsolatai
				else
					table.insert(UJNEURONOK[nsz].Kapcs,MI[esz2].NEURONOK[nsz].Kapcs[Kapcs]) --második egyed kapcsolatai
				end
			end
		end
		UjEgyed(UJNEURONOK)
		ennyit=ennyit-1
	end
	return #MI
end