# Campus Events

**Domain:** campus events. Each event has a title, a category (Tech, Music, Sport, Art, Career, Social), a start date and time, a capacity, a list of attendees, an online/offline mode and an optional description. "Register" adds your name to the list. All data lives in memory.

## Screenshots

| Phone, light | Phone, dark | Tablet, grid |
| --- | --- | --- |
| ![light](screenshots/phone_light.png) | ![dark](screenshots/phone_dark.png) | ![grid](screenshots/tablet_grid.png) |

## Decisions

The event list and the profile live in the shell's `State`, so the list tab, the favourites tab and the profile tab all read one source of truth; tabs get data as constructor parameters and send changes up as callbacks. The detail screen takes the event and callbacks through its route arguments because it is a pushed route above the shell and cannot reach the shell's state otherwise, while the form only returns a value through `pop`, so the caller decides what to do with it (and backing out changes nothing). The list/grid choice is a `LayoutBuilder` because it must depend on the space the widget is given, not on the screen size, which differs in split view or when the widget sits inside a narrower parent. `PopScope` compares a snapshot record of the current field values with the snapshot taken when the form opened, so changing a value back makes the form clean again. With week 9's tools I would move the event list and the profile out of `State` into a shared state-management solution and replace the callback chain with it.
