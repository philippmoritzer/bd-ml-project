
from ast import parse
from csv import DictReader
from collections import OrderedDict


from influxdb_client import InfluxDBClient, Point, WriteOptions
import os
import sys
import uuid

#import rx for functional programming
import rx
from rx import operators

from app.connect_to_influx import connect_to_influxdb

url = os.environ['INFLUX_URL'] or 'http://localhost:8086'
token = os.environ['INFLUX_TOKEN'] or '4t6SUQYXFtiFuUcRLO7vcdp9SmUS8uW5L5WCUP2COq9vQ5OoIzK68fi9NiY0a8Y0eEWB-f4FeVQZeBtL2DcLaA=='
org = os.environ['INFLUX_ORG'] or 'pmoritzer'

#bucket_api = client.buckets_api()
#bucket_name = 'bird-migration {}'.format(uuid.uuid4().hex)
#bucket = bucket_api.create_bucket(bucket_name=bucket_name, org=org)

def parse_row(row: OrderedDict):   
    return Point("migration-point").tag("type", "migration-value") \
        .field("event-id", row['event-id']) \
        .field("location-long", row['location-long']) \
        .field("location-lat", row['location-lat']) \
        .field("manually-marked-outlier", row['manually-marked-outlier']) \
        .field("visible", row['visible']) \
        .field("sensor-type", row['sensor-type']) \
        .field("individual-taxon-canonical-name", row['individual-taxon-canonical-name']) \
        .field("tag-local-identifier", row['tag-local-identifier']) \
        .field("individual-local-identifier", row['individual-local-identifier']) \
        .field("study-name", row['study-name']) \
        .time(row['timestamp'])
        #.field("ECMWF Interim Full Daily Invariant Low Vegetation Cover", row['ECMWF Interim Full Daily Invariant Low Vegetation Covere']) \
        #.field("NCEP NARR SFC Vegetation at Surface", row['NCEP NARR SFC Vegetation at Surface']) \
        #.field("ECMWF Interim Full Daily Invariant High Vegetation Cover", row['ECMWF Interim Full Daily Invariant High Vegetation Cover']) \
        

data = rx \
    .from_iterable(DictReader(open('migration_original.csv', 'r'))) \
    .pipe(operators.map(lambda row: parse_row(row)))

with connect_to_influxdb(url, token, org) as client:    
    with client.write_api(write_options=WriteOptions(batch_size=50000, flush_interval=10000)) as write_api:        
        write_api.write(bucket="bird-migration", record=data)

    query = 'from(bucket:"bird-migration")' \
            ' |> range(start: 0, stop: now())'
    result = client.query_api().query(query=query)
    print()
    print("=== results ===")
    print()