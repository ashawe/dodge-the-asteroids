## [0.8.16] - 2026-03-09
 
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
