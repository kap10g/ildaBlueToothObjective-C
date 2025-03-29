//
//  LaserClient.h
//  Exquisite Corpus_beforeAddAUv3
//
//  Created by George Rosar on 3/24/25.
//
// ILDA Bluetooth UUIDs (placeholder, update with real UUIDs if known)
#pragma once
//#ifndef _LaserClient_include_h
//#define _LaserClient_include_h 1

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
#import "ildaIncludeRandos.h"
#import "ltc2656.h"
#import "ildaNode.h"
#import "ildaFile.h"

#ifdef __cplusplus
//extern "C" {
#endif

#define ILDA_DEVICE_UUID            @"19EE35F9-C927-D4B7-0D30-BBAC6D1B19AD"
#define DEVICE_INFORMATION_SERVICE_UUID @"180A"
//#define ILDA_SERVICE_UUID        @"E8D21DFE-1831-8863-A3B6-2FFF68F83219"
#define ILDA_SERVICE_UUID           @"FF00"
#define ILDA_SERVICE_TWO            @"0000FF00-0000-1000-8000-00805F9B34FB"
#define ILDA_CHARACTERISTIC_READ_UUID  @"0000FF01-0000-1000-8000-00805F9B34FB"

#define ILDA_CHARACTERISTIC_WRITE_UUID @"0000FF02-0000-1000-8000-00805F9B34FB"
typedef NS_ENUM(NSUInteger, AnimationType) {
    AnimationTypeCircle,
    AnimationTypeLine,
    AnimationTypeSpiral,
    AnimationTypeText,
    AnimationTypeImage,
    AnimationTypeRandom
};
typedef NS_ENUM(NSInteger, LaserMode) {
    LaserModeRandomPlayback,
    LaserModeAnimationPlayback,
    LaserModeImagePlayback,
    LaserModePiano
};
typedef NS_ENUM(NSUInteger, QuadrantMode) {
    QuadrantModeXPlusYPlus,
    QuadrantModeXPlusYMinus,
    QuadrantModeXMinusYMinus,
    QuadrantModeXMinusYPlus
};

typedef NS_ENUM(NSUInteger, ModulationMode) {
    ModulationModeAnalog,
    ModulationModeTTL
};
@interface LaserBluetoothDriver : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (atomic, strong) CBCentralManager *centralManager;
@property (atomic, strong) CBPeripheral *laserPeripheral;
@property (atomic, strong) CBCharacteristic *ildaCharacteristic;
@property (atomic, strong) CBCharacteristic *readCharacteristic;
+ (instancetype)sharedInstance;

- (void)startScan;
- (void)connectToLaser:(CBPeripheral *)peripheral;
- (void)sendILDAFrame:(NSData *)data;
//- (void)sendDMXData:(NSData *)data;
- (void)disconnect;

@end




// LaserClient implementation is unchanged

@class LaserClient;
@class LaserController;
@class LaserProgram;
@class IldaFileParser;
@interface LaserMenuController : UIViewController

@property (atomic, strong) LaserClient *laserClient;
@property (nonatomic, assign) AnimationType currentAnimation;
@property (nonatomic, assign) LaserMode currentMode;
@property (atomic, strong) UIButton *randomButton;
@property (atomic, strong) UIButton *animationButton;
@property (atomic, strong) UIButton *imageButton;
@property (atomic, strong) UIButton *pianoButton;
@property (atomic, strong) LaserController *laserController;
@property (atomic, strong) LaserProgram *laserProgram;
@property (atomic, strong) IldaFileParser *ildaFileParser;

+ (instancetype)sharedInstance;
- (void)switchToRandomPlayback;
- (void)switchToAnimationPlayback;
- (void)switchToImagePlayback;
- (void)switchToPianoMode;

@end









@interface LaserClient : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (atomic, strong) IldaFileParser *ildaFileParser;
@property (atomic, strong) CBCentralManager *centralManager;
@property (atomic, strong) CBPeripheral *laserPeripheral;
@property (atomic, strong) CBCharacteristic *ildaCharacteristic;
@property (atomic, strong) CBCharacteristic *readCharacteristic;
@property (atomic, strong) NSTimer *animationTimer;
@property (atomic, strong) NSMutableArray *points;
@property (nonatomic, assign) AnimationType animationType;
@property (nonatomic, assign) QuadrantMode quadrantMode;
@property (nonatomic, assign) ModulationMode modulationMode;
@property (nonatomic, assign) float targetFPS;
@property (nonatomic, assign) int currentFrameIndex;
@property (atomic, strong) NSString *textToRender;
@property (atomic, strong) UIImage *imageToRender;
@property (assign, nonatomic) CGPoint lastPoint; // Store last point
@property (strong, atomic) NSDictionary *color; // Store color
- (void)startDiscoveringServices;
// CBPeripheralDelegate method
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;
- (CBCentralManager *)getCentralManager;
- (CBPeripheral *)getPeripheral;
- (CBCharacteristic *)getIldaCharacteristic;
- (CBCharacteristic *)getReadCharacteristic;
+ (instancetype)sharedInstance;
- (instancetype)init;
- (void)startScanningForLaserWithUUID:(NSUUID *)uuid;
- (void)startAnimationLoop;
- (void)stopAnimationLoop;
- (void)setFPS:(float)newFPS;
- (void)setAnimationType:(AnimationType)typeZ;
- (void)setText:(NSString *)text;
- (void)setImage:(UIImage *)image;
- (void)sendNextFrame;
- (NSArray<NSDictionary *> *)generateCircleWithRadius:(float)radius points:(int)numPoints color:(NSDictionary *)color;
- (NSArray<NSDictionary *> *)generateLineFrom:(CGPoint)start to:(CGPoint)end points:(int)numPoints color:(NSDictionary *)color;
- (NSArray<NSDictionary *> *)generateSpiralWithRadius:(float)maxRadius turns:(int)turns points:(int)numPoints color:(NSDictionary *)color;
- (NSArray<NSDictionary *> *)generateImage:(UIImage *)image;
- (NSArray<NSDictionary *> *)generateText:(NSString *)text color:(NSDictionary *)color;
- (NSDictionary *)pointDictWithPoint:(CGPoint)p color:(NSDictionary *)color;
- (NSData *)generateILDAFrameWithPoints:(NSArray<NSDictionary *> *)points;
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI;
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
@end

#ifdef __cplusplus
//}
#endif
//#endif
