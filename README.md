
```
# Weather Observation Analysis

This repository contains a Flask application that provides weather observation analysis via a RESTful API. The application uses external APIs to fetch geolocation and weather data, processes it, and returns the high and low temperatures for a given location and date range.

## Directory Structure

- `app.py`: The main Flask application file.
- `requirements.txt`: Lists the Python packages required to run the application.
- `Dockerfile`: Instructions for building a Docker image of the application.
- `docker-compose.yml`: A Docker Compose file for orchestrating multi-container Docker applications.
- `tests/`: Contains unit tests for the application.
- `scripts/`: Additional scripts that may be used for various purposes.
- `instance/`: Instance-specific files, such as configuration files that might differ between deployment environments.
- `tf/`: Terraform files for infrastructure as code.

## Prerequisites

- Python  3.x installed on your machine.
- Docker (optional, for containerization).
- Virtual environment (recommended, but not strictly required).

## Installation

1. Clone the repository to your local machine.
2. Create a virtual environment (optional):
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows, use `venv\Scripts\activate`
   ```
3. Install the required packages:
   ```bash
   pip install -r requirements.txt
   ```

## Running the Application

To run the application locally without Docker:

```bash
export FLASK_APP=app.py
flask run
```

Or, if you prefer to use Docker:

```bash
docker build -t weather-observation-analysis .
docker run --rm -p  5000:5000 weather-observation-analysis
```

## Testing

To run the tests:

```bash
python -m unittest discover -s tests
```

## Usage

Once the application is running, you can access the `/weather` endpoint by making a GET request with the following query parameters:

- `location`: The name of the location you want weather data for.
- `start`: The start date for the weather range in ISO  8601 format (e.g., `2024-01-01T00:00:00Z`).
- `end`: The end date for the weather range in ISO  8601 format (e.g., `2024-02-01T00:00:00Z`).

Example request:

```bash
curl "http://127.0.0.1:5000/weather?location=New+York&start=2024-01-01T00:00:00Z&end=2024-02-01T00:00:00Z"
```

## Deployment

The `docker-compose.yml` file can be used to deploy the application using Docker Compose. Ensure you have Docker and Docker Compose installed, then execute:

```bash
docker-compose up
```

## Contributing

Feel free to fork the repository and submit pull requests. Please adhere to the existing style guidelines and include tests for new features or bug fixes.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
```
