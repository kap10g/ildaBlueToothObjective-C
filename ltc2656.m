#import <Foundation/Foundation.h>
#import <UIKit/UIKey.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreGraphics/CoreGraphics.h>

#import "ltc2656.h"
//#import "LaserClient.h"

@implementation LaserController

+ (instancetype)sharedInstance {
    static LaserController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //_centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _laserClient = [LaserClient sharedInstance];
        _centralManager = [_laserClient getCentralManager];
        _laserPeripheral = [_laserClient getPeripheral];
        _writeCharacteristic = [_laserClient getIldaCharacteristic];
        _readCharacteristic = [_laserClient getReadCharacteristic];
        _scaleX = 1.0;
        _scaleY = 1.0;
        _delayMicroS = 0;
        
        [_laserClient startDiscoveringServices];
        [self startDiscoveringServices];
        _centralManager = [_laserClient getCentralManager];
        _laserPeripheral = [_laserClient getPeripheral];
        _writeCharacteristic = [_laserClient getIldaCharacteristic];
        _readCharacteristic = [_laserClient getReadCharacteristic];
    }
    return self;
}


//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        // Initialize the central manager for Bluetooth
//        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
//        self.scaleX = 1.0;
//        self.scaleY = 1.0;
//        self.delayMicroS = 0;
//    }
//    return self;
//}

- (void)startDiscoveringServices {
    self.laserPeripheral.delegate = self;
    [self.laserPeripheral discoverServices:nil]; // Pass nil to discover all services
}


- (void)initLaser {
    // Start scanning for peripherals offering our laser service(s)
    [self.centralManager scanForPeripheralsWithServices:@[
        [CBUUID UUIDWithString:ILDA_SERVICE_UUID],
        [CBUUID UUIDWithString:ILDA_SERVICE_TWO]
    ] options:nil];
}

- (void)closeLaser {
    if (self.laserPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.laserPeripheral];
    }
}

- (void)setChVal:(unsigned char)channel valUpper:(unsigned char)valUpper valLower:(unsigned char)valLower {
    unsigned char dataBytes[] = {channel, valUpper, valLower};
    NSData *dataToSend = [NSData dataWithBytes:dataBytes length:sizeof(dataBytes)];
    [self writeDataToLaser:dataToSend];
}

- (void)setChVal_int:(unsigned char)channel val:(unsigned int)val {
    [self setChVal:channel valUpper:(unsigned char)(val >> 8) valLower:(unsigned char)(val & 0xFF)];
}

- (void)setChVal_float:(unsigned char)channel val:(float)val {
    [self setChVal_int:channel val:(unsigned int)(val * 32768 + 32767)];
}

// Instead of using SPI LDAC_PIN toggling, we send a command via Bluetooth.
- (void)executeValues {
    // For this example, assume that a specific command data (for instance, a known sequence) must be sent.
    // Replace the below with the actual command expected by your laser.
    const char command[] = "EXEC";
    NSData *data = [NSData dataWithBytes:command length:sizeof(command) - 1];
    [self writeDataToLaser:data];
}

- (void)writeDataToLaser:(NSData *)data {
    if (self.laserPeripheral && self.writeCharacteristic) {
        [self.laserPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

- (void)setColourWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    // Clamp values between 0 and 1
    red = MIN(MAX(red, 0.0), 1.0);
    green = MIN(MAX(green, 0.0), 1.0);
    blue = MIN(MAX(blue, 0.0), 1.0);
    
    // Here you would convert these values to the appropriate format and send them.
    // For example, assume channel 0x01 controls red, 0x02 green, 0x03 blue.
    [self setChVal_float:0x01 val:red];
    [self setChVal_float:0x02 val:green];
    [self setChVal_float:0x03 val:blue];
    
    //NSLog(@"Setting laser color to R: %.2f, G: %.2f, B: %.2f", red, green, blue);
}

- (void)moveToX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z {
    // Normalize or convert coordinates as necessary.
    // For this example, we assume the coordinates passed in are already normalized.
    // You might need to adjust them depending on your laser's coordinate system.
    //NSLog(@"Moving laser to X: %.2f, Y: %.2f, Z: %.2f", x, y, z);
    // For example, you might package these values in a data frame and send them:
    unsigned char cmd[] = {0x10, (unsigned char)x, (unsigned char)y, (unsigned char)z};
    NSData *data = [NSData dataWithBytes:cmd length:sizeof(cmd)];
    [self writeDataToLaser:data];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOn:
            NSLog(@"Bluetooth is powered on.");
            [self initLaser];
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"Bluetooth is powered off.");
            break;
        case CBManagerStateResetting:
            NSLog(@"Bluetooth is resetting.");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"Bluetooth is unauthorized.");
            break;
        case CBManagerStateUnsupported:
            NSLog(@"Bluetooth is unsupported.");
            break;
        case CBManagerStateUnknown:
        default:
            NSLog(@"Bluetooth state is unknown.");
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    // Match by device UUID or name as appropriate. In this example, we match by device name.
    if ([peripheral.name isEqualToString:@"TD5322A_001"]) {
        [self.centralManager stopScan];
        self.laserPeripheral = peripheral;
        self.laserPeripheral.delegate = self;
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [peripheral discoverServices:@[
        [CBUUID UUIDWithString:DEVICE_INFORMATION_SERVICE_UUID],
        [CBUUID UUIDWithString:ILDA_SERVICE_UUID],
        [CBUUID UUIDWithString:ILDA_SERVICE_TWO]
    ]];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering services: %@", error.localizedDescription);
        return;
    }
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service: %@", service.UUID);
        if ([service.UUID isEqual:[CBUUID UUIDWithString:ILDA_SERVICE_UUID]] ||
            [service.UUID isEqual:[CBUUID UUIDWithString:ILDA_SERVICE_TWO]]) {
            [peripheral discoverCharacteristics:@[
                [CBUUID UUIDWithString:ILDA_CHARACTERISTIC_WRITE_UUID],
                [CBUUID UUIDWithString:ILDA_CHARACTERISTIC_READ_UUID]
            ] forService:service];
        } else if ([service.UUID isEqual:[CBUUID UUIDWithString:DEVICE_INFORMATION_SERVICE_UUID]]) {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering characteristics: %@", error.localizedDescription);
        return;
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ILDA_CHARACTERISTIC_WRITE_UUID]]) {
            self.writeCharacteristic = characteristic;
            NSLog(@"Found ILDA WRITE characteristic.");
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ILDA_CHARACTERISTIC_READ_UUID]]) {
            self.readCharacteristic = characteristic;
            NSLog(@"Found ILDA READ characteristic.");
            // Optionally, read the value immediately:
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error reading characteristic: %@", error.localizedDescription);
        return;
    }
    CBUUID *ildaReadUUID = [CBUUID UUIDWithString:ILDA_CHARACTERISTIC_READ_UUID];
    if ([characteristic.UUID isEqual:ildaReadUUID]) {
        NSData *data = characteristic.value;
        NSString *asciiString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSString *utf8String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (asciiString) {
            NSLog(@"ILDA Data (ASCII): %@", asciiString);
        } else if (utf8String) {
            NSLog(@"ILDA Data (UTF-8): %@", utf8String);
        } else {
            NSLog(@"ILDA Data (Raw): %@", data);
        }
    }
    // Handle other characteristics (like device information) as needed
}

@end



//@implementation LaserController
//
//+ (instancetype)sharedInstance {
//    static LaserController *sharedInstance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sharedInstance = [[self alloc] init];
//    });
//    return sharedInstance;
//}
//
//// Implement other methods here
//
//- (void)setColourWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
//    // Implement the method to set the laser's color
//    // Ensure that the values are within the valid range [0.0, 1.0]
//    red = MIN(MAX(red, 0.0), 1.0);
//    green = MIN(MAX(green, 0.0), 1.0);
//    blue = MIN(MAX(blue, 0.0), 1.0);
//
//    // Set the laser color using the provided values
//    // Replace the following line with your actual implementation
//    NSLog(@"Setting laser color to R: %.2f, G: %.2f, B: %.2f", red, green, blue);
//}
//
//- (void)moveToX:(CGFloat)x y:(CGFloat)y z:(CGFloat)z {
//    // Implement the method to move the laser to the specified coordinates
//    // Normalize the coordinates if necessary
//    // For example, if the coordinates range from -32768 to 32767, normalize to [0.0, 1.0]
//    CGFloat normalizedX = (x + 32768.0) / 65536.0;
//    CGFloat normalizedY = (y + 32768.0) / 65536.0;
//    CGFloat normalizedZ = (z + 32768.0) / 65536.0;
//
//    // Move the laser to the normalized coordinates
//    // Replace the following line with your actual implementation
//    NSLog(@"Moving laser to X: %.2f, Y: %.2f, Z: %.2f", normalizedX, normalizedY, normalizedZ);
//}
//
//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        //_centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
//        _scaleX = 1.0;
//        _scaleY = 1.0;
//        _delayMicroS = 0;
//
//        _laserClient = [LaserClient sharedInstance];
//        [_laserClient startDiscoveringServices];
//        [self startDiscoveringServices];
//        _centralManager = [_laserClient getCentralManager];
//        _laserPeripheral = [_laserClient getPeripheral];
//        _writeCharacteristic = [_laserClient getIldaCharacteristic];
//    }
//    return self;
//}
//
//- (void)initLaser {
//    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:ILDA_SERVICE_UUID], [CBUUID UUIDWithString:ILDA_SERVICE_TWO]] //options:nil];
//}
//
//- (void)closeLaser {
//    if (self.laserPeripheral) {
//        [self.centralManager cancelPeripheralConnection:self.laserPeripheral];
//    }
//}
//
//- (void)setChVal:(unsigned char)channel valUpper:(unsigned char)valUpper valLower:(unsigned char)valLower {
//    unsigned char data[] = {channel, valUpper, valLower};
//    NSData *dataToSend = [NSData dataWithBytes:data length:sizeof(data)];
//    [self writeDataToLaser:dataToSend];
//}
//
//- (void)setChVal_int:(unsigned char)channel val:(unsigned int)val {
//    [self setChVal:channel valUpper:(unsigned char)(val >> 8) valLower:(unsigned char)(val & 0xFF)];
//}
//
//- (void)setChVal_float:(unsigned char)channel val:(float)val {
//    [self setChVal_int:channel val:(unsigned int)(val * 32768 + 32767)];
//}
//
////- (void)executeValues {
////    NSData *data = [NSData dataWithBytes:"LDAC_PIN" length:strlen("LDAC_PIN")];
////    //    digitalWrite (LDAC_PIN, LOW);
////    //    delayMicroseconds(1);
////    //    digitalWrite (LDAC_PIN,  HIGH);
////    [self writeDataToLaser:data];
////}
//
//- (void)executeValues {
//    // Prepare the data to send to the laser
//    //NSData *data = [NSData dataWithBytes:&LDAC_PIN length:sizeof(LDAC_PIN)];
//    //[self writeDataToLaser:data];
//}
//
//
//- (void)writeDataToLaser:(NSData *)data {
//    if (self.laserPeripheral && self.writeCharacteristic) {
//        [self.laserPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
//    }
//}
//
//#pragma mark - CBCentralManagerDelegate
//
//- (void)startDiscoveringServices {
//    self.laserPeripheral.delegate = self;
//    [self.laserPeripheral discoverServices:nil]; // Pass nil to discover all services
//}
//
//// CBPeripheralDelegate method
//- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
//    if (error) {
//        NSLog(@"Error discovering services: %@", [error localizedDescription]);
//        return;
//    }
//    for (CBService *service in peripheral.services) {
//        NSLog(@"Discovered service: %@", service.UUID);
//        // If you want to discover characteristics of this service, you can do it here
//        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:ILDA_CHARACTERISTIC_READ_UUID], [CBUUID //UUIDWithString:ILDA_CHARACTERISTIC_WRITE_UUID]] forService:service];
//    }
//}
//
//- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary //*)advertisementData RSSI:(NSNumber *)RSSI {
//    if ([peripheral.name isEqualToString:@"TD5322A_001"]) {
//        [self.centralManager stopScan];
//        self.laserPeripheral = peripheral;
//        self.laserPeripheral.delegate = self;
//        [self.centralManager connectPeripheral:peripheral options:nil];
//    }
//}
//
//- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
//    [peripheral discoverServices:nil];
//}
//
//- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
//
//}
//
//
///*- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
//    for (CBService *service in peripheral.services) {
//        [peripheral discoverCharacteristics:nil forService:service];
//    }
//}*/
//
//- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
//    for (CBCharacteristic *characteristic in service.characteristics) {
//        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ILDA_CHARACTERISTIC_WRITE_UUID]]) {
//            self.writeCharacteristic = characteristic;
//        }
//        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ILDA_CHARACTERISTIC_READ_UUID]]) {
//            self.readCharacteristic = characteristic;
//        }
//    }
//}
//
//
//
//
//
//@end

// Main
//int main() {
//    @autoreleasepool {
//        LaserController *laserController = [[LaserController alloc] init];
//        [laserController initLaser];
//
//        // Set some example values
//        [laserController setChVal_float:1 val:1.0f];
//        [laserController executeValues];
//
//        [laserController closeLaser];
//    }
//    return 0;
//}


//#include <stdio.h>
//#include <wiringPi.h>
//#include <stdlib.h>
//#include <fcntl.h>		//Needed for SPI port
//#include <sys/ioctl.h>		//Needed for SPI port
//#include <linux/spi/spidev.h>	//Needed for SPI port
//#include <unistd.h>		//Needed for SPI port (close)
//#include "ltc2656.h"
//
//int spi_cs0_fd;			//file descriptor for the SPI device
//int spi_cs1_fd;			//file descriptor for the SPI device
//
//
////SET SPI MODE
//unsigned char SPI_MODE = SPI_MODE_0; //SPI_MODE_0 (0,0) CPOL = 0, CPHA = 0, Clock idle low, data is clocked in on rising edge, output data (change) on falling edge
//
//
////***********************************
////***********************************
////********** SPI OPEN PORT **********
////***********************************
////***********************************
////spi_device	0=CS0, 1=CS1
//int SpiOpenPort (int spi_device)
//{
//    int status_value = -1;
//    int *spi_cs_fd;
//
//    if (spi_device)
//    	spi_cs_fd = &spi_cs1_fd;
//    else
//    	spi_cs_fd = &spi_cs0_fd;
//
//
//    if (spi_device)
//    	*spi_cs_fd = open(SPIDEV_1_PATH, O_RDWR);
//    else
//    	*spi_cs_fd = open(SPIDEV_0_PATH, O_RDWR);
//
//    if (*spi_cs_fd < 0)
//    {
//        perror("Error - Could not open SPI device");
//        exit(1);
//    }
//
//    status_value = ioctl(*spi_cs_fd, SPI_IOC_WR_MODE, &SPI_MODE);
//    if(status_value < 0)
//    {
//        perror("Could not set SPIMode (WR)...ioctl fail");
//        exit(1);
//    }
//
//    status_value = ioctl(*spi_cs_fd, SPI_IOC_RD_MODE, &SPI_MODE);
//    if(status_value < 0)
//    {
//      perror("Could not set SPIMode (RD)...ioctl fail");
//      exit(1);
//    }
//
//	unsigned char bitsPerWord = SPI_BITS_PER_WORD;
//    status_value = ioctl(*spi_cs_fd, SPI_IOC_WR_BITS_PER_WORD, &bitsPerWord);
//    if(status_value < 0)
//    {
//      perror("Could not set SPI bitsPerWord (WR)...ioctl fail");
//      exit(1);
//    }
//
//    status_value = ioctl(*spi_cs_fd, SPI_IOC_RD_BITS_PER_WORD, &bitsPerWord);
//    if(status_value < 0)
//    {
//      perror("Could not set SPI bitsPerWord(RD)...ioctl fail");
//      exit(1);
//    }
//	unsigned int spiSpeed = SPI_SPEED;
//    status_value = ioctl(*spi_cs_fd, SPI_IOC_WR_MAX_SPEED_HZ, &spiSpeed);
//    if(status_value < 0)
//    {
//      perror("Could not set SPI speed (WR)...ioctl fail");
//      exit(1);
//    }
//
//    status_value = ioctl(*spi_cs_fd, SPI_IOC_RD_MAX_SPEED_HZ, &spiSpeed);
//    if(status_value < 0)
//    {
//      perror("Could not set SPI speed (RD)...ioctl fail");
//      exit(1);
//    }
//    return(status_value);
//}
//
////************************************
////************************************
////********** SPI CLOSE PORT **********
////************************************
////************************************
//int SpiClosePort (int spi_device)
//{
//	int status_value = -1;
//    int *spi_cs_fd;
//
//    if (spi_device)
//    	spi_cs_fd = &spi_cs1_fd;
//    else
//    	spi_cs_fd = &spi_cs0_fd;
//
//
//    status_value = close(*spi_cs_fd);
//    if(status_value < 0)
//    {
//    	perror("Error - Could not close SPI device");
//    	exit(1);
//    }
//    return(status_value);
//}
//
////*******************************************
////*******************************************
////********** SPI WRITE & READ DATA **********
////*******************************************
////*******************************************
////data		Bytes to write.  Contents is overwritten with bytes read.
//int SpiWriteAndRead (int spi_device, unsigned char *data, int length){
//	struct spi_ioc_transfer spi[length];
//	int i = 0;
//	int retVal = -1;
//	int *spi_cs_fd;
//
//    if (spi_device)
//    	spi_cs_fd = &spi_cs1_fd;
//    else
//    	spi_cs_fd = &spi_cs0_fd;
//
//	//one spi transfer for each byte
//
//	for (i = 0 ; i < length ; i++)
//	{
//		spi[i].tx_buf        = (unsigned long)(data + i); // transmit from "data"
//		spi[i].rx_buf        = (unsigned long)(data + i) ; // receive into "data"
//		spi[i].len           = sizeof(*(data + i)) ;
//		spi[i].delay_usecs   = 0 ;
//		spi[i].speed_hz      = SPI_SPEED ;
//		spi[i].bits_per_word = SPI_BITS_PER_WORD ;
//		spi[i].cs_change = 0;
//		spi[i].pad = 0;
//	}
//	retVal = ioctl(*spi_cs_fd, SPI_IOC_MESSAGE(length), &spi) ;
//	if(retVal < 0)
//	{
//		perror("Error - Problem transmitting spi data..ioctl");
//		exit(1);
//	}
//
//	return retVal;
//}
//
//void setChVal(unsigned char channel, unsigned char valUpper, unsigned char valLower){
//	unsigned char data[] = {channel, valUpper, valLower};
//	SpiWriteAndRead(0, data, 3);
//}
//
//void setChVal_int(unsigned char channel, unsigned int val){
//	setChVal(channel, (unsigned char)(val>>8), val & 0xff);
//}
//
//void setChVal_float(unsigned char channel, float val){
//	setChVal_int(channel, val * 32768 + 32767);
//}
//
//void executeValues(){
//	digitalWrite (LDAC_PIN, LOW);
//	delayMicroseconds(1);
//	digitalWrite (LDAC_PIN,  HIGH);
//}
//
//void initLtc2656(){
//	wiringPiSetup ();
//	pinMode (LDAC_PIN, OUTPUT);
//	digitalWrite (LDAC_PIN,  HIGH);
//	SpiOpenPort(SPI_DEV);
//}
//
//void closeLtc2656(){
//	SpiClosePort(SPI_DEV);
//}
//
//
//
