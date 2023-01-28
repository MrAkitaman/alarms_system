timer.Simple( 0 , function()
http.Fetch( "https://web7458.holycloud.ovh/menu/sound/blinding-lights-arabic-version.mp3",

	-- onSuccess function
	function( body, length, headers, code )
		-- The first argument is the HTML we asked for.
        print(body)
        print("---------------------------------------")
        print(length)
        print("---------------------------------------")
        print(headers)
        print("---------------------------------------")
        print(code)
	end,

	-- onFailure function
	function( message )
		-- We failed. =(
		print( message )
	end
)
end)
