# Weaver
The idea is to take an image and come up with data to weave it using a single thread on a circular rim.

Basically this: *A picture is worth a thousand words.*
![Work by Petros Vrellis](https://user-images.githubusercontent.com/14050128/65774967-b74a9200-e158-11e9-8949-f77d1162b44e.png)

## Screenshots
### Multiple colors
![Color Circle Frame](https://user-images.githubusercontent.com/14050128/65891086-69829380-e3bd-11e9-9364-e8dadb31fef2.png)

### Grayscale
![Circle Frame](https://user-images.githubusercontent.com/14050128/65774788-663a9e00-e158-11e9-9f45-405036d38be7.png)
![Square Frame](https://user-images.githubusercontent.com/14050128/65774834-7ce0f500-e158-11e9-941d-2204f92e5e52.png)

## Basic algorithm
This piece of software requires 3 inputs from the user:
- A picture to be drawn
- Total points/nails on a circular rim, `P`
- Total lines to be drawn, `L`

All three inputs are crucial on how the final result is going to look. The program does the following:
1. Converts the color picture to grayscale.
2. The picture is then cropped to a square.
3. Places a virtual circular rim with `P` equidistant points on it.
4. Takes the first point (`p = 0`) as the starting point.
5. Finds the next point `p'` to draw a line from point `p` by finding the highest intensity line.
   - The intensity of a line is calculated by adding up the all the pixel values of a line from `p` to `p'`.
6. A new line is drawn from `p` to `p'` on the circular rim.
7. The original image is modified such that the pixels under the line from `p` to `p'` are lightened* so that the same line is not drawn next time.
8. `p'` is set as the new starting point `p` and then the steps from `5` is repeated until `L` lines are drawn.

\* The amount by which a line should be lightened can also be configured.

## How to run?
- You'll need to download [Processing](https://processing.org/download/). It's available for Windows / Mac / Linux.
- Open up `Weaver.pde` using Processing.
- Hit `Run` or press `CTRL+R` to execute the application.
- Click anywhere on the application to start processing.
- Click again to pause.
- After the process is complete, a text file will be generated. This file contains the positions of each point where the thread should be knitted next.

**Note:** Those of you who are downloading the repository as *.zip* file, you must rename the folder `Weaver-master` to `Weaver` before opening on Processing.

## Configuration
The `setup()` function in `Weaver.pde` chooses one of the example configurations. Check the `example.pde` to modify the configuration of each example.

## Credits
Kudos to [i-make-robots](https://github.com/i-make-robots/) for originally writting [this algorithm](https://github.com/i-make-robots/weaving_algorithm).

I changed it a little bit to clean up the code, improve GUI and add some extra features.
