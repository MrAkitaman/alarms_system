--3D2D
surface.CreateFont( "SCPALARM::FONT2D3DTITLE", {
	font = "CloseCaption_Bold",
	size = 35,
	weight = 700,
	antialias = true,
} )
surface.CreateFont( "SCPALARM::FONT2D3DTEXT", {
	font = "CloseCaption_Bold",
	size = 25,
	weight = 700,
	antialias = true,
} )

--Derma fonts
local iScrh = ScrH()

surface.CreateFont( "SCPALARM::DermaTitle", {
	font = "Rajdhani Bold",
	size = math.ceil(iScrh/25),
	weight = math.ceil(iScrh),
	antialias = true,
} )
surface.CreateFont( "SCPALARM::Cross", {
	font = "Rajdhani Bold",
	size = math.ceil(iScrh/45),
	weight = 0,
	antialias = true,
} )
surface.CreateFont( "SCPALARM::Text", {
	font = "Rajdhani Regular",
	size = math.ceil(iScrh/40),
	weight = math.ceil(iScrh),
	antialias = true,
} )
