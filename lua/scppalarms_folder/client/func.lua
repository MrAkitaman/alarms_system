--Credit : Timmy - https://www.gmodstore.com/users/timmythenobody/addons
function SCPALARM.IsEntityInRange( eEnt, iRange, fDelay )
    if not IsValid( eEnt ) then
        return
    end

    if ( CurTime() > ( eEnt.iNextDistCheck or 0 ) ) then
        if not IsValid( LocalPlayer() ) then
            return
        end

        eEnt.iLastDist = LocalPlayer():GetPos():DistToSqr( eEnt:GetPos() )
        eEnt.iNextDistCheck = ( CurTime() + ( fDelay or 1 ) )
    end

    return ( eEnt.iLastDist <= iRange )
end

--Credit : Timmy - https://www.gmodstore.com/users/timmythenobody/addons
function SCPALARM.DrawLoader( iX, iY, iW, iH, iPoints )
    local iPoints = ( iPoints or 6 )
    local iBranchH = ( iW / ( iPoints * 2 ) )

    for i = 1, iPoints do
        local iBranchX = ( iX + ( ( i - 1 ) * ( iBranchH * 2 ) ) )
        local iBranchY = ( iY + TimedSin( 1, ( iH * .5 ), 0, ( i * .5 ) ) )
        local iScale = ( iBranchY * iBranchH / iH )

        surface.DrawRect( iBranchX, iBranchY, iScale, iScale )
    end
end

function SCPALARM.PlaySound(iCat, iSong, bLoop)
    local sUrl = SCPALARM.config.sound[iCat].song[iSong].link
    sound.PlayURL(sUrl, "noblock noplay", function( sData )
    	if ( IsValid( sData ) ) then
            sData:EnableLooping( bLoop or false )
    		sData:Play()
            SCPALARM.SoundName = SCPALARM.config.sound[iCat].song[iSong].name
    	else
    		LocalPlayer():ChatPrint( "Invalid URL!" )
    	end
    end)
end
