import importlib.util
from pathlib import Path
import unittest

spec=importlib.util.spec_from_file_location('publication',Path(__file__).with_name('report-native-publication.py'))
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)

class PublicationAccounting(unittest.TestCase):
    def row(self,changed,broken,total,byte_count=None):
        return dict(broken_bonds=total,native_counts=dict(
            native_topology_observed_chunks=changed,native_topology_observed_bonds=broken,
            native_topology_observation_bytes=40+24*changed+4*broken if byte_count is None else byte_count))
    def test_initial_quiet_and_cycle_cut(self):
        rows=[self.row(8,0,0),self.row(0,0,0,0),self.row(0,1,1),self.row(4,2,3)]
        self.assertEqual(module.check_rows(dict(chunks=8,bonds=6),rows),dict(
            observed_chunks=12,observed_bonds=3,device_to_host_bytes=420))
    def test_reject_missing_or_duplicate_bond(self):
        with self.assertRaises(AssertionError):module.check_rows(dict(chunks=8,bonds=6),[self.row(8,0,1)])
    def test_reject_overflow(self):
        with self.assertRaises(AssertionError):module.check_rows(dict(chunks=8,bonds=6),[self.row(9,0,0)])
    def test_reject_unaccounted_transfer(self):
        with self.assertRaises(AssertionError):module.check_rows(dict(chunks=8,bonds=6),[self.row(8,0,0,0)])

if __name__=='__main__':unittest.main()
