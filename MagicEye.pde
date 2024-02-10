// Feel free to edit these defaults (what config parameters' defaults to):
static class DEFAULTS {
  // additional config - not available through .addConfig(...)
  static final float HORI_TILES = 8.5;     // amount of horizontal tiles (autoscale)
  static final float POPOUT = 0.5;         // (0 < value <= 1) amount magic eye "pops out"
  static final long  ALGORITHM_SEED = -1;  // set to -1 for a random seed every algorithmic texture generation
                                           // (set to any other number for an exact seed every algorithmic texture generation)
  
  // basic config defaults (must all be strings)
  static final String DEPTH_MAP_SCALE = "";
  static final String TEXTURE_MODE = "1";
  static final String TEXTURE_FILE_SCALE = "";
  static final String TEXTURE_ALGORITHM = "0";
  static final String TEXTURE_ALGORITHM_RESOLUTION = "";
  static final String ANIM_LOOPS = "1";
  static final String ANIM_TEXTURE_MOVEMENT = "0,0";
  static final String RESOLUTION = "1024x1024";
  static final String SCALE = "2x2";
  static final String EXPORT_IMAGES_PREFIX = "Compiled/export";
  static final String EXPORT_IMAGES_EXTENSION = "png";
  static final String CONSOLE_STATUS_MESSAGES = "true";
}


/*
  
  ----------
  
  DO NOT EDIT THE REST OF THIS FILE!
  It is responsible for generating your magic eye image(s)!
  
  ----------
  
*/


// dependencies
import java.util.*;


// pseudo enums (returns integers)

static class CONFIG {
  static final int DEPTH_MAP_FILE = 0;
  static final int DEPTH_MAP_SCALE = 1;
  
  static final int TEXTURE_MODE = 2;
  static final int TEXTURE_FILE = 3, TEXTURE_FILE_SCALE = 4;
  static final int TEXTURE_ALGORITHM = 5, TEXTURE_ALGORITHM_RESOLUTION = 6;
  
  static final int ANIM_LOOPS = 7;
  static final int ANIM_TEXTURE_MOVEMENT = 8;
  
  static final int RESOLUTION = 9;
  static final int SCALE = 10;
  
  static final int EXPORT_IMAGES_PREFIX = 11;
  static final int EXPORT_IMAGES_EXTENSION = 12;
  
  static final int CONSOLE_STATUS_MESSAGES = 13;
}

static class TEXTURE_MODE {
  static final int FILE = 0;
  static final int ALGORITHM = 1;
}

static class ALGORITHMS {
  static final int TV_STATIC = 0;
  static final int RANDOM = 1;
  static final int PERLIN_NOISE_GRAYSCALE = 2;
  static final int PERLIN_NOISE_COLOR = 3;
}


// MagicEye class

class MagicEye {
  // config parameters
  HashMap<Integer, String> config;
  String depthMapFile; boolean depthMapAutoScale; float[] depthMapScale;
  int textureMode;
  String textureFile; float[] textureFileScale;
  int textureAlgorithm; int[] textureAlgorithmResolution;
  int loopCount; int[] textureMovement;
  int[] resolution; float[] scale;
  String exportImagesPrefix, exportImagesExtension;
  
  // images
  ArrayList<PImage> depthMap;
  ArrayList<PImage> texture;
  ArrayList<PImage> magicEye;
  
  // console messages
  boolean consoleStatusMessages;
  boolean noError = true;
  
  // constructor
  MagicEye() {
    // config
    config = new HashMap<Integer, String>();
    configSetDefaults();
    
    // images
    depthMap = new ArrayList<PImage>();
    magicEye = new ArrayList<PImage>();
  }
  
  
  // ***
  
  
  // main execution
  void generate() {
    int _steps = 1;
    int _stepCount = 4;
    
    // 1
    statusMessage("generate", "loading configurations... (step " + str(_steps) + " of " + str(_stepCount) + ")");
    configSetup();
    
    // 2
    if (noError) {
      statusMessage("generate", "configurations loaded successfully");
      _steps++;
      
      statusMessage("generate", "setting up images... (step " + str(_steps) + " of " + str(_stepCount) + ")");
      imagesSetup();
    }
    
    // 3
    if (noError) {
      statusMessage("generate", "images loaded/generated successfully (step " + str(_steps) + " of " + str(_stepCount) + ")");
      _steps++;
      
      statusMessage("generate", "preparing images for generation... (step " + str(_steps) + " of " + str(_stepCount) + ")");
      imagesPrepare();
    }
    
    // 4
    if (noError) {
      statusMessage("generate", "images prepared successfully (step " + str(_steps) + " of " + str(_stepCount) + ")");
      _steps++;
      
      statusMessage("generate", "generating images... (step " + str(_steps) + " of " + str(_stepCount) + ")");
      __generate();
      __export();
    }
    
    if (noError && consoleStatusMessages) {
      String _exportImagesFilename = exportImagesPrefix;
      if (magicEye.size() > 1) {
        String _hashtags = new String(new char[str(magicEye.size() - 1).length()]).replace('\0', '#');
        _exportImagesFilename += "-frame-" + _hashtags;
      }
      _exportImagesFilename += "." + exportImagesExtension;
      
      statusMessage("generate", "magic eye frame(s) exported to \"" + _exportImagesFilename + "\" successfully (step " + str(_steps) + " of " + str(_stepCount) + ")");
      println("\n---\n");
      statusMessage("generate", "congratulations on generating your magic eye!");
      if (magicEye.size() > 1) {
        String _ffmpegCommand = "ffmpeg -i \"" + exportImagesPrefix + "-frame-" + "%" + nf(str(magicEye.size() - 1).length(), 2) + "d." + exportImagesExtension + "\" \"" + exportImagesPrefix + ".gif\"";
        String _infoMessage = "since multiple frames have been generated, here are several options for how to combine them into a single file:\n";
        _infoMessage += "> ffmpeg [run this command in the root directory of your project (you must have ffmpeg installed)]:\n";
        _infoMessage += "  - " + _ffmpegCommand + "\n";
        _infoMessage += "> use a website [upload all frames to any of these websites and export]:\n";
        _infoMessage += "  - https://ezgif.com/maker\n";
        _infoMessage += "  - https://imgflip.com/gif-maker\n";
        _infoMessage += "  - https://www.freeconvert.com/gif-converter";
        statusMessage("generate", _infoMessage);
      }
      
      String _finalMessage = "\n#########################################";
      _finalMessage +=       "\n# I hope you found this tool useful! :) #";
      _finalMessage +=       "\n#                           ~anastaci1a #";
      _finalMessage +=       "\n#########################################";
      println(_finalMessage);
    }
  }
  
  
  // ***
  
  
  // config
  
  void configSetDefaults() {
    // depth map
    addConfig(CONFIG.DEPTH_MAP_SCALE, DEFAULTS.DEPTH_MAP_SCALE);
    
    // texture
    addConfig(CONFIG.TEXTURE_FILE_SCALE, DEFAULTS.TEXTURE_FILE_SCALE);
    addConfig(CONFIG.TEXTURE_MODE, DEFAULTS.TEXTURE_MODE);
    addConfig(CONFIG.TEXTURE_ALGORITHM, DEFAULTS.TEXTURE_ALGORITHM);
    addConfig(CONFIG.TEXTURE_ALGORITHM_RESOLUTION, DEFAULTS.TEXTURE_ALGORITHM_RESOLUTION);
    
    // animation
    addConfig(CONFIG.ANIM_LOOPS, DEFAULTS.ANIM_LOOPS);
    addConfig(CONFIG.ANIM_TEXTURE_MOVEMENT, DEFAULTS.ANIM_TEXTURE_MOVEMENT);
    
    // resolution
    addConfig(CONFIG.RESOLUTION, DEFAULTS.RESOLUTION);
    addConfig(CONFIG.SCALE, DEFAULTS.SCALE);
    
    // export
    addConfig(CONFIG.EXPORT_IMAGES_PREFIX, DEFAULTS.EXPORT_IMAGES_PREFIX);
    addConfig(CONFIG.EXPORT_IMAGES_EXTENSION, DEFAULTS.EXPORT_IMAGES_EXTENSION);
    
    // console messages
    addConfig(CONFIG.CONSOLE_STATUS_MESSAGES, DEFAULTS.CONSOLE_STATUS_MESSAGES);
  }
  
  void configSetup() {
    // load config map into relevant variables
    
    // depth map
    depthMapFile = getConfigValue(CONFIG.DEPTH_MAP_FILE);
    String _depthMapScale = getConfigValue(CONFIG.DEPTH_MAP_SCALE);
    if (_depthMapScale != "") depthMapScale = parseScale(_depthMapScale);
    
    // texture
    textureMode = getConfigValueInt(CONFIG.TEXTURE_MODE);
    switch(textureMode) {
      case TEXTURE_MODE.FILE:
        textureFile = getConfigValue(CONFIG.TEXTURE_FILE);
        String _textureFileScale = getConfigValue(CONFIG.TEXTURE_FILE_SCALE);
        if (_textureFileScale != "") textureFileScale = parseScale(_textureFileScale);
        break;
      case TEXTURE_MODE.ALGORITHM:
        textureAlgorithm = getConfigValueInt(CONFIG.TEXTURE_ALGORITHM);
        if (getConfigValue(CONFIG.TEXTURE_ALGORITHM_RESOLUTION) != "") {
          textureAlgorithmResolution = parseResolution(getConfigValue(CONFIG.TEXTURE_ALGORITHM_RESOLUTION));;
        }
        break;
    }
    
    // animation
    loopCount = getConfigValueInt(CONFIG.ANIM_LOOPS);
    textureMovement = parseTextureMovement(getConfigValue(CONFIG.ANIM_TEXTURE_MOVEMENT));
    
    // resolution
    String _resolution = getConfigValue(CONFIG.RESOLUTION);
    if (_resolution != "") resolution = parseResolution(_resolution);
    scale = parseScale(getConfigValue(CONFIG.SCALE));
    
    // export
    exportImagesPrefix = getConfigValue(CONFIG.EXPORT_IMAGES_PREFIX);
    exportImagesExtension = getConfigValue(CONFIG.EXPORT_IMAGES_EXTENSION);
    
    // console messages
    consoleStatusMessages = getConfigValueBoolean(CONFIG.CONSOLE_STATUS_MESSAGES);
  }
  
  String getConfigValue(int _key) {
    String _value = config.get(_key);
    if (_value != null) return _value;
    else {
      error("getConfigValue",
            "parameter " + str(_key) + " was not set.",
            "ensure you've initialized all [REQUIRED] config parameters.");
      return null;
    }
  }
  
  int getConfigValueInt(int _key) {
    String _value = getConfigValue(_key);
    try {
      return int(_value);
    } catch (Exception _e) {
      error("getConfigValueInt",
            "parameter " + str(_key) + " was an invalid datatype.",
            "ensure you've set the config parameters correctly.");
      return -1;
    }
  }
  
  boolean getConfigValueBoolean(int _key) {
    String _value = getConfigValue(_key);
    try {
      return boolean(_value);
    } catch (Exception _e) {
      error("getConfigValueBoolean",
            "parameter " + str(_key) + " was an invalid datatype.",
            "ensure you've set the config parameters correctly.");
      return false;
    }
  }
  
  void addConfig(int _key, String _value) {
    if (config.get(_key) != null) config.replace(_key, _value);
    else config.put(_key, _value);
  }
  void addConfig(int _key, int _value) {
    addConfig(_key, str(_value));
  }
  
  
  // ***
  
  
  // images
  
  void imagesSetup() {
    // depth map
    depthMap = imagesLoad(depthMapFile);
    statusMessage("configSetup", str(depthMap.size()) + " frame(s) loaded into depth map");
    
    // animation
    setLoops();
    
    // resolution
    if (getConfigValue(CONFIG.RESOLUTION) == "") setResolution();
    
    // textureAlgorithmResolution
    if (getConfigValue(CONFIG.TEXTURE_ALGORITHM_RESOLUTION) == "") {
      textureAlgorithmResolution = new int[] {
        int(resolution[0] / DEFAULTS.HORI_TILES),
        resolution[1]
      };
    }
    
    // texture
    switch(textureMode) {
      case TEXTURE_MODE.FILE:
        texture = imagesLoad(textureFile);
        if (getConfigValue(CONFIG.TEXTURE_FILE_SCALE) == "") setTextureFileScale();
        statusMessage("configSetup", str(texture.size()) + " frame(s) loaded into texture");
        break;
      case TEXTURE_MODE.ALGORITHM:
        texture = textureGenerator(textureAlgorithm, textureAlgorithmResolution, depthMap.size());
        statusMessage("configSetup", str(texture.size()) + " frame(s) generated into texture");
        break;
    }
  }
  
  void imagesPrepare() {
    //same size check
    imagesAreSameSize(depthMap);
    if (textureMode == TEXTURE_MODE.FILE) {
      imagesAreSameSize(texture);
      texture = scaleImages(texture, textureFileScale);
    }
    
    // auto scale
    if (getConfigValue(CONFIG.DEPTH_MAP_SCALE) == "") {
      setDepthMapScale();
    }
    
    // depth map preparing
    depthMap = makeGrayscale(depthMap);
    depthMap = scaleImages(depthMap, depthMapScale);
  }
  
  PImage imageLoad(String _path) {
    try {
      return loadImage(_path);
    } catch (Exception _e) {
      return null;
    }
  }
  
  PImage imageLoadCertain(String _path) { // know for sure image *should* be there
    PImage _image = imageLoad(_path);
    if (_image != null) return _image;
    else {
      error("imageLoadCertain",
            "image path \"" + _path + "\" does not exist",
            "ensure you have the right filename/directory and include all relevant escape characters");
      return null;
    }
  }
  
  ArrayList<PImage> imagesLoad(String _path) { // if _path has hashtags (#) it checks for as many images that fit the hashtag characters, else returns a single image
    ArrayList<PImage> _images = new ArrayList<PImage>();
    boolean _multipleImages = _path.contains("#");
    if (_multipleImages) {
      String _pathToModify = _path;
      String _path_previous = _pathToModify;
      int _path_hashtags = 0;
      while (_pathToModify.contains("#")) {
        _path_previous = _pathToModify;
        _pathToModify = _pathToModify.replaceFirst("#", "");
        _path_hashtags++;
      }
      _pathToModify = _path_previous; // _path_previous will have had one hashtag (#) left
      for (int _i = 0; _i < pow(10, _path_hashtags); _i++) {
        String _path_actual = _pathToModify.replace("#", nf(_i, _path_hashtags));
        PImage _image = imageLoad(_path_actual);
        if (_image != null) _images.add(_image);
        else if (_i > 0) {
          statusMessageShowAnyway("imagesLoad", "ignore this error (\"...missing or inaccessible...\")");
          break;
        } else {
          break;
        }
      }
    } else {
      PImage _image = imageLoadCertain(_path);
      if (_image != null) _images.add(_image);
    }
    if (_images.size() == 0) error("imagesLoad",
                                   "no images were available under the filename \"" + _path + "\"",
                                   "ensure you have the right filename/directory and include all relevant escape characters");
    return _images;
  }
  
  void imagesAreSameSize(ArrayList<PImage> _images) {
    if (_images.size() > 1) {
      boolean _areSameSize = true;
      PVector _prevResolution = new PVector(_images.get(0).width, _images.get(0).height);
      
      for (int _i = 1; _i < _images.size(); _i++) {
        PVector _currResolution = new PVector(_images.get(_i).width, _images.get(_i).height);
        if (_prevResolution.equals(_currResolution)) {
          _prevResolution.set(_currResolution);
        } else {
          _areSameSize = false;
          break;
        }
      }
      
      if (!_areSameSize) {
        error("imagesAreSameSize",
              "one or more imported frames are not the same resolution",
              "ensure all individual frame sets are the same size");
      }
    }
  }
  
  
  // ***
  
  
  // texture generation algorithms
  
  ArrayList<PImage> textureGenerator(int _algorithm, int[] _resolution, int _frameCount) {
    ArrayList<PImage> _frames = new ArrayList<PImage>();
    for (int _i = 0; _i < _frameCount; _i++) {
      PImage _frame = createImage(_resolution[0], _resolution[1], ARGB);
      _frame.loadPixels();
      
      float _noiseSpread = 5.0;
      if (DEFAULTS.ALGORITHM_SEED == -1) { noiseSeed((long) random(1000000)); randomSeed((long) random(1000000)); }
      else { noiseSeed((long) DEFAULTS.ALGORITHM_SEED); randomSeed(DEFAULTS.ALGORITHM_SEED); }
      color[] _noiseColLerp = new color[] { color(random(360), random(50, 100), random(50, 100)), color(random(360), random(25, 100), random(50, 100)) };
      switch (_algorithm) {
        case ALGORITHMS.TV_STATIC:
          for (int _x = 0; _x < _frame.width; _x++) {
            for (int _y = 0; _y < _frame.height; _y++) {
              color _col = color(0, 0, 100 * round(random(1)));
              _frame.pixels[getPixel(_frame, _x, _y)] = _col;
            }
          }
          break;
        
        case ALGORITHMS.RANDOM:
          for (int _x = 0; _x < _frame.width; _x++) {
            for (int _y = 0; _y < _frame.height; _y++) {
              color _col = color(random(360), random(100), random(100));
              _frame.pixels[getPixel(_frame, _x, _y)] = _col;
            }
          }
          break;
        
        case ALGORITHMS.PERLIN_NOISE_GRAYSCALE:
          for (int _x = 0; _x < _frame.width; _x++) {
            for (int _y = 0; _y < _frame.height; _y++) {
              float _nx = abs(_x - (_frame.width / 2));
              float _ny = abs(_y - (_frame.height / 2));
              float _n = noise(_nx / _noiseSpread, _ny / _noiseSpread);
              color _col = color(0, 0, 100 * _n);
              _frame.pixels[getPixel(_frame, _x, _y)] = _col;
            }
          }
          break;
        
        case ALGORITHMS.PERLIN_NOISE_COLOR:
          for (int _x = 0; _x < _frame.width; _x++) {
            for (int _y = 0; _y < _frame.height; _y++) {
              float _nx = abs(_x - (_frame.width / 2));
              float _ny = abs(_y - (_frame.height / 2));
              float _n = noise(_nx / _noiseSpread, _ny / _noiseSpread);
              color _col = lerpColor(_noiseColLerp[0], _noiseColLerp[1], _n);
              _frame.pixels[getPixel(_frame, _x, _y)] = _col;
            }
          }
          break;
      }
      
      _frame.updatePixels();
      _frames.add(_frame);
    }
    return _frames;
  }
  
  
  // ***
  
  // scaling
  
  
  PImage scaleImage(PImage _image, float[] _scale) {
    if (_scale[0] != 1 && _scale[1] != 1) {
      PImage _imageScaled = createImage(int(_image.width * _scale[0]), int(_image.height * _scale[1]), ARGB);
      
      _image.loadPixels();
      _imageScaled.loadPixels();
      
      for (int _x = 0; _x < _imageScaled.width; _x++) {
        for (int _y = 0; _y < _imageScaled.height; _y++) {
          int _ux = int(_x / _scale[0]);
          int _uy = int(_y / _scale[1]);
          color _col = getImageColor(_image, _ux, _uy);
          _imageScaled.pixels[getPixel(_imageScaled, _x, _y)] = _col;
        }
      }
      
      _imageScaled.updatePixels();
      _image.updatePixels();
      
      return _imageScaled;
    } else return _image;
  }
  
  ArrayList<PImage> scaleImages(ArrayList<PImage> _images, float[] _scale) {
    if (_scale[0] != 1 && _scale[1] != 1) {
      ArrayList<PImage> _imagesScaled = new ArrayList<PImage>();
      
      for (int _i = 0; _i < _images.size(); _i++) {
        PImage _image = scaleImage(_images.get(_i), _scale);
        _imagesScaled.add(_image);
      }
      
      statusMessage("scaleImages", "scaled " + _images.size() + " frame(s) by " + str(_scale[0]) + "x" + str(_scale[1]));
      return _imagesScaled;
    } else return _images;
  }
  
  void setResolution() {
    PImage _depthMap = depthMap.get(0);
    resolution = new int[] {
      round(_depthMap.width * 1.5),
      _depthMap.height
    };
  }
  
  void setDepthMapScale() {
    try {
      PImage _depthMap = depthMap.get(0);
      int[] _resolution = { resolution[0] - texture.get(0).width, resolution[1] };
      
      float _wScale = (float) _resolution[0] / _depthMap.width;
      float _hScale = (float) _resolution[1] / _depthMap.height;
      float _bestScale = min(_wScale, _hScale);
      
      depthMapScale = new float[] { _bestScale, _bestScale };
    } catch (Exception _e) {
      error("setDepthMapScale",
            "no depth map images were available to scale");
    }
  }
  
  void setTextureFileScale() {
    try {
      PImage _texture = texture.get(0);
      float _targetWidth = resolution[0] / DEFAULTS.HORI_TILES;
      float _scale = _targetWidth / _texture.width;
      textureFileScale = new float[] { _scale, _scale };
    } catch (Exception _e) {
      error("setDepthMapScale",
            "no texture images were available to scale");
    }
  }
  
  
  // ***
  
  
  // misc
  
  int[] parseTextureMovement(String _textureMovementString) {
    int[] _textureMovement = parseValuesInt(_textureMovementString);
    boolean _noError = true;
    
    if (_textureMovement.length != 2) _noError = false;
    
    if (_noError) {
      return _textureMovement;
    }
    else {
      error("parseTextureMovement",
            "texture movement values \"" + _textureMovementString + "\" could not be read",
            "ensure that values are in the correct format (\"[width-wide movements],[height-wide movements]\")");
      return null;
    }
  }
  
  int[] parseValuesInt(String _valuesString) {
    float[] _valuesFloatArray = parseValues(_valuesString);
    int[] _values = new int[_valuesFloatArray.length];
    for (int _i = 0; _i < _values.length; _i++) {
      _values[_i] = int(_valuesFloatArray[_i]);
    }
    return _values;
  }
  
  float[] parseValues(String _valuesString) {
    try {
      String[] _valuesStringArray = _valuesString.split(",", 0);
      float[] _values = new float[_valuesStringArray.length];
      for (int _i = 0; _i < _values.length; _i++) {
        _values[_i] = float(_valuesStringArray[_i]);
      }
      return _values;
    } catch (Exception _e) {
      error("parseValues",
            "one or more values could not be read (\"" + _valuesString + "\")",
            "ensure that values are in the correct format (\"[value],...\")");
      return null;
    }
  }
  
  float[] parseScale(String _scaleString) {
    try {
      String[] _scaleArray = _scaleString.split("x");
      float[] _scale = {
        float(_scaleArray[0]),
        float(_scaleArray[1])
      };
      if (_scale[0] > 0 && _scale[1] > 0) return _scale;
      else {
        error("parseScale",
              "scale values could not be read (\"" + _scaleString + "\")",
              "ensure that resolutions are in the correct format (\"[width factor]x[height factor]\")");
        return null;
      }
    } catch (Exception _e) {
      error("parseScale",
            "scale values could not be read (\"" + _scaleString + "\")",
            "ensure that resolutions are in the correct format (\"[width factor]x[height factor]\")");
      return null;
    }
  }
  
  int[] parseResolution(String _resolutionString) {
    try {
      String[] _resolutionArray = _resolutionString.split("x");
      int[] _resolution = {
        int(_resolutionArray[0]),
        int(_resolutionArray[1])
      };
      if (_resolution[0] > 0 && _resolution[1] > 0) return _resolution;
      else {
        error("parseResolution",
              "resolution values could not be read (\"" + _resolutionString + "\")",
              "ensure that resolutions are in the correct format (\"[width]x[height]\")");
        return null;
      }
    } catch (Exception _e) {
      error("parseResolution",
            "resolution values could not be read (\"" + _resolutionString + "\")",
            "ensure that resolutions are in the correct format (\"[width]x[height]\")");
      return null;
    }
  }
  
  int getPixel(PImage _img, int _x, int _y) {
    return (_y * _img.width) + _x;
  }
  
  ArrayList<PImage> makeGrayscale(ArrayList<PImage> _images) {
    ArrayList<PImage> _grayscale_images = _images;
    
    for (int _i = 0; _i < _grayscale_images.size(); _i++) {
      PImage _image = _grayscale_images.get(_i);
      _image.loadPixels();
      for (int _x = 0; _x < _image.width; _x++) {
        for (int _y = 0; _y < _image.height; _y++) {
          color _col = getImageColor(_image, _x, _y);
          color _gray = color(0, 0, brightness(_col) * (alpha(_col) / 255));
          _image.pixels[getPixel(_image, _x, _y)] = _gray;
        }
      }
    }
    
    return _grayscale_images;
  }
  
  float posMod(float _val, float _mod) {
    var _r = _val;
    while (_r < 0) _r += _mod;
    _r %= _mod;
    return _r;
  }
  
  int posModInt(int _val, int _mod) {
    return int(posMod(_val, _mod));
  }
  
  color getImageColor(PImage _img, int _x, int _y) {
    color _col = _img.pixels[getPixel(_img, _x, _y)];
    return _col;
  }
  
  color getTextureColor(PImage _texture, int _frameX, int _frameY) {
    // tiling vars
    int _tileX_topLeft = -(resolution[0] / 2);
    int _tileY_topLeft = (_texture.height / 2) - (resolution[1] / 2);
    int _tileX = posModInt(_tileX_topLeft + _frameX, _texture.width);
    int _tileY = posModInt(_tileY_topLeft + _frameY, _texture.height);
    color _col = getImageColor(_texture, _tileX, _tileY);
    return _col;
  }
  
  float getDepthMapValue(PImage _depthMap, int _frameX, int _frameY) {
    //       [center depth map--------------------------]   [frame]   [texture width allocation-]
    int _x = (_depthMap.width / 2)  - (resolution[0] / 2) + _frameX - (texture.get(0).width / 2);
    int _y = (_depthMap.height / 2) - (resolution[1] / 2) + _frameY;
    
    if ((0 <= _x && _x < _depthMap.width) && (0 <= _y && _y < _depthMap.height)) {
      return brightness(_depthMap.pixels[getPixel(_depthMap, _x, _y)]);
    } else return 0;
  }
  
  void setLoops() {
    if (loopCount < 1) loopCount = 1;
    try {
      ArrayList<PImage> _depthMap = new ArrayList<PImage>();
      for (int _i = 0; _i < loopCount * depthMap.size(); _i++) {
        int _j = _i % depthMap.size();
        _depthMap.add(depthMap.get(_j));
      }
      depthMap = _depthMap;
    } catch (Exception _e) {
      error("setLoops",
            "attempted to create " + str(loopCount) + " loops (" + str(loopCount * depthMap.size()) + " frames), but ran out of memory",
            "you can allocate more memory to processing in File>Preferences");
    }
  }
  
  
  // ***
  
  
  // actually generate
  
  void __generate() {
    try {
      ArrayList<PImage> _magicEye = new ArrayList<PImage>();
      
      float[] _textureMovementPerFrame = new float[] {
        (float) (textureMovement[0] * texture.get(0).width)  / depthMap.size(),
        (float) (textureMovement[1] * texture.get(0).height) / depthMap.size()
      };
      float[] _textureOffset = new float[] { 0, 0 };
      
      for (int _i = 0; _i < depthMap.size(); _i++) {
        float _maxDisplacement = DEFAULTS.POPOUT * texture.get(0).width;
        
        PImage _frame = createImage(resolution[0], resolution[1], ARGB);
        PImage _texture = texture.get(_i % texture.size());
        PImage _depthMap = depthMap.get(_i);
        
        _frame.loadPixels();
        _texture.loadPixels();
        _depthMap.loadPixels();
        
        for (int _y = 0; _y < _frame.height; _y++) {
          // baseline texture for this row before displacement
          for (int _x = 0; _x < _frame.width; _x++) {
            int _offX = round(_x - _textureOffset[0]);
            int _offY = round(_y - _textureOffset[1]);
            color _col = getTextureColor(_texture, _offX, _offY);
            _frame.pixels[getPixel(_frame, _x, _y)] = _col;
          }
          
          // displacement modifications
          
          // buffer to keep track of largest displacement written at given x position
          int[] _largestDisplacementBuffer = new int[_frame.width];
          Arrays.fill(_largestDisplacementBuffer, Integer.MAX_VALUE); // initialize with maximum values
          
          // iterate through x (start from second column of tiled texture, first must remain unmodified)
          for (int _x = _texture.width; _x < _frame.width; _x++) {
            float _depthMapValue = getDepthMapValue(_depthMap, _x,_y);
            int _displacement = round(map(_depthMapValue, 0, 100 /* HSB*/, 0, _maxDisplacement));
            int _displacedX = _x - _displacement;
            
            if (_displacedX < _frame.width && _displacement < _largestDisplacementBuffer[_displacedX]) {
              color _col = getImageColor(_frame, _x - _texture.width, _y); // find color from left (potentially modified) column
              _frame.pixels[getPixel(_frame, _displacedX, _y)] = _col;
              _largestDisplacementBuffer[_displacedX] = _displacement;
            }
          }
        }
        
        _depthMap.updatePixels();
        _texture.updatePixels();
        _frame.updatePixels();
        _magicEye.add(_frame);
        
        _textureOffset[0] += _textureMovementPerFrame[0]; _textureOffset[1] += _textureMovementPerFrame[1];
        
        statusMessage("__generate",
                      "frame " + str(_i + 1) + " of " + str(depthMap.size()) + " generated");
      }
      
      magicEye = scaleImages(_magicEye, scale);
    } catch (Exception _e) {
      error("__generate",
            "error when generating",
            "it is likely that the process ran out of memory when generating",
            "you can allocate more memory to processing in File>Preferences");
    }
  }
  
  void __export() {
    statusMessage("__export",
                  "exporting " + str(magicEye.size()) + " image(s)...");
    if (magicEye.size() > 1) {
      int _digits = str(magicEye.size() - 1).length();
      for (int _i = 0; _i < magicEye.size(); _i++) {
        String _filename = exportImagesPrefix + "-frame-" + nf(_i, _digits) + "." + exportImagesExtension;
        magicEye.get(_i).save(_filename);
      }
    } else if (magicEye.size() == 1) {
      String _filename = exportImagesPrefix + "." + exportImagesExtension;
      magicEye.get(0).save(_filename);
    } else {
      error("__export",
            "an unknown error occurred",
            "no frame(s) available for export");
    }
  }
  
  
  // ***
  
  
  // console messages
  
  void statusMessage(String _method, String _message) {
    if (consoleStatusMessages) println("[MagicEye." + _method + "] " + _message);
  }
  void statusMessageShowAnyway(String _method, String _message) {
    println("[MagicEye." + _method + "] " + _message);
  }
  
  void error(String... _errorMessage) {
    noError = false;
    
    String[] _errorTitle = {
      "\n---------------- MagicEye Class Error [DO NOT IGNORE]: ----------------",
      ""
    };
    _errorMessage[0] = "[MagicEye." + _errorMessage[0] + "]";
    String[] _error = new String[_errorMessage.length + _errorTitle.length];
    System.arraycopy(_errorTitle, 0, _error, 0, _errorTitle.length);
    System.arraycopy(_errorMessage, 0, _error, _errorTitle.length, _errorMessage.length);
    _error[_error.length - 1] += "\n\n------------------------------ Error End ------------------------------\n";
    systemError(_error);
  }
  
  void systemError(String[] _err) {
    for (int _i = 0; _i < _err.length; _i++) {
      System.err.println(_err[_i]);
    }
    exit();
  }
}
