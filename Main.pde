MagicEye magicEye;

// ***
void setup() {
  magicEye = new MagicEye();
  
  /*
    
    MagicEye config parameters:
    
    --- depth map ---
    
    > CONFIG.DEPTH_MAP (0): [REQUIRED]
      - local filename of depth map
        (i.e. "depth-map.png")
      - depth map image(s) will always be automatically centered
      - while gifs are not supported, you may add hashtags (#) representing the number of digits for the indices of each frame (frames start at 0)
        (i.e. "frame-###.png" >> "frame-000.png", "frame-001.png", ... "frame-999.png" (incorrect: "frame-0.png", ... "frame-10.png"))
      - note: any depth map image with color will automatically be converted to grayscale
        - transparency in png images will be interpreted as darker, perceived farther away, sections in the depth map
    
    > CONFIG.DEPTH_MAP_SCALE (1):
      - scale factor for the resolution of the inputted depth map image(s)
        (i.e. "2x2", defaults to autoscaling if not set)
      - note: autoscaling automatically sets the image sizing to best fit the resolution (maintains aspect ratio)
    
    
    --- texture ---
    
    > CONFIG.TEXTURE_MODE (2):
      (defaults to TEXTURE_MODE.ALGORITHM) 
      - can only be set to TEXTURE_MODE.FILE (0) or TEXTURE_MODE.ALGORITHM (1)
    
    > CONFIG.TEXTURE_FILE (3): [REQUIRED (Only applicable when CONFIG.TEXTURE_MODE is set to TEXTURE_MODE.FILE)]
      - if CONFIG.TEXTURE_MODE is set to TEXTURE_MODE.FILE, use this parameter to set the filename of your texture image
        (i.e. "texture.png")
      - as mentioned in CONFIG.DEPTH_MAP, you are able to add hashtags (#) representing the number of digits for the indices of each frame (frames start at 0)
        (i.e. "frame-###.png" >> "frame-000.png", "frame-001.png", ... "frame-999.png")
        - note: if depth map and texture frame counts are not aligned, the depth map will take precedent and loop smoothly,
                while the texture frames will jump to the first frame early at the end of the depth map loop
    
    > CONFIG.TEXTURE_FILE_SCALE (4):
      - scale factor for the resolution of the inputted texture image(s) (Only applicable when CONFIG.TEXTURE_MODE is set to TEXTURE_MODE.FILE)
        (i.e. "2x2", defaults to autoscaling if not set)
      - note: as mentioned in CONFIG.DEPTH_MAP_SCALE, autoscaling automatically sets the image sizing to best fit the resolution (maintains aspect ratio)
    
    > CONFIG.TEXTURE_ALGORITHM (5):
      (defaults to ALGORITHMS.TV_STATIC)
      - if CONFIG.TEXTURE_MODE is set to TEXTURE_MODE.ALGORITHM, use this parameter to set the algorithm of your texture
        - algorithm options:
          > ALGORITHMS.TV_STATIC (0):
            - this algorithm generates random black and white "tv static" images
          > ALGORITHMS.RANDOM (1):
            - this algorithm generates images with all pixels' colors chosen at random
          > ALGORITHMS.PERLIN_NOISE_GRAYSCALE (2):
            - this algorithm generates black and white images using perlin noise
          > ALGORITHMS.PERLIN_NOISE_COLOR (3):
            - this algorithm generates color images using perlin noise
      - note: all algorithms regenerate a new random texture every frame
    > CONFIG.TEXTURE_ALGORITHM_RESOLUTION (6):
      - if CONFIG.TEXTURE_MODE is set to TEXTURE_MODE.ALGORITHM, use this parameter to set the resolution of each texture that the selected algorithm generates
        (i.e. "40x40", defaults to "[resolution width / 10]x[resolution height]")
    
    --- animation ---
    
    > CONFIG.ANIM_LOOPS (7):
      - amount of times the depth map frames loop (if your depth map has only one frame, you can use this determine the amount of frames for that single depth map image)
        (i.e. "5", defaults to "1")
    
    > CONFIG.ANIM_TEXTURE_MOVEMENT (8):
      - amount of times background texture shifts its position horizontally and vertically by full width and length increments, creates a moving background effect
        (i.e. "1,2", defaults to "0,0" (must be integers))
      - note: this works best with imported textures, as program-generated textures are randomly regenerated every frame (negates the movement effect)
    
    --- resolution ---
    
    > CONFIG.RESOLUTION (9):
      - resolution of target image (not including scaling parameter)
        (i.e. "1920x1080", defaults to "1024x1024")
    > CONFIG.SCALE (10):
      - scale factor for the resolution set using CONFIG.RESOLUTION
        (i.e. "10x10", defaults to "2x2")
      - use only if you want each perceived pixel to be "bigger" - while this may increase the final resolution of the image, it doesn't upscale/interpolate
    
    --- export ---
    
    > CONFIG.EXPORT_IMAGES_PREFIX (11):
      - filename prefix of image(s) to be exported
        (i.e. "my magiceye", defaults to "Compiled/export")
    > CONFIG.EXPORT_IMAGES_EXTENSION (12):
      - filetype of exported images(s)
        (i.e. "jpg", defaults to "png")
      - note: as said earlier, "gif" is not supported (all frames are exported individually)
    
    --- console messages ---
    
    > CONFIG.CONSOLE_STATUS_MESSAGES (13):
      - if "true", console messages stating the image load/generation status will be shown
        (must be "true" or "false", defaults to "true")
    
  */
  
  
  /* ------------------------- EDIT THIS: ------------------------- */
  
  // load depth map file(s)
  magicEye.addConfig(CONFIG.DEPTH_MAP_FILE, "Depth Maps/cube.png");
  /*
    > example depth maps:
      - Depth Maps/atomium.png
      - Depth Maps/cube.png
      - Depth Maps/head.png
      - Depth Maps/saturn.png
      - Depth Maps/ship.png
      - Depth Maps/tree.png
      - Depth Maps/vortex.png
      - Depth Maps/wireframe-cube.png
  */
  
  // load texture file(s)
  magicEye.addConfig(CONFIG.TEXTURE_MODE, TEXTURE_MODE.FILE);
  magicEye.addConfig(CONFIG.TEXTURE_FILE, "Textures/geometry.png");
  /*
    > example textures:
      - Textures/geometry.png
      - Textures/moon.png
  */
  
  
  /* ---------------------- DON'T EDIT THIS: ---------------------- */
  /* (unless you know what you're doing)                            */
  
  colorMode(HSB, 360, 100, 100, 255);
  
  /*
    if you want more than one magic eye to generate in one execution, create
    more MagicEye objects, set their parameters, and add another call to
    .generate() on your new MagicEye object here (before the exit function).
  */
  
  magicEye.generate();
  
  exit();
}
