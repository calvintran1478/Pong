Player = Entity:extend()

function Player:new(x, y, width, height, speed, name, up_key, down_key)
	Player.super.new(self, x, y, width, height, 10)
	self.speed = speed
	self.name = name
	self.up_key = up_key
	self.down_key = down_key
	self.score = 0
end

function Player:update(dt)
	-- Move player based on keyboard input
	if love.keyboard.isDown(self.up_key) then
		self.v_y = -self.speed
	elseif love.keyboard.isDown(self.down_key) then
		self.v_y = self.speed
	else
		self.v_y = 0
	end
	Player.super.update(self, dt)

	-- Prevent player from moving out of the window
	local window_height = love.graphics.getHeight()
	if self.y < 0 then
		self.y = 0
	elseif self.y + self.height > window_height then
		self.y = window_height - self.height
	end
end
