# Aurora Age Gate Overlay Quick Fix

Use this guide to port the updated age-gate behaviour to other static lounge sites. The goal is to keep the existing HTML + JS logic, but layer in the CSS needed to display the gate as a true modal overlay (instead of rendering inline at the footer).

---

## 1. HTML: keep the standard gate markup

Your page should already include this block near the end of the `<body>`:

```html
<div id="age-gate" class="age-gate age-gate--hidden" role="dialog"
     aria-labelledby="age-gate-title" aria-describedby="age-gate-description">
  <div class="age-gate__backdrop" aria-hidden="true"></div>
  <div class="age-gate__modal">
    <h2 id="age-gate-title">Are you 18 or older?</h2>
    <p id="age-gate-description">This site contains adult content. By entering you confirm you are 18+.</p>
    <button type="button" id="age-gate-confirm" class="button primary">I am 18 or older</button>
    <a class="button ghost" href="https://www.google.com/">Leave</a>
    <noscript>
      <p class="age-gate__note">
        JavaScript is required to enter. If you are 18+, visit
        <a href="/?adult=1">/?adult=1</a>.
      </p>
    </noscript>
  </div>
</div>
```

**Locations in this repo**

- `index.html:779` (main landing page)
- `blackjack/index.html:645` (game table page)

> No structural changes were required-only presentation tweaks. Copy this verbatim if any project is missing the snippet.

---

## 2. JavaScript: leave the existing logic in place

The script already handles:

- Setting/removing the `age-gate-open` class on `<body>`
- Auto-bypass for Googlebot (`isGoogleAgent`) and returning visitors with `adult=1`
- Optional `?adult=1` query override

**Locations in this repo**

- `index.html:795-845`
- `blackjack/index.html:661-708`

Unless your other sites customised the script, you can reuse this block verbatim.

---

## 3. CSS: add the overlay rules

Missing CSS was the source of the footer rendering bug. Add the following to the global stylesheet and to any page-specific stylesheet that needs it.

### Global (`styles.css`)

Insert the snippet near the end of the hero section (see `styles.css:332` in this repo):

```css
body.age-gate-open {
  overflow: hidden;
}

.age-gate {
  position: fixed;
  inset: 0;
  display: grid;
  place-items: center;
  padding: clamp(1.5rem, 4vw, 3rem);
  z-index: 1800;
  transition: opacity 0.3s ease, visibility 0.3s ease;
}

.age-gate--hidden {
  opacity: 0;
  visibility: hidden;
  pointer-events: none;
}

.age-gate__backdrop {
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(6, 14, 36, 0.9), rgba(3, 8, 24, 0.92));
  backdrop-filter: blur(18px);
  opacity: 0.96;
}

.age-gate__modal {
  position: relative;
  z-index: 1;
  width: min(480px, 100%);
  padding: clamp(2rem, 5vw, 2.8rem);
  border-radius: var(--radius-md);
  background: rgba(10, 18, 42, 0.92);
  border: 1px solid rgba(126, 191, 255, 0.32);
  box-shadow: 0 42px 110px rgba(3, 10, 28, 0.6);
  display: grid;
  gap: 1.25rem;
  text-align: center;
}

.age-gate__modal h2 {
  margin: 0;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  font-size: clamp(1.35rem, 4vw, 1.65rem);
  color: var(--muted-strong);
}

.age-gate__modal p {
  margin: 0;
  color: var(--muted);
}

.age-gate__modal .button {
  justify-self: center;
  min-width: 220px;
}

.age-gate__note {
  font-size: 0.85rem;
  color: rgba(210, 224, 255, 0.72);
}
```

### Blackjack-only sheet (`blackjack.css`)

The table page ships with its own styles, so mirror the same block there (see `blackjack.css:205`). The colours differ slightly but the structure is identical.

---

## 4. Cache busting

After editing CSS, bump the query string on your `<link>` tags so browsers pull the new file:

- Landing page: `<link rel="stylesheet" href="/styles.css?v=2">`
- Blackjack page: `<link rel="stylesheet" href="/blackjack.css?v=2">`
- Update any other routes or templates (e.g., `tools/generate-games.ps1`) to keep them in sync.

---

## 5. Quick prompt for other sites

```
Rebrand the age-gate modal so it renders as a full-screen overlay:
1. Add the body lock and .age-gate/.age-gate__* styles used in social-07/styles.css (see docs/age-gate-overlay-guide.md).
2. Mirror the same CSS in the blackjack page stylesheet (or whichever bundle handles the game view).
3. Ensure the HTML block with id="age-gate" matches the source site (header, backdrop, modal contents).
4. Do not modify the existing JS except to keep the body class toggling; it should still bypass Googlebot via UA sniffing and respect the adult=1 query/cookie.
5. Bump any stylesheet cache-busting query strings so the new CSS ships.
```

Run that prompt (or the equivalent manual steps) in each lounge variant to eliminate the footer rendering bug. Once complete, hard-refresh each site to confirm the overlay appears centred, with the page behind it locked and blurred.








