# Weaver
The idea is to take an image and come up with data to weave it using a single thread on a circular rim.

Basically this: *A picture is worth a thousand words.*
![Work by Petros Vrellis](http://static.boredpanda.com/blog/wp-content/uploads/2016/08/single-thread-art-painting-petros-vrellis-fb.png)

## Screenshots
![](/weaver_start.png?raw=true)
![](/weaver_end.png?raw=true)

## How to run?
- You'll need to download [Processing](https://processing.org/download/). It's available for Windows / Mac / Linux.
- Open up `Weaver.pde` using Processing.
- Hit `Run` or press `CTRL+R` to execute the application.
- Click anywhere on the application to start processing.
- Click again to pause.
- After the process is complete, a file will be generated, `output.txt`. This file contains the positions of each point where the thread should be knitted next.
 
## Configuration
Open up the code, `Weaver.pde`. You'll find comments on first few lines about all the configurable variables.

## Credits
Kudos to [i-make-robots](https://github.com/i-make-robots/) for originally writting [this algorithm](https://github.com/i-make-robots/weaving_algorithm).

I changed it a little bit to clean up the code, improve GUI and add some extra features.

