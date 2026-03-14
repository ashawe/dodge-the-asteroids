## [0.96.1] - 2026-03-14

### Added

### Changed
- Made texture_filter to be "nearest" for most sprites (made the game look more high rez)

### Fixed
- One log message having an extra space

## [0.96] - 2026-03-14

### Added

### Changed

### Fixed
- Each asteroid now has a different time it glows

## [0.95] - 2026-03-14

### Added
- Log Messages **AI CONTRIBUTION**
	- Uses tween for animating fade-in and fade-out
	- Max 4 messages at a time
	- Messages fade out after a while
	- Each difficulty increase posts a message

### Changed
- Difficulty Timer Back to 15-20
- Spawn Interval Step increased (made it easier)
- Minimum mob speed decreased (made it easier) but increased the rate at which they gain speed

### Fixed

## [0.94] - 2026-03-13

### Added
- Music Attribution in Readme.md
- Parallax effect in Background
	- Camera follows Spaceship
	- Asteroids don't disappear unless they're too far from spaceship
- Asteroid now aims in the *general* direction of the player **AI Contribution**
	- MATH.md => explains how direction from asteroid to where the player is going to be was calculated
	- Another thing that contributes to difficulty scaling as time goes on

### Changed
- Game resumes from where the player was not from a set start position (might cause issues if the player goes way way off the screen?)
- Difficulty increases every 10-20 seconds instead of 15-20

### Fixed
- Background being 1px off
- Asteroids not spawning properly

## [0.93] - 2026-03-12
 
### Added
- Music
	- Background Music
	- Player Hit Music / Asteroid Break music
	- Game Over Music
- Ship art changes when player gets damaged

### Changed

### Fixed

## [0.92] - 2026-03-11
 
### Added
- Exclamation Art
- Pointer Art
- Exclamation pointer now shows up from where the asteroid is coming

### Changed

### Fixed
- 0.91 changelog's date

## [0.91] - 2026-03-10
 
### Added
- Gradual difficulty scaling

### Changed
- Start button color and background

### Fixed
- Lives set back to 3

## [0.9] - 2026-03-09
 
### Added
- Highscore is now displayed and saved to disk in user folder

### Changed
 
### Fixed

## [0.8.15] - 2026-03-09
 
### Added

### Changed
 
### Fixed
- README.md formatting
- Contribution dates

## [0.8.14] - 2026-03-09
 
### Added
- Contributors in README.md

### Changed
 
### Fixed


## [0.8.13] - 2026-03-08
 
### Added
- Dynamic hearts: HUD now has a hearts api that allows to lose and restore all hearts dynamically. Hearts can be set dynamically using main scene's MAX_LIVES constant.

### Changed
- Polished code
	- Improved comments
	- Statically typed all variables
	- Simplify reduce life function
	- Move heart logic to HUD
	- Decouple hit flash and flicker to it's own component
	- Stop Main from directly reading player node's lives
	- Decouple mob size, speed, direction from main
	- Removed print() statements
	- Fix `windaaaow` typo
	- Removed empty functions
	- Reset is_invulnerable in start()
	- Removed unnecessary shader
 
### Fixed


## [0.8] - 2026-03-08

### Initial Version
*Features:*
- Spaceship based movement
- Asteroids glow
- Difficuly is random
	- Asteroid's size varies
	- Asteroid's speed varies
- 3 Lives
	- Invulnerability when player get's hit
	- Visual feedback on hit
- Score == how many seconds you've survived so far.
