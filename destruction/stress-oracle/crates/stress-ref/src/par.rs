//! Deterministic data parallelism for the substep's independent per-item work.
//!
//! Bond responses and chunk loads within a substep depend only on the state at the
//! start of the substep, so they are computed in parallel into a list in item order and
//! then applied sequentially in that order. Results (and every floating-point sum taken
//! from them) are therefore bit-identical for any thread count. The worker pool is
//! rayon's (`RAYON_NUM_THREADS` sets its size).

use rayon::prelude::*;

/// Below this many items the loop runs on the calling thread: waking the pool costs more
/// than the work. Measured on 4 cores, every benchmark scene (up to ~2000 bonds) ran as
/// fast or faster serially, so only larger structures go to the pool.
const MIN_PARALLEL_ITEMS: usize = 4096;

/// `items.iter().map(f).collect()`, split over the worker pool, in item order.
pub fn map<T: Sync, R: Send>(items: &[T], f: impl Fn(&T) -> R + Sync + Send) -> Vec<R> {
    if items.len() < MIN_PARALLEL_ITEMS {
        return items.iter().map(f).collect();
    }
    items.par_iter().with_min_len(MIN_PARALLEL_ITEMS / 4).map(f).collect()
}

/// `items.into_iter().map(f).collect()`, split over the worker pool, in item order.
pub fn map_into<T: Send, R: Send>(items: Vec<T>, f: impl Fn(T) -> R + Sync + Send) -> Vec<R> {
    if items.len() < MIN_PARALLEL_ITEMS {
        return items.into_iter().map(f).collect();
    }
    items.into_par_iter().with_min_len(MIN_PARALLEL_ITEMS / 4).map(f).collect()
}

#[cfg(test)]
mod tests {
    #[test]
    fn map_keeps_item_order() {
        let items: Vec<u64> = (0..10_000).collect();
        let out = super::map(&items, |x| x * 3 + 1);
        assert!(out.iter().enumerate().all(|(i, &v)| v == 3 * i as u64 + 1));
    }
}
