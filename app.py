from flask import Flask, jsonify, request
import requests
from datetime import datetime

app = Flask(__name__)

@app.route('/weather', methods=['GET'])
def weather():
    location = request.args.get('location')
    start = request.args.get('start')
    end = request.args.get('end')

    if not location or not start or not end:
        return jsonify({'error': 'Missing required parameters: location, start, end'}), 400

    # Geocoding location to lat, lon
    geocode_res = requests.get(f"https://nominatim.openstreetmap.org/search?format=json&q={location}", headers={"User-Agent": "weather_observation_analysis (http://www.dangerouscentaur.com)"})
    if not geocode_res.ok:
        return jsonify({'error': 'Failed to geocode location'}), 500
    lat, lon = geocode_res.json()[0]['lat'], geocode_res.json()[0]['lon']

    # Finding nearest weather station
    points_res = requests.get(f"https://api.weather.gov/points/{lat},{lon}")
    if not points_res.ok:
        return jsonify({'error': 'Failed to find nearest station'}), 500
    station_url = points_res.json()['properties']['observationStations']
    station_res = requests.get(station_url)
    if not station_res.ok or not station_res.json()['features']:
        return jsonify({'error': 'No stations found'}), 500
    station_id = station_res.json()['features'][0]['properties']['stationIdentifier']

    # Fetching observations
    observations_res = requests.get(f"https://api.weather.gov/stations/{station_id}/observations?start={start}&end={end}", headers={"Accept": "application/geo+json"})
    if not observations_res.ok:
        return jsonify({'error': 'Failed to fetch observations'}), 500
    observations = observations_res.json()['features']

    # Extracting high and low temperatures
    daily_temps = {}
    for obs in observations:
        try:
            obs_time = datetime.strptime(obs['properties']['timestamp'], '%Y-%m-%dT%H:%M:%S%z').date()
        except ValueError:
            # Handle cases where the timestamp is not in the expected format
            obs_time = datetime.strptime(obs['properties']['timestamp'], '%Y-%m-%dT%H:%M:%S').date()
        temp = obs['properties']['temperature']['value']
        if temp is None:
            continue
        temp_f = temp *  9/5 +  32
        if obs_time not in daily_temps:
            daily_temps[obs_time] = {'High': temp_f, 'Low': temp_f}
        else:
            daily_temps[obs_time]['High'] = max(daily_temps[obs_time]['High'], temp_f)
            daily_temps[obs_time]['Low'] = min(daily_temps[obs_time]['Low'], temp_f)

    # Formatting for response
    formatted_result = {str(date): temps for date, temps in daily_temps.items()}
    
    return jsonify(formatted_result)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)

