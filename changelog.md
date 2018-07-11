0.1.17

* Added *continue off road* light green paint tile. Carts will continue straight until another path is encountered.
* Added trial group-specific *optional route* tiles, to allow directing cart groups using only paint.
* Further reduce burner cart fuel efficiency.

0.1.16

* Changed cart recipe category to allow hand-crafting.
* Added trial group-specific path tiles, to allow directing cart groups using only paint.
* BEHAVIOUR CHANGE: carts now only load from buffer chests. This seems more useful, without a modal option like requester "request from buffer chests".

0.1.15

* BUGFIX: check combinator signals_count (limit) before sending cart contents

0.1.14

* Changed yellow *turn-if-clear* arrows to blue *optional routes* (cosmetic only; same item/entity in saves).
* Added orange *alternate route* arrows as the inverse action.

0.1.13

* BUGFIX: Yield tiles were broken in 0.1.11.
* Avoid double-claiming a cell (duplicating the transient marker entity) when CART_TICK_ARRIVING.

0.1.12

* BUGFIX: Fix nil reference on entity rotation.

0.1.11

* New cart graphics thanks to [Arch666Angel](https://mods.factorio.com/user/Arch666Angel)
* Carts now automatically interact with logistic chests adjacent to stops. See above for docs.
* Reduced mod overhead a lot; should be easier on UPS and have less bloat in save files now.
* BALANCING: Slight increase to burner cart fuel consumption to represent inefficiency compared to electric.
* BALANCING: Reduce base cart speed to 5km/h (leaves room for future cart speed research, and is offset by increased loading speed).
* BALANCING: Bump up cart recipe costs.

0.1.10

* Prevent nil entity ref crash: https://forums.factorio.com/viewtopic.php?f=190&t=61053#p370623 .
* Adjust cart timing slightly to reduce jitter (due to auto centering on a tile before moving to next).
* Add missing item-group-name.

0.1.9

* Added second-tier electric cart. Usable with solar panels or [induction charging](https://mods.factorio.com/mod/Induction%20Charging).
* Adjustment to per-tile cart fuel consumption to better match the advertised 50kW consumption.

0.1.8

* Changed precedence of yellow turn paint vs L/R/S signals (previous order essentially made them useless when combined).
* Fixed constant combinators not resetting in some layouts after cart departure on L/R signal.

0.1.7

* Improved anti-collision and path centering checks.
* Fixed constant combinator detection when adjacent to more than one path.
* Driving carts is now blocked as it causes too many issues with on_tick. Player will be automatically switched to the passenger seat.
* *BEHAVIOUR CHANGE*: If a cart has filtered trunk slots the item count sent to constant combinators will be negative if there is a shortfall. This allows *item < 0* checks for loading stops, and *item >= N* of *item != 0* for unloading stops.

0.1.6

* Carts now send signals to constant combinators slightly before arrival to allow circuits time to execute and possibly avoid a cart stopping at all.

0.1.5

* Added an path-stop paint symbol.
* *BEHAVIOUR CHANGE*: inserters and constant combinators no longer implicitly stop carts (though gates still do, and a CC next to a stop still sends and receives cart signals). Place explicit path-stop symbols. This change allows carts to supply a row of inserters while driving past, which is an easy way to load balance resource distribution.

0.1.4

* Carts will now pause if damaged.
* Added L=go-left, R=go-right, S=go-straight incoming signals to direct carts using the circuit network.
* Added small equipment grid to carts, and equipment contents is sent to the circuit network at stops.
* Added G1-G5 equipment for easily identifying cart groups.

0.1.3

* Improve tile clean up when removing from under cars, or when just traversed.
* Fix a lua nil reference bug when removing paint path.

0.1.2

* Stop leaking state and making save file size blow out. Updating the mod should fix existing saves.

0.1.1

* EN locale
