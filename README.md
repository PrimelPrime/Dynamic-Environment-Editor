# Dynamic Environment Editor Version 1.0 for MTA:SA
A tool to help you preview most modifiable settings inside your server for whatever use you desire.

This is an ongoing project that got its origin from https://wiki.multitheftauto.com/wiki/SetWorldProperty as I wanted to have a quick way of finding certain settings for my maps.
## DEE - Showcase

[![DEE Showcase](http://img.youtube.com/vi/IgQYAogL9jc/0.jpg)](http://www.youtube.com/watch?v=IgQYAogL9jc "Video Title") [![DEE Showcase2](http://img.youtube.com/vi/StsAq1q6GYs/0.jpg)](http://www.youtube.com/watch?v=StsAq1q6GYs "Video Title")
## Installation
> Press the green button on the top right that shows "Code"

> Select "Download ZIP"

> Extract to "YOUR_INSTALLATION_PATH\MTA San Andreas 1.6\server\mods\deathmatch\resources..."

> Start your server and the resource "/start DEE"

> Enjoy!
### Finding the Lua
> If you press the "output lua" button check your local MTASA folder -> mods -> deathmatch -> resource and search for "outputs"

> You will then find a folder with either your first output or several others depending on how often you pressed the button
# Changelog
## Version 1.0
- Implementation of most modifiable functions from https://wiki.multitheftauto.com/wiki/Client_Scripting_Functions#World_functions
## Version 1.1
- Added increment and decrement buttons
- Added Time Lock > Default set to "True"
- Added "save values" and updated "update values" to call every value for when you reopen the test inside the map editor
- Slider position is now at the default value that has been saved on client resource start
- Time/Weather slider values have been adjusted
- General slider values are also now integers instead of floats
## Version 1.1.1
- Fixed dynamic settings
- removed debugstrings


