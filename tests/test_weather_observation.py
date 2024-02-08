import unittest
from app import app
from unittest.mock import patch
import json

class WeatherObservationTestCase(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def mock_requests_get(*args, **kwargs):
        class MockResponse:
            def __init__(self, json_data, status_code):
                self.json_data = json_data
                self.status_code = status_code

            def json(self):
                return self.json_data

            def ok(self):
                return self.status_code == 200

        if "nominatim.openstreetmap.org" in args[0]:
            # Corrected to return a list to mimic the real service's response
            return MockResponse([{'lat': '40.7128', 'lon': '-74.0060'}], 200)
        elif "api.weather.gov/points" in args[0]:
            return MockResponse({'properties': {'observationStations': 'stationURL'}}, 200)
        elif "stationURL" in args[0]:
            return MockResponse({'features': [{'properties': {'stationIdentifier': 'stationID'}}]}, 200)
        elif "api.weather.gov/stations" in args[0]:
            return MockResponse({
                'features': [
                    {'properties': {
                        'timestamp': '2023-01-01T12:00:00Z',
                        'temperature': {'value': 5}
                    }},
                    {'properties': {
                        'timestamp': '2023-01-01T16:00:00Z',
                        'temperature': {'value': 10}
                    }}
                ]
            }, 200)
        return MockResponse(None, 404)

    @patch('requests.get', side_effect=mock_requests_get)
    def test_weather_endpoint(self, mock_get):
        response = self.app.get('/weather?location=New+York&start=2023-01-01T00:00:00Z&end=2023-01-07T23:59:59Z')
        
        # Printing response data for debugging
        print(response.data)
        
        # Check the response status before attempting JSON decode
        self.assertEqual(response.status_code, 200, f"Expected HTTP 200 OK, got {response.status_code}")
        
        # Assuming the response is correct, decode the JSON
        try:
            data = json.loads(response.data.decode('utf-8'))
            # Assertions to check the correctness of data
            self.assertIn('2023-01-01', data)
            self.assertTrue(data['2023-01-01']['High'] >= data['2023-01-01']['Low'])
        except json.decoder.JSONDecodeError as e:
            self.fail(f"JSON decode error: {e}")

if __name__ == '__main__':
    unittest.main()

