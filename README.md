Collection of lua modules for
- timers
- animations
- easings

everything can be found in `data_static/scripts/libraries`
with examples being in `data_static/scripts/examples`

To use: 
Copy the `libraries` folder into your project and use `tm.os.DoFile("<path to file>")` to use it.

Animation file format:
```json
{
	"loop" : "loop", // loop mode of the animation, Options [never, loop, ping pong]
	"start" : { // start transform of the object
		"position" : {
			"x" : 0,
			"y" : 350,
			"z" : 0
		},
		"rotation" : {
			"x" : 0,
			"y" : 0,
			"z" : 0
		},
		"scale" : {
			"x" : 1,
			"y" : 1,
			"z" : 1
		}
	},
	"keyframes" : [ // array of keyframes, these will be played 1 after the other unless 'parallel' is true, in that case it will be played at the same time as the previous keyframe
		{
			"type" : "position", // keyframe type, Options [position, rotation, scale, wait]
			"endValue" : { // end value of the keyframe (it will start at the previous keyframe value/start transform
				"x" : 0,
				"y" : 300,
				"z" : 0
			},
			"duration" : 2, //duration of the keyframe, if 'parallel' is true its recommended to make it the same as the previous keyframe
			"easing" : "Bounce", //easing that will be used
			"easingType" : "Out", //easing type that will be used
			"parallel" : false
		},
		{
			"type" : "wait",
			"duration" : 1, //wait only needs duration
		},
		{
			"type" : "position",
			"endValue" : {
				"x" : 0,
				"y" : 300,
				"z" : 20
			},
			"duration" : 2,
			"easing" : "Sine",
			"easingType" : "Out",
			"parallel" : false
		},
		{
			"type" : "rotation",
			"endValue" : {
				"x" : 0,
				"y" : 90,
				"z" : 0
			},
			"duration" : 2,
			"easing" : "Elastic",
			"easingType" : "InOut",
			"parallel" : true
		}
	]
}
```
