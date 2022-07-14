import "date"

from(bucket: "bird-migration")
|> range(start: v.timeRangeStart, stop: v.timeRangeStop)
|> filter(fn: (r) => (r._field == "lat"))  
|> pivot(rowKey: ["_time"], columnKey: ["_field"], valueColumn: "_value")
|> map(fn: (r) => ({    
  _location:       
    if r["lat"] >= 0 and r["lat"] < 23.5 then
      "tropical"
    else if r["lat"] >= 23.5 and r["lat"] < 40 then
      "subtropical"
    else if r["lat"] >= 40 and r["lat"] < 60 then
      "mild"  
    else
      "cold",
  winter: 
    if date.month(t: r._time) == 12 or date.month(t: r._time) <= 2 then 
      1 else 0,
  spring: 
    if date.month(t: r._time) >= 3 and date.month(t: r._time) <= 5 then 
      1 else 0,
  summer:
    if date.month(t: r._time) >= 6 and date.month(t: r._time) <= 8 then 
      1 else 0,
  autumn:
    if date.month(t: r._time) >= 9 and date.month(t: r._time) <= 11 then 
      1 else 0,
  }))
