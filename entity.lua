Entity = Object:extend()

function Entity:new(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.v_x = 0
	self.v_y = 0
end

function Entity:checkCollision(e)
	return self.x + self.width > e.x
	and self.x < e.x + e.width
	and self.y + self.height > e.y
	and self.y < e.y + e.height
end

function Entity:update(dt)
	self.x = self.x + self.v_x * dt
	self.y = self.y + self.v_y * dt
end

function Entity:draw()
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end
