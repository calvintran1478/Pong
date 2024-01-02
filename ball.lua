Ball = Entity:extend()

function Ball:new(x, y, size)
	Ball.super.new(self, x, y, size, size, 0)
	self.size = size
end

function Ball:update(dt)
	-- Move ball based on its speed
	Ball.super.update(self, dt)

	-- Prevent ball from moving out of the window
	if self.y < 0 or self.y + self.size > love.graphics.getHeight() then
		self.v_y = -self.v_y
	end
end
