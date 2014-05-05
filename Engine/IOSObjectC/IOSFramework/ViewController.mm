//
//  ViewController.m
//  GenesisEngine
//
//  Created by 宋 琦 on 13-6-2.
//  Copyright (c) 2013年 宋 琦. All rights reserved.
//

#import "ViewController.h"
#import <UIKit/UIApplication.h>

#include "Shell/Genesis.h"
#include <sys/utsname.h>


#define BUFFER_OFFSET(i) ((char *)NULL + (i))

typedef std::vector<UITouch*> UITouches;
float        g_fScale;
int          g_Width;
int          g_Height;
UITouches g_TouchCache;

@interface ViewController () {
    
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation ViewController

enum DeviceLevel
{
    LEL_LOW = 0,
    LEL_BASE,
    LEL_HIGH,
    LEL_ULTRA,
};


DeviceLevel GetDeviceLevel()
{
    struct utsname sysinfo;
    uname(&sysinfo);
    //NSString *platform = [[[UIDevice currentDevice].systemName copy] autorelease];
    NSString* platform = [NSString stringWithCString: sysinfo.machine encoding: NSUTF8StringEncoding];
    if ([platform isEqualToString:@"iPhone1,1"])    return LEL_LOW;//return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return LEL_LOW;//return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return LEL_LOW;//return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return LEL_BASE;//return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return LEL_BASE;//return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return LEL_ULTRA;//return @"iPhone 4S";
    if ([platform isEqualToString:@"iPod1,1"])      return LEL_LOW;//return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return LEL_LOW;//return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return LEL_LOW;//return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return LEL_BASE;//return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])      return LEL_LOW;//return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return LEL_ULTRA;//return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return LEL_ULTRA;//return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return LEL_ULTRA;//return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return LEL_ULTRA;//return @"iPad 2";
    if ([platform isEqualToString:@"iPad3,1"])      return LEL_ULTRA;//return @"iPad-3G (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return LEL_ULTRA;//return @"iPad-3G (4G)";
    if ([platform isEqualToString:@"iPad3,3"])      return LEL_ULTRA;//return @"iPad-3G (4G)";
    if ([platform isEqualToString:@"iPad3,4"])      return LEL_ULTRA;//return @"iPad-4G (4G)";
    return LEL_ULTRA;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    g_fScale = 1.0;
    //g_fScale = [UIScreen mainScreen].scale;
    DeviceLevel dl = GetDeviceLevel();
    if ( LEL_LOW == dl || LEL_BASE == dl )
    {
        g_fScale = 1.0;
    }
    view.contentScaleFactor = g_fScale;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.multipleTouchEnabled = TRUE;
    
    [self setupGL];
}

- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
    
    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = nil;
    
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    static bool init = false;
    if (!init) {
        [self setupSystem];
        init = true;
    }
    
    EngineShell::Update();
    //[self RenderFrame];
}

#pragma mark -  OpenGL ES 2 shader compilation



-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window

{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskAll;
    else  /* iphone */
        return UIInterfaceOrientationMaskAllButUpsideDown;
}


- (BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations

{
    return UIInterfaceOrientationMaskAll;
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
    
}

- (void)setupSystem
{
    GLKView *view = (GLKView *)self.view;
    g_Width      = view.drawableWidth;
	g_Height     =  view.drawableHeight;
    
	//sleep(30);
    [self InitApp];
    
}

- (void)InitApp
{
	//…Ë÷√◊ ‘¥¬∑æ∂
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    const char *resChar = [resPath UTF8String];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	const char *appWriteableDic = [documentsDirectory UTF8String];
    EngineShell::InitEngine(g_Width,g_Height,resChar,appWriteableDic,"asset:BeginScene.scene",true);
	
}

int CheckTouchID(UITouch* touch, bool del)
{
    //find id.
    for (int i = 0; i < g_TouchCache.size(); ++i)
    {
        if (touch == g_TouchCache[i])
        {
            if (del)
            {
                g_TouchCache[i] = NULL;
            }
            return i;
        }
    }
    // new id.
    for (int j = 0; j < g_TouchCache.size(); ++j)
    {
        if (NULL == g_TouchCache[j])
        {
            if (del)
            {
                return j;
            }
            else
            {
                g_TouchCache[j] = touch;
                return j;
            }
        }
    }
    // array full.
    if (del)
    {
        return g_TouchCache.size();
    }
    else
    {
        g_TouchCache.push_back(touch);
        return g_TouchCache.size() - 1;
    }
    
}

//void ProcessTouchEvent(UIView* view, UIEvent* event, const EngineShell::InputAciton& action, bool del )
//{
//    NSSet *allTouches = [event allTouches];
//    EngineShell::PointfVector points;
//    EngineShell::TouchIDVector ids;
//    points.resize( allTouches.count );
//    ids.reserve(allTouches.count);
//    int i = 0;
//    for (UITouch *touch in allTouches)
//    {
//        CGPoint location = [touch locationInView:view];
//        points[i].x = location.x * g_fScale;
//        points[i].y = location.y * g_fScale;
//        ids[i] = CheckTouchID(touch, del);
//        ++i;
//    }
//    EngineShell::TouchPoint( points, ids, action );
//}
void ProcessTouchEvent(UIView* view, NSSet* allTouches, const EngineShell::InputAciton& action, bool del )
{
    EngineShell::TouchDataVector touchDatas;
    touchDatas.resize( allTouches.count );
    int i = 0;
    for (UITouch *touch in allTouches)
    {
        CGPoint location = [touch locationInView:view];
        touchDatas[i].x = location.x * g_fScale;
        touchDatas[i].y = location.y * g_fScale;
        touchDatas[i].id = CheckTouchID(touch, del);
        ++i;
    }
    EngineShell::TouchPoint( touchDatas, action );
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //ProcessTouchEvent( self.view, event, EngineShell::IA_DOWN, false);
    ProcessTouchEvent(self.view, touches, EngineShell::IA_DOWN, false);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //ProcessTouchEvent( self.view, event, EngineShell::IA_MOVE, false);
    ProcessTouchEvent(self.view, touches, EngineShell::IA_MOVE, false);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //ProcessTouchEvent( self.view, event, EngineShell::IA_UP, true);
    ProcessTouchEvent(self.view, touches, EngineShell::IA_UP, true);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //ProcessTouchEvent( self.view, event, EngineShell::IA_CANCEL, true);
    ProcessTouchEvent(self.view, touches, EngineShell::IA_CANCEL, true);
}

- (void)OnResumed
{
    EngineShell::OnResumed();
}

- (void)OnStopped
{
    EngineShell::OnStopped();
}


@end
