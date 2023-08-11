# SelfFound Addon for WoW
Basically a SSF without the Solo part. \
This addon will prevent you from Trading, using the Auction House and Mailing unless you meet certain conditions. \
Should work with TurtleWoW, Vanilla, The Burning Crusade (TBC), Wrath of the Lich King (Wotlk).

### Important Specifics
* In order to change the addon mode, you must be lvl 1 and not be in bank mode!
* If a bank character levels up, he will be switched to collector mode.
* Any characters who didn't have the addon enabled from lvl 1 are automatically in collector mode.
* Until high enough lvl, Trading can only be used in instances in order to share drinks, heartstones, etc.
* Until high enough lvl, Auction House can only be used to buy items, since some quests require it.

These are the available modes and lvl requirements for using Mail, AH and Trading:

| Mode      | Mail Lvl     | Auction House | Trading |
| -         | -            | -             | -       |
| Normal    | Half Max Lvl | Max Lvl       | Max Lvl |
| Hardcore  | Max Lvl      | Never         | Never   |
| Collector | Never        | Never         | Never   |
| Bank      | Lvl 1        | Never         | Never   |

Chat Commands:
* `/selffound info` - shows the mode that the addon is using.
* `/selffound normal` - switches the addon to Normal Mode (which is the default).
* `/selffound hardcore` - switches the addon to Hardcore Mode.
* `/selffound collector` - switches the addon to Collector Mode.
* `/selffound bank` - switches the addon to Bank Mode.
