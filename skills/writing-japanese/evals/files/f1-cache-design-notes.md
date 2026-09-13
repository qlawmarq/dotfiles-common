# Inventory service: tiered cache and write-ahead log (design notes, v0.3)

## Why we are here
The inventory read path is falling over at peak. Most reads hit the same few thousand SKUs, but every read currently lands on the primary database, and the database is starting to bleed connections under load. We want a cache tier that owns the hot path and lets the database live a quieter life.

## Shape of the cache
- Two tiers. An in-process LRU per node fronts a shared cache cluster. The in-process tier is tiny and exists only to absorb thundering herds on a single node; the shared tier carries the real working set.
- Entries are keyed by SKU and carry the stock level, a version number, and the time the entry was hydrated from the database.
- Hot entries can be pinned. A pinned entry is never evicted by the LRU policy; it lives in the cache until an operator unpins it or its version is bumped by a write. We expect to pin a few hundred promotional SKUs during campaigns.
- Everything else is subject to eviction. When the shared tier runs out of memory it evicts the coldest entries first, and if memory pressure keeps climbing it spills the coldest 5% to local disk rather than dropping them on the floor.

## Writes
- Every stock change is appended to a write-ahead log before it touches the database. The log is the source of truth for anything that hasn't been flushed yet; the database is the source of truth for everything that has.
- The log is fsynced on every append. This is the one place we refuse to trade durability for latency.
- A background flusher drains the log into the database in batches. If the database falls behind, backpressure surfaces to the writers as a slower append, never as a dropped write.
- After a batch is flushed, the flusher invalidates the affected cache entries by bumping their version. Readers that see a stale version go back to the database and re-hydrate the entry.

## Warm-up and tear-down
- On deploy, a node comes up cold. It warms its in-process tier from the shared tier, and the shared tier warms itself from a snapshot taken at the last flush. Nothing warms directly from the database; the database is fenced off from warm-up traffic on purpose.
- On tear-down, a node drains in-flight reads, hands its pinned set to a peer, and only then exits. If the hand-off fails the pinned set is simply rebuilt from the database on the next campaign start.

## Failure modes we care about
- Split brain between the log and the database after a crash mid-flush. The recovery path replays the log from the last checkpoint; replays are idempotent because each log entry carries the version it produced.
- A cache node that keeps serving after it has been partitioned from the flusher. Stale reads bubble up to customers as "in stock" for items that sold out. We bound this with a TTL on every entry; pinned entries get a longer TTL but not an infinite one.
- Thundering herd on a version bump. When a hot SKU's version changes, thousands of readers miss at once. The in-process tier collapses those misses into a single fetch per node; the shared tier does the same per cluster.

## Open questions
- Should the flusher batch by time or by size? Batching by size gives better throughput, batching by time bounds staleness. We probably want both with the smaller winning.
- Who owns the pinned set during a campaign? Marketing wants a self-service knob; platform is nervous about handing that knob to people who cannot see memory pressure.
- Do we gate the disk spill behind a feature flag for the first release, or ship it on by default and watch?
