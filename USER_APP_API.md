# Udghosh User App – Backend Guide

Everything the **user app** needs from the backend. The user app only reads data and logs in with an email OTP. It never calls admin endpoints.

---

## Basics

| Item | Value |
|---|---|
| Base URL | `https://<backend-host>/api` (port from the server's `PORT`, default `3001`) |
| Request body | JSON, with header `Content-Type: application/json` |
| Auth | None. No token is needed for any user app endpoint |
| Errors | JSON `{ "error": "message" }` with a 4xx/5xx status |

### Data formats
- **Dates** (`date`) come as ISO strings, e.g. `"2025-10-01T00:00:00.000Z"`. Show only the date part. If dates appear one day early, the server's timezone is not UTC: convert to local time before taking the date.
- **Times** (`time`) come as `"HH:MM:SS"`, e.g. `"09:30:00"`.
- **Timestamps** (`created_at`, `updated_at`) are ISO strings.
- **Cricket overs** (`team1_overs`, `team2_overs`) come as **strings**, e.g. `"12.3"`.
- Unset values come as `null`.

### Supported sports
Use these exact values wherever a sport is needed (`sportTableName`):

`cricket`, `volleyball`, `basketball`, `hockey`, `lawntennis`, `tabletennis`, `badminton`, `chess`, `football`, `kabaddi`, `khokho`, `squash`, `taekwondo`, `ultimatefrisbee`, `athletics`, `aquatics`, `weightlifting`, `powerlifting`

Spaces, hyphens and capital letters are ignored, so `Lawn Tennis` also works.

`athletics`, `aquatics`, `weightlifting` and `powerlifting` are **individual** sports — one competitor, not two teams/players. See 2.5 for how their fields differ. "Mr. Udghosh" is not in this list and has no API — it's a separate pageant-style event, not covered by the matches system at all.

---

## Suggested screens

| Screen | Endpoints |
|---|---|
| Login | `POST /auth/requestotp` → `POST /auth/verifyotp` |
| Home / sports list | `GET /getTablesLength` (live match count per sport) |
| Schedule (upcoming) | `GET /matches` |
| Live scores | `GET /getLiveMatches?sportTableName=…` (poll, e.g. every 15–30 s) |
| Results | `GET /getCompletedMatches?sportTableName=…` |
| Events | `GET /upcoming-events`, `GET /upcoming-events/:id` |
| Informal sports | `GET /informal-sports`, `GET /informal-sports/:id` |
| Notices | `GET /notices`, `GET /notices/:id` |
| Gallery | `GET /gallery` |

There is no push or websocket. Refresh live data by polling.

---

## 1. Login (email OTP)

Only emails that an admin has added can log in. There is no sign-up.

### 1.1 Request OTP
**POST** `/auth/requestotp`

```json
{ "email": "student@iitk.ac.in" }
```

| Status | Body | Meaning / what to show |
|---|---|---|
| `200` | `{ "message": "OTP sent successfully" }` | Go to the OTP screen |
| `400` | `{ "error": "A valid email is required" }` | Invalid email |
| `404` | `{ "error": "User not found" }` | "This email is not registered" |
| `429` | `{ "error": "Please wait 60 seconds before requesting another OTP" }` | Disable "Resend" for 60 s |
| `500` | `{ "error": "Internal Server Error" }` | Email could not be sent; try again |

OTP rules:
- 6 digits, sent by email, valid for **5 minutes**.
- A new OTP can be requested only **60 seconds** after the last one. The new OTP replaces the old one.

### 1.2 Verify OTP
**POST** `/auth/verifyotp`

```json
{ "email": "student@iitk.ac.in", "otp": "123456" }
```

| Status | Body | Meaning |
|---|---|---|
| `200` | see below | Logged in |
| `400` | `{ "error": "A valid email and 6-digit OTP are required" }` | Bad input |
| `401` | `{ "error": "Invalid or expired OTP" }` | Wrong, expired, already used, or too many attempts |
| `500` | `{ "error": "Internal Server Error" }` | Server error |

```json
{
  "message": "OTP verified",
  "user": { "id": 1, "email": "student@iitk.ac.in", "name": "Name or null" }
}
```

Notes:
- Each OTP works **once**. After **5 wrong attempts** it stops working, and the user must request a new one.
- **No token is returned.** Save the `user` object on the device to keep the user logged in. Logging out just clears it.

---

## 2. Matches

A match is in one of three states:

| Status | Endpoint |
|---|---|
| `upcoming` | `GET /matches` |
| `live` | `GET /getLiveMatches` |
| `completed` | `GET /getCompletedMatches` |

Each match is returned by only one of these endpoints at a time. When a match goes live it leaves `/matches`, and it keeps the same `matchId`.

### 2.1 Upcoming matches (schedule)
**GET** `/matches`

| Query | Required | Default | Notes |
|---|---|---|---|
| `sportTableName` | no | `all` | `all` or a supported sport |
| `search` | no | – | Matches part of team names, time, venue, sport or category |
| `page` | no | `1` | Invalid values use the default |
| `limit` | no | `10` | Max `500` |

Sorted by date, then time (soonest first).

```json
{
  "message": "Matches fetched successfully",
  "page": 1,
  "limit": 10,
  "size": 2,
  "matches": [
    {
      "matchId": 12,
      "team1": "IIT Kanpur",
      "team2": "IIT Delhi",
      "venue": "Cricket Ground A",
      "time": "09:00:00",
      "category": "Men",
      "status": "upcoming",
      "sport": "cricket",
      "liveStreamUrl": null,
      "date": "2025-10-01T00:00:00.000Z",
      "locationUrl": "https://maps.google.com/..."
    }
  ]
}
```

`size` is the number of matches on this page. There is no total count: keep loading pages until `size < limit`.

Errors: `400 { "error": "Invalid sportTableName" }`, `500`.

### 2.2 Live matches
**GET** `/getLiveMatches?sportTableName=cricket`

| Query | Required | Default | Notes |
|---|---|---|---|
| `sportTableName` | **yes** | – | A supported sport |
| `search` | no | – | Matches part of team/player names, venue, sport or category |
| `page` | no | `1` | |
| `limit` | no | `10` | Max `500` |

Sorted newest first.

```json
{
  "message": "Matches fetched successfully",
  "page": 1,
  "limit": 10,
  "matches": [ { ...match row, see "Match fields by sport" } ]
}
```

Errors: `400 { "error": "A valid sportTableName is required" }`, `500`.

### 2.3 Completed matches (results)
**GET** `/getCompletedMatches?sportTableName=cricket`

Same query parameters as live matches, plus:

| Query | Default | Notes |
|---|---|---|
| `order` | `DESC` | `DESC` = newest first, `ASC` = oldest first |

The response has the same shape as live matches.

### 2.4 Live match count per sport
**GET** `/getTablesLength`

```json
{
  "success": true,
  "data": [
    ["cricket", 2],
    ["volleyball", 0],
    ["basketball", 1]
  ]
}
```

Each item is `[sport, number of live matches]`. Use it for "LIVE" badges on the sports list.

### 2.5 Match fields by sport (live and completed)

Every live or completed match has these fields:

| Field | Meaning |
|---|---|
| `matchId` | Match id |
| `venue`, `time`, `date`, `category`, `sport` | Match details |
| `status` | `live` or `completed` |
| `liveStreamUrl` | Stream link or `null` |
| `locationUrl` | Map link or `null` |
| `winner` | `null` while live; after completion `1` = side 1 won, `2` = side 2 won, **`0` = draw** |
| `active` | Always `1`, ignore it |

Names and scores depend on the sport:

| Sport | Names | Score fields |
|---|---|---|
| `basketball` | `team1`, `team2` | `team1_score`, `team2_score` |
| `cricket` | `team1`, `team2` | `team1_score`, `team1_wickets`, `team1_overs`, `team2_score`, `team2_wickets`, `team2_overs` |
| `hockey`, `football` | `team1`, `team2` | `team1_goals`, `team2_goals` |
| `kabaddi`, `khokho`, `ultimatefrisbee` | `team1`, `team2` | `team1_points`, `team2_points` |
| `volleyball`, `lawntennis`, `tabletennis` | `team1`, `team2` | `set1_score1`, `set1_score2` … `set5_score1`, `set5_score2` |
| `badminton`, `squash` | `player1`, `player2` | `set1_score1`, `set1_score2` … `set5_score1`, `set5_score2` |
| `taekwondo` | `player1`, `player2` | `player1_points`, `player2_points` |
| `chess` | `player1`, `player2` | `team1_points`, `team2_points`, `result` (text like `"1-0"`) |
| `athletics`, `aquatics` | `athlete`, `event` | `result` (free text, e.g. `"10.52s"`, `"6.5m"`) |
| `weightlifting` | `athlete`, `category` (weight class, e.g. `"Men 81kg"`) | `snatch_best`, `cleanjerk_best`, `total` |
| `powerlifting` | `athlete`, `category` (weight class) | `squat_best`, `benchpress_best`, `deadlift_best`, `total` |

Notes:
- In set scores, `setN_score1` is side 1's score in set N and `setN_score2` is side 2's. Sets that weren't played are `0` or `null`: hide them.
- Upcoming matches (`/matches`) always use `team1`/`team2`, even for player and individual sports — the individual sports' `athlete` name is carried in `team1`, and `team2` is a placeholder you can ignore until the match goes live.
- For `athletics`/`aquatics`/`weightlifting`/`powerlifting`, there is only **one** competitor: `winner` is always `1` (once `result`/`total` is recorded) or `null`, **never `2`, never a draw**. Design the results UI for these sports around a single name + result, not a "vs" layout.

Showing the result:
- `winner = 1` → name of side 1 (`team1`/`player1`/`athlete`)
- `winner = 2` → name of side 2 (`team2`/`player2`) — not applicable for the individual sports above
- `winner = 0` → "Draw" — not applicable for the individual sports above

---

## 3. Events

### 3.1 Upcoming events
**GET** `/upcoming-events` returns a plain array, sorted by date then time.

```json
[
  {
    "id": 3,
    "event_name": "Opening Ceremony",
    "data": "Description text",
    "time": "18:00:00",
    "date": "2025-10-01T00:00:00.000Z",
    "venue": "Main Stadium",
    "image_url": "https://example.com/opening.jpg",
    "created_at": "2025-09-20T10:00:00.000Z",
    "updated_at": "2025-09-20T10:00:00.000Z"
  }
]
```

**GET** `/upcoming-events/:id` returns one event object (same fields), or `404 { "error": "Event not found" }`.

### 3.2 Informal sports
**GET** `/informal-sports` and **GET** `/informal-sports/:id` return the same fields as events. The 404 error is `{ "error": "Informal sport not found" }`.

### Images
`image_url` is a full `http(s)` link, or `null` when there is no image. Load it directly and show a placeholder when it is `null` or fails to load. Some old events may have links starting with `/uploads/...`: these no longer work, so treat them as missing.

---

## 4. Notices

**GET** `/notices` returns a plain array, newest first.

```json
[
  {
    "id": 5,
    "title": "Schedule change",
    "content": "Football finals moved to 5 PM.",
    "created_at": "2025-10-02T08:00:00.000Z",
    "updated_at": "2025-10-02T09:15:00.000Z"
  }
]
```

**GET** `/notices/:id` wraps the notice in an object:

```json
{ "message": "Notice fetched successfully", "notice": { ...same fields } }
```

Errors: `404 { "error": "Notice not found" }`.

`title` and `content` are plain text. Render them as text, not HTML. If `updated_at` differs from `created_at`, you can show "edited".

---

## 5. Gallery

**GET** `/gallery` returns a plain array, newest first.

```json
[
  { "id": 9, "image_url": "https://example.com/photo.jpg", "created_at": "2025-10-03T12:00:00.000Z" }
]
```

All images come in one response, with no pagination. Load thumbnails lazily. Handle links that fail to load, because they are external.

---

## 6. Error handling checklist

- **Parsing:** always parse the body as JSON when the status is 4xx/5xx. If parsing fails (a rare server error page), show a generic error.
- **`500`:** show "Something went wrong, try again".
- **Network errors or timeouts:** keep the last data on screen and retry on the next poll.
