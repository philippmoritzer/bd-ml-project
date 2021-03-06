import "date"
import "array"

training_data = from(bucket: "bird-migration")
|> range(start: v.timeRangeStart, stop: v.timeRangeStop)
|> filter(fn: (r) => (r._field == "lat"))  
|> pivot(rowKey: ["_time"], columnKey: ["_field"], valueColumn: "_value")
|> map(fn: (r) => ({
  tropical:       
    if r["lat"] >= 0 and r["lat"] < 23.5 then
      1 else 0,
  subtropical:
    if r["lat"] >= 23.5 and r["lat"] < 40 then
      1 else 0,
  mild:
    if r["lat"] >= 40 and r["lat"] < 60 then
      1 else 0,
  cold:
    if r["lat"] >= 40 and r["lat"] >= 60 then
      1 else 0,
  _season: 
    if date.month(t: r._time) == 12 or date.month(t: r._time) <= 2 then 
      "winter"
    else if date.month(t: r._time) >= 3 and date.month(t: r._time) <= 5 then 
      "spring"
    else if date.month(t: r._time) >= 6 and date.month(t: r._time) <= 8 then 
      "summer"
    else 
      "autumn"
  }))

all_entries = training_data |> reduce(
        fn: (r, accumulator) => ({all_entries: accumulator.all_entries + 1 }),
        identity: {all_entries: 0}, 
    ) |> set(key: "tag", value: "")
        |> group(columns: ["tag"])

winter_season_entries = training_data |> reduce(
        fn: (r, accumulator) => ({winter_season_entries: if r["_season"] == "winter" then accumulator.winter_season_entries + 1 else accumulator.winter_season_entries + 0 }),
        identity: {winter_season_entries: 0}, 
    ) |> set(key: "tag", value: "")
        |> group(columns: ["tag"])

spring_season_entries = training_data |> reduce(
        fn: (r, accumulator) => ({spring_season_entries: if r["_season"] == "spring" then accumulator.spring_season_entries + 1 else accumulator.spring_season_entries + 0 }),
        identity: {spring_season_entries: 0}, 
    ) |> set(key: "tag", value: "")
        |> group(columns: ["tag"])

summer_season_entries = training_data |> reduce(
        fn: (r, accumulator) => ({summer_season_entries: if r["_season"] == "summer" then accumulator.summer_season_entries + 1 else accumulator.summer_season_entries + 0 }),
        identity: {summer_season_entries: 0}, 
    ) |> set(key: "tag", value: "")
        |> group(columns: ["tag"])
autumn_season_entries = training_data |> reduce(
        fn: (r, accumulator) => ({autumn_season_entries: if r["_season"] == "autumn" then accumulator.autumn_season_entries + 1 else accumulator.autumn_season_entries + 0 }),
        identity: {autumn_season_entries: 0}, 
    ) |> set(key: "tag", value: "")
        |> group(columns: ["tag"])

tropical_entries = training_data |> reduce(fn: (r, accumulator) => ({tropical_entries: r["tropical"] + accumulator.tropical_entries}), identity: {tropical_entries: 0})
        |> set(key: "tag", value: "")
        |> group(columns: ["tag"])

subtropical_entries = training_data |> reduce(fn: (r, accumulator) => ({subtropical_entries: r["subtropical"] + accumulator.subtropical_entries}), identity: {subtropical_entries: 0})
        |> set(key: "tag", value: "")
        |> group(columns: ["tag"])

mild_entries = training_data |> reduce(fn: (r, accumulator) => ({mild_entries: r["mild"] + accumulator.mild_entries}), identity: {mild_entries: 0})
        |> set(key: "tag", value: "")
        |> group(columns: ["tag"])

cold_entries = training_data |> reduce(fn: (r, accumulator) => ({cold_entries: r["cold"] + accumulator.cold_entries}), identity: {cold_entries: 0})
        |> set(key: "tag", value: "")
        |> group(columns: ["tag"])

combined_1 = join(tables: {t1: winter_season_entries, t2: spring_season_entries}, on: ["tag"])
combined_2 = join(tables: {t1: combined_1, t2: summer_season_entries}, on: ["tag"])
combined_3 = join(tables: {t1: combined_2, t2: autumn_season_entries}, on: ["tag"]) 
combined_4 = join(tables: {t1: combined_3, t2: tropical_entries}, on: ["tag"]) 
combined_5 = join(tables: {t1: combined_4, t2: subtropical_entries}, on: ["tag"]) 
combined_6 = join(tables: {t1: combined_5, t2: mild_entries}, on: ["tag"]) 
combined_7 = join(tables: {t1: combined_6, t2: cold_entries}, on: ["tag"]) 
count_entries = join(tables: {t1: combined_7, t2: all_entries}, on: ["tag"])

rows = [
  {_class: "winter", _field: "tropical"},
  {_class: "winter", _field: "subtropical"},
  {_class: "winter", _field: "mild"},
  {_class: "winter", _field: "cold"},

  {_class: "spring", _field: "tropical"},
  {_class: "spring", _field: "subtropical"},
  {_class: "spring", _field: "mild"},
  {_class: "spring", _field: "cold"},

  {_class: "summer", _field: "tropical"},
  {_class: "summer", _field: "subtropical"},
  {_class: "summer", _field: "mild"},
  {_class: "summer", _field: "cold"},

  {_class: "autumn", _field: "tropical"},
  {_class: "autumn", _field: "subtropical"},
  {_class: "autumn", _field: "mild"},
  {_class: "autumn", _field: "cold"},
]
  
class_field_mapping = array.from(rows: rows) 
        |> set(key: "tag", value: "")
        |> group(columns: ["tag"])

class_field_count_total = join(tables: {t1: count_entries, t2: class_field_mapping}, on: ["tag"]) 

count_fields_by_class = (tables=<-, class) => tables
    |> reduce(
        identity: {
            sum_cold: 0,
            sum_mild: 0,
            sum_subtropical: 0,
            sum_tropical: 0,
        },
        fn: (r, accumulator) => ({
          sum_tropical: if r["_season"] == class and r["tropical"] == 1 then accumulator.sum_tropical + 1 else accumulator.sum_tropical + 0,
          sum_subtropical: if r["_season"] == class and r["subtropical"] == 1 then accumulator.sum_subtropical + 1 else accumulator.sum_subtropical + 0,
          sum_mild: if r["_season"] == class and r["mild"] == 1 then accumulator.sum_mild + 1 else accumulator.sum_mild + 0,
          sum_cold: if r["_season"] == class and r["cold"] == 1 then accumulator.sum_cold + 1 else accumulator.sum_cold + 0,
        }),
    )

field_while_class_winter = training_data |> count_fields_by_class(class: "winter") |> set(key: "tag", value: "") |> group(columns: ["tag"])
field_while_class_spring = training_data |> count_fields_by_class(class: "spring") |> set(key: "tag", value: "") |> group(columns: ["tag"])
field_while_class_summer = training_data |> count_fields_by_class(class: "summer") |> set(key: "tag", value: "") |> group(columns: ["tag"])
field_while_class_autumn = training_data |> count_fields_by_class(class: "autumn") |> set(key: "tag", value: "") |> group(columns: ["tag"])

combined_field_class_1 = join(tables: {winter: field_while_class_winter, spring: field_while_class_spring}, on: ["tag"])
combined_field_class_2 = join(tables: {t3: combined_field_class_1, summer: field_while_class_summer}, on: ["tag"])
combined_field_class = join(tables: {summer: combined_field_class_2, autumn: field_while_class_autumn}, on: ["tag"]) 

temp_combined_field_class_count_total = join(tables: {t1: class_field_count_total, t2: combined_field_class}, on: ["tag"]) 

temp_combined_field_class_count_total |> map(fn: (r) => ({
    r with field_in_class_count: if r["_class"] == "winter" and r["_field"] == "tropical" then r["sum_tropical_winter"]
    else if r["_class"] == "winter" and r["_field"] == "subtropical" then r["sum_subtropical_winter"]
    else if r["_class"] == "winter" and r["_field"] == "mild" then r["sum_mild_winter"]
    else if r["_class"] == "winter" and r["_field"] == "cold" then r["sum_cold_winter"]

    else if r["_class"] == "spring" and r["_field"] == "tropical" then r["sum_tropical_spring"]
    else if r["_class"] == "spring" and r["_field"] == "subtropical" then r["sum_subtropical_spring"]
    else if r["_class"] == "spring" and r["_field"] == "mild" then r["sum_mild_spring"]
    else if r["_class"] == "spring" and r["_field"] == "cold" then r["sum_cold_spring"]

    else if r["_class"] == "summer" and r["_field"] == "tropical" then r["sum_tropical_summer"]
    else if r["_class"] == "summer" and r["_field"] == "subtropical" then r["sum_subtropical_summer"]
    else if r["_class"] == "summer" and r["_field"] == "mild" then r["sum_mild_summer"]
    else if r["_class"] == "summer" and r["_field"] == "cold" then r["sum_cold_summer"]

    else if r["_class"] == "autumn" and r["_field"] == "tropical" then r["sum_tropical_autumn"]
    else if r["_class"] == "autumn" and r["_field"] == "subtropical" then r["sum_subtropical_autumn"]
    else if r["_class"] == "autumn" and r["_field"] == "mild" then r["sum_mild_autumn"]
    else if r["_class"] == "autumn" and r["_field"] == "cold" then r["sum_cold_autumn"]

    else 0    
})) |> drop(columns: ["sum_tropical_winter","sum_subtropical_winter","sum_mild_winter","sum_cold_winter","sum_tropical_spring","sum_subtropical_spring","sum_mild_spring","sum_cold_spring",
"sum_tropical_summer","sum_subtropical_summer","sum_mild_summer","sum_cold_summer","sum_tropical_autumn","sum_subtropical_autumn","sum_mild_autumn","sum_cold_autumn"])