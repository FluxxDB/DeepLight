if (game:GetService("RunService"):IsServer()) then
	local Knit = require(script.KnitServer)
	Knit.Modules = game.ServerScriptService.Server.Modules
	Knit.Shared = game.ReplicatedStorage.Shared
	_G.Knit = Knit
	return Knit
else
	script.KnitServer:Destroy()
	
	local Knit = require(script.KnitClient)
	Knit.Modules = game.StarterPlayer.StarterPlayerScripts.Client.Modules
	Knit.Shared = game.ReplicatedStorage.Shared
	_G.Knit = Knit

	return Knit
end