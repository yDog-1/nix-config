import importlib.util
import pathlib
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('usage', pathlib.Path(__file__).with_name('usage.py'))
usage = importlib.util.module_from_spec(spec)
spec.loader.exec_module(usage)


class UsageTests(unittest.TestCase):
    @patch.object(usage, 'gpu_stats', return_value=(25, 50))
    @patch.object(usage, 'cpu_percent', return_value=32)
    def test_cpu_output(self, _cpu, _gpu):
        result = usage.output('cpu')
        self.assertIn('32%', result['text'])
        self.assertEqual(result['tooltip'], 'CPU: 32%\nGPU: 25%')

    @patch.object(usage, 'gpu_stats', return_value=None)
    @patch.object(usage, 'memory_percent', return_value=42)
    def test_unavailable_gpu_is_not_reported_as_zero(self, _memory, _gpu):
        result = usage.output('memory')
        self.assertIn('42%', result['text'])
        self.assertEqual(result['tooltip'], 'RAM: 42%\nVRAM: 取得不可')

    @patch.object(usage, 'disk_mounts', return_value=[{'source': '/dev/sda1', 'target': '/'}, {'source': '/dev/sdb1', 'target': '/mnt/a&b'}])
    @patch.object(usage, 'disk_percent', side_effect=[60, 60, 70])
    def test_disk_lists_mounts_and_escapes_markup(self, _disk, _mounts):
        result = usage.output('disk')
        self.assertIn('60%', result['text'])
        self.assertEqual(result['tooltip'], '/dev/sda1 (/): 60%\n/dev/sdb1 (/mnt/a&amp;b): 70%')


if __name__ == '__main__':
    unittest.main()
