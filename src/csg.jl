# csg.jl

import Base.hypot

export volume,
       sphere,
       cylinderX,
       cylinderY,
       cylinderZ,
       box

function volume(f, x_min,y_min,z_min,x_max,y_max,z_max, scale)
	x_rng = x_max - x_min
	y_rng = y_max - y_min
	z_rng = z_max - z_min
	
	nx, ny, nz = int(scale*x_rng), int(scale*y_rng), int(scale*z_rng)

	vol = zeros(Float64, (nx,ny,nz))

	for i = 1:nx, j = 1:ny, k = 1:nz
		x = x_min + x_rng*(i/nx)
		y = y_min + y_rng*(j/ny)
		z = z_min + z_rng*(k/nz)
	
		vol[i,j,k] = f(x,y,z)
	end
	
	vol
end


function hypot(x,y,z)
	sqrt(x^2 + y^2 + z^2)
end


function sphere(x,y,z, sx,sy,sz,sr)
	hypot(x-sx, y-sy, z-sz) - sr
end


function cylinderX(x,y,z, cy,cz,cr,cxmin,cxmax)
	vr = hypot(y-cy,z-cz) - cr
	vx = max(cxmin-x, x-cxmax)
	max(vr,vx)
end


function cylinderY(x,y,z, cx,cz,cr,cymin,cymax)
	vr = hypot(x-cx,z-cz) - cr
	vy = max(cymin-y, y-cymax)
	max(vr,vy)
end


function cylinderZ(x,y,z, cx,cy,cr,czmin,czmax)
	vr = hypot(x-cx,y-cy) - cr
	vz = max(czmin-z, z-czmax)
	max(vr,vz)
end


function box(x,y,z, x_min,y_min,z_min,x_max,y_max,z_max)
	vx = max(x_min-x, x-x_max)
	vy = max(y_min-y, y-y_max)
	vz = max(z_min-z, z-z_max)
	max(vx, vy, vz)
end

