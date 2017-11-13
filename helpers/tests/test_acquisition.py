import pytest
import time
import unittest

from bci.helpers.acquisition import init_eeg_acquisition
from mock import mock_open, patch


class TestAcquisition(unittest.TestCase):

    def test_default_values(self):
        params = {}

        m = mock_open()
        with patch('bci.acquisition.processor.open', m):
            client, server = init_eeg_acquisition(params)
            client.start_acquisition()
            time.sleep(0.1)
            client.stop_acquisition()
            server.stop()
            m.assert_called_once_with('rawdata.csv', 'w')
            handle = m()
            assert 'daq_type,DSI' in str(handle.write.mock_calls[0])
            assert 'sample_rate,300' in str(handle.write.mock_calls[1])

    def test_allows_customization(self):
        f = 'foo.csv'
        params = {'connection_params': {'port': 9999}, 'filename': f}

        m = mock_open()
        with patch('bci.acquisition.processor.open', m):
            client, server = init_eeg_acquisition(params)
            with client:
                time.sleep(0.1)
            server.stop()
            m.assert_called_once_with(f, 'w')
            handle = m()
            assert 'daq_type,DSI' in str(handle.write.mock_calls[0])
            assert 'sample_rate,300' in str(handle.write.mock_calls[1])

    def test_accepts_clock(self):
        class _MockClock(object):
            """Clock that acts as a counter."""

            def __init__(self):
                super(_MockClock, self).__init__()
                self.count = 0

            def getTime(self):
                self.count += 1
                return float(self.count)

        params = {}
        clock = _MockClock()
        m = mock_open()
        with patch('bci.acquisition.processor.open', m):
            client, server = init_eeg_acquisition(params, clock=clock)

            with client:
                time.sleep(0.1)

            server.stop()

            data = client.get_data()
            assert clock.count > 0
            assert len(data) == clock.count

    def test_null_server(self):
        params = {}
        client, server = init_eeg_acquisition(params, server=False)

        with pytest.raises(Exception):
            with client:
                time.sleep(0.1)

        server.stop()