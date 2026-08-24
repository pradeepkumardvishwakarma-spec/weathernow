# Offline Strategy Skill

This app has two different offline patterns, on purpose — never merge them into one.

**Home/Search — online-first**
Try the network first. Fall back to the last cached reading for that city only if the request fails or there's no connection. Show an "updated Xh ago · offline" badge when serving cached data.

**Favorites — cache-first**
Show the last known reading instantly, no spinner. Refresh in the background afterward. Never block the UI on a fresh fetch for a saved favorite.

If a change makes these two behave identically, that's a bug — flag it to the user instead of "cleaning it up."
