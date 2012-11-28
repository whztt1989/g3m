//
//  ViewController.m
//  Glob3iOSDemo
//
//  Created by José Miguel S N on 31/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#include "LayerSet.hpp"
#include "WMSLayer.hpp"
#include "Factory_iOS.hpp"
#include "EllipsoidalTileTessellator.hpp"
#include "TileRenderer.hpp"
#include "TilesRenderParameters.hpp"
#include "MarksRenderer.hpp"
#include "CameraConstraints.hpp"
//#include "GLErrorRenderer.hpp"
//#include "LatLonMeshRenderer.hpp"
#include "LevelTileCondition.hpp"
#include "BingLayer.hpp"
#include "TrailsRenderer.hpp"
#include "PeriodicalTask.hpp"
#include "ShapesRenderer.hpp"
//#include "QuadShape.hpp"
#include "CircleShape.hpp"
#include "BoxShape.hpp"
//#include "CompositeShape.hpp"
#include "SceneJSShapesParser.hpp"
#include "G3MWidget.hpp"

#include "G3MBuilder_iOS.hpp"
#include "BusyMeshRenderer.hpp"
#include "CompositeRenderer.hpp"
#include "TileRendererBuilder.hpp"
#include "CameraRenderer.hpp"
#include "CameraSingleDragHandler.hpp"
#include "CameraDoubleDragHandler.hpp"
#include "CameraRotationHandler.hpp"
#include "CameraDoubleTapHandler.hpp"
#include "NativeGL2_iOS.hpp"
#include "SQLiteStorage_iOS.hpp"
#include "CachedDownloader.hpp"
#include "Downloader_iOS.hpp"
#include "ThreadUtils_iOS.hpp"
#include "Planet.hpp"

@implementation ViewController

@synthesize G3MWidget;

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];

    // initialize a customized widget without using a builder
//    [[self G3MWidget] initSingletons];
//    [self initWithoutBuilder];
    
    // initizalize a default widget by using a builder
//    [self initDefaultWithBuilder];
    
    // initialize a customized widget by using a buider
    [self initCustomizedWithBuilder];

  [[self G3MWidget] startAnimation];
}

- (void) initWithoutBuilder
{
    INativeGL* nativeGL = new NativeGL2_iOS();
    
    IStorage* storage = new SQLiteStorage_iOS("g3m.cache");
    
    const bool saveInBackground = true;
    IDownloader* downloader = new CachedDownloader(new Downloader_iOS(8),
                                                   storage,
                                                   saveInBackground);
    
    IThreadUtils* threadUtils = new ThreadUtils_iOS();
    
    const Planet* planet = Planet::createEarth();
    
    CompositeRenderer* mainRenderer = new CompositeRenderer();
    
    TileRenderer* tileRenderer = [self createTileRenderer: [self createTileRenderParameters]
                                                 layerSet: [self createLayerSet]];
    mainRenderer->addRenderer(tileRenderer);
    
    MarksRenderer* marksRenderer = [self createMarksRenderer];
    mainRenderer->addRenderer(marksRenderer);
    
    ShapesRenderer* shapesRenderer = [self createShapesRenderer];
    mainRenderer->addRenderer(shapesRenderer);
    
    Renderer* busyRenderer = new BusyMeshRenderer();
    
    std::vector<PeriodicalTask*> periodicalTasks;
   
    [[self G3MWidget] initWidget: nativeGL
                         storage: storage
                      downloader: downloader
                     threadUtils: threadUtils
                          planet: planet
               cameraConstraints: [self createCameraConstraints]
                  cameraRenderer: [self createCameraRenderer]
                    mainRenderer: mainRenderer
                    busyRenderer: busyRenderer
                 backgroundColor: Color::fromRGBA((float)0, (float)0.1, (float)0.2, (float)1)
                          logFPS: true
         logDownloaderStatistics: false
              initializationTask: [self createSampleInitializationTask: shapesRenderer]
    autoDeleteInitializationTask: true
                 periodicalTasks: periodicalTasks
                        userData: NULL];
    
}

- (void) initDefaultWithBuilder
{
    G3MBuilder_iOS* builder = new G3MBuilder_iOS([self G3MWidget]);

    // initialization
    builder->initializeWidget();
}

- (void) initCustomizedWithBuilder
{
    G3MBuilder_iOS* builder = new G3MBuilder_iOS([self G3MWidget]);

    SimpleCameraConstrainer* scc = new SimpleCameraConstrainer();
    builder->addCameraConstraint(scc);
    
    builder->setCameraRenderer([self createCameraRenderer]);
    
    builder->setPlanet(Planet::createEarth());
    
    Color* bgColor = Color::newFromRGBA((float)0, (float)0.1, (float)0.2, (float)1);
    builder->setBackgroundColor(bgColor);
    
    LayerSet* layerSet = [self createLayerSet];
    builder->setLayerSet(layerSet);
    
    TilesRenderParameters* parameters = [self createTileRenderParameters];
    builder->setTileRendererParameters(parameters);
    
    TileRenderer* tileRenderer = [self createTileRenderer: parameters
                                                 layerSet: layerSet];
    builder->setTileRenderer(tileRenderer);
    
    Renderer* busyRenderer = new BusyMeshRenderer();
    builder->setBusyRenderer(busyRenderer);
    
//    DummyRenderer* dum = new DummyRenderer();
//    builder->addRenderer(dum);
//    SimplePlanetRenderer* spr = new SimplePlanetRenderer("world.jpg");
//    builder->addRenderer(spr);
    
    MarksRenderer* marksRenderer = [self createMarksRenderer];
    builder->addRenderer(marksRenderer);
    
    ShapesRenderer* shapesRenderer = [self createShapesRenderer];
    builder->addRenderer(shapesRenderer);
    
    UserData* userData = NULL;
    builder->setUserData(userData);

    GTask* initializationTask = [self createSampleInitializationTask:(ShapesRenderer *) shapesRenderer];
    builder->setInitializationTask(initializationTask);
    
    const bool autoDeleteInitializationTask = true;
    builder->setAutoDeleteInitializationTask(autoDeleteInitializationTask);
    
//    PeriodicalTask* periodicalTask = [self createSamplePeriodicalTask:(builder)];
//    builder->addPeriodicalTask(periodicalTask);
    
    const bool logFPS = true;
    builder->setLogFPS(logFPS);
    
    const bool logDownloaderStatistics = false;
    builder->setLogDownloaderStatistics(logDownloaderStatistics);
    
    // initialization
    builder->initializeWidget();
}

- (CameraRenderer*) createCameraRenderer
{
    CameraRenderer* cameraRenderer = new CameraRenderer();
    const bool useInertia = true;
    cameraRenderer->addHandler(new CameraSingleDragHandler(useInertia));
    const bool processRotation = true;
    const bool processZoom = true;
    cameraRenderer->addHandler(new CameraDoubleDragHandler(processRotation,
                                                           processZoom));
    cameraRenderer->addHandler(new CameraRotationHandler());
    cameraRenderer->addHandler(new CameraDoubleTapHandler());
    
    return cameraRenderer;
}

- (std::vector <ICameraConstrainer*>) createCameraConstraints
{
    std::vector <ICameraConstrainer*> cameraConstraints;
    SimpleCameraConstrainer* scc = new SimpleCameraConstrainer();
    cameraConstraints.push_back(scc);
    
    return cameraConstraints;
}

- (LayerSet*) createLayerSet
{
    LayerSet* layerSet = new LayerSet();
    
    if (false) {
        WMSLayer* blueMarble = new WMSLayer("bmng200405",
                                            URL("http://www.nasa.network.com/wms?", false),
                                            WMS_1_1_0,
                                            Sector::fullSphere(),
                                            "image/jpeg",
                                            "EPSG:4326",
                                            "",
                                            false,
                                            new LevelTileCondition(0, 6));
        layerSet->addLayer(blueMarble);
        
        WMSLayer* i3Landsat = new WMSLayer("esat",
                                           URL("http://data.worldwind.arc.nasa.gov/wms?", false),
                                           WMS_1_1_0,
                                           Sector::fullSphere(),
                                           "image/jpeg",
                                           "EPSG:4326",
                                           "",
                                           false,
                                           new LevelTileCondition(7, 100));
        layerSet->addLayer(i3Landsat);
    }
    
    //  WMSLayer* political = new WMSLayer("topp:cia",
    //                                     URL("http://worldwind22.arc.nasa.gov/geoserver/wms?"),
    //                                     WMS_1_1_0,
    //                                     Sector::fullSphere(),
    //                                     "image/png",
    //                                     "EPSG:4326",
    //                                     "countryboundaries",
    //                                     true,
    //                                     NULL);
    //  layerSet->addLayer(political);
    
    bool useBing = true;
    if (useBing) {
        WMSLayer* bing = new WMSLayer("ve",
                                      URL("http://worldwind27.arc.nasa.gov/wms/virtualearth?", false),
                                      WMS_1_1_0,
                                      Sector::fullSphere(),
                                      "image/jpeg",
                                      "EPSG:4326",
                                      "",
                                      false,
                                      NULL);
        layerSet->addLayer(bing);
    }
    
    bool useOSM = false;
    if (useOSM) {
        //    WMSLayer *osm = new WMSLayer("osm",
        //                                 URL("http://wms.latlon.org/"),
        //                                 WMS_1_1_0,
        //                                 Sector::fromDegrees(-85.05, -180.0, 85.5, 180.0),
        //                                 "image/jpeg",
        //                                 "EPSG:4326",
        //                                 "",
        //                                 false,
        //                                 NULL);
        //    layerSet->addLayer(osm);
        WMSLayer *osm = new WMSLayer("osm_auto:all",
                                     URL("http://129.206.228.72/cached/osm", false),
                                     WMS_1_1_0,
                                     // Sector::fromDegrees(-85.05, -180.0, 85.05, 180.0),
                                     Sector::fullSphere(),
                                     "image/jpeg",
                                     "EPSG:4326",
                                     "",
                                     false,
                                     NULL);
        layerSet->addLayer(osm);
        
    }
    
    const bool usePnoaLayer = false;
    if (usePnoaLayer) {
        WMSLayer *pnoa = new WMSLayer("PNOA",
                                      URL("http://www.idee.es/wms/PNOA/PNOA", false),
                                      WMS_1_1_0,
                                      Sector::fromDegrees(21, -18, 45, 6),
                                      "image/png",
                                      "EPSG:4326",
                                      "",
                                      true,
                                      NULL);
        layerSet->addLayer(pnoa);
    }
    
    const bool testURLescape = false;
    if (testURLescape) {
        WMSLayer *ayto = new WMSLayer(URL::escape("Ejes de via"),
                                      URL("http://sig.caceres.es/wms_callejero.mapdef?", false),
                                      WMS_1_1_0,
                                      Sector::fullSphere(),
                                      "image/png",
                                      "EPSG:4326",
                                      "",
                                      true,
                                      NULL);
        layerSet->addLayer(ayto);
        
    }
    
    //  WMSLayer *vias = new WMSLayer("VIAS",
    //                                "http://idecan2.grafcan.es/ServicioWMS/Callejero",
    //                                WMS_1_1_0,
    //                                "image/gif",
    //                                Sector::fromDegrees(22.5,-22.5, 33.75, -11.25),
    //                                "EPSG:4326",
    //                                "",
    //                                true,
    //                                Angle::nan(),
    //                                Angle::nan());
    //  layerSet->addLayer(vias);
    
    //  WMSLayer *osm = new WMSLayer("bing",
    //                               "bing",
    //                               "http://wms.latlon.org/",
    //                               WMS_1_1_0,
    //                               "image/jpeg",
    //                               Sector::fromDegrees(-85.05, -180.0, 85.5, 180.0),
    //                               "EPSG:4326",
    //                               "",
    //                               false,
    //                               Angle::nan(),
    //                               Angle::nan());
    //  layerSet->addLayer(osm);
    
    return layerSet;
}

- (TilesRenderParameters*) createTileRenderParameters
{
    const bool renderDebug = false;
    const bool useTilesSplitBudget = true;
    const bool forceTopLevelTilesRenderOnStart = true;
    const bool incrementalTileQuality = true;
    TilesRenderParameters* parameters = TilesRenderParameters::createDefault(renderDebug,
                                                                             useTilesSplitBudget,
                                                                             forceTopLevelTilesRenderOnStart,
                                                                             incrementalTileQuality);
    return parameters;
}

- (TileRenderer*) createTileRenderer: (TilesRenderParameters*) parameters
                            layerSet: (LayerSet*) layerSet
{
    TileRendererBuilder* trBuilder = new TileRendererBuilder();
    trBuilder->setShowStatistics(false);
    trBuilder->setTileRendererParameters(parameters);
    trBuilder->setLayerSet(layerSet);
    
    TileRenderer* tileRenderer = trBuilder->create();

    return tileRenderer;
}

- (MarksRenderer*) createMarksRenderer
{
    
    class TestMarkTouchListener : public MarkTouchListener {
    public:
        bool touchedMark(Mark* mark) {
            NSString* message = [NSString stringWithFormat: @"Touched on mark \"%s\"", mark->getName().c_str()];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Glob3 Demo"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            return true;
        }
    };
    
    
    // marks renderer
    const bool readyWhenMarksReady = false;
    MarksRenderer* marksRenderer = new MarksRenderer(readyWhenMarksReady);
    
    marksRenderer->setMarkTouchListener(new TestMarkTouchListener(), true);
    
    Mark* m1 = new Mark("Fuerteventura",
                        URL("http://glob3m.glob3mobile.com/icons/markers/g3m.png", false),
                        Geodetic3D(Angle::fromDegrees(28.05), Angle::fromDegrees(-14.36), 0));
    marksRenderer->addMark(m1);
    
    
    Mark* m2 = new Mark("Las Palmas",
                        URL("file:///plane.png", false),
                        Geodetic3D(Angle::fromDegrees(28.05), Angle::fromDegrees(-15.36), 0));
    marksRenderer->addMark(m2);
    
    if (false) {
        for (int i = 0; i < 2000; i++) {
            const Angle latitude = Angle::fromDegrees( (int) (arc4random() % 180) - 90 );
            const Angle longitude = Angle::fromDegrees( (int) (arc4random() % 360) - 180 );
            
            marksRenderer->addMark(new Mark("Random",
                                            URL("http://glob3m.glob3mobile.com/icons/markers/g3m.png", false),
                                            Geodetic3D(latitude, longitude, 0)));
        }
    }
    
    return marksRenderer;
    
}

- (ShapesRenderer*) createShapesRenderer
{
    ShapesRenderer* shapesRenderer = new ShapesRenderer();
    
    //  std::string textureFileName = "g3m-marker.png";
    //  IImage* textureImage = IFactory::instance()->createImageFromFileName(textureFileName);
    //
    //  Shape* shape = new QuadShape(Geodetic3D(Angle::fromDegrees(37.78333333),
    //                                          Angle::fromDegrees(-122.41666666666667),
    //                                          8000),
    //                               textureImage, true, textureFileName,
    //                               50000, 50000);
    
    Shape* circle = new CircleShape(new Geodetic3D(Angle::fromDegrees(37.78333333),
                                                   Angle::fromDegrees(-122.76666666666667),
                                                   8000),
                                    50000,
                                    Color::newFromRGBA(1, 1, 0, 0.5));
    //  circle->setHeading( Angle::fromDegrees(45) );
    //  circle->setPitch( Angle::fromDegrees(45) );
    //  circle->setScale(2.0, 0.5, 1);
    shapesRenderer->addShape(circle);
    
    Shape* box = new BoxShape(new Geodetic3D(Angle::fromDegrees(37.78333333),
                                             Angle::fromDegrees(-122.41666666666667),
                                             45000),
                              Vector3D(20000, 30000, 50000),
                              2,
                              Color::newFromRGBA(1,    0, 0, 0.5),
                              Color::newFromRGBA(0.75, 0, 0, 0.75));
    shapesRenderer->addShape(box);
    
    return shapesRenderer;
}

- (GTask*) createSampleInitializationTask : (ShapesRenderer*) shapesRenderer
{
    class SampleInitializationTask : public GTask {
    private:
        G3MWidget_iOS*  _iosWidget;
        ShapesRenderer* _shapesRenderer;
        
    public:
        SampleInitializationTask(G3MWidget_iOS* iosWidget,
                                 ShapesRenderer* shapesRenderer) :
        _iosWidget(iosWidget),
        _shapesRenderer(shapesRenderer)
        {
            
        }
        
        void run(const G3MContext* context) {
            printf("Running initialization Task\n");
            
            [_iosWidget widget]->setAnimatedCameraPosition(Geodetic3D(Angle::fromDegreesMinutes(37, 47),
                                                                      Angle::fromDegreesMinutes(-122, 25),
                                                                      1000000),
                                                           TimeInterval::fromSeconds(5));
            /*
             NSString *filePath = [[NSBundle mainBundle] pathForResource: @"seymour-plane"
             ofType: @"json"];
             if (filePath) {
                 NSString *nsString = [NSString stringWithContentsOfFile: filePath
                 encoding: NSUTF8StringEncoding
                 error: nil];
                 if (nsString) {
                     std::string str = [nsString UTF8String];
                     Shape* plane = SceneJSShapesParser::parse(str);
                     
                     plane->setPosition( new Geodetic3D(Angle::fromDegrees(37.78333333),
                     Angle::fromDegrees(-122.41666666666667),
                     100) );
                     plane->setScale(100, 100, 100);
                     plane->setPitch(Angle::fromDegrees(-90));
                     _shapesRenderer->addShape(plane);
                 }
             }
             */
        }
    };
    
    GTask* initializationTask = new SampleInitializationTask([self G3MWidget], shapesRenderer);
    
    return initializationTask;
}

- (PeriodicalTask*) createSamplePeriodicalTask: (G3MBuilder_iOS*) builder
{
    TrailsRenderer* trailsRenderer = new TrailsRenderer();
    
    Trail* trail = new Trail(50, Color::fromRGBA(1, 1, 1, 1), 2);

    Geodetic3D position(Angle::fromDegrees(37.78333333),
                  Angle::fromDegrees(-122.41666666666667),
                  7500);
    trail->addPosition(position);
    trailsRenderer->addTrail(trail);
    builder->addRenderer(trailsRenderer);

//    if (false) {
//        LatLonMeshRenderer *renderer = new LatLonMeshRenderer();
//        builder->addRenderer(renderer);
//    }
 
    
    //  renderers.push_back(new GLErrorRenderer());

    class TestTrailTask : public GTask {
    private:
        Trail* _trail;

        double _lastLatitudeDegrees;
        double _lastLongitudeDegrees;
        double _lastHeight;

    public:
        TestTrailTask(Trail* trail,
                      Geodetic3D lastPosition) :
            _trail(trail),
            _lastLatitudeDegrees(lastPosition.latitude()._degrees),
            _lastLongitudeDegrees(lastPosition.longitude()._degrees),
            _lastHeight(lastPosition.height())
        {

        }

        void run(const G3MContext* context) {
          _lastLatitudeDegrees += 0.025;
          _lastLongitudeDegrees += 0.025;
          _lastHeight += 200;

          _trail->addPosition(Geodetic3D(Angle::fromDegrees(_lastLatitudeDegrees),
                                         Angle::fromDegrees(_lastLongitudeDegrees),
                                         _lastHeight));
        }
    };

    PeriodicalTask* periodicalTask = new PeriodicalTask(TimeInterval::fromSeconds(1),
                                                        new TestTrailTask(trail, position));
    return periodicalTask;
}
             

/*
- (void) initWidgetDemo
{
  LayerSet* layerSet = new LayerSet();

  if (false) {
    WMSLayer* blueMarble = new WMSLayer("bmng200405",
                                        URL("http://www.nasa.network.com/wms?", false),
                                        WMS_1_1_0,
                                        Sector::fullSphere(),
                                        "image/jpeg",
                                        "EPSG:4326",
                                        "",
                                        false,
                                        new LevelTileCondition(0, 6));
    layerSet->addLayer(blueMarble);

    WMSLayer* i3Landsat = new WMSLayer("esat",
                                       URL("http://data.worldwind.arc.nasa.gov/wms?", false),
                                       WMS_1_1_0,
                                       Sector::fullSphere(),
                                       "image/jpeg",
                                       "EPSG:4326",
                                       "",
                                       false,
                                       new LevelTileCondition(7, 100));
    layerSet->addLayer(i3Landsat);
  }

  //  WMSLayer* political = new WMSLayer("topp:cia",
  //                                     URL("http://worldwind22.arc.nasa.gov/geoserver/wms?"),
  //                                     WMS_1_1_0,
  //                                     Sector::fullSphere(),
  //                                     "image/png",
  //                                     "EPSG:4326",
  //                                     "countryboundaries",
  //                                     true,
  //                                     NULL);
  //  layerSet->addLayer(political);

  bool useBing = true;
  if (useBing) {
    WMSLayer* bing = new WMSLayer("ve",
                                  URL("http://worldwind27.arc.nasa.gov/wms/virtualearth?", false),
                                  WMS_1_1_0,
                                  Sector::fullSphere(),
                                  "image/jpeg",
                                  "EPSG:4326",
                                  "",
                                  false,
                                  NULL);
    layerSet->addLayer(bing);
  }

  bool useOSM = false;
  if (useOSM) {
    //    WMSLayer *osm = new WMSLayer("osm",
    //                                 URL("http://wms.latlon.org/"),
    //                                 WMS_1_1_0,
    //                                 Sector::fromDegrees(-85.05, -180.0, 85.5, 180.0),
    //                                 "image/jpeg",
    //                                 "EPSG:4326",
    //                                 "",
    //                                 false,
    //                                 NULL);
    //    layerSet->addLayer(osm);
    WMSLayer *osm = new WMSLayer("osm_auto:all",
                                 URL("http://129.206.228.72/cached/osm", false),
                                 WMS_1_1_0,
                                 // Sector::fromDegrees(-85.05, -180.0, 85.05, 180.0),
                                 Sector::fullSphere(),
                                 "image/jpeg",
                                 "EPSG:4326",
                                 "",
                                 false,
                                 NULL);
    layerSet->addLayer(osm);

  }

  const bool usePnoaLayer = false;
  if (usePnoaLayer) {
    WMSLayer *pnoa = new WMSLayer("PNOA",
                                  URL("http://www.idee.es/wms/PNOA/PNOA", false),
                                  WMS_1_1_0,
                                  Sector::fromDegrees(21, -18, 45, 6),
                                  "image/png",
                                  "EPSG:4326",
                                  "",
                                  true,
                                  NULL);
    layerSet->addLayer(pnoa);
  }

  const bool testURLescape = false;
  if (testURLescape) {
    WMSLayer *ayto = new WMSLayer(URL::escape("Ejes de via"),
                                  URL("http://sig.caceres.es/wms_callejero.mapdef?", false),
                                  WMS_1_1_0,
                                  Sector::fullSphere(),
                                  "image/png",
                                  "EPSG:4326",
                                  "",
                                  true,
                                  NULL);
    layerSet->addLayer(ayto);

  }

  //  WMSLayer *vias = new WMSLayer("VIAS",
  //                                "http://idecan2.grafcan.es/ServicioWMS/Callejero",
  //                                WMS_1_1_0,
  //                                "image/gif",
  //                                Sector::fromDegrees(22.5,-22.5, 33.75, -11.25),
  //                                "EPSG:4326",
  //                                "",
  //                                true,
  //                                Angle::nan(),
  //                                Angle::nan());
  //  layerSet->addLayer(vias);

  //  WMSLayer *osm = new WMSLayer("bing",
  //                               "bing",
  //                               "http://wms.latlon.org/",
  //                               WMS_1_1_0,
  //                               "image/jpeg",
  //                               Sector::fromDegrees(-85.05, -180.0, 85.5, 180.0),
  //                               "EPSG:4326",
  //                               "",
  //                               false,
  //                               Angle::nan(),
  //                               Angle::nan());
  //  layerSet->addLayer(osm);

  std::vector<Renderer*> renderers;

  //  if (false) {
  //    // dummy renderer with a simple box
  //    DummyRenderer* dum = new DummyRenderer();
  //    comp->addRenderer(dum);
  //  }

  //  if (false) {
  //    // simple planet renderer, with a basic world image
  //    SimplePlanetRenderer* spr = new SimplePlanetRenderer("world.jpg");
  //    comp->addRenderer(spr);
  //  }


  if (true) {

    class TestMarkTouchListener : public MarkTouchListener {
    public:
      bool touchedMark(Mark* mark) {
        NSString* message = [NSString stringWithFormat: @"Touched on mark \"%s\"", mark->getName().c_str()];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Glob3 Demo"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

        return true;
      }
    };


    // marks renderer
    const bool readyWhenMarksReady = false;
    MarksRenderer* marksRenderer = new MarksRenderer(readyWhenMarksReady);
    renderers.push_back(marksRenderer);

    marksRenderer->setMarkTouchListener(new TestMarkTouchListener(), true);

    Mark* m1 = new Mark("Fuerteventura",
                        URL("http://glob3m.glob3mobile.com/icons/markers/g3m.png", false),
                        Geodetic3D(Angle::fromDegrees(28.05), Angle::fromDegrees(-14.36), 0));
    marksRenderer->addMark(m1);


    Mark* m2 = new Mark("Las Palmas",
                        URL("file:///plane.png", false),
                        Geodetic3D(Angle::fromDegrees(28.05), Angle::fromDegrees(-15.36), 0));
    marksRenderer->addMark(m2);

    if (false) {
      for (int i = 0; i < 2000; i++) {
        const Angle latitude = Angle::fromDegrees( (int) (arc4random() % 180) - 90 );
        const Angle longitude = Angle::fromDegrees( (int) (arc4random() % 360) - 180 );

        marksRenderer->addMark(new Mark("Random",
                                        URL("http://glob3m.glob3mobile.com/icons/markers/g3m.png", false),
                                        Geodetic3D(latitude, longitude, 0)));
      }
    }
  }

  //  if (true) {
  ShapesRenderer* shapesRenderer = new ShapesRenderer();

  //  std::string textureFileName = "g3m-marker.png";
  //  IImage* textureImage = IFactory::instance()->createImageFromFileName(textureFileName);
  //
  //  Shape* shape = new QuadShape(Geodetic3D(Angle::fromDegrees(37.78333333),
  //                                          Angle::fromDegrees(-122.41666666666667),
  //                                          8000),
  //                               textureImage, true, textureFileName,
  //                               50000, 50000);

  Shape* circle = new CircleShape(new Geodetic3D(Angle::fromDegrees(37.78333333),
                                                 Angle::fromDegrees(-122.76666666666667),
                                                 8000),
                                  50000,
                                  Color::newFromRGBA(1, 1, 0, 0.5));
  shapesRenderer->addShape(circle);

  Shape* box = new BoxShape(new Geodetic3D(Angle::fromDegrees(37.78333333),
                                           Angle::fromDegrees(-122.41666666666667),
                                           45000),
                            Vector3D(20000, 30000, 50000),
                            2,
                            Color::newFromRGBA(1,    0, 0, 0.5),
                            Color::newFromRGBA(0.75, 0, 0, 0.75));

  box->setAnimatedScale(1, 1, 20);

  shapesRenderer->addShape(box);


  renderers.push_back(shapesRenderer);
  //  }


  //  TrailsRenderer* trailsRenderer = new TrailsRenderer();
  //  renderers.push_back(trailsRenderer);
  //
  //  Trail* trail = new Trail(50, Color::fromRGBA(1, 1, 1, 1), 2);
  //
  //  Geodetic3D position(Angle::fromDegrees(37.78333333),
  //                      Angle::fromDegrees(-122.41666666666667),
  //                      7500);
  //  trail->addPosition(position);
  //  trailsRenderer->addTrail(trail);


  //  if (false) {
  //    LatLonMeshRenderer *renderer = new LatLonMeshRenderer();
  //    renderers.push_back(renderer);
  //  }


  //  renderers.push_back(new GLErrorRenderer());

  //  class TestTrailTask : public GTask {
  //  private:
  //    Trail* _trail;
  //
  //    double _lastLatitudeDegrees;
  //    double _lastLongitudeDegrees;
  //    double _lastHeight;
  //
  //  public:
  //    TestTrailTask(Trail* trail,
  //                  Geodetic3D lastPosition) :
  //    _trail(trail),
  //    _lastLatitudeDegrees(lastPosition.latitude()._degrees),
  //    _lastLongitudeDegrees(lastPosition.longitude()._degrees),
  //    _lastHeight(lastPosition.height())
  //    {
  //
  //    }
  //
  //    void run() {
  //      _lastLatitudeDegrees += 0.025;
  //      _lastLongitudeDegrees += 0.025;
  //      _lastHeight += 200;
  //
  //      _trail->addPosition(Geodetic3D(Angle::fromDegrees(_lastLatitudeDegrees),
  //                                     Angle::fromDegrees(_lastLongitudeDegrees),
  //                                     _lastHeight));
  //    }
  //  };

  std::vector<PeriodicalTask*> periodicalTasks;
  //  periodicalTasks.push_back( new PeriodicalTask(TimeInterval::fromSeconds(1),
  //                                                new TestTrailTask(trail, position)));


  std::vector <ICameraConstrainer*> cameraConstraints;
  SimpleCameraConstrainer* scc = new SimpleCameraConstrainer();
  cameraConstraints.push_back(scc);


  class SampleInitializationTask : public GTask {
  private:
    G3MWidget_iOS*  _iosWidget;
    ShapesRenderer* _shapesRenderer;

  public:
    SampleInitializationTask(G3MWidget_iOS* iosWidget,
                             ShapesRenderer* shapesRenderer) :
    _iosWidget(iosWidget),
    _shapesRenderer(shapesRenderer)
    {

    }

    void run(const G3MContext* context) {
      printf("Running initialization Task\n");

      [_iosWidget widget]->setAnimatedCameraPosition(Geodetic3D(Angle::fromDegreesMinutes(37, 47),
                                                                Angle::fromDegreesMinutes(-122, 25),
                                                                1000000),
                                                     TimeInterval::fromSeconds(5));
      / *
      NSString *filePath = [[NSBundle mainBundle] pathForResource: @"seymour-plane"
                                                           ofType: @"json"];
      if (filePath) {
        NSString *nsString = [NSString stringWithContentsOfFile: filePath
                                                       encoding: NSUTF8StringEncoding
                                                          error: nil];
        if (nsString) {
          std::string str = [nsString UTF8String];
          Shape* plane = SceneJSShapesParser::parse(str);

          plane->setPosition( new Geodetic3D(Angle::fromDegrees(37.78333333),
                                             Angle::fromDegrees(-122.41666666666667),
                                             100) );
          plane->setScale(100, 100, 100);
          plane->setPitch(Angle::fromDegrees(-90));
          _shapesRenderer->addShape(plane);
        }
      }
      * /
    }
  };

  UserData* userData = NULL;
  const bool incrementalTileQuality = false;
  [[self G3MWidget] initWidgetWithCameraConstraints: cameraConstraints
                                           layerSet: layerSet
                             incrementalTileQuality: incrementalTileQuality
                                          renderers: renderers
                                           userData: userData
                                 initializationTask: new SampleInitializationTask([self G3MWidget], shapesRenderer)
                                    periodicalTasks: periodicalTasks];
}
*/


- (void)viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  } else {
    return YES;
  }
}

@end
