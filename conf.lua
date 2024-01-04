function love.conf(t)
	t.window.title = "Pong"
	t.version = "11.5"

	-- Disable unused modules
	t.modules.data = false
	t.modules.events = false
	t.modules.image = false
	t.modules.joystick = false
	t.modules.mouse = false
	t.modules.physics = false
	t.modules.system = false
	t.modules.thread = false
	t.modules.touch = false
	t.modules.video = false
end
