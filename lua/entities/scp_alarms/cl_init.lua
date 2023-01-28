--[[
    SCP Alarms (Online) - A sound player for Garry's Mod
    Copyright (C) 2019-2021  Cyborger (pro.cyborg3r@gmail.com)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

include("shared.lua")

function ENT:Draw()
	self:DrawModel()
	if not SCPALARM.IsEntityInRange( self, 100000, 0.5 ) then
    	return
  	end
	local tPos = self:GetPos() + ( self:GetUp()*3.065 ) + ( self:GetForward()*-3 ) + ( self:GetRight()*0.35 )
	local tAng = self:GetAngles()
	tAng:RotateAroundAxis( tAng:Right(), 0 )
	tAng:RotateAroundAxis( tAng:Up(), 90 )
	tAng:RotateAroundAxis( tAng:Forward(), 0 )

	cam.Start3D2D( tPos, tAng, 0.05 )
	surface.SetDrawColor( SCPALARM.color.Grey40 )
    surface.DrawRect( -211, 0, 435, 72 )
	draw.SimpleTextOutlined( SCPALARM.lang[SCPALARM.config.lang].addonName, "SCPALARM::FONT2D3DTITLE", 6, 17, SCPALARM.color.White255, 1, 1, 2.5, SCPALARM.color.Black0 )
	draw.SimpleTextOutlined( string.format( SCPALARM.lang[SCPALARM.config.lang].press, input.LookupBinding( "+use" ) ), "SCPALARM::FONT2D3DTEXT", 6, 52, SCPALARM.color.White255, 1, 1, 2.5, SCPALARM.color.Black0 )
	cam.End3D2D()
end
