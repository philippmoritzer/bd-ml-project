from(bucket: "bird-migration")
|> range(start: v.timeRangeStart, stop: v.timeRangeStop)
|> filter(fn: (r) => r._measurement == "migration")
|> filter(fn: (r) => (r._field == "lat") or  (r._field == "lon") or (r._field == "individual-local-identifier"))  
|> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")

|>  filter(fn: (r) => contains(value: r["individual-local-identifier"], set: ${localIdentifier:json}))


