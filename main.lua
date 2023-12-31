function initialize_game()
    local window_width, window_height = love.graphics.getDimensions()
    local margin = 10

    -- Initialize player 1 position and velocity
    player1.x = margin
    player1.y = (window_height - player1.height) / 2
    player1.v_x = 0
    player1.v_y = 0

    -- Initialize player 2 position and velocity
    player2.x = window_width - player2.width - margin
    player2.y = (window_height - player2.height) / 2
    player2.v_x = 0
    player2.v_y = 0

    -- Initalize ball position and velocity
    local offset = love.math.random(-game.ball_spawn_range, game.ball_spawn_range)
    ball.x = (window_width - ball.size) / 2
    ball.y = (window_height - ball.size) / 2 + offset
    ball.touched = false
    if love.math.random(0, 1) == 0 then
        ball.v_x = game.untouched_ball_speed
    else
        ball.v_x = -game.untouched_ball_speed
    end
    ball.v_y = love.math.random(-game.ball_initial_vy_range, game.ball_initial_vy_range)
end

function love.keypressed(key)
    -- Restart game
    if key == "r" and game.winner then
        love.load()
    -- Mute/unmute audio
    elseif key == "m" then
        game.mute = not game.mute
    end
end

function love.load()
    -- Imports
    Object = require "classic"
    require "entity"
    require "player"
    require "ball"

    -- Game parameters
    local player_width = 20
    local player_height = 100
    local player_speed = 520
    local ball_size = 25
    game = {
        untouched_ball_speed = 250,
        initial_touched_ball_speed = 500,
        ball_speedup = 5,
        ball_spawn_range = 120,
        ball_initial_vy_range = 100,
        control_factor = 0.20,
        score_goal = 5,
        mute = false,
    }

    -- Initialize game
    player1 = Player(0, 0, player_width, player_height, player_speed, "Player 1", "w", "s")
    player2 = Player(0, 0, player_width, player_height, player_speed, "Player 2", "up", "down")
    ball = Ball(0, 0, ball_size)
    initialize_game()

    -- Text fonts and Sound Effects
    normal_font = love.graphics.newFont(24)
    larger_font = love.graphics.newFont(40)
    sfx = love.audio.newSource("sfx/ping_pong_8bit_plop.ogg", "static")

    -- Add players and ball to a list of game objects
    objects = {}
    table.insert(objects, player1)
    table.insert(objects, player2)
    table.insert(objects, ball)
end

function love.update(dt)
    if not game.winner then
        -- Update position of ball and players
        for _,obj in ipairs(objects) do
            obj:update(dt)
        end

        -- Resolve collisions between ball and players
        local colliding_player
        if ball:resolveCollision(player1) then
            colliding_player = player1
        elseif ball:resolveCollision(player2) then
            colliding_player = player2
        end

        if colliding_player then
            -- Reflect ball to the other direction
            local speedup
            if not ball.touched then
                ball.touched = true
                speedup = game.initial_touched_ball_speed - game.untouched_ball_speed
            else
                speedup = game.ball_speedup
            end
            ball:reflect(speedup)
            ball.v_y = ball.v_y + colliding_player.v_y * game.control_factor

            -- Play sound effect
            if not game.mute then
                sfx:play()
            end
        end

        -- Check if any players have scored
        local scoring_player
        if ball.x < 0 then
            scoring_player = player2
        elseif ball.x + ball.size > love.graphics.getWidth() then
            scoring_player = player1
        end

        -- If a player has scored, reset game positions or declare winner
        if scoring_player then
            scoring_player.score = scoring_player.score + 1
            if scoring_player.score == game.score_goal then
                game.winner = scoring_player
            else
                initialize_game()
            end
        end
    end
end

function love.draw()
    local window_width, window_height = love.graphics.getDimensions()
    if not game.winner then
        -- Display score
        love.graphics.setFont(normal_font)
        love.graphics.print(player1.score, window_width * 0.25, 20)
        love.graphics.print(player2.score, window_width * 0.75, 20)

        -- Line separator
        local num_dashes = 12
        local line_height = window_height / (num_dashes * 2)
        local center = window_width / 2
        for i=0,num_dashes-1 do
            love.graphics.line(center, (2 * i) * line_height, center, (2 * i + 1) * line_height)
        end

        -- Display players and ball
        for _,obj in ipairs(objects) do
            obj:draw()
        end
    else
        -- Display winner
        local winner_text = string.format("%s wins!", game.winner.name)
        local play_again_text = "Press R to play again"
        local font_height = larger_font:getHeight()
        local limit = 500

        love.graphics.setFont(larger_font)
        love.graphics.printf(winner_text, (window_width - larger_font:getWidth(winner_text)) / 2, (window_height - font_height) / 2 - 60, limit, "left")
        love.graphics.printf(play_again_text, (window_width - larger_font:getWidth(play_again_text)) / 2, (window_height - font_height) / 2 + 30, limit, "left")
    end
end
