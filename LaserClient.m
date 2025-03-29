//
//  Bugger.m
//  Exquisite Corpus_beforeAddAUv3
//
//  Created by George Rosar on 3/24/25.
//

#import "LaserClient.h"


@implementation LaserBluetoothDriver
+ (instancetype)sharedInstance {
    static LaserBluetoothDriver *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

- (void)startScan {
    if (_centralManager.state == CBManagerStatePoweredOn) {
        [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:ILDA_SERVICE_UUID], [CBUUID UUIDWithString:ILDA_SERVICE_TWO]] options:nil];
    }
}

- (void)startScanningForLaserWithUUID:(NSUUID *)uuid {
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:ILDA_SERVICE_UUID], [CBUUID UUIDWithString:ILDA_SERVICE_TWO]] options:nil];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBManagerStatePoweredOn) {
        NSLog(@"[LaserClient] BLE powered on, ready to scan.");
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    self.laserPeripheral = peripheral;
    self.laserPeripheral.delegate = self;
    [self.centralManager stopScan];
    [self.centralManager connectPeripheral:peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [peripheral discoverServices:nil];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:ILDA_SERVICE_UUID]] || [service.UUID isEqual:[CBUUID UUIDWithString:ILDA_SERVICE_TWO]]) {
            [peripheral discoverCharacteristics:@[
                [CBUUID UUIDWithString:ILDA_CHARACTERISTIC_WRITE_UUID],
                [CBUUID UUIDWithString:ILDA_CHARACTERISTIC_READ_UUID]
            ] forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ILDA_CHARACTERISTIC_WRITE_UUID]]) {
            self.ildaCharacteristic = characteristic;
            NSLog(@"[LaserClient] Found ILDA characteristic and ready to stream.");
            //[self startAnimationLoop];
        }
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ILDA_CHARACTERISTIC_READ_UUID]]) {
            self.readCharacteristic = characteristic;
            NSLog(@"[LaserClient] Found ILDA READ characteristic, ready to listen.");
            // Start reading the characteristic value periodically
            [self.laserPeripheral readValueForCharacteristic:self.readCharacteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ILDA_CHARACTERISTIC_READ_UUID]]) {
        // Log the value read from the characteristic
        NSData *data = characteristic.value;
        NSLog(@"[LaserClient] Read from ILDA characteristic: %@", data);
        
        // Optionally, you can process the data further here
    }
}
- (void)sendILDAFrame:(NSData *)data {
    if (_laserPeripheral && _ildaCharacteristic) {
        [_laserPeripheral writeValue:data forCharacteristic:_ildaCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

/*- (void)sendDMXData:(NSData *)data {
    if (_laserPeripheral && _dmxCharacteristic) {
        [_laserPeripheral writeValue:data forCharacteristic:_dmxCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}*/

- (void)disconnect {
    if (_laserPeripheral) {
        [_centralManager cancelPeripheralConnection:_laserPeripheral];
    }
}

- (void)connectToLaser:(CBPeripheral *)peripheral {
    // Logic for connecting to laser
}

@end

@implementation LaserMenuController
+ (instancetype)sharedInstance {
    static LaserMenuController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
//- (void)setupUI {
//    self.randomButton = [self createButtonWithTitle:@"Random Playback" action:@selector(switchToRandomPlayback)];
//    self.animationButton = [self createButtonWithTitle:@"Animation Playback" action:@selector(switchToAnimationPlayback)];
//    self.imageButton = [self createButtonWithTitle:@"Image Playback" action:@selector(switchToImagePlayback)];
//    self.pianoButton = [self createButtonWithTitle:@"Piano Mode" action:@selector(switchToPianoMode)];
//
//    // Add buttons to the view and position them
//    [self.view addSubview:self.randomButton];
//    [self.view addSubview:self.animationButton];
//    [self.view addSubview:self.imageButton];
//    [self.view addSubview:self.pianoButton];
//
//    // Setup frames or use Auto Layout to position the buttons
//    // For simplicity, I'm setting frames here
//    CGFloat buttonWidth = self.view.frame.size.width - 40;
//    self.randomButton.frame = CGRectMake(20, 100, buttonWidth, 50);
//    self.animationButton.frame = CGRectMake(20, 160, buttonWidth, 50);
//    self.imageButton.frame = CGRectMake(20, 220, buttonWidth, 50);
//    self.pianoButton.frame = CGRectMake(20, 280, buttonWidth, 50);
//}
- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Start Laser Button
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [startButton setTitle:@"Start Laser" forState:UIControlStateNormal];
    startButton.frame = CGRectMake(20, 100, self.view.frame.size.width - 40, 50);
    [startButton addTarget:self action:@selector(startLaserAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startButton];
    
    // Parse ILDA File Button
    UIButton *parseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [parseButton setTitle:@"Parse ILDA File" forState:UIControlStateNormal];
    parseButton.frame = CGRectMake(20, 170, self.view.frame.size.width - 40, 50);
    [parseButton addTarget:self action:@selector(parseIldaFileAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:parseButton];
    self.randomButton = [self createButtonWithTitle:@"Random Playback" action:@selector(switchToRandomPlayback)];
    self.animationButton = [self createButtonWithTitle:@"Animation Playback" action:@selector(switchToAnimationPlayback)];
    self.imageButton = [self createButtonWithTitle:@"Image Playback" action:@selector(switchToImagePlayback)];
    self.pianoButton = [self createButtonWithTitle:@"Piano Mode" action:@selector(switchToPianoMode)];
    
    // Add buttons to the view and position them
    [self.view addSubview:self.randomButton];
    [self.view addSubview:self.animationButton];
    [self.view addSubview:self.imageButton];
    [self.view addSubview:self.pianoButton];
    
    // Setup frames or use Auto Layout to position the buttons
    // For simplicity, I'm setting frames here
    CGFloat buttonWidth = self.view.frame.size.width - 40;
    self.randomButton.frame = CGRectMake(20, 100, buttonWidth, 50);
    self.animationButton.frame = CGRectMake(20, 160, buttonWidth, 50);
    self.imageButton.frame = CGRectMake(20, 220, buttonWidth, 50);
    self.pianoButton.frame = CGRectMake(20, 280, buttonWidth, 50);
    // Additional buttons can be added here to invoke other LaserProgram actions
}

- (void)startLaserAction {
    // Start the Bluetooth connection and scanning.
    [self.laserController initLaser];
    
    // Optionally, start a predefined laser program.
    // For example, assume LaserProgram has a method runProgram that starts an animation:
    [self.laserProgram runProgram];
}

- (void)parseIldaFileAction {
    // Trigger ILDA file parsing.
    NSError *error = nil;
    if ([self.ildaFileParser parseFileWithError:&error]) {
        NSLog(@"ILDA file parsed successfully.");
    } else {
        NSLog(@"Error parsing ILDA file: %@", error.localizedDescription);
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the shared LaserController instance.
    self.laserController = [LaserController sharedInstance];
    
    // Initialize LaserProgram (which might contain pre-defined animations or commands)
    self.laserProgram = [LaserProgram sharedInstance];
    
    // Optionally, if you have an ILDA file in your bundle, load it via IldaFileParser.

    
    // Setup simple UI controls to trigger actions.
    [self setupUI];
    self.laserClient = [LaserClient sharedInstance];
    NSUUID *laserServiceUUID = [[NSUUID alloc] initWithUUIDString:ILDA_DEVICE_UUID];
    [self.laserClient startScanningForLaserWithUUID:laserServiceUUID];
    
    // Set up the UI elements for different modes
    //[self setupButtons];
}



- (UIButton *)createButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - Mode Switchers

- (void)switchToRandomPlayback {
    self.currentMode = LaserModeRandomPlayback;
    //[self.laserClient setAnimationType:AnimationTypeRandom];
    [self.laserClient startAnimationLoop];
}

- (void)switchToAnimationPlayback {
    self.currentMode = LaserModeAnimationPlayback;
    //[self.laserClient setAnimationType:AnimationTypeCircle]; // or any other animation type you want to use
    [self.laserClient startAnimationLoop];
}

- (void)switchToImagePlayback {
    self.currentMode = LaserModeImagePlayback;
    //[self.laserClient setAnimationType:AnimationTypeImage];
    [self.laserClient startAnimationLoop];
}

- (void)switchToPianoMode {
    self.currentMode = LaserModePiano;
    [self activatePianoMode];
}

#pragma mark - Piano Mode

- (void)activatePianoMode {
    // Assuming 88 keys (white and black keys) are to be mapped to the laser
    // Each key can be a different laser shape or animation
    // For simplicity, we'll toggle animation based on key pressed
    // For more complex piano logic, you can also handle MIDI or key events
    
    // Sample logic to render laser effects based on key pressed
    // Placeholder for piano key handling
    // Here, we're just alternating between red and green animations
    //[self.laserClient setAnimationType:AnimationTypeCircle];  // Modify to suit your needs
    [self.laserClient startAnimationLoop];
}
@end
@implementation LaserClient

- (void)startDiscoveringServices {
    self.laserPeripheral.delegate = self;
    [self.laserPeripheral discoverServices:nil]; // Pass nil to discover all services
}

// CBPeripheralDelegate method
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        return;
    }
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service: %@", service.UUID);
        // If you want to discover characteristics of this service, you can do it here
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:ILDA_CHARACTERISTIC_READ_UUID], [CBUUID UUIDWithString:ILDA_CHARACTERISTIC_WRITE_UUID]] forService:service];
    }
}

- (CBCentralManager *)getCentralManager {
    return _centralManager;
}
- (CBPeripheral *)getPeripheral {
    return _laserPeripheral;
}
- (CBCharacteristic *)getIldaCharacteristic {
    return _ildaCharacteristic;
}
- (CBCharacteristic *)getReadCharacteristic {
    return _readCharacteristic;
}

+ (instancetype)sharedInstance {
    static LaserClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.targetFPS = 30.0;
        self.quadrantMode = QuadrantModeXPlusYPlus;
        self.modulationMode = ModulationModeAnalog;
        self.animationType = AnimationTypeCircle;
        self.points = [NSMutableArray array];
        self.ildaFileParser = [IldaFileParser sharedInstance];
    }
    return self;
}

#pragma mark - BLE

- (void)startScanningForLaserWithUUID:(NSUUID *)uuid {
    // Ensure the Bluetooth is powered on
    if (self.centralManager.state == CBManagerStatePoweredOn) {
        [self startDiscoveringServices];
        // Proceed with scanning
        [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:ILDA_SERVICE_UUID], [CBUUID UUIDWithString:ILDA_SERVICE_TWO]] options:nil]; //, [CBUUID UUIDWithString:ILDA_CHARACTERISTIC_WRITE_UUID]] options:nil];
        //[self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:ILDA_CHARACTERISTIC_READ_UUID]] options:nil];
    } else {
        // Handle Bluetooth not being powered on
        NSLog(@"Bluetooth is not powered on. Can't start scanning.");
    }
}

// Delegate method to check the state of Bluetooth
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStateUnknown:
            NSLog(@"Bluetooth state is unknown.");
            break;
        case CBManagerStateResetting:
            NSLog(@"Bluetooth state is resetting.");
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"Bluetooth is powered off.");
            break;
        case CBManagerStatePoweredOn:
            NSLog(@"Bluetooth is powered on.");
            [self startScanningForLaserWithUUID:[[NSUUID alloc] initWithUUIDString:ILDA_DEVICE_UUID]];
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"Bluetooth is unauthorized.");
            break;
        case CBManagerStateUnsupported:
            NSLog(@"Bluetooth is unsupported.");
            break;
        default:
            break;
    }
}



- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if ([peripheral.identifier.UUIDString isEqualToString:ILDA_DEVICE_UUID]) {
        self.laserPeripheral = peripheral;
        self.laserPeripheral.delegate = self;
        [self.centralManager stopScan];
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    //[peripheral discoverServices:@[[CBUUID UUIDWithString:DEVICE_INFORMATION_SERVICE_UUID]]];
    [peripheral discoverServices:nil];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error reading characteristic: %@", error.localizedDescription);
        return;
    }

    // Define the UUID for ILDA_CHARACTERISTIC_READ_UUID
    //#define ILDA_CHARACTERISTIC_READ_UUID  @"0000FF01-0000-1000-8000-00805F9B34FB"
    //#define ILDA_CHARACTERISTIC_WRITE_UUID @"0000FF02-0000-1000-8000-00805F9B34FB"


    // Usage
    //CBUUID *ildaCharacteristicUUID = [CBUUID UUIDWithString:ILDA_CHARACTERISTIC_READ_UUID];

    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ILDA_CHARACTERISTIC_READ_UUID]]) {
        // Characteristic matches ILDA_CHARACTERISTIC_READ_UUID
        NSData *data = characteristic.value;
        if (data) {
            NSString *asciiString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSString *utf8String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (asciiString) {
                NSLog(@"ILDA Data (ASCII): %@", asciiString);
            } else if (utf8String) {
                NSLog(@"ILDA Data (UTF-8): %@", utf8String);
            } else {
                NSLog(@"ILDA Data (Raw): %@", data);
            }
        } else {
            NSLog(@"ILDA Characteristic has no value.");
        }
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]]) { // Manufacturer Name UUID
        NSString *manufacturerName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"Manufacturer Name: %@", manufacturerName);
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A24"]]) { // Model Number UUID
        NSString *modelNumber = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"Model Number: %@", modelNumber);
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A25"]]) { // Serial Number UUID
        NSString *serialNumber = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"Serial Number: %@", serialNumber);
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A26"]]) { // Hardware Revision UUID
        NSString *hardwareRevision = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"Hardware Revision: %@", hardwareRevision);
    }
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A27"]]) { // Firmware Revision UUID
        NSString *firmwareRevision = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"Firmware Revision: %@", firmwareRevision);
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering characteristics: %@", error.localizedDescription);
        return;
    }

    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ILDA_CHARACTERISTIC_WRITE_UUID]]) {
            // Launch file parsing and starting the animation loop asynchronously.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *ildaFilePath = [[NSBundle mainBundle] pathForResource:@"DoveOfPeace" ofType:@"ILD"];
                if (ildaFilePath) {
                    NSURL *ildaURL = [NSURL fileURLWithPath:ildaFilePath];
                    // Initialize the ILDA file parser asynchronously
                    self.ildaFileParser = [[IldaFileParser sharedInstance] initWithFileURL:ildaURL];
                }
                // Once done, switch back to the main queue to start the animation loop
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self startAnimationLoop];
                });
            });
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ILDA_CHARACTERISTIC_READ_UUID]]) {
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
}

//- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    if (error) {
//        NSLog(@"Error reading characteristic: %@", error.localizedDescription);
//        return;
//    }
//
//    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]]) { // Manufacturer Name UUID
//        NSString *manufacturerName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//        NSLog(@"Manufacturer Name: %@", manufacturerName);
//    }
//    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A24"]]) { // Model Number UUID
//        NSString *modelNumber = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//        NSLog(@"Model Number: %@", modelNumber);
//    }
//    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A25"]]) { // Serial Number UUID
//        NSString *serialNumber = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//        NSLog(@"Serial Number: %@", serialNumber);
//    }
//    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A26"]]) { // Hardware Revision UUID
//        NSString *hardwareRevision = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//        NSLog(@"Hardware Revision: %@", hardwareRevision);
//    }
//    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A27"]]) { // Firmware Revision UUID
//        NSString *firmwareRevision = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//        NSLog(@"Firmware Revision: %@", firmwareRevision);
//    }
//}

#pragma mark - Animation Loop

- (void)startAnimationLoop {
    self.currentFrameIndex = 0;
    [self.animationTimer invalidate];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / self.targetFPS)
                                                               target:self
                                                             selector:@selector(sendNextFrame)
                                                             userInfo:nil
                                                              repeats:YES];
    });
}



- (NSArray<NSDictionary *> *)generateImage:(UIImage *)image {
    NSMutableArray *points = [NSMutableArray array];
    
    // Scale the image to fit into the laser's range (e.g., 255x255)
    CGSize imageSize = CGSizeMake(255, 255);
    UIGraphicsBeginImageContext(imageSize);
    [image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // Get pixel data
    CGImageRef cgImage = scaledImage.CGImage;
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    const uint8_t *data = CFDataGetBytePtr(pixelData);
    
    int width = (int)imageSize.width;
    int height = (int)imageSize.height;
    
    // Loop through pixels and map them to laser points
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            int pixelIndex = ((height - y - 1) * width + x) * 4;  // Image is upside-down
            uint8_t r = data[pixelIndex];
            uint8_t g = data[pixelIndex + 1];
            uint8_t b = data[pixelIndex + 2];

            // Normalize x and y to the range -128 to 127
            int8_t normalizedX = (int8_t)((x - width / 2) * 2);
            int8_t normalizedY = (int8_t)((y - height / 2) * 2);
            
            if (r > 0 || g > 0 || b > 0) {
                CGPoint point = [self applyQuadrantToPoint:CGPointMake(normalizedX, normalizedY)];
                [points addObject:[self pointDictWithPoint:point color:@{@"r": @(r), @"g": @(g), @"b": @(b)}]];
            }
        }
    }
    
    CFRelease(pixelData);
    return points;
}

- (NSArray *)generateText:(NSString *)text color:(NSDictionary *)color {
    NSMutableArray *pointsArray = [NSMutableArray array];
    
    if (!text || text.length == 0) {
        return pointsArray; // Return empty array if no text is provided.
    }

    // Define a font and size for rendering the text as a path
    UIFont *font = [UIFont systemFontOfSize:20]; // You can adjust the size as needed
    NSDictionary *attributes = @{ NSFontAttributeName: font };
    
    // Create a bezier path from the text
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    CGRect textBounds = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:attributes
                                           context:nil];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:textBounds];
    
    // Convert the path to an array of points
    CGPathRef cgPath = path.CGPath;
    CGPathApply(cgPath, (__bridge void *)(self), pathElementCallback);
    
    // Populate points array with processed points and colors
    for (int i = 0; i < self.points.count; i++) {
        NSDictionary *point = self.points[i];
        NSDictionary *coloredPoint = @{ @"x": point[@"x"], @"y": point[@"y"], @"r": color[@"r"], @"g": color[@"g"], @"b": color[@"b"] };
        [pointsArray addObject:coloredPoint];
    }
    
    return pointsArray;
}


void pathElementCallback(void *info, const CGPathElement *element) {
    LaserClient *client = (__bridge LaserClient *)info;
    
    switch (element->type) {
        case kCGPathElementMoveToPoint:
            client.lastPoint = element->points[0]; // Set the initial point
            break;
        case kCGPathElementAddLineToPoint:
            [client.points addObject:@{ @"x": @(client.lastPoint.x), @"y": @(client.lastPoint.y), @"r": client.color[@"r"], @"g": client.color[@"g"], @"b": client.color[@"b"] }];
            client.lastPoint = element->points[0]; // Update last point
            break;
        case kCGPathElementAddQuadCurveToPoint:
            [client.points addObject:@{ @"x": @(client.lastPoint.x), @"y": @(client.lastPoint.y), @"r": client.color[@"r"], @"g": client.color[@"g"], @"b": client.color[@"b"] }];
            client.lastPoint = element->points[1];
            break;
        case kCGPathElementAddCurveToPoint:
            [client.points addObject:@{ @"x": @(client.lastPoint.x), @"y": @(client.lastPoint.y), @"r": client.color[@"r"], @"g": client.color[@"g"], @"b": client.color[@"b"] }];
            client.lastPoint = element->points[2];
            break;
        case kCGPathElementCloseSubpath:
            break;
    }
}

- (CGPoint)applyQuadrantToPoint:(CGPoint)point {
    switch (self.quadrantMode) {
        case QuadrantModeXPlusYPlus:
            return point;  // No change to the point.
            
        case QuadrantModeXPlusYMinus:
            return CGPointMake(point.x, -point.y);  // Flip Y-axis.
            
        case QuadrantModeXMinusYMinus:
            return CGPointMake(-point.x, -point.y);  // Flip both X and Y axes.
            
        case QuadrantModeXMinusYPlus:
            return CGPointMake(-point.x, point.y);  // Flip X-axis.
            
        default:
            return point;  // Default case for safety.
    }
}

// Generate a circle with specified radius, number of points, and color.
- (NSArray<NSDictionary *> *)generateCircleWithRadius:(float)radius points:(int)numPoints color:(NSDictionary *)color {
    NSMutableArray *circle = [NSMutableArray array];
    for (int i = 0; i < numPoints; i++) {
        float angle = (2 * M_PI * i) / numPoints;  // Calculate angle for each point
        int8_t x = (int8_t)(cos(angle) * radius);  // X-coordinate based on angle and radius
        int8_t y = (int8_t)(sin(angle) * radius);  // Y-coordinate based on angle and radius
        CGPoint p = [self applyQuadrantToPoint:CGPointMake(x, y)];  // Apply quadrant transformation
        [circle addObject:[self pointDictWithPoint:p color:color]];  // Add point with color
    }
    return circle;  // Return the array of circle points
}

// Generate a line from the start point to the end point with the specified number of points and color.
- (NSArray<NSDictionary *> *)generateLineFrom:(CGPoint)start to:(CGPoint)end points:(int)numPoints color:(NSDictionary *)color {
    NSMutableArray *line = [NSMutableArray array];
    
    for (int i = 0; i < numPoints; i++) {
        float t = (float)i / (numPoints - 1);  // Interpolation factor for each point
        float x = start.x + t * (end.x - start.x);  // Interpolate X-coordinate
        float y = start.y + t * (end.y - start.y);  // Interpolate Y-coordinate
        
        // Apply quadrant transformation to each point
        CGPoint p = [self applyQuadrantToPoint:CGPointMake(x, y)];
        
        // Add the point to the array with the color applied
        [line addObject:[self pointDictWithPoint:p color:color]];
    }
    
    return line;  // Return the array of points along the line
}

// Generate a spiral with a specified radius, number of turns, number of points, and color.
- (NSArray<NSDictionary *> *)generateSpiralWithRadius:(float)maxRadius turns:(int)turns points:(int)numPoints color:(NSDictionary *)color {
    NSMutableArray *spiral = [NSMutableArray array];
    for (int i = 0; i < numPoints; i++) {
        float t = (float)i / numPoints;  // Calculate interpolation factor for spiral
        float angle = turns * 2 * M_PI * t;  // Calculate the angle for the spiral
        float radius = maxRadius * t;  // Calculate the radius for the spiral
        
        int8_t x = (int8_t)(cos(angle) * radius);  // X-coordinate based on angle and radius
        int8_t y = (int8_t)(sin(angle) * radius);  // Y-coordinate based on angle and radius
        CGPoint p = [self applyQuadrantToPoint:CGPointMake(x, y)];  // Apply quadrant transformation
        [spiral addObject:[self pointDictWithPoint:p color:color]];  // Add point with color
    }
    return spiral;  // Return the array of spiral points
}


- (void)sendNextFrame {
    if (!self.ildaCharacteristic || self.laserPeripheral.state != CBPeripheralStateConnected) return;

    NSArray *frame;
    switch (self.animationType) {
        case AnimationTypeCircle:
            // Generate a circle with radius 100, 40 points, and red color
            frame = [self generateCircleWithRadius:100 points:40 color:@{ @"r": @255, @"g": @0, @"b": @0 }];
            break;
        case AnimationTypeLine:
            // Generate a line from (-100, 0) to (100, 0) with green color
            frame = [self generateLineFrom:CGPointMake(-100, 0) to:CGPointMake(100, 0) points:50 color:@{ @"r": @0, @"g": @255, @"b": @0 }];
            break;
        case AnimationTypeSpiral:
            // Generate a spiral with radius 100, 3 turns, 50 points, and blue color
            frame = [self generateSpiralWithRadius:100 turns:3 points:50 color:@{ @"r": @0, @"g": @0, @"b": @255 }];
            break;
        case AnimationTypeText:
            // Render text with yellow color
            frame = [self generateText:self.textToRender color:@{ @"r": @255, @"g": @255, @"b": @0 }];
            break;
        case AnimationTypeImage:
            // Generate points from image (assumed implementation)
            frame = [self generateImage:self.imageToRender];
            break;
        case AnimationTypeRandom:
            // Generate a random shape, either a circle or line
            frame = arc4random_uniform(2) ?
                    [self generateCircleWithRadius:80 points:30 color:@{ @"r": @255, @"g": @0, @"b": @255 }] :
                    [self generateLineFrom:CGPointMake(-50, -50) to:CGPointMake(50, 50) points:40 color:@{ @"r": @0, @"g": @255, @"b": @255 }];
            break;
    }

    // Convert points to ILDA frame data
    NSData *data = [self generateILDAFrameWithPoints:frame];
    
    // Send the ILDA frame to the laser projector
    [self.laserPeripheral writeValue:data forCharacteristic:self.ildaCharacteristic type:CBCharacteristicWriteWithoutResponse];
    
    // Increment frame index
    self.currentFrameIndex++;
}




- (void)setFPS:(float)newFPS {
    if (newFPS < 1.0) newFPS = 1.0;
    if (newFPS > 120.0) newFPS = 120.0;
    self.targetFPS = newFPS;
    [self.animationTimer invalidate];
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / self.targetFPS)
                                                           target:self
                                                         selector:@selector(sendNextFrame)
                                                         userInfo:nil
                                                          repeats:YES];
}

- (void)stopAnimationLoop {
    [self.animationTimer invalidate];
    self.animationTimer = nil;
}

- (void)setAnimationType:(AnimationType)typeZ {
    _animationType = typeZ; // Directly set the iVar
}


- (void)setText:(NSString *)text {
    self.textToRender = text;
}

- (void)setImage:(UIImage *)image {
    self.imageToRender = image;
}

- (NSDictionary *)pointDictWithPoint:(CGPoint)p color:(NSDictionary *)color {
    NSNumber *r = color[@"r"];
    NSNumber *g = color[@"g"];
    NSNumber *b = color[@"b"];

    if (self.modulationMode == ModulationModeTTL) {
        uint8_t ttl = ([r intValue] > 0 || [g intValue] > 0 || [b intValue] > 0) ? 255 : 0;
        r = @(ttl); g = @(ttl); b = @(ttl);
    }

    return @{ @"x": @(p.x), @"y": @(p.y), @"r": r, @"g": g, @"b": b };
}

#pragma mark - ILDA Packet Generator

- (NSData *)generateILDAFrameWithPoints:(NSArray<NSDictionary *> *)points {
    NSMutableData *data = [NSMutableData data];
    for (NSDictionary *pt in points) {
        // Extract the point coordinates and color values
        CGFloat x = [pt[@"x"] floatValue];
        CGFloat y = [pt[@"y"] floatValue];
        uint8_t r = [pt[@"r"] unsignedCharValue];
        uint8_t g = [pt[@"g"] unsignedCharValue];
        uint8_t b = [pt[@"b"] unsignedCharValue];
        
        // Apply quadrant transformation to the point coordinates
        CGPoint transformedPoint = [self applyQuadrantToPoint:CGPointMake(x, y)];
        
        // Convert the transformed point to the expected ILDA format
        int8_t transformedX = (int8_t)transformedPoint.x;
        int8_t transformedY = (int8_t)transformedPoint.y;
        
        // Create the buffer with the transformed coordinates and color values
        uint8_t buf[5] = { (uint8_t)transformedX, (uint8_t)transformedY, r, g, b };
        
        // Append the buffer to the data
        [data appendBytes:buf length:5];
    }
    return data;
}


@end
