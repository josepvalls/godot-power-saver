# godot-power-saver
A Godot 3.5 project for my submission to Gamedev.js Jam 2024 

Play it in your browser on itch.io: https://josepvalls.itch.io/power-saver

## Gameplay

You play as the power-saver fairy, you can turn stuff on and off, and plug and unplug stuff. You can click on devices to see if they are being used or are wasting power. You can also drag cable endpoints to devices and power sockets to connect them.

## Scoring

Your goal is to keep your friend Luzy happy.

The game is deterministic. Pay attention to the following rules to maximize your score:

* When Luzy is in the room, she wants the lights on.

* When Luzy is not in the room, she wants the lights off.

* When she is using a device, you should keep it on.

* When she is not using a device, you should turn it off.

* A device that uses battery power, will only work if the battery is not empty.

* A device that has a battery, will charge the battery when connected to a power socket

The rules are checked at an interval and you score points for every rule that you are successfully satisfying. The first 10 levels are deterministic and a snapshot of your score will be displayed for bragging rights. How did you do?

## Credits

* Music and SFX by checkpoint: https://ch3ckpo1nt.com/
(also contributed game ideas and playtesting)

* Animated girl sprite by GameArt2D: https://www.gameart2d.com/cute-girl-free-sprites.html

* Jelly sprite by GameArt2D: https://www.gameart2d.com/jelly-squash-free-sprites.html

* All the object images on the table are from Kenney's Generic Items Pack: https://kenney.nl/assets/generic-items

* I make liberal use of the Antialiased Line2D add-on for Godot 3.x add-on: https://github.com/godot-extended-libraries/godot-antialiased-line2d
