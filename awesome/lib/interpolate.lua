local gears = require "gears"
local naughty = require "naughty"
local printf = require("string").format

--- Linear easing (in quotes).
local linear = {
	F = 0.5,
	easing = function(t) return t end
}

--- Sublinear easing.
local zero = {
	F = 1,
	easing = function(t) return 1 end
}

--- Quadratic easing.
local function quadratic(t) return t^2 end

--- Get the slope (this took me forever to find).
-- @param i intro duration
-- @param o outro duration
-- @param t total duration
-- @param d distance
-- @param F_1 value of the antiderivate at 1: F_1(1)
-- @param F_2 value of the outro antiderivative at 1: F_2(1)
-- @param[opt] b y-intercept
-- @return m the slope
-- @see timed
local function get_slope(i, o, t, d, F_1, F_2, b)
	return (d + i * b * (F_1 - 1)) / (i * (F_1 - 1) + o * (F_2 - 1) + t)
end


--- INTERPOLATE. bam. it still ends in a period. But this one is timed.
-- @field duration the length of the animation (1)
-- @field rate how many times per second the aniamtion refrehses (32)
-- @field pos initial position of the animation (0)
-- @field intro duration of intro (0.2)
-- @field outro duration of outro (same as intro)
-- @field easing easing method (linear)
-- @field easing_outro easing method for outro (same as easing)
-- @field easing_inter intermittent easing method (same as easing)
-- @field subscribed an initial function to subscribe (nil)
-- @return timed interpolator
-- @method timed:subscribe(func) subscribe a function to the timer refresh
-- @method timed:update_rate(rate_new) please use this function instead of
-- manually updating rate
-- @method timed:set(target_new) set the target value for pos to end at
local function timed(obj)

	--set up default arguments
	local obj = obj or {}

	obj.duration = obj.duration or 1
	obj.rate = obj.rate or 30
	obj.pos = obj.pos or 0

	obj.intro = obj.intro or 0.2
	obj.outro = obj.outro or obj.intro

	obj.easing = obj.easing or linear
	obj.easing_outro = obj.easing_outro or obj.easing
	obj.easing_inter = obj.easing_inter or obj.easing
	
	--subscription stuff
	local subscribed = {}
	local subscribed_i = {}
	local s_counter = 1

	--TODO: fix double pos thing
	local time = 0			--elapsed time in seconds
	local target = obj.pos	--target value for pos
	local dt = 1 / obj.rate --dt based off rate
	local dx = 0			--variable slope
	local m = 0				--maximum slope  @see obj:set
	local b = 0				--y-intercept  @see obj:set
	local easing = nil		--placeholder easing function variable
	local inter = false		--checks if it's in an intermittent state


	local timer = gears.timer { timeout = dt }
	timer:connect_signal("timeout", function()

		--increment time
		time = time + dt

		--intro math (and intermittent math)
		if time <= obj.intro then
			easing = inter and obj.easing_inter.easing or obj.easing.easing
			dx = easing(time / obj.intro) * (m - b) + b

		--outro math
		elseif (obj.duration - time) <= obj.outro then
			dx = obj.easing_outro.easing((obj.duration - time) / obj.outro) * m

		--otherwise
		else dx = m end


		--increment pos by dx
		obj.pos = obj.pos + dx * dt
		print(tostring(obj.pos).." "..tostring(dx).." "..tostring(b).." "..tostring(m).." "..tostring(time))
		
		--sets up when to stop by time
		if obj.duration - time < dt / 2 then
			obj.pos = target

			inter = false --resets intermittent
			timer:stop()  --stops itself
		end

		--run subscribed in functions
		for _, func in ipairs(subscribed) do 
			func(obj.pos, time, dx) end

	end)

	--set target and begin interpolation
	function obj:set(target_new)
		print("\n\n")

		target = target_new	--sets target 
		time = 0			--resets time
		
		--updates b if need be
		if timer.started then 
			inter = true
			b = dx 

			print(tostring(obj.pos).."\n")
			print(string.format("%f %f %f %f %f %f %f\n", obj.intro, obj.outro, obj.duration, 
				target - obj.pos, obj.easing_inter.F, obj.easing_outro.F, b))

			
			m = get_slope(
				obj.intro, obj.outro, obj.duration, 
				target - obj.pos, obj.easing_inter.F, obj.easing_outro.F, b)

		else 

			b = 0

			print(string.format("%f %f %f %f %f %f %f\n", obj.intro, obj.outro, obj.duration, 
				target - obj.pos, obj.easing_inter.F, obj.easing_outro.F, b))

			m = get_slope(
				obj.intro, obj.outro, obj.duration, 
				target - obj.pos, obj.easing.F, obj.easing_outro.F, b)

			timer:start() 
		end
	end
	
	--updating methods
	function obj:update_rate(rate_new)
		obj.rate = rate_new 
		increment = 1 / obj.rate
	end

	function obj:subscribe(func)
		subscribed[s_counter] = func
		subscribed_i[func] = s_counter
		s_counter = s_counter + 1
	end

	--subscribe one given function
	if obj.subscribed then obj:subscribe(obj.subscribed) end

	function obj:unsubscribe(func)
		table.remove(subscribed, subscribed_i[func])
		table.remove(subscribed_i, func)
	end

	function obj:is_started() return timer.started end
	
	function obj:abort()
		time = 0
		target = obj.pos
		b = 0
		inter = false
		timer:stop()
	end

	return obj
	
end

--- this is the target function. It works but it doesn't have easing.
local function target(args)
	
end

local function interpolate(args)
	--rate is executions/sec
	--slope is units/execution (units/sec/r)
	--pos is the initial position
	--subscribed is the list of functions to execute
	--target is the target, should be set with set
	local self = args or {}
	self.subscribed = self.subscribed or {}
	self.target = 0
	self.pos = self.pos or 0
	self.rate = self.rate or 32
	self.slope = self.slope or 1/32
	
	--sets up timer with timeout and non-timeout stuff
	self.timer = gears.timer { timeout = 1 / self.rate }
	self.timer:connect_signal("timeout", function()

		self.pos = self.pos > self.target and self.pos - self.slope or self.pos + self.slope 
		for _, func in ipairs(self.subscribed) do
			func(self.pos) end


		if (self.slope / 2) >= math.abs(self.target - self.pos) then

			self.timer:stop()

			self.pos = self.target
			for _, func in ipairs(self.subscribed) do
				func(self.pos) end
		end
	end)
	
	--set the target and begin interpolation
	function self:set(target)

		self.target = target

		--starts it if it's not going
		if not self.timer.started then
			self.timer:start() end
	end

	return self
end

return {
	interpolate = interpolate,
	timed = timed,
	target = target,
	linear = linear,
	zero = zero,
	quadratic = quadratic,

}
