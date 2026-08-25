# AI Prompts / Chat History Log

**Tool:** Claude Code

---

### 1. Initial architecture & scaffold


**Prompt:**
> i need to create app based on the file i have attached so requesting you to go
> through the file line by line and create the app in flutter following clean
> architecture sperating module as data, domain and presentation. in data there
> will be datasources, repositories and model. in domain there will be usecase,
> repositories(abstract or interface class), entities. in presentation there will
> be widgets/screens, riverpod as state management(there will be states as
> described in document), offline capability using connectivity plus(hive), use
> go_router for navigation, use listview.builder for pagination, use debounce for
> search, cachenetworkimage for image loading, use dependency injection... use
> orchestrator, agents, skills, and rules. should work in low network and security
> best practices should be there. split the widget tree into smaller widgets, use const where necessary.

---

### 2. Bottomnavigation

> Build bottomnavigationbar using shell routing that will contain Home, Favorite and Settings
> Highlight the icon when clicked


### 3. Home Screen integration

> Implement the Search/Home screen exactly against the assignment.
> It must support city search, loading, current temperature, description, humidity, wind, icon, 5-day forecast strip, retryable user-friendly errors, offline/cached indication and favorite action.
> Keep UI simple and interview-reviewable.

---

### 4. Search debounce/cancellation

**Prompt:**
> Developed and Review the current search flow. Add a small debounce for search input and
> ensure obsolete API requests are cancelled. The latest user search must
> win without race conditions. Explain why debounce and CancelToken solve
> different problems. Do not add unnecessary search infrastructure.

### 5. Forecast detail

**Prompt:**
> Implement Forecast Detail. Tapping a day from the forecast strip should
> open a detail view showing the available 3-hour readings in a readable
> morning/afternoon/evening-style breakdown. Going back must preserve the
> existing Home state and should not re-fetch everything unnecessarily.

### 6. Favorites

**Prompt:**
> Implement Favorites according to the assignment. Persist saved cities in
> Hive. Load cached previews first. If connected, refresh favorite weather
> in the background. If offline, retain the last known icon/temperature
> and updated time. Allow removal and navigation into a favorite's
> weather. Use ListView.builder for the dynamic list.

### 7. Settings

**Prompt:**
> Implement the °C/°F setting. Changing it must update every relevant
> screen immediately without another weather API call. Persist it so the
> choice survives restart. Keep persistence behind the
> repository/use-case boundary.


### 8. Image caching

**Prompt:**
> Developed and Review weather icon loading and use cached_network_image. Add loading
> and error fallbacks and make sure image loading does not cause
> unnecessary rebuilds or repeated downloads.


### 9. Fresh performance pass

**Prompt:**
> Develop and Review WeatherNow for Flutter performance. Check unnecessary rebuilds,
> provider scope, ListView.builder usage, image caching, async lifecycle,
> request cancellation and expensive work in build(). Tell me exactly
> what to measure in Flutter DevTools. Do not invent profiling numbers.

### 10. Raw 401 error text shown on the Search screen

**Prompt:**
> when i am searching mumbai in search bar then i am getting long error
> message showing 401 and all. normal user will not understand this, it should
> be user understandable

---

### 11. Restructuring `.claude/` into agents, skills, and rules

**Prompt:**
> now what i want is look at the existing .claude folder and restructure it with agents, skills and rules. 
> agents should use the relevant skills and always follow the project rules. keep the number of agents and skills limited and useful, don't create them just for the sake of it. 
> also make sure this setup can be used when a new developer adds a feature so the same architecture and coding standards are followed.

### 12. A junior-developer-usable "how to build a new feature" guide

**Prompt:**
> i want this prompts, or claude files or documents whatever is there if
> given to any junior then on the basis of this he can develop any new
> module follwing same architecture, security principles and many more like
> this

### 13. Senior code review

**Prompt:**
> Review the complete WeatherNow repository as a Senior Flutter Developer
> interviewer. Audit Clean Architecture, Riverpod, Dart/Flutter quality, API
> integration, cancellation, offline/cache, favorites, settings, navigation,
> debounce, image caching, error handling, testing, security, performance,
> DI and maintainability. For each issue provide severity, file, problem,
> why it matters and the smallest recommended fix. Also list likely
> interview questions about this implementation.

---

### 14. Domain layer wasn't actually independent

**Prompt:**
> right now for localdatasource domain layer is directly depend on data
> layer??
> see my take is domain layer should be independent of any other layer.
> also make a seperate injectable_container.dart class where all the
> injection should take place

---

### 15. Validate the existing orchestrator workflow

**Prompt:**
> now review the existing orchestrator and make sure it is actually using the agents, skills and rules correctly.
> based on the type of task it should select the appropriate agent and skills, and the code review agent should check the changes against the project rules. 
> don't add unnecessary agents or workflows, just fix anything missing in the current setup.

---

### 16. Meaningful tests, not exhaustive ones

**Prompt:**
> so do the meaningful test what is actual needed and all let me know how this
> has to be done becoz if interviewer ask me then i should also be able to do
> it

---

### 17. Tests that had never actually been run had real bugs

**Prompt:**
> [pasted real `flutter test` output, across several rounds]

---

### 18. DevTools-driven jank investigation

**Prompt:**
> [pasted real Flutter DevTools Performance-tab readings and `Choreographer`/frame-tracker
> log output across several rounds — cold start, opening the keyboard on the search
> screen, and navigating to forecast detail — reporting the actual UI ms / raster ms
> per flagged frame each time]
>
> wherever listview is there in project repalce it with listview.builder i told this
> earlier as well. please replace it with listview.builder

---

### 19. Theming — from bare default to an owned, specified palette

**Prompt:**
> actually it is not looking good in real it looks like i have just created the app not owned
> it what do you say??
>
> :root { --primary-color: #4a90e2; /* Sky Blue */ --secondary-color: #f5f6fa; /* Light Gray */
> --accent-color: #2ecc71; /* Green */ --warning-color: #f1c40f; /* Yellow */ --danger-color:
> #e74c3c; /* Red */ --text-color: #2c3e50; /* Dark Gray */ --light-text: #ecf0f1;
> --background-color: #ffffff; }
>
> use above color also app bar height is too much reduce it in favorites text is not given
> right and left margin appbar is also not there please build like a production app and not
> just the app

### 20. Weather icons invisible against a white card in light mode

**Prompt:**
> in white theme clouds are not visible since background cards are also white or similar to
> that so make it light sky blue so that it is visible in light themw
>
> in case of dark theme this sky blue background will not be there

### 21. Centralize scattered string literals

**Prompt:**
> any strings constants are there then add that in constants file and take from there

### 22. Auditing and expanding `.claude/agents`, `skills`, and `rules`

**Prompt:**
> requesting you to thoroughly check agents, skills and rules and if anything is pending to
> add based on my project then please add that
>
> related to architecture, then in qa reveriwer whatever specified in document add that
>
> qa reviewer means what qa will check and according to that code is there or not this what
> qa means. qa doesnt have to do anyhting with prompts, api integration, db, architecure you
> got my point. also in flutter-architecture mention like created core folder, add constants,
> exceptions, failure make feature first architecure make seperate file for DI all this
> things add.

### 23. Two security hardening features added, then both removed

Both of these were explicitly requested and implemented, then explicitly reverted once a real
flaw in each was found — API-key encryption (the decryption key/IV would have shipped inside
the app too, just relocating the problem rather than solving it) and root/jailbreak detection
(the underlying package flagged emulators as compromised, which would block the app from
opening at all in an emulator review environment).

**Prompt:**
> i dont want my key to be extractable from apk so use encrption package with key and iv or root/jailbreak detection
>
> but in document they have specifically mentioned that Handle security sensibly throughout —
> we'll be paying attention to this.
>
> yes do the changes but first let me know what you are doing then do the changes
>
> [chose "Real AES encryption (adds 1 package)" from the options presented]
>
> so this key and iv also can get hacked by any attacker
>
> cant we make use of flutter secure storage?
>
> remove this code then and check for root/jailbreak detection only
>
> can we do like we remove the jailbreak but add in readme stating that we can add
> root/jailbreak for security purpose because on simulator it is showing jailbreak message??

---

### 24. Forecast Detail logic walkthrough, and an ordering bug found along the way

**Prompt:**
> what is the logic for showing forecast details??
>
> so for example for today and tommorrow what will be the data??
>
> tommorrow eveing i am getting 00:00, 03:00, 18:00 and 21:00 why so??
>
> but in afternoon after showing 15:00 it should show 18:00, then 21:00, then 00:00 and then
> 03:00

---

### 25. "Last searched city" bug after an offline search — traced and fixed

**Prompt:**
> so what is happening when i am offline and search new delhi it will not show because i have
> not added in favorite which is correct but i have added surat in my favorite then after
> killing and reopening the app surat should be able to see right now new delhi is there in
> textfield and saying no internet connection... which is incorrect
>
> the flow will be if internet is there then last searched city and its data will be shown if
> internet is not there then last added favorites will be there correct this flow you are
> talking about also??
>
> what is there in document??
>
> but fix this issue

---

### 26. Search input validation — max length only, no character restrictions

**Prompt:**
> there will be any validation to search box means any symbol should not there, any length
> wise check what you say??
>
> maxlength guard add

---

### 27. Removing `setState`, and a deeper forecast-ordering bug the first fix had missed

**Prompt:**
> remove setstate and use riverpod
>
> also one major bug has been found in tommorows weather i will see data from 00:00 till 23:00
> pm divided into 3 hrs correct but in wednesday i am seeing 06:00, 09:00, 12:00, 15:00, 18:00,
> 21:00, 00:00 and 03:00. idealy it should start with 00:00 and go upto 21:00 for tommorrow what
> is your take??

---

### 28. Moving business logic into the correct clean-architecture layer

**Prompt:**
> but all logic related things are there in domain part correct??
>
> move into domain part or according to clean architecture whever it should resides add there
> only. it is a big change let me know first then do the changes affected file and all let me
> know first
>
> start with smaller changes first
>
> go with change no 2
>
> go for first change

---

### 29. Final architecture and state-management verification before submission

**Prompt:**
> read complete project again and check if clean architecture is being followed or not
>
> state management properly used, setstate is not there, only needed widget is updated and not
> complete build method all this things 
>
> lazy loading is there or not??

