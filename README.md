
# 📦  Event System

A lightweight ESX-based event system for FiveM servers. Built for **Sunset** by Gert 👽.

---

## 🎮 Features

- Create private event worlds dynamically
- Auto-assign routing buckets to event players
- Staff-only mode toggle
- Live teleportation to event location
- Clean join/leave flow
- Discord webhook logging for event actions
- Auto-cleanup of unused worlds

---

## 📜 Commands

| Command         | Description                             | Staff Only |
|----------------|-----------------------------------------|------------|
| `/startevent`  | Start a new private event               | ✅ Yes     |
| `/joinevent`   | Join the current active event           | ❌ No      |
| `/leaveevent`  | Leave the current event world           | ❌ No      |
| `/qevent`     | Stop the current event (creator only)   | ✅ Yes     |

---

## 🛠 Requirements

- [ESX Framework](https://github.com/esx-framework/esx_core)
- Notifications: `CodePlazaNotify` (customizable)
- Discord webhook (optional)

---

## 📂 Setup

1. Add both client & server code to your resource.
2. Set your Discord webhook URL in `server.lua`:
   ```lua
   local webhook = 'your_webhook_here'
   ```
3. Add the resource to your `server.cfg`.

---

## 🔐 Permissions

By default, only players with one of these jobs can start/stop events:

```lua
local staffJobs = {'admin', 'moderator', 'staff'}
```

You can edit the list in `server.lua`.

---

## 📡 Webhook Example

Your Discord webhook will receive embed logs like:

```
📢 Event started
Event: Alien Hunt
By: Gert
```

---

## 👽 Built by Gert

- GitHub: [github.com/CodePlazaGert](https://github.com/CodePlazaGert)
- Twitter/X: [@gertgart40](https://x.com/gertgart40)

---

> 👾 “Event worlds are temporary, but chaos is forever.”
> 
