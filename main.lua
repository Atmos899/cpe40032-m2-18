push = require 'push'
Class = require 'class'
require 'StateMachine'
require 'states/BaseState'
require 'states/CountdownState'
require 'states/PlayState'
require 'states/ScoreState'
require 'states/TitleScreenState'


require 'Bird'
require 'Pipe'
require 'PipePair'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288


local background = love.graphics.newImage('background.png')
local backgroundScroll = 0

local ground = love.graphics.newImage('ground.png')
local groundScroll = 0

local pauseIcon = love.graphics.newImage('pauseicon.png')

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

local BACKGROUND_LOOPING_POINT = 413

scrolling = true
game_pause = false

function love.load()
  
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())
    love.window.setTitle('Fifty Bird')
    smallFont = love.graphics.newFont('font.ttf', 8)
    mediumFont = love.graphics.newFont('flappy.ttf', 14)
    flappyFont = love.graphics.newFont('flappy.ttf', 28)
    hugeFont = love.graphics.newFont('flappy.ttf', 56)
    love.graphics.setFont(flappyFont)
    sounds = {
        ['jump'] = love.audio.newSource('jump.wav', 'static'),
        ['explosion'] = love.audio.newSource('explosion.wav', 'static'),
        ['hurt'] = love.audio.newSource('hurt.wav', 'static'),
        ['score'] = love.audio.newSource('score.wav', 'static'),
        ['pauseSound'] = love.audio.newSource('pausesound.wav', 'static'),


        ['music'] = love.audio.newSource('marios_way.mp3', 'static')
    }


        sounds['music']:setLooping(true)
        sounds['music']:play()


  
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })


    gStateMachine = StateMachine {
        ['title'] = function() return TitleScreenState() end,
        ['countdown'] = function() return CountdownState() end,
        ['play'] = function() return PlayState() end,
        ['score'] = function() return ScoreState() end
    }
    gStateMachine:change('title')

 
    love.keyboard.keysPressed = {}
     love.mouse.buttonsPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    
 
    love.keyboard.keysPressed[key] = true

    if key == 'escape' then
        love.event.quit()
    end
    
    if key == 'p' and game_pause == false then
        game_pause = true
        sounds['pauseSound']:play()
        sounds['music']:stop()
    elseif key == 'p' and game_pause == true then
        game_pause = false
        sounds['music']:play()
    end
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end
function love.mousepressed(x, y, button)
    love.mouse.buttonsPressed[button] = true
end



function love.mouse.wasPressed(button)
    return love.mouse.buttonsPressed[button]
end

function love.update(dt)
  if game_pause == false then
  if scrolling then
        backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT
        groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH
    end
gStateMachine:update(dt)
love.keyboard.keysPressed = {}
love.mouse.buttonsPressed = {}


   end
end

function love.draw()
    push:start()
   
    love.graphics.draw(background, -backgroundScroll, 0)
    gStateMachine:render()
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)

    if game_pause == true then
        love.graphics.print("PAUSED", VIRTUAL_WIDTH/2 - 50, VIRTUAL_HEIGHT/2 + 50, 0, 2)
        love.graphics.draw(pauseIcon, VIRTUAL_WIDTH/2 - 20, VIRTUAL_HEIGHT/2 )
    end

    push:finish()
end