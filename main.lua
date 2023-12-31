function love.load()
    -- Imports
    Object = require "classic"
    require "entity"
    require "player"
    require "ball"

    -- Game parameters
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    local player_width = 20
    local player_height = 100
    local player_speed = 300
    local ball_size = 25
    local ball_speed = 300
    local ball_spawn_range = 120
    local ball_initial_vy_range = 100
    local score_goal = 5
    local margin = 10

    -- Initialize players
    player1 = Player(margin, (window_height - player_height) / 2, player_width, player_height, player_speed, "w", "s")
    player2 = Player(window_width - player_width - margin, (window_height - player_height) / 2, player_width, player_height, player_speed, "up", "down")

    -- Place ball in the middle of the screen
    local offset = love.math.random(-ball_spawn_range, ball_spawn_range)
    ball = Ball((window_width - ball_size) / 2, (window_height - ball_size) / 2 + offset, ball_size)

    -- Set ball to start at initial random velocity
    if love.math.random(0, 1) == 0 then
        ball.v_x = ball_speed
    else
        ball.v_x = -ball_speed
    end
    ball.v_y = love.math.random(-ball_initial_vy_range, ball_initial_vy_range)

    -- Add players and ball to a list of game objects
    objects = {}
    table.insert(objects, player1)
    table.insert(objects, player2)
    table.insert(objects, ball)
end

function love.update(dt)
    for i,obj in ipairs(objects) do
        obj:update(dt)
    end

    -- Resolve collisions between ball and players
    if ball:resolveCollision(player1) then
        ball.v_x = -ball.v_x
        ball.v_y = ball.v_y + player1.v_y / 2
    elseif ball:resolveCollision(player2) then
        ball.v_x = -ball.v_x
        ball.v_y = ball.v_y + player2.v_y / 2
    end
end

function love.draw()
    for i,obj in ipairs(objects) do
        obj:draw()
    end
end
