#!/usr/bin/env python3
"""CPU-only synthetic timing attribution tests; no compiler, renderer or GPU use."""
import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location("wall_timing", Path(__file__).with_name("analyze-native-wall-timing.py"))
timing = importlib.util.module_from_spec(spec)
spec.loader.exec_module(timing)


def phase(event, when, stage="physics_step", frame=0, pid=1, enabled=1):
    return f"NATIVE_WALL_TIMING event={event} pid={pid} stage={stage} frame={frame} clock=steady_clock monotonic_ns={when * 1000000} compile_trace={enabled}"


def compile(event, when, span=1, pid=1, stage="metal_new_compute_pipeline"):
    return f"CUMETAL_COMPILE event={event} pid={pid} span={span} stage={stage} input_bytes=0 elapsed_ms=0 clock=steady_clock monotonic_ns={when * 1000000}"


class TimingTests(unittest.TestCase):
    def test_union_clipping_and_warm_spikes(self):
        rows = [phase("begin", 0, "setup", -1), phase("end", 10, "setup", -1),
                phase("begin", 10), phase("end", 30),
                compile("begin", 5), compile("end", 18),
                compile("begin", 12, 2), compile("end", 22, 2),
                compile("begin", 15, 3), compile("end", 16, 3),
                phase("begin", 30, "observation"), phase("end", 35, "observation"),
                phase("begin", 35, frame=1), phase("end", 235, frame=1),
                phase("begin", 235, frame=2), phase("end", 237, frame=2),
                phase("begin", 237, "teardown", -1), phase("end", 240, "teardown", -1)]
        r = timing.analyze("\n".join(rows))
        self.assertEqual(r["status"], "complete")
        self.assertEqual(r["stage_totals"]["setup"]["metal_compile_overlap_ms"], 5)
        self.assertEqual(r["phases"][1]["metal_compile_overlap_ms"], 12)
        self.assertEqual(r["phases"][1]["noncompile_wall_ms"], 8)
        self.assertEqual(r["compilation_free_physics_step_wall"]["count"], 2)
        self.assertEqual(r["compilation_free_physics_step_wall"]["max_ms"], 200)
        self.assertEqual(r["physics_step_wall"]["count"], 3)

    def test_pid_matching(self):
        r = timing.analyze("\n".join([phase("begin", 0), phase("end", 10),
                                      compile("begin", 0, pid=2), compile("end", 10, pid=2)]))
        self.assertEqual(r["phases"][0]["metal_compile_overlap_ms"], 0)

    def test_disabled_trace_is_unknown(self):
        r = timing.analyze(phase("begin", 0, enabled=0) + "\n" + phase("end", 10, enabled=0))
        self.assertEqual(r["status"], "incomplete")
        self.assertIsNone(r["phases"][0]["metal_compile_overlap_ms"])
        self.assertEqual(r["physics_steps_with_unknown_compile_coverage"], 1)

    def test_missing_timestamp_or_clock_is_unknown(self):
        for field in (" monotonic_ns=1000000", " clock=steady_clock"):
            with self.subTest(field=field):
                c = compile("begin", 1).replace(field, "")
                r = timing.analyze("\n".join([phase("begin", 0), phase("end", 10), c, compile("end", 2)]))
                self.assertEqual(r["status"], "incomplete")
                self.assertIsNone(r["phases"][0]["noncompile_wall_ms"])

    def test_unclosed_or_reversed_compile_is_unknown(self):
        for tail in ([], [compile("end", 0)]):
            r = timing.analyze("\n".join([phase("begin", 0), phase("end", 10), compile("begin", 1)] + tail))
            self.assertEqual(r["status"], "incomplete")
            self.assertIsNone(r["phases"][0]["compilation_free"])

    def test_unclosed_phase_and_duplicate_records(self):
        for rows in ([phase("begin", 0)], [phase("begin", 0), phase("begin", 0), phase("end", 10)],
                     [phase("end", 10)]):
            self.assertEqual(timing.analyze("\n".join(rows))["status"], "incomplete")

    def test_overlapping_phases_are_unknown(self):
        r = timing.analyze("\n".join([phase("begin", 0), phase("end", 10),
                                      phase("begin", 5, "observation"), phase("end", 15, "observation")]))
        self.assertEqual(r["status"], "incomplete")
        self.assertTrue(all(p["metal_compile_overlap_ms"] is None for p in r["phases"]))

    def test_compiler_only_spans_excluded_and_empty_input(self):
        r = timing.analyze("\n".join([phase("begin", 0), phase("end", 10),
            compile("begin", 0, stage="ptx_import"), compile("end", 10, stage="ptx_import")]))
        self.assertEqual(r["status"], "complete")
        self.assertTrue(r["phases"][0]["compilation_free"])
        self.assertEqual(timing.analyze("")["status"], "incomplete")


if __name__ == "__main__":
    unittest.main()
