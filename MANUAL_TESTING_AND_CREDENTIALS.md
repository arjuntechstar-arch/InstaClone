# TOKYO.GRAM: Manual Testing Guide, Role Credentials & Workflow Matrix

This document provides a single-source reference for manually testing the entire **TOKYO.GRAM** platform (Node.js REST/WebSocket Backend + Flutter Mobile/Desktop Client), including credentials for each user persona, their role capabilities, and step-by-step test workflows across every feature.

---

## 🌐 Live External Testing via Cloudflare (Active Now)

You can test the entire app and backend from **any external device, phone, browser, or outside network** using these live Cloudflare tunnels:

* **🚀 Flutter Web Application (Outside App Testing)**:
  `https://farmers-settle-thin-riverside.trycloudflare.com/?apiUrl=https://textbook-fountain-statistical-relates.trycloudflare.com`
* **⚡ Backend API (REST Tunnel)**:
  `https://textbook-fountain-statistical-relates.trycloudflare.com`
* **📡 Real-Time WebSocket Tunnel**:
  `wss://textbook-fountain-statistical-relates.trycloudflare.com`

> **Note on Mobile/External Devices**: Open the Flutter Web Application link above directly in any mobile browser (Safari, Chrome) or desktop browser. The `apiUrl` query parameter automatically binds the frontend to the Cloudflare backend tunnel with end-to-end HTTPS & WSS encryption.

---

## 1. Quick Start & Service Status

### 1.1 Local Services (Running in Background)
* **Backend Server**: Port `4000` (Node.js + Express + `ws` WebSocket relay)
* **Frontend Web Server**: Port `3000` (Flutter Web Server)
* **Backend Cloudflare Tunnel**: `task-98` (Proxying port `4000` to `textbook-fountain-statistical-relates.trycloudflare.com`)
* **Frontend Cloudflare Tunnel**: `task-132` (Proxying port `3000` to `farmers-settle-thin-riverside.trycloudflare.com`)

### 1.2 Start Flutter Application
In a second terminal:
```powershell
cd "c:\Projects\Aug27 studio\InstaClone\frontend"
# Run on Windows Desktop:
flutter run -d windows
# Or run on Chrome Web:
flutter run -d chrome
# Or run on connected Android Device / Emulator:
flutter run
```

---

## 2. Role Credentials & Persona Matrix

The system comes pre-seeded with 6 distinct cyberpunk personas, including both public nodes and encrypted private accounts. In accordance with the "Quantum Protocol", credentials use standard secure passkeys.

| User ID | Username | Display Name | Role / Persona | Neural Access Level | Passkey / Password | Privacy Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `u1` | **`cyber_ren`** | Ren Tanaka | **Primary Verified Creator / Photographer** | Level 5 (Admin / Creator) | `neon_ren_2088` | Public |
| `u2` | **`neon_kaito`** | Kaito Vance | **Cyber Modder / Crypto Specialist** | Level 4 (Verified Modder) | `quantum_kaito_42` | Public |
| `u3` | **`kira_synth`** | Kira Oshiro | **Live Streamer / Audio DJ** | Level 5 (Broadcast Creator) | `synth_kira_99` | Public |
| `u4` | **`neotech_admin`** | NeoTech Corp | **Marketplace Merchant / Brand Partner** | Level 3 (Merchant / Drops) | `neotech_drop_77` | Public |
| `guest` | **`anon_mesh`** | Anonymous Explorer | **Consumer / Guest User** | Level 1 (Read / Interact) | `guest_token_00` | Public |
| `usr_rei` | **`rei_kusanagi`** | Rei Kusanagi | **Stealth Netrunner / Operative** | Level 4 (Classified) | `stealth_rei_00` | **Private (Encrypted)** |

---

## 3. Role Capabilities & Permissions Matrix

| Feature / Domain | `cyber_ren` (Creator) | `neon_kaito` (Modder) | `kira_synth` (Streamer) | `neotech_admin` (Merchant) | `rei_kusanagi` (Private) | `anon_mesh` (Guest) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Feed Viewing & Pull-to-Refresh** | Yes | Yes | Yes | Yes | Yes | Yes |
| **Interactive Like & Heart Explosion** | Yes | Yes | Yes | Yes | Yes | Yes |
| **Repost / Retweet Post to Network** | **Yes** | Yes | Yes | Yes | Yes | Yes |
| **Comment & Interactive Discussion** | **Full Author** | Yes | Yes | Yes | Yes | Yes |
| **Cyber Share Sheet & Transmit Packet** | **Yes** | Yes | Yes | Yes | Yes | Yes |
| **Suggested Users Tray (Follow/Dismiss)** | **Yes** | Yes | Yes | Yes | Yes | Yes |
| **Private Account Lock Reticle** | N/A (Public) | N/A (Public) | N/A (Public) | N/A (Public) | **Enforced Lock** | N/A (Public) |
| **Request Access / Follow Approval** | Target | Target | Target | Target | **Requires Request** | Target |
| **Bookmark Save to Vault** | Yes | Yes | Yes | Yes | Yes | Yes (Local) |
| **Publish New Post (Camera / Studio)** | **Full Author** | Yes | Yes | No | Yes | Read-only |
| **Mint as 3D Digital Hologram** | **Yes** | Yes | Yes | No | Yes | No |
| **Story Viewing & Auto-Progress** | Yes | Yes | Yes | Yes | Yes | Yes |
| **Interactive Poll Creation** | **Author** | No | Author | No | No | No |
| **Vote on Story Polls** | Yes | Yes | Yes | Yes | Yes | Yes |
| **Reels Swipe & Video Playback** | Yes | Yes | Yes | Yes | Yes | Yes |
| **Follow / Unfollow Users** | Yes | Yes | Yes | Yes | Yes | Yes |
| **Audio Track Page & "Use Audio"** | Yes | Yes | **Artist Owner** | No | Yes | Yes |
| **Explore Search & Hashtag Filtering** | Yes | Yes | Yes | Yes | Yes | Yes |
| **E2EE Direct Messaging (Text)** | Yes | **Primary Contact** | Yes | Inquiries | Inquiries | No |
| **Voice Waveform Audio Messages** | Yes | **Yes (Sender)** | Yes | No | No | No |
| **3D Hologram Spatial Messages** | Yes | **Yes (Sender)** | Yes | No | No | No |
| **Pin Comment as Author** | **Yes** | No | Yes | No | No | No |
| **Host Live Stream Broadcast** | No | No | **Host Owner** | No | No | No |
| **Send Live Reactions (Particles)** | Yes | Yes | Host | Yes | Yes | Yes |
| **Send Cyber Gifts (Ramen/Drones)** | Yes | Yes | Host (Receiver) | Yes | Yes | Yes |
| **Marketplace Catalog Management** | View / Wishlist | View / Wishlist | View / Wishlist | **Catalog Owner** | View / Wishlist | View / Wishlist |
| **Configure Settings & Privacy Mode** | Yes | Yes | Yes | Yes | **Private Node** | Local Defaults |

---

## 4. Step-by-Step Manual Testing Workflows

Follow these comprehensive test workflows in the running Flutter app.

### Workflow 0: Neural Access Terminal (Sign In, Quick-Select & Registration)
* **Objective**: Verify the initial Sign In screen, 1-tap quick persona fill, quantum passkey masking/unmasking, identity registration tab, and session disconnect.
* **Test Steps**:
  1. Open the application (default launches to `http://localhost:3000`).
  2. The **NEURAL ACCESS TERMINAL // SEC_04** authentication screen is displayed:
     - Header shows glowing neon **TOKYO** (hot pink) and **.GRAM** (cyan).
     - Two tabs: **SIGN IN** and **MINT IDENTITY**.
  3. Under **SIGN IN**:
     - Locate the **QUICK-SELECT NEURAL ROLE (1-TAP FILL)** bar:
       - `@cyber_ren` (Creator)
       - `@neon_kaito` (Modder)
       - `@kira_synth` (Streamer)
       - `@neotech_admin` (Merchant)
       - `@anon_mesh` (Guest)
     - Tap `@neon_kaito`:
       - The Neural Identifier automatically populates with `neon_kaito`.
       - The Quantum Passkey field automatically populates with `quantum_kaito_42`.
     - Tap the eye icon next to the passkey field: toggles visibility between asterisks and cleartext.
  4. Tap **CONNECT TO NEURAL GRID**:
     - Displays brief loading spinner.
     - Handshake succeeds, authenticates with `POST /api/auth/login`.
     - Smoothly transitions into the main application authenticated as `@neon_kaito`.
  5. Switch to Tab 1: **MINT IDENTITY** (Registration):
     - Enter custom handle (e.g. `synth_valkyrie_88`), Display Name, choose a role from the dropdown, and specify a passkey.
     - Tap **MINT NEURAL IDENTITY**: identity is registered via `POST /api/auth/register` and logged in.
  6. To Sign Out / Return to Terminal:
     - Tap Tab 4 (**User Profile**).
     - Tap the **Gear** icon in the top right to open **Settings**.
     - Scroll to the bottom and tap **DISCONNECT NEURAL SESSION (SIGN OUT)**.
     - The app smoothly disconnects and returns to the Neural Access Terminal.

---

### Workflow 1: Home Feed & Social Interaction Engine (Like, Repost, Comment, Share)
* **Objective**: Verify "Electric Nightscape" cyberpunk theme, glowing feed header, stories carousel, post cards, audio indicators, double-tap heart animations, repost/retweet toggles, interactive comments sheet, and cyber share sheet.
* **Test Steps**:
  1. Launch the app. The bottom navigation bar defaults to Tab 0 (**Home Feed**).
  2. Verify the top header displays **TOKYO** (hot pink `#FF2D78` glow) and **.GRAM** (cyan `#00FFCC` glow).
  3. Verify top action buttons: Live broadcast icon (with pulsating red dot), Activity heart icon, and Direct Messages paper plane (with `'2'` unread badge).
  4. Scroll down the feed: verify Post 1 (`cyber_ren`) and Post 2 (`neon_kaito`).
  5. Check Post 1: verify author avatar with verified cyan badge, location *"Shinjuku Sector 4, Neo-Tokyo"*, and filter badge *"Neon Glitch"*.
  6. Look at the bottom-left of the media image: verify the audio chip displays an active equalizer waveform animation with track *"Kavinsky - Nightcall"*.
  7. **Interactive Like**:
     - Single-tap the **Heart** icon or **Double-Tap the image**: An oversized glowing hot pink heart explodes with smooth scale and fade transition.
     - The heart turns solid hot pink (`#FF2D78`) and the like counter increments immediately.
     - Tapping again toggles the like off and decrements counter.
  8. **Interactive Retweet / Repost**:
     - Tap the **Repost** icon (`Icons.repeat_rounded`) on the action bar.
     - The icon turns glowing cyber cyan (`#00FFCC`), an instant toast confirms *"Reposted to your neural network! ⚡"*, and the repost counter increments.
     - Tapping again cancels the repost.
  9. **Interactive Comments & Discussion**:
     - Tap the **Comment** bubble icon.
     - The **"COMMENTS & DISCUSSION"** bottom sheet modal slides up with glowing cyan top border.
     - Review the list of existing comments with nested replies.
     - Tap quick reaction emojis (`❤️`, `🔥`, `⚡`, `🍜`, `🚀`, `💯`) to immediately insert them.
     - Tap any comment's heart icon to like/unlike that specific comment.
     - Tap **"Reply"** on any comment: the input bar displays *"Replying to @username"*.
     - Type a comment and tap the **POST** button: the new comment immediately appends to the top of the discussion list optimistically and syncs with the server.
     - Tap the `X` button on the top right to close the sheet.
  10. **Interactive Cyber Share Sheet**:
     - Tap the **Share** (paper airplane) icon.
     - The **"SHARE TO QUANTUM DIRECT"** modal opens displaying recent contacts (`@neon_kaito`, `@kira_synth`, `@neotech_admin`, etc.), search filter, and custom note field.
     - Tap **"SEND"**: toast confirms transmission and dispatches an encrypted DM to the recipient.
  11. Tap the **Bookmark** icon on the bottom right: verify the icon toggles to solid cyan and saves the post to your vault.
  12. Perform a pull-to-refresh swipe downward: verify the neon pink refresh spinner animates and reloads feed telemetry.

---

### Workflow 1.1: Suggested Users to Follow Tray
* **Objective**: Verify horizontal carousel of recommended nodes, follower counts, follow requests for private accounts, and dismissal.
* **Test Steps**:
  1. Scroll down the Home Feed between Post 1 and Post 2.
  2. Locate the **"SUGGESTED FOR YOU"** horizontal recommendation tray.
  3. Inspect the user cards:
     - Avatar with story ring and verification badge.
     - Display name and `@username`.
     - Mutual connection indicators and node category.
     - Private node indicator: `@rei_kusanagi` displays a padlock icon and **"REQUEST"** button.
     - Public node: `@neon_kaito` or `@shibuya_speed_unit` displays a **"FOLLOW"** button.
  4. Tap **"FOLLOW"** on a public user:
     - Button instantly turns to **"FOLLOWING"** with cyan border.
  5. Tap **"REQUEST"** on private node (`@rei_kusanagi`):
     - Button switches to **"REQUESTED"** with amber border.
  6. Tap the small `X` (dismiss) on the top-right corner of any suggested card:
     - That user card is smoothly removed from the tray.

---

### Workflow 2: Story Viewer & Interactive Poll Voting
* **Objective**: Verify auto-advancing story bars, full-screen background media, and real-time poll vote calculation.
* **Test Steps**:
  1. On the Home Feed, locate the top horizontal **Story Tray**.
  2. Tap the first story avatar (`cyber_ren`).
  3. The full-screen **Story Viewer** launches.
  4. Verify the top progress bar animates across from 0% to 100% over several seconds.
  5. Tap the right 60% of the screen: advances to the next story immediately.
  6. Tap the left 30% of the screen: rewinds to the previous story.
  7. On `cyber_ren`'s story, locate the **NEURAL POLL** card: *"Which optics enhancement should I install next?"*.
  8. Tap **"Cyan Thermal HUD"** (Option 1):
     - The option immediately highlights with a glowing border and checkmark.
     - Live percentages animate instantly across the options (e.g. 58% vs 42%).
     - Vote tally is persisted to the backend API (`POST /api/stories/:id/vote`).
  9. In the bottom message bar, tap the quick reaction emojis (`❤️`, `🔥`, `⚡`): verify instant confirmation toast.
  10. Tap the top-right `X` button: dismisses back to the feed.

---

### Workflow 3: Fullscreen Cyber Reels & Spinning Audio Disc
* **Objective**: Verify vertical swipe reels, spinning audio vinyl disc, follow toggle, and action counters.
* **Test Steps**:
  1. On the bottom navigation bar, tap Tab 3 (**Reels** icon).
  2. The full-screen vertical Reels player loads (`kira_synth` video).
  3. Verify the spinning vinyl record in the bottom-right corner rotates continuously with cyan glow.
  4. Verify the music marquee displays *"Carpenter Brut - Turbo Killer"*.
  5. Look at the author row: tap the hot pink **FOLLOW** button.
     - Button instantly flips to **FOLLOWING** with cyan outlined styling.
  6. Tap the **Heart** like button on the right rail:
     - Heart turns neon hot pink with drop glow; like count increments.
  7. Swipe vertically upwards: transitions seamlessly to the next reel in the stack.

---

### Workflow 4: Creator Studio & Holographic Post Publishing
* **Objective**: Verify AR camera viewfinder, reticle brackets, filter carousel, and post publishing flow.
* **Test Steps**:
  1. On the bottom navigation bar, tap the glowing center **+ / Camera** button (Tab 2).
  2. The **Create Camera** screen appears with:
     - Cyberpunk HUD Reticle brackets on all 4 corners.
     - Center aiming crosshair.
     - Holographic CRT scanline overlay.
     - Top controls: Flash toggle, Grid lines toggle, and Camera Flip toggle.
  3. Scroll through the bottom filter chips: tap **"NEON GLITCH"** or **"CYAN MATRIX"**.
  4. Tap the large center glowing hot pink **Shutter Button**:
     - Captures the viewfinder snapshot.
  5. The app automatically transitions to the **New Neural Post** publishing screen:
     - Media thumbnail displays with cyan border and filter tag.
     - Tap hashtag chips (e.g. `#cyberpunk`, `#neotokyo`): appends them to the caption text field.
     - Select a location tag from the dropdown (e.g. *"Shinjuku Sector 4, Neo-Tokyo"*).
     - Select an audio track from the dropdown (e.g. *"Perturbator - Future Club"*).
     - Toggle the **"Mint as Digital Hologram"** switch: switch glows hot pink.
  6. Tap **TRANSMIT TO FEED** (or top-right **SHARE**):
     - Transmits payload to `POST /api/feed`.
     - Automatically redirects to Home Feed (Tab 0) with the new post inserted at the top.

---

### Workflow 5: Quantum E2EE Direct Messaging (Waveforms & 3D Holograms)
* **Objective**: Verify encrypted chat list, voice waveform playback, and 3D spatial geometry messages.
* **Test Steps**:
  1. On the Home Feed, tap the paper-plane **Direct Messages** icon in the top right.
  2. The **Neural Chat** inbox opens:
     - Verify the top banner: *"QUANTUM ENCRYPTION ACTIVE // PROTOCOL V4.2"*.
     - Verify thread with `neon_kaito` displaying an online status badge and `'3'` unread counter.
  3. Tap `neon_kaito`'s thread to open the conversation:
     - Chat header displays *"256-BIT QUANTUM LOCKED"*.
  4. Inspect the message history:
     - Outgoing messages display with hot pink gradient.
     - Incoming messages display with dark cyan border.
     - Locate the **Voice Waveform Message**: tap the circular play button. The equalizer bars animate dynamically as audio plays.
     - Locate the **3D Spatial Hologram Message**: displays a rotating 3D wireframe preview with scanline effect.
  5. Test sending messages:
     - Type *"System handshake verified"* in the text input and tap the neon Send button: message appears instantly.
     - Tap the **Mic** button in the dock: generates and sends a new voice waveform packet with duration.
     - Tap the **3D Hologram Cube** button (`Icons.view_in_ar`): transmits a spatial holographic geometry card.

---

### Workflow 6: Live Stream Viewer with Floating Reaction Particles
* **Objective**: Verify live HUD, live chat stream overlay, and upward-floating reaction particle engine.
* **Test Steps**:
  1. On the Home Feed, tap the top-left **Live Sensors** broadcast icon (with red dot).
  2. The **Live Stream Viewer** screen launches (`kira_synth` broadcast):
     - Top HUD displays host avatar with **LIVE** badge and viewer ticker (`18,420 viewers`).
  3. Look at the lower chat overlay:
     - Pinned comment with gold pin badge: *"The sub-bass drop is vibrating my neural interface!"*.
     - Cyber gift banner: *"Sent a Neon Heart"*.
  4. Tap the reaction buttons in the bottom-right:
     - Tap `❤️`, `🔥`, `⚡`, or `🍜` (Quantum Ramen).
     - **Observe the canvas**: glowing emoji particles shoot upward from the bottom right, fluttering with randomized offsets and fading out smoothly as they ascend.
  5. Type a comment in the stream chat bar (e.g. *"Bass drop is legendary"*) and tap submit:
     - Chat comment appears in the live scroll stream.
     - Dispatched via WebSocket relay to `ws://localhost:4000`.

---

### Workflow 7: Comments & Discussion Sheet
* **Objective**: Verify pinned creator comments, nested replies, quick emoji insertion, and comment submission.
* **Test Steps**:
  1. On any post in the Home Feed, tap the **Comment bubble** icon.
  2. The **Comments & Discussion** bottom sheet slides up:
     - Pinned comment at the top with gold/cyan **PINNED** badge.
     - Nested reply indented underneath with author avatar and timestamp.
  3. Tap the quick emoji bar at the bottom (`🔥`, `⚡`, `🚀`): inserts the emoji into the input box.
  4. Tap **Reply** on any comment: the bar displays *"Replying to @username"* banner.
  5. Type text and tap **POST**: the comment is added to the discussion list and persisted to `POST /api/comments/:postId`.

---

### Workflow 8: Cyber Marketplace & Wishlist
* **Objective**: Verify product catalog, category filters, and wishlist toggling.
* **Test Steps**:
  1. Tap Tab 4 (**User Profile**) on the bottom navigation bar.
  2. Tap the cyan shopping bag icon in the top app bar to open **Cyber Marketplace**.
  3. Tap category filter chips: **"All"**, **"Optics"**, **"Techwear"**, **"Neural Rig"**, **"Cyberdeck"**.
     - Product grid updates instantly to show matching items.
  4. Inspect the **"Tactical Holo-Visor V3"** product card:
     - Displays price `$249.99`, brand `"NEO-TECH CORP"`, rating `4.9 ⭐`, and `"IN STOCK"` cyan badge.
  5. Tap the **Heart** icon on the product card: toggles wishlist status to solid pink.

---

### Workflow 9: Saved Vault Collections
* **Objective**: Verify private vault folders, cover images, and item counts.
* **Test Steps**:
  1. On the **User Profile** screen (Tab 4), tap the **Bookmark** icon in the top app bar.
  2. The **Saved Vault** screen opens:
     - Displays folders like *"Neon Inspo 2088"* (34 items) with padlock icon indicating private encryption.
  3. Tap the **+** icon in the app bar: shows confirmation toast for creating a new vault folder.

---

### Workflow 10: Settings & Neural Privacy Controls
* **Objective**: Verify cyber optics display mode, quantum encryption, biometric auth, and stealth cloak toggles.
* **Test Steps**:
  1. On the **User Profile** screen (Tab 4), tap the **Gear** icon in the top app bar.
  2. The **Settings & Neural Link** screen opens.
  3. Under **CYBER OPTICS & DISPLAY**, tap the dropdown:
     - Select between *"Neon Vivid"*, *"High Contrast Cyber"*, and *"Monochrome 2088"*.
  4. Under **SECURITY & QUANTUM MESH**:
     - Toggle **Quantum End-to-End Encryption**: enables/disables cryptographic keys.
     - Toggle **Biometric Neural ID**: controls vault scan requirements.
     - Toggle **Stealth Cloak Mode**: hides user beacon from public grid.
  5. Tap **DISCONNECT NEURAL SESSION**: clears session cache and resets to anonymous guest profile.

### Workflow 11: Ephemeral Story Creator & Interactive Polls
* **Objective**: Verify composing and broadcasting an ephemeral story to the timeline with optional custom poll questions and options.
* **Test Steps**:
  1. On the **Home Feed** (Tab 0), tap **"Your Story"** (with `+` badge) at the beginning of the story tray.
  2. The **"MINT NEURAL STORY"** modal sheet opens:
     - Shows hologram feed background selector (4 neon cyber options).
     - Text field: **"STORY CAPTION"** (enter custom thought).
     - Switch: **"ATTACH INTERACTIVE POLL"** (defaults to active).
     - Poll Question & Options fields (pre-filled with `"OVERCLOCK ⚡"` and `"COOLDOWN ❄️"`).
  3. Enter a custom caption or question, then tap **"BROADCAST STORY TO TIMELINE"**.
  4. Confirmation toast appears: `"Story broadcast to your neural timeline! ⚡"`.
  5. The story tray instantly updates with your newly minted story.
  6. Tap your story in the tray to view it in full screen with animated progress bars and interactive poll voting!

---

### Workflow 12: Quantum Direct Share & Two-Way Interactive Messaging
* **Objective**: Verify sharing feed posts/reels straight into DM threads and experiencing real-time two-way simulated replies.
* **Test Steps**:
  1. On any post in the Home Feed (or in Reels), tap the **Share** (paper airplane) icon.
  2. The **"SHARE TO QUANTUM DIRECT"** modal bottom sheet slides up:
     - Shows post thumbnail preview and caption.
     - Search / note input field: *"Add encrypted telemetry note..."*.
     - Contact list with online statuses: `@neon_kaito`, `@kira_synth`, `@neotech_admin`, `@cyber_ren`, `@anon_mesh`.
  3. Tap **"SEND"** next to `@neon_kaito`:
     - Button switches to active state, confirmation toast `"Transmitted post to @neon_kaito! ⚡"`.
  4. Tap the **Direct Messages** icon (top right paper airplane on Home Feed):
     - Thread with `@neon_kaito` is prioritized and displays the shared post.
  5. Tap into the thread:
     - View the shared post message bubble.
     - Send any text message (e.g. *"Check out this sector visual"*).
     - Within ~1.4 seconds, an encrypted simulated response arrives from `@neon_kaito` (*"Quantum uplink confirmed. Patching into Akihabara subnet now. 🦾⚡"*), making conversations feel completely alive!

---

### Workflow 13: Full Post Telemetry Viewer (`PostDetailScreen`)
* **Objective**: Verify that tapping photos in Explore or Profile grids opens full interactive Instagram-style post details.
* **Test Steps**:
  1. Tap Tab 1 (**Explore**) or Tab 4 (**User Profile**).
  2. In the Explore mosaic or Profile gallery, tap any photo or video tile.
  3. The **"POST TELEMETRY"** detail viewer screen opens with full resolution:
     - Shows author avatar, username, verified badge, and location.
     - Full interactive action bar: Like (heart), Comment (chat bubble), Share (send), Bookmark (vault).
     - Detailed likes count, rich-text author caption, and timestamp.
  4. Double-tap the image: triggers pink heart burst animation and increments like counter.
  5. Tap the back arrow: smoothly returns to the explore or profile grid.

---

### Workflow 14: Profile Editing & Instant Persona Quick-Switching
* **Objective**: Verify interactive identity editing and 1-tap switching between all 5 role personas directly from the profile screen.
* **Test Steps**:
  1. Navigate to Tab 4 (**User Profile**).
  2. Under the bio, locate the **"QUICK SWITCH NEURAL PERSONA"** bar:
     - Displays role chips: `@cyber_ren` (Creator), `@neon_kaito` (Modder), `@kira_synth` (Streamer), `@neotech_admin` (Merchant), `@anon_mesh` (Guest).
     - Active persona is highlighted in neon hot-pink glow with checkmark.
  3. Tap `@neon_kaito`:
     - Profile immediately reconfigures to Kaito Vance, showing his bio (*"Overclocking quantum cyberdecks..."*), modder badge, and gallery.
  4. Tap **"EDIT PROFILE"**:
     - The **"EDIT NEURAL IDENTITY"** modal sheet opens.
     - Modify Display Name, Bio, or Sector Location.
     - Toggle the **"Private Account Node"** switch to make your profile private/public.
     - Tap **"SAVE IDENTITY UPDATES"**: toast confirms update and profile updates immediately.
  5. Tap **"SHARE PROFILE"**:
     - Hologram transmission sheet appears with user handle, avatar, badge, and **"COPY NEURAL LINK"** button.

---

### Workflow 15: Account Privacy & Private Node Lockdown (`@rei_kusanagi`)
* **Objective**: Verify private profile encryption, holographic lock reticle, access request states, and global privacy configuration.
* **Test Steps**:
  1. **View Private Account as Non-Follower**:
     - From Explore (Tab 1) or from the Suggested Users Tray on Home Feed, tap on **`@rei_kusanagi`** (or search `"rei_kusanagi"`).
     - Notice the lock icon next to her username in the AppBar.
     - The profile header displays her avatar, bio (*"Aesthetic perfection. Shibuya underground never sleeps."*), and follower metrics.
     - **Lockout Reticle Enforced**: In place of her media gallery and reels, the glowing yellow Holographic Lock Reticle displays:
       - Large glowing lock shield (`Icons.lock_outline_rounded`).
       - Header: **"THIS ACCOUNT IS PRIVATE"**.
       - Description: *"Follow this node to view their media, holographic reels, and telemetry streams."*.
       - Encryption Badge: *"QUANTUM 4096-BIT ENCRYPTION"*.
       - Action Button: **"REQUEST ACCESS"**.
  2. **Send Access Request**:
     - Tap **"REQUEST ACCESS"** (either on the reticle or in the header).
     - The button immediately updates to **"REQUESTED"** / **"ACCESS REQUESTED [PENDING APPROVAL]"** with outlined amber styling.
     - Tapping again cancels the pending request.
  3. **Toggle Privacy on Current Account (Settings)**:
     - Switch to your profile (Tab 4).
     - Tap the **Settings** gear icon in the top right.
     - Scroll to **"SECURITY & QUANTUM MESH"**.
     - Locate the **"Private Account Node"** toggle (*"When private, only approved nodes can decrypt your feed & stories"*).
     - Toggle the switch: updates `isPrivate` in real time on your persona.
  4. **Toggle Privacy in Edit Profile Modal**:
     - Tap **"EDIT PROFILE"** on your profile screen.
     - Scroll to the bottom: toggle the **"Private Account Node"** switch.
     - Tap **"SAVE IDENTITY UPDATES"**: lock icon appears next to your username in the AppBar.

---

## 5. Automated Verification Status

All 57 test suites across the backend and mobile client are automated and verified 100% green:

| Test Suite | File Location | Tests | Status |
| :--- | :--- | :---: | :---: |
| **Backend Integration Suite** | `backend/test/api.test.js` | 15 / 15 | **PASSED** |
| **Phase 2: Architecture & Models** | `frontend/test/phase2_architecture_test.dart` | 14 / 14 | **PASSED** |
| **Phase 3: Feeds & Navigation** | `frontend/test/phase3_navigation_and_feeds_test.dart` | 7 / 7 | **PASSED** |
| **Phase 4: Creator Studio & Camera** | `frontend/test/phase4_creator_and_publishing_test.dart` | 3 / 3 | **PASSED** |
| **Phase 5: Messaging & Live Stream** | `frontend/test/phase5_messaging_and_live_test.dart` | 4 / 4 | **PASSED** |
| **Phase 6: Profile & Marketplace** | `frontend/test/phase6_profile_shop_integration_test.dart` | 5 / 5 | **PASSED** |
| **Phase 7: Instagram-Grade Features** | `frontend/test/phase7_instagram_features_test.dart` | 4 / 4 | **PASSED** |
| **Phase 8: Social & Privacy Suite** | `frontend/test/phase8_social_interactions_and_privacy_test.dart` | 4 / 4 | **PASSED** |
| **Smoke Suite** | `frontend/test/widget_test.dart` | 1 / 1 | **PASSED** |
| **TOTAL** | | **57 / 57** | **100% GREEN** |

---

## 6. Common Troubleshooting

* **Backend not connecting from Android Emulator**: The Android emulator maps `http://10.0.2.2:4000` to the host machine's `localhost:4000`. The `ApiService` automatically handles this mapping.
* **Network Images in Offline Mode**: The client includes a resilient fallback cache and mock byte interceptor (`TestHttpOverrides`), ensuring UI renders even when offline.
* **WebSocket Live Relay**: If running on Web, verify port 4000 is open and not blocked by browser CORS extensions.
