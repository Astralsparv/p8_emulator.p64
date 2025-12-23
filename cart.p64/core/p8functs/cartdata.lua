--[[pod_format="raw",created="2025-12-20 22:37:24",modified="2025-12-23 18:16:03",revision=49]]
local cartdata
local cartdataID=""
local cartdataPath=fs.cartdata
local cartdataDirty=false

p8env.cartdata=function(id)
	if (cartdataID=="") then
		cartdataID=id
		cartdataPath..=cartdataID..".pod"
		cartdata=fetch(cartdataPath)
		if (cartdata==nil) then --initialise cartdata
			cartdata={}
			--initialise 0-indexed cartdata
			for i=0, 63 do
				cartdata[i]=0
			end
			cartdataDirty=true
		end
	else
		error("cartdata() can only be called once")
	end
end

p8env.dget=function(k)
	if (cartdataID=="") then
		error("dget called before cartdata()")
	else
		return cartdata[k]
	end
end

p8env.dset=function(k,v)
	if (cartdataID=="") then
		error("dset called before cartdata()")
	else
		if (cartdata[k]!=v) then --only write when needed
			cartdata[k]=v
			cartdataDirty=true
		end
	end
end

function updateCartdata()
	if (cartdataDirty) then
		store(cartdataPath,cartdata)
		cartdataDirty=false
	end
end