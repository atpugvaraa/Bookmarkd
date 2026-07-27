# Design notes — the negative prompt

Read this before designing a screen. It records what has already been tried and rejected, so
the next round does not quietly rebuild it.

Ten Home designs were built across two rounds. **All ten were rejected.** Aarav's summary:

> too literal · too busy and gimmicky · didn't feel designed enough · wrong content on screen
> — and "the design felt cheap … they lacked any character.. just generic screens
> unfortunately with repeated ideas or designs."

## The ten, and why they died

| Design | The idea | Why it failed |
|---|---|---|
| The Shelf | Books as spines on wooden planks, thickness by page count | Drew furniture. Same idea as The Stack. |
| The Nightstand | Hero cover with habit stats beside it | Generic. Same idea as Fore-Edge. |
| The Reading Log | The last fourteen days as a written log | Same idea as Chalkboard. |
| The Cafe Table | Books arranged on a café tabletop | Drew a café. Same idea as Stamp Card. |
| The Quiet Page | Minimal single-column type | Underdesigned — plain rather than restrained. |
| Stamp Card | The streak as a café loyalty card, hand-pressed stamps | Drew a paper artifact. Novelty gimmick. |
| Fore-Edge | Progress as visible page thickness, hairline slices | Drew a book edge-on. |
| Ribbon | A draggable satin bookmark setting the page | Drew a ribbon. One gimmick carrying the screen. |
| Chalkboard | The day as a café specials board, chalk on espresso | Drew a chalkboard. |
| The Stack | The unread pile seen edge-on, thickness by page count | Drew a pile of books. |

**Ten designs were four ideas.** Books-as-physical-slabs twice, hero-cover-plus-stats twice,
the-week-as-bars twice, café-artifact twice. That repetition is the single most useful thing in
this document — the failure was not execution on any one screen, it was mining one vein
(*furniture that holds books*) until it was empty and then continuing to mine it.

## Round 3 — the over-correction

Five more, built after the ten above with objects and decoration banned outright. Rejected as
*"almost exactly the same, like literally no new invention.. no creativity."*

| Design | The idea | Why it failed |
|---|---|---|
| Folio | The screen set like a printed page — running head, index, folio | Tan ground, dark left-aligned type, hairlines |
| Tonight | One book full-bleed, the backlog hidden behind a swipe | Same ground and type, blurred cover behind the same left column |
| Ledger | The whole library at once, no covers | Same, denser |
| Spread | Two facing pages leafed through horizontally | Same, split across two pages |
| Hours | Time as the only unit, shelf sorted by duration | Same, minutes instead of pages |

**The cause is precise and worth not repeating: palette, type *and* shape language were all
held constant at the same time as decoration was banned.** That removes every variable the eye
registers in the first second — ground colour, imagery scale, shape, composition, depth — and
leaves five arrangements of the same dark text on the same tan. "Density" and "what leads the
screen" are real distinctions, but they are ones you have to squint to see. They make layout
variants, not designs.

## Round 4 — competent, and still wrong

Five more, this time each with its own palette and shape language. The verdict split into two
groups, and the split is the useful part:

| Design | The idea | Verdict |
|---|---|---|
| Mug | Near-white, 28pt radii, progress ring around the cover | *"clean designs but not what i am looking for right now"* — no personality, not actually cozy, wrong things on screen |
| Quilt | Grid of warm colour tiles, progress as a rising level | as above |
| Gallery | Full-width cover posters in a vertical feed | *"utterly useless garbage and nothing similar should ever be made"* |
| Deck | One book per card, paged sideways | as above |
| Split | Brown vertical rail of stats beside a cream shelf | as above |

Two lessons. **Competence is not the gap** — Mug and Quilt were well made and still wrong, so
polishing harder does not fix a wrong direction. And **near-white is not cozy**: `#FBF7F0` reads
clean and sterile, closer to a wellness app than to a café. Warm and one step deeper is the
target — a latte with more coffee in it, not a pale grey-cream.

## The failure that spans all four rounds

Twenty designs, but only four ideas: objects, documents, soft cards, layout variants. Each round
found one well and dug five holes in it.

> *"i think it is too less and you are cycling around the same ideas over and over and creating
> the same design 5 times which is exactly the problem."*

**Five designs made in one sitting will be one design unless the space is sampled on purpose.**
So each design now declares a `Coordinate` (`Design/DesignLab/DesignLab.swift`) across five
axes — what it leads with, composition, imagery scale, ground, shape/depth — and **no two may
share more than two of the five**. It is checked before anything ships. Gallery and Deck shared
four, which is why they were the same design in two palettes.

Also worth recording, because it was tried and was useless: there is no reference to go and
fetch. *"if i had any inspiration then i would have obviously started at that."* Asking for one
wastes a round. So does offering a tuner — the font lab was liked because it *"finally contained
some useful fonts"*, meaning genuine breadth, not because it had a picker.

## Banned

- **Drawn physical objects and faux materials.** No spines, planks, shelves, page edges,
  ribbons, stamps, chalk, leaning stacks, wood grain, paper texture, torn edges, perforations.
  The app is about reading, not about furniture that stores books. That vein is exhausted.
- **The novelty signature.** One eye-catching gimmick per screen, with an ordinary list
  underneath, is what read as cheap. A design earns its character from structure and type,
  not from a decoration bolted to the top.
- **Repeating a structure already on the list.** A new design must name the axis it occupies —
  what leads the screen, its density, how covers are treated — and that axis must be unclaimed.
  Two designs that differ only in ornament are one design.
- **A set that shares palette, type and shape language.** That is one design in five costumes,
  and it is how round 3 died. Enforced now by `Coordinate`: no two designs may share more than
  two of the five axes.
- **Near-white grounds.** `#FBF7F0` reads sterile. Grounds live between `#F2E5D0` and
  `#D9C2A0` — golden and caramel, warm rather than pale.
- **Bare as the answer to gimmicky.** Stripping decoration without adding craft produces a
  screen that reads as unfinished rather than restrained. Both poles have now been rejected.
- **`AsyncImage`.** Covers go through Kingfisher via `Design/Kit/Cover.swift`. All five
  round-two designs got this wrong independently, which is exactly what the kit prevents.

## Required

- **The ground is warm cream, not tan and not near-white.** `#C8A882` is heavier than the brief
  — *"warm and cozy like a coffee made well, sort of lighter shades like cream or lighter shades
  of brown"* — and `#FBF7F0` is too pale to be cozy. The window is `#F2E5D0` to `#D9C2A0`.
- Warmth comes from light, softness, generous scale and real depth — not from texture.
- One accent colour, one job. A hue that means two things means nothing.
- Every design is a pure function of `HomeSnapshot` (`Design/Kit/`). A design that reaches into
  a TCA store is coupled to today's UI and cannot be thrown away cheaply, which is what made
  the first ten expensive to iterate on.

## Reference points that were ruled out

Asked directly, Aarav rejected all four of the obvious comparisons: **Letterboxd** (dark,
poster-forward), **Oku** (stark white minimal), **StoryGraph** (charts as the aesthetic) and the
**Apple Books / Spotify** look (glossy, gradient, heavy depth) — *"i have a very different vibe
for a book app in my head."*

So the target is **not** dark, **not** stark white, **not** chart-led, **not** glossy. It is
warm, light and soft. Two of these are listed in `spec.html` as UX references; that is about
information architecture, not about how the app should look.
