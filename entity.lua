Entity = Object:extend()

function Entity:new(x, y, width, height, strength)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.strength = strength

	-- Save previous state for resolving collisions
	self.prev = {}
	self.prev.x = self.x
	self.prev.y = self.y

	-- Velocities
	self.v_x = 0
	self.v_y = 0
end

function Entity:wasVerticallyAligned(e)
	return self.prev.y < e.prev.y + e.height and self.prev.y + self.height > e.prev.y
end

function Entity:wasHorizontallyAligned(e)
	return self.prev.x < e.prev.x + e.width and self.prev.x + self.width > e.prev.x
end

function Entity:checkCollision(e)
	return self.x + self.width > e.x
	and self.x < e.x + e.width
	and self.y + self.height > e.y
	and self.y < e.y + e.height
end

function Entity:resolveCollision(e)
	-- The weaker entity resolves the collision
	if self.strength > e.strength then
		return e:resolveCollision(self)
	end

	if self:checkCollision(e) then
		-- Quantify overlap between entities and adjust positions accordingly
		local pushback
		if self:wasVerticallyAligned(e) then
			if self.x + self.width / 2 < e.x + e.width / 2 then
				pushback = -(self.x + self.width - e.x)
			else
				pushback = e.x + e.width - self.x
			end
			self.x = self.x + pushback
		elseif self:wasHorizontallyAligned(e) then
			if self.y + self.height / 2 < e.y + e.height / 2 then
				pushback = -(self.y + self.height - e.y)
			else
				pushback = e.y + e.height - self.y
			end
			self.y = self.y + pushback
		end
		return true
	end
	return false
end

function Entity:update(dt)
	self.x = self.x + self.v_x * dt
	self.y = self.y + self.v_y * dt
end

function Entity:draw()
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end
