function initialize_game()
    local window_width, window_height = love.graphics.getDimensions()

    -- Initialize player 1 position and velocity
    player1.x = game.margin
    player1.y = (window_height - player1.height) / 2
    player1.v_x = 0
    player1.v_y = 0

    -- Initialize player 2 position and velocity
    player2.x = window_width - player2.width - game.margin
    player2.y = (window_height - player2.height) / 2
    player2.v_x = 0
    player2.v_y = 0

    -- Initalize ball position and velocity
    local offset = love.math.random(-game.ball_spawn_range, game.ball_spawn_range)
    ball.x = (window_width - ball.size) / 2
    ball.y = (window_height - ball.size) / 2 + offset
    if love.math.random(0, 1) == 0 then
        ball.v_x = game.initial_ball_speed
    else
        ball.v_x = -game.initial_ball_speed
    end
    ball.v_y = love.math.random(-game.ball_initial_vy_range, game.ball_initial_vy_range)
end

function love.keypressed(key)
    -- Restart game
    if key == "r" and game.winner then
        love.load()
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
    local player_speed = 500
    local ball_size = 25
    game = {
        initial_ball_speed = 500,
        ball_speedup = 5,
        ball_spawn_range = 120,
        ball_initial_vy_range = 100,
        control_factor = 0.20,
        score_goal = 5,
        margin = 10
    }

    -- Initialize game
    player1 = Player(0, 0, player_width, player_height, player_speed, "Player 1", "w", "s")
    player2 = Player(0, 0, player_width, player_height, player_speed, "Player 2", "up", "down")
    ball = Ball(0, 0, ball_size)
    initialize_game()

    -- Text fonts
    normalFont = love.graphics.newFont(16)
    largerFont = love.graphics.newFont(40)

    -- Add players and ball to a list of game objects
    objects = {}
    table.insert(objects, player1)
    table.insert(objects, player2)
    table.insert(objects, ball)
end

function love.update(dt)
    if not game.winner then
        -- Update position of ball and players
        for i,obj in ipairs(objects) do
            obj:update(dt)
        end

        -- Resolve collisions between ball and players
        if ball:resolveCollision(player1) then
            ball.v_x = -ball.v_x + game.ball_speedup
            ball.v_y = ball.v_y + player1.v_y * game.control_factor
        elseif ball:resolveCollision(player2) then
            ball.v_x = -ball.v_x - game.ball_speedup
            ball.v_y = ball.v_y + player2.v_y * game.control_factor
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
        love.graphics.setFont(normalFont)
        love.graphics.print(player1.score, window_width * (1 / 4), 20, 0, 1.5, 1.5)
        love.graphics.print(player2.score, window_width * (3 / 4), 20, 0, 1.5, 1.5)

        -- Line separator
        local num_dashes = 12
        local line_height = window_height / (num_dashes * 2)
        local center = window_width / 2
        for i=0,num_dashes-1 do
            love.graphics.line(center, (2 * i) * line_height, center, (2 * i + 1) * line_height)
        end

        -- Display players and ball
        for i,obj in ipairs(objects) do
            obj:draw()
        end
    else
        -- Display winner
        local winner_text = string.format("%s wins!", game.winner.name)
        local play_again_text = "Press R to play again"
        local font_height = largerFont:getHeight()
        local limit = 500

        love.graphics.setFont(largerFont)
        love.graphics.printf(winner_text, (window_width - largerFont:getWidth(winner_text)) / 2, (window_height - font_height) / 2 - 60, limit, "left")
        love.graphics.printf(play_again_text, (window_width - largerFont:getWidth(play_again_text)) / 2, (window_height - font_height) / 2 + 30, limit, "left")
    end
end
