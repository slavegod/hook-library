# hook-library
simple library I'm working on to easier add hooks and connections.

# example for you spastics

hooking.Add(
    "PlayerJoined",
    "joined",
    function(player)
        print(player.Name .. " has joined.")
    end,
    true
)
