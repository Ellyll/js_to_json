JS to JSON
==========

This is a simple Ruby script that reads global variables from a JavaScript file or URL and outputs it as JSON. For example it will convert `var fgColour = "red"; var bgColour = "green";` to `{"fgColour":"red","bgColour":"green"}`.

It requires the ruby gem rkelly (install with `sudo gem install rkelly`).

Usage
-----

`./js_to_json.rb url`

Example
-------

`./js_to_json.rb https://raw.githubusercontent.com/tinyspeck/glitch-GameServerJS/master/items/cheese_very_very_stinky.js > cheese_very_very_stinky.json`

This will parse <https://raw.githubusercontent.com/tinyspeck/glitch-GameServerJS/master/items/cheese_very_very_stinky.js> and place the output in the file cheese_very_very_stinky.json.

Limitations
-----------

This is a quick and dirty script, so probably won't handle everything. For most things it doesn't understand, like object literals that containing functions, it replaces the values with null. If you come across any errors or have any suggestions please let me know.