import importlib.util
from pathlib import Path
import unittest

import numpy as np
from scipy.sparse.linalg import spsolve

spec = importlib.util.spec_from_file_location('audit', Path(__file__).with_name('audit-native-stress-solution.py'))
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)


class SolutionAudit(unittest.TestCase):
    def fixture(self):
        p = audit.problem
        nodes = np.zeros(3, dtype=p.NODE)
        nodes['component'] = [p.INVALID, 1, 1]
        nodes['inertia'][1:] = 1
        nodes['rhs'][2] = [1, 2, 3, 4, 5, 6]
        nodes['residual'] = nodes['rhs']
        nodes['threshold'] = 1e-10
        bonds = np.zeros(3, dtype=p.BOND)
        bonds['first'] = [0, 1, 0]
        bonds['second'] = [1, 2, 2]
        bonds['scale'] = bonds['health'] = 1
        A, B, rhs, _, _ = p.assemble(nodes, bonds, 1)
        return nodes, bonds, A, B, rhs

    def test_exact_solution_and_force_perturbation(self):
        nodes, bonds, A, B, rhs = self.fixture()
        force = np.asarray(B.T @ spsolve(A, rhs)).reshape(-1, 6)
        result = audit.audit_component(nodes, bonds, force, 1)
        self.assertLess(result['force_max_scaled_error'], 1e-12)
        force[1, 0] += .5
        result = audit.audit_component(nodes, bonds, force, 1)
        self.assertGreater(result['force_max_scaled_error'], .1)
        self.assertGreater(result['actual_gradient_squared'], .1)

    def test_equilibrium_does_not_prove_self_stress(self):
        nodes, bonds, A, B, rhs = self.fixture()
        minimum = B.T @ spsolve(A, rhs)
        seed = np.arange(18, dtype=np.float64)
        null = seed - B.T @ spsolve(A, B @ seed)
        self.assertLess(np.linalg.norm(B @ null), 1e-12)
        bonds['warm'] = null.reshape(-1, 6)
        nodes['residual'][1:] = (rhs - B @ bonds['warm'].ravel()).reshape(-1, 6)
        result = audit.audit_component(nodes, bonds, minimum.reshape(-1, 6), 1)
        self.assertLess(result['actual_gradient_squared'], 1e-20)
        self.assertGreater(result['warm_self_stress_norm'], 1)
        self.assertGreater(result['actual_update_outside_range_norm'], 1)
        self.assertGreater(result['force_relative_l2_error'], .1)

    def test_corrupt_capture_rejected(self):
        nodes, bonds, _, _, _ = self.fixture()
        nodes['residual'][1, 0] = 100
        with self.assertRaisesRegex(ValueError, 'warm residual disagrees'):
            audit.audit_component(nodes, bonds, np.zeros((3, 6)), 1)

    def test_free_body_uses_least_squares_without_artificial_anchor(self):
        p = audit.problem
        nodes = np.zeros(2, dtype=p.NODE)
        nodes['component'] = 0
        nodes['inertia'] = 1
        bonds = np.zeros(1, dtype=p.BOND)
        bonds['second'] = 1
        bonds['scale'] = bonds['health'] = 1
        force = np.arange(1, 7, dtype=float).reshape(1, 6)
        nodes['rhs'][0] = force[0]
        nodes['rhs'][1] = -force[0]
        # A common translation belongs to the rigid-motion nullspace. The
        # internal stress must not acquire an artificial support reaction.
        nodes['rhs'][:, 3] += 7
        nodes['residual'] = nodes['rhs']
        result = audit.audit_component(nodes, bonds, force, 0)
        self.assertFalse(result['anchored'])
        self.assertEqual(result['reference_rank'], 6)
        self.assertLess(result['force_max_scaled_error'], 1e-12)
        self.assertGreater(result['actual_residual_norm'], 1)
        self.assertLess(result['actual_gradient_squared'], 1e-20)


if __name__ == '__main__':
    unittest.main()
