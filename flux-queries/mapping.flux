import "csv"

identifier = from(bucket:"bird-migration")
|> range(start: 0, stop: now())  
|> filter(fn: (r) =>
    r._measurement == "migration" and
    r._field == "individual-local-identifier"
  )
|> distinct(column: "_value") 
|> rename(columns: {_value: "identifier"}) 
|> findColumn(
    fn: (key) => key._measurement == "migration",
    column: "identifier",
) 

csvData = "
id,color
0,#00fa9a
1,#dc143c
2,#00ffff
3,#00bfff
4,#f4a460
5,#9370db
6,#0000ff
7,#a020f0
8,#adff2f
9,#da70d6
10,#b0c4de
11,#ff00ff
12,#1e90ff
13,#f0e68c
14,#fa8072
15,#dda0dd
16,#ff1493
17,#afeeee
18,#98fb98
19,#7fffd4
20,#fafad2
21,#ff69b4
22,#ffb6c1
23,#fff015
24,#8fbc8f
25,#800800
26,#b03060
27,#d2b48c
28,#ff0000
29,#ffa500
30,#ffd700
31,#ffff00
32,#00ff00
33,#3cb371
34,#b8860b
35,#4682b4
36,#d2691e
37,#9acd32
38,#20b2aa
39,#00008b
40,#32cd32
41,#808080
42,#2f4f4f
43,#556b2f
44,#8b4513
45,#006400
46,#8b0000
47,#808000
48,#483d8b
"

colors = csv.from(
    csv: csvData, mode: "raw"
)
|> map(fn: (r) => ({r with color: r["color"], tag: r["tag"], "unique-local-identifier": if int(v: r["id"]) < length(arr: identifier) then identifier[int(v: r["id"])] else "no color"}))
|> drop(columns: ["id"])
|> yield()
