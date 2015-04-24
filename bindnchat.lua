-- This addon temporarily disables the user's key bindings so that they may
-- type regularly without their keybindings blocking their input into game chat. 

-- This addon is now intended to demo how to hook some of Windower's events. 
-- This demo shows the use of Windower's load, keyboard and incoming text
-- events. 

-- You can easily do what this addon does by binding your keys with the % modifier. 
-- This way the binding '%!e input /ma "dia" <t>' will only trigger when the console
-- is closed. 

-- These fields will be shown when your addon is loaded. 
_addon.name = 'BindNChat'
_addon.author = 'ZeroLimits'
_addon.version = '0.1'

-- Require any libraries you want to use in your addon. 
require('strings')
require('chat')

-- Table of keybinds to restore after the user is done chatting. 
keybinds = {}

-- Headers we don't won't to appear in game chat when we are 
-- finding keybind data. 
headers = {}
headers['===== Done Listing Currently Bound Keys ====='] = true
headers['===== Listing Currently Bound Keys ====='] = true

-- The load method is called once when the addon is loaded.  
windower.register_event('load', function()
	debug(false)
	tests(false)
end)
		
-- Incoming text event is fired when you recieve an in game message. 
-- The string 'str' is the actual message recieved. 
windower.register_event('incoming text', function(str)

	-- What we are doing here is saving the keybinds when the addon
	-- issues the 'listbinds' windower command. 
	if(str:find(':')) then
		bind = parse_bind(str)
		table.insert(keybinds, bind)
		
		-- Returning true here will prevent the message from being seen
		-- in game chat. 
		return true
	end	

	-- Block the list bind headers from being printed. 
	if(headers[str])then return true end
end)

-- The keyboard event is fired whenever a key is pressed or released. 
windower.register_event('keyboard', function(dik, key_up, blocked)
	-- Here we are reading the size of console's input. 
	-- So if we type '/echo hello' in the game window, the size should 
	-- be around 11 characters. 
	input_text, input_size = windower.chat.get_input()

	-- input size could not be determined. 
	if not input_size then return end

	-- Now we determine if the user is typing a message by checking 
	-- the input's length. If length of the input is one then they are 
	-- not typing. 
	if(input_size > 1) then
		
		-- Do not save or clear bindings if we've done so already. 
		if #keybinds == 0 then return end

		-- So if we've determined the user is typing, we'll 
		-- issue the 'listbinds' command that will trigger saving
		-- the binds in the 'incoming text' event handler. 
		windower.chat.input("//listbinds")

		-- Now we unbind all of the keybindings so the user can 
		-- type uninterrupted. 
		windower.chat.input('//clearbinds')
	else 
		-- Ok, so the user is no longer typing. We'll restore 
		-- their bindings so they can execute cool moves again. 
		for i = 1, #keybinds do 
			windower.chat.input(keybinds[i])
		end

		-- Clear out the old binding data. 
		keybinds = {}
	end

	-- We are using key up so that we can so that 
	-- the input_size is accessible immediately after
	-- sending or canceling a message. 

	-- User begins process of sending a message 
	-- by hitting the enter key. 
	if(dik == 28 and key_up) then
		-- windower.chat.set_input('', 1)
	end

	-- User cancels the process of sending a message
	-- by hitting the esc key. 
	if(dik == 1 and key_up) then		
		-- windower.chat.set_input('', 1)				
	end
end)

-- Utility function to get key information values. 
function printkeyinfo(dik, key_up, blocked)
	print("Key: " .. dik)
	print("Flags: " .. tostring(key_up))
	print("Blocked: " .. blocked)
end

-- Parses the chat message into usable key bindings. 
function parse_bind(str)
	-- Not a binding since no colon can be found. 
	if not str:find(':') then return end

	-- Separate out the binding from the command. 
	values = str:split(':')
	keys = values[1]
	command = values[2]

	-- return the converted binding in its usable form. 
	return convert_binding(keys) .. command
end

-- Converts 'listbinds' chatlog messages into usable key bindings. 
function convert_binding(keys)	
	keybind = '//bind '

	-- The the binding has modifiers convert them to a 
	-- usable form. 
	if keys:find('-') then		
		-- Split the keys by the delimiter. 
		keys = keys:split('-') 	
		
		-- Convert all modifiers to the usable forms. 
		for i = 1, #keys - 1 do 
			keybind = keybind .. convert_modifier(keys[i])
		end

		-- Add the last key to the modifiers. 
		keybind = keybind .. keys[#keys]		
	else 
		keybind = keybind .. keys
	end

	-- Return the keybinding
	return keybind
end

-- Converts the 'listbinds' chat log modifier text into
-- proper key binding modifiers. 
function convert_modifier(str)
	modifiers = {}
	modifiers['Ctrl']	= '!'
	modifiers['Alt'] 	= '^'
	modifiers['Win'] 	= '@'
	modifiers['Apps'] 	= '#'

	return modifiers[str]
end

-- Runs addon's tests. 
function tests(testing)
	-- Is testing enabled?
	if not testing then return end
	-- Begin testing. 		

	-- Parse_bind tests. 
	print(parse_bind("e: input /ma \"dia\" <t>"))
	-- print(parse_bind("Alt-e: input /ma \"dia\" <t>"))
end

-- Setup binds for easier debugging. 
function debug(debugging)
	-- Is debugging enabled?
	if not debugging then return end
	windower.chat.input('//bind f1 input //lua load bindnchat')
	windower.chat.input('//bind f2 input //lua unload bindnchat')
	windower.chat.input('//bind f3 input /echo party')
end

--[[
Copyright (c) 2015, ZeroLimits
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Silence nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL IHINA BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
