#!/bin/bash

# Define start and end dates for observations in ISO  8601 format
startDate="2023-01-01T00:00:00Z"
endDate="2023-01-07T23:59:59Z"

# Define locations (latitude and longitude)
declare -a locations=(
    "40.7128,-74.0060" # New York
    "34.0522,-118.2437" # Los Angeles
    "41.8781,-87.6298" # Chicago
)

# Define the search pattern for 'generac'
pattern='generac'

# Define the keyword for searching in .tf files
keyword='security'

# Function to check for SSH access in security group rules
check_ssh_access() {
    local sg_id=$1
    echo "Checking for SSH access in Security Group $sg_id..."
    local ssh_rules=$(aws ec2 describe-security-groups --group-ids "$sg_id" --query "SecurityGroups[].IpPermissions[?ToPort==22 && IpProtocol=='tcp'].IpRanges[].CidrIp" --output text)
    
    if [[ -z "$ssh_rules" ]]; then
        echo "No SSH access rule found in Security Group $sg_id."
    else
        echo "SSH access allowed from IPs: $ssh_rules"
    fi
}

# Main script starts here
VPC_ID=$1
INSTANCE_ID=$2

if [[ -z "$VPC_ID" || -z "$INSTANCE_ID" ]]; then
    echo "Usage: $0 <VPC-ID> <Instance-ID>"
    exit  1
fi

echo "VPC ID: $VPC_ID"
echo "Instance ID: $INSTANCE_ID"

# Fetching weather observation data for each location
for location in "${locations[@]}"; do
    echo "Fetching data for location: $location"
    
    # Split location into latitude and longitude
    IFS=',' read -r -a latlong <<< "$location"
    latitude="${latlong[0]}"
    longitude="${latlong[1]}"

    # Fetch nearest weather station for the location
    stationResponse=$(curl -s "https://api.weather.gov/points/$latitude,$longitude")
    
    # Extract station ID from the response (simplified, assumes jq is installed)
    stationId=$(echo "$stationResponse" | jq -r '.properties.observationStations' | awk -F'/' '{print $NF}')
    
    if [ -z "$stationId" ]; then
        echo "No station found for location $location. Skipping."
        continue
    fi
    
    echo "Nearest station ID: $stationId"

    # Fetch observations for the station
    observations=$(curl -s -H "Accept: application/geo+json" "https://api.weather.gov/stations/$stationId/observations?start=$startDate&end=$endDate")

    # Check if features array is empty
    if echo "$observations" | jq '.features | length' | grep -q "0"; then
        echo "No observations found for $location ($stationId) within the date range."
    else
        echo "Observations found for $location ($stationId)."
        # Optionally, process or save your observations data here
        # echo "$observations" > "observations_${location}.json"
    fi
done

# Recursively search for the pattern in all .tf files
grep -r -C   3 --include \*.tf "$pattern" .

# Search for 'security' in all .tf files, showing file path, line number, and the line content
grep -rnc   3 "$keyword" --include *.tf .

# Instance state check
instance_state=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[].Instances[].State.Name" --output text)
echo "Instance State: $instance_state"
if [[ "$instance_state" != "running" ]]; then
    echo "Instance is not in a running state."
    exit  1
fi

# Fetch instance security group(s)
sg_ids=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[].Instances[].SecurityGroups[].GroupId" --output text)
if [[ -z "$sg_ids" ]]; then
    echo "No Security Groups found for instance $INSTANCE_ID."
    exit  1
fi

# Check each security group for SSH access
for sg_id in $sg_ids; do
    check_ssh_access "$sg_id"
done

# Diagnostic information for EC2 instances in VPC
echo "Finding EC2 instances in VPC $VPC_ID..."
INSTANCE_IDS=$(aws ec2 describe-instances --filters "Name=vpc-id,Values=$VPC_ID" --query "Reservations[*].Instances[*].InstanceId" --output text)

if [ -z "$INSTANCE_IDS" ]; then
    echo "No instances found in VPC $VPC_ID."
    exit  1
fi

# Process each instance
for INSTANCE_ID in $INSTANCE_IDS; do
    echo "-------------------------------------------------"
    echo "Processing Instance: $INSTANCE_ID"
    

