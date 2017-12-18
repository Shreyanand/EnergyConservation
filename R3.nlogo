breed [ agents agent ]

globals [
  power-profile
  sum-power
  no-agents
  average-power
  average-powerf
  act-hr
  highest-payoff
  highest-prdctd-hr
  most-prdctd-hr
  stoc-prdctd-hr
  pav-prdctd-hr
  average-R
  average-payoff
  initial-consumption
  final-consumption

  average-payoffS
  average-payoffP
  average-payoffG
  average-payoffC
  percentage

  f

]
agents-own[
  my-power-profile
  personality
  total-payoff
  payoff
  prdctd-hr
  R
  ]

to setup
  ca
  reset-ticks
;  set power-profile [443211  434024  437194  453160  471251  492983  521046  555261  588518  616840  640647  658809  670530  677365  680204  673011  657920  641418  623794  592619  555188  519217  487376  461944
  set power-profile [23156  21475  20393  19638  19254  19352  19656  20188  22124  24387  26860  29093  30967  32440  33616  34483  35044  34941  33691  31854  30883  29460  27305  24886]
  set sum-power [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]
  set average-powerf [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]
  ;set rc 0.8
  set no-agents stochastic-number + pavlovian-number + greedy-number + conformist-number
  create-agents stochastic-number [
     setxy random-pxcor random-pycor
     set personality "Stochastic"
     set my-power-profile map[? + initial-noise - random (2 * initial-noise)] power-profile
     set total-payoff 0
     set color red
]
    create-agents pavlovian-number [
     setxy random-pxcor random-pycor
     set personality "Pavlovian"
     set my-power-profile map[? + initial-noise - random (2 * initial-noise)] power-profile
     set total-payoff 0
     set color green
]
      create-agents greedy-number [
     setxy random-pxcor random-pycor
     set personality "Greedy"
     set my-power-profile map[? + initial-noise - random (2 * initial-noise)] power-profile
     set total-payoff 0
     set color blue
]
        create-agents conformist-number [
     setxy random-pxcor random-pycor
     set personality "Conformist"
     set my-power-profile map[? + initial-noise - random (2 * initial-noise)] power-profile
     set total-payoff 0
     set color yellow
]
  ask agents [ set sum-power (map + sum-power my-power-profile) ]
  set average-power map [? / no-agents] sum-power
  set f sum average-power
  set act-hr position max average-power average-power
  set highest-payoff 0
  set average-R 0
  set average-payoff 0
end

to go
  tick
  set sum-power [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]
  ask agents [ set sum-power (map + sum-power my-power-profile) ]
  set average-power map [? / no-agents] sum-power
  set initial-consumption sum average-power
  set act-hr position max average-power average-power
  let pwr 0


  ask agents [

    if personality = "Stochastic" [
      set pwr max my-power-profile
      set prdctd-hr position pwr my-power-profile
      let p random 10
      ifelse p < 4 [set R 1] [set R rc + random-float (1 - rc)]
     ]

    if personality = "Pavlovian" [
      ifelse (average-payoff = 0 or average-payoff > payoff) [set R 1 set pwr one-of my-power-profile set prdctd-hr position pwr my-power-profile ]
      [set R rc + random-float (1 - rc) set pwr item prdctd-hr my-power-profile ]]

    if personality = "Greedy" [
    set R 1
    ifelse highest-payoff = 0 [set pwr one-of my-power-profile set prdctd-hr position pwr my-power-profile ] [ set prdctd-hr highest-prdctd-hr set pwr item prdctd-hr my-power-profile]
    ]

    if personality = "Conformist" [
    ifelse average-R = 0 [set R rc + random-float (1 - rc) set pwr one-of my-power-profile set prdctd-hr position pwr my-power-profile ][
      set prdctd-hr most-prdctd-hr set pwr item prdctd-hr my-power-profile
      set R average-R
      ]

    ]

    set payoff  1 / (R * (abs(prdctd-hr - act-hr) + 1))
    set total-payoff total-payoff + payoff
    set my-power-profile replace-item prdctd-hr my-power-profile 0
    let redis pwr * R / 24
    set my-power-profile map [? + redis ] my-power-profile
    ]


  set highest-payoff 0
  ask agents [ if payoff > highest-payoff [
      set highest-payoff payoff
      set highest-prdctd-hr prdctd-hr
       ]
  ]


  let freq [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]
  let freqS [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]
  let freqP [ 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]

  set average-R 0
  set average-payoff 0

  set average-payoffS 0
  set average-payoffP 0
  set average-payoffG 0
  set average-payoffC 0

  ask agents [
    set average-R average-R + R
    set average-payoff average-payoff + payoff

    let temp item prdctd-hr freq
    set temp temp + 1
    set freq replace-item prdctd-hr freq temp

    if personality = "Stochastic" [
      set average-payoffS average-payoffS + total-payoff
      let tempS item prdctd-hr freqS
      set tempS tempS + 1
      set freqS replace-item prdctd-hr freqS tempS
      ]
    if personality = "Pavlovian" [
      set average-payoffP average-payoffP + total-payoff
      let tempP item prdctd-hr freqP
      set tempP tempP + 1
      set freqP replace-item prdctd-hr freqP tempP
      ]

    ]
  set average-R average-R / no-agents

  set average-payoffS average-payoffS / (stochastic-number + 1)
  set average-payoffP average-payoffP / (pavlovian-number + 1)
  set average-payoffG average-payoffG / (greedy-number + 1)
  set average-payoffC average-payoffC / (conformist-number + 1)

  set most-prdctd-hr position max freq freq
  set stoc-prdctd-hr position max freqS freqS
  set pav-prdctd-hr position max freqP freqP
  set average-payoff average-payoff / no-agents

  set average-powerf [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]
  ask agents [ set average-powerf (map + average-powerf my-power-profile) ]
  set average-powerf map [? / no-agents] average-powerf
  set final-consumption sum average-powerf
  set percentage 100 * ( 1 - ( final-consumption / initial-consumption ))
  ;show freq
  plot-graphs

end

to plot-graphs
  set-current-plot "Average Power Profile"
  clear-plot
  let i 0
  foreach(average-power)[
    plotxy i ?
    set i i + 1
    ]
  set-current-plot "Payoffs for Different Agent Personalities"
  clear-plot
  ask agents with [personality = "Stochastic"] [set-current-plot-pen "Stochastic"  plot total-payoff ]
  ask agents with [personality = "Pavlovian"] [set-current-plot-pen "Pavlovian"  plot total-payoff ]
  ask agents with [personality = "Greedy"] [set-current-plot-pen "Greedy"  plot total-payoff ]
  ask agents with [personality = "Conformist"] [set-current-plot-pen "Conformist"  plot total-payoff ]
  set-current-plot "Peak Hour Variation"
  set-current-plot-pen "Most predicted hour"
  plotxy ticks most-prdctd-hr
  set-current-plot-pen "Highest payoff hour"
  plotxy ticks highest-prdctd-hr
  set-current-plot-pen "Actual peak hour"
  plotxy ticks act-hr
  set-current-plot-pen "Stochastic predicted hour"
  plotxy ticks stoc-prdctd-hr
  set-current-plot-pen "Pavlovian predicted hour"
  plotxy ticks pav-prdctd-hr
end
@#$#@#$#@
GRAPHICS-WINDOW
157
59
486
409
16
16
9.67
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
6
71
79
104
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
6
117
69
150
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
504
58
931
328
Average Power Profile
hour
Power
0.0
24.0
0.0
10.0
true
false
"" ""
PENS
"p1" 1.0 0 -16777216 true "" ""

PLOT
958
59
1387
328
Payoffs for Different Agent Personalities
Agents
Payoffs
0.0
10.0
0.0
5.0
true
true
"" ""
PENS
"Stochastic" 1.0 2 -2674135 true "" ""
"Pavlovian" 1.0 2 -10899396 true "" ""
"Greedy" 1.0 2 -13345367 true "" ""
"Conformist" 1.0 2 -1184463 true "" ""

MONITOR
1053
429
1196
474
NIL
average-R
17
1
11

MONITOR
1052
487
1193
532
NIL
average-payoff
17
1
11

SLIDER
5
160
116
193
initial-noise
initial-noise
0
3000
1000
500
1
NIL
HORIZONTAL

SLIDER
5
246
142
279
stochastic-number
stochastic-number
0
100
50
5
1
NIL
HORIZONTAL

SLIDER
3
290
142
323
pavlovian-number
pavlovian-number
0
100
50
5
1
NIL
HORIZONTAL

SLIDER
3
331
148
364
greedy-number
greedy-number
0
100
50
5
1
NIL
HORIZONTAL

SLIDER
3
372
145
405
conformist-number
conformist-number
0
100
50
5
1
NIL
HORIZONTAL

SLIDER
5
203
97
236
rc
rc
0
1
0.8
0.1
1
NIL
HORIZONTAL

PLOT
2
419
665
772
Peak Hour Variation
Iteration
Peak hour
0.0
10.0
0.0
24.0
true
true
"" ""
PENS
"Actual peak hour" 1.0 0 -2674135 true "" ""
"Highest payoff hour" 1.0 0 -10899396 true "" ""
"Most predicted hour" 1.0 0 -13345367 true "" ""
"Stochastic predicted hour" 1.0 0 -6459832 true "" ""
"Pavlovian predicted hour" 1.0 0 -1184463 true "" ""

MONITOR
517
536
592
581
Peak Hour
act-hr
17
1
11

MONITOR
516
580
593
625
NIL
most-prdctd-hr
17
1
11

MONITOR
515
624
593
669
NIL
highest-prdctd-hr
17
1
11

PLOT
685
426
1046
623
Percentage of Energy Saved Per Iteration
Iterations
Energy Saved Percentage
0.0
10.0
0.0
0.3
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy ticks percentage"

MONITOR
988
446
1038
491
cumulative
100 * (1 - final-consumption / f)
17
1
11

MONITOR
514
669
593
714
NIL
stoc-prdctd-hr
17
1
11

MONITOR
514
716
593
761
NIL
pav-prdctd-hr
17
1
11

TEXTBOX
246
17
1320
52
Reduction of Energy Consumption Through Incentives in Social Games
30
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
