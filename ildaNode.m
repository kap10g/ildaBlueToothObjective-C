#import <Foundation/Foundation.h>
#import <UIKit/UIKey.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreGraphics/CoreGraphics.h>
//#import "ltc2656.h"
#import "ildaNode.h"
//#import "ildaFile.h"


@implementation LaserProgram
+ (instancetype)sharedInstance {
    static LaserProgram *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _laserController = [LaserController sharedInstance];
        _scaleX = 1.0;
        _scaleY = 1.0;
        _delayMicroS = 0;
        _lastX = 0.0;
        _lastY = 0.0;
        _lastRed = 0.0;
        _lastGreen = 0.0;
        _lastBlue = 0.0;
    }
    return self;
}
- (void)runProgram {
    // Get the shared instance of LaserController.
    LaserController *controller = [LaserController sharedInstance];
    
    // Example animation: draw a circle using the laser.
    // Set the laser color to red.
    [controller setColourWithRed:1.0 green:0.0 blue:0.0];
    
    // Loop to generate circle points.
    // This is a simplified animation that moves the laser along a circle.
    CGFloat radius = 0.5;  // Example radius (normalized coordinate space)
    NSInteger numPoints = 36;
    
    for (NSInteger i = 0; i < numPoints; i++) {
        CGFloat angle = (2 * M_PI * i) / numPoints;
        CGFloat x = cos(angle) * radius;
        CGFloat y = sin(angle) * radius;
        CGFloat z = 0.0; // 2D animation, z remains constant
        
        [controller moveToX:x y:y z:z];
        
        // Pause briefly to simulate an animation frame (adjust as needed)
        [NSThread sleepForTimeInterval:0.05];
    }
    
    // Optionally, clear the laser after finishing the animation.
    [controller setColourWithRed:0.0 green:0.0 blue:0.0];
}

- (void)initILDA {
    // Initialization if needed
    [_laserController initLaser];
}

- (void)endILDA {
    // Cleanup if needed
    [_laserController closeLaser];
}

- (void)moveTo:(float)x y:(float)y {
    x *= self.scaleX;
    y *= self.scaleY;
    if (self.lastX != x) {
        self.lastX = x;
        [self.laserController setChVal_float:CH_X val:x];
    }
    if (self.lastY != y) {
        self.lastY = y;
        [self.laserController setChVal_float:CH_Y val:y];
    }
    [self.laserController executeValues];
}

- (void)moveToTimed:(float)x y:(float)y micros:(int)micros {
    if (micros > MOVE_TIME_MICROS) {
        int steps = micros / MOVE_TIME_MICROS;
        int remain = micros % MOVE_TIME_MICROS;
        float dx = (x - self.lastX) / steps;
        float dy = (y - self.lastY) / steps;
        for (int i = 1; i < steps; i++) {
            [self moveTo:self.lastX + dx y:self.lastY + dy];
        }
        usleep(remain);
        [self moveTo:x y:y];
    } else {
        [self moveTo:x y:y];
    }
}

- (void)moveToSpeedLimit:(float)x y:(float)y distPerS:(int)distPerS {
    float dx = (x - self.lastX);
    float dy = (y - self.lastY);
    int micros = 0;
    if (dx > dy) {
        micros = (dx / distPerS) * 1000000.0;
    } else {
        micros = (dy / distPerS) * 1000000.0;
    }
    [self moveToTimed:x y:y micros:micros];
}

- (void)setColour:(float)red green:(float)green blue:(float)blue {
    if (self.lastRed != red) {
        [self.laserController setChVal_float:CH_R val:red];
        self.lastRed = red;
    }
    if (self.lastGreen != green) {
        [self.laserController setChVal_float:CH_G val:green];
        self.lastGreen = green;
    }
    if (self.lastBlue != blue) {
        [self.laserController setChVal_float:CH_B val:blue];
        self.lastBlue = blue;
    }
}

- (void)cicle:(float)r posX:(float)posX posY:(float)posY {
    for (float i = 0.0; i < 360.0; i += 4) {
        [self moveTo:sin(M_PI * i / 180.0) * r + posX y:cos(M_PI * i / 180.0) * r + posY];
    }
}

- (void)rotatingCicle {
    for (float i = 0.0; i < 360.0; i += 20) {
        [self cicle:0.2 posX:sin(M_PI * i / 180.0) * 0.5 posY:cos(M_PI * i / 180.0) * 0.5];
    }
}

- (void)houseOfNicolaus {
    [self moveToTimed:-1.0 * HOUSE_SIZE y:-1.0 * HOUSE_SIZE micros:HOUSE_WAIT_MICROS];
    [self moveToTimed:HOUSE_SIZE y:-1.0 * HOUSE_SIZE micros:HOUSE_WAIT_MICROS];
    [self moveToTimed:-1.0 * HOUSE_SIZE y:ROOF_SIZE * HOUSE_SIZE micros:HOUSE_WAIT_MICROS];
    [self moveToTimed:HOUSE_SIZE y:ROOF_SIZE * HOUSE_SIZE micros:HOUSE_WAIT_MICROS];
    [self moveToTimed:0.0 y:HOUSE_SIZE micros:HOUSE_WAIT_MICROS];
    [self moveToTimed:-1.0 * HOUSE_SIZE y:ROOF_SIZE * HOUSE_SIZE micros:HOUSE_WAIT_MICROS];
    [self moveToTimed:-1.0 * HOUSE_SIZE y:-1.0 * HOUSE_SIZE micros:HOUSE_WAIT_MICROS];
    [self moveToTimed:HOUSE_SIZE y:ROOF_SIZE * HOUSE_SIZE micros:HOUSE_WAIT_MICROS];
    [self moveToTimed:HOUSE_SIZE y:-1.0 * HOUSE_SIZE micros:HOUSE_WAIT_MICROS];
}

- (int)selectWhatToDo {
    int number;
    printf("Type in the number to select:\n");
    printf("0: quit\n");
    printf("1: paint a circle\n");
    printf("2: paint a cycling circle\n");
    printf("3: paint a house\n");
    printf("4: execute ILDA-file\n");
    printf("5: options\n");
    scanf("%d", &number);
    return number;
}

- (void)options {
    printf("Type in the number to select:\n");
    printf("0: back\n");
    printf("1: scale X\n");
    printf("2: scale Y\n");
    int selection;
    scanf("%d", &selection);
    if (selection == 0) {
        return;
    } else if (selection == 1) {
        printf("Actual x scaling: %f\n", self.scaleX);
        printf("Enter new: ");
        scanf("%f", &_scaleX);
    } else if (selection == 2) {
        printf("Actual y scaling: %f\n", self.scaleY);
        printf("Enter new: ");
        scanf("%f", &_scaleY);
    } else {
        printf("%i is not an option.\n", selection);
    }
}

@end

//int main(int argc, const char * argv[]) {
//    @autoreleasepool {
//        LaserProgram *program = [LaserProgram sharedInstance];
//        [program initILDA];
//
//        int choice = 0;
//        while (choice != 0) {
//            choice = [program selectWhatToDo];
//            switch (choice) {
//                case 1:
//                    [program cicle:0.5 posX:0.0 posY:0.0];
//                    break;
//                case 2:
//                    [program rotatingCicle];
//                    break;
//                case 3:
//                    [program houseOfNicolaus];
//                    break;
//                case 4:
//                    // execute ILDA file
//                    break;
//                case 5:
//                    [program options];
//                    break;
//                default:
//                    break;
//            }
//        }
//
//        [program endILDA];
//    }
//    return 0;
//}



//#include <stdio.h>
//#include <unistd.h>
//#include <termios.h>
//#include <fcntl.h>
//#include <stdlib.h>
//#include <math.h>
////#include <wiringPi.h>
//#include <string.h>
////#include "ltc2656.h"
//#include "ildaFile.h"
//#include "ildaNode.h"
//
void initILDA(void){
	//initLtc2656();
    [[LaserProgram sharedInstance] initILDA];
}
//
void endILDA(void){
	//closeLtc2656();
    [[LaserProgram sharedInstance] endILDA];
}
//
float lastX = 0.0;
float lastY = 0.0;
float scaleX = 1.0;
float scaleY = 1.0;
int delayMicroS = 0;
///*
//mesured speed 0.15ms (~6.6kpps)
//*/
void moveTo(float x, float y){
//x *= scaleX;
//y *= scaleY;
//if(lastX != x){
//	lastX = x;
//	setChVal_float(CH_X, x);
//}
//if(lastY != y){
//	lastY = y;
//	setChVal_float(CH_Y, y);
//}
//executeValues();
    [[LaserProgram sharedInstance] moveTo:x y:y];
}
//
///*
//min 150 micros (used to set the values)
//*/
void moveToTimed(float x, float y, int micros){
	//if(micros > MOVE_TIME_MICROS){
	//	int steps = micros / MOVE_TIME_MICROS;
	//	int remain = micros % MOVE_TIME_MICROS;
	//	float dx = (x - lastX) / steps;
	//	float dy = (y - lastY) / steps;
	//	//doing one step less
	//	for(int i = 1; i < steps; i++){
	//		moveTo(lastX + dx, lastY + dy);
	//	}
	//	//do last step
	//	delayMicroseconds(remain);
	//	moveTo(x, y);
	//}else{
	//	moveTo(x, y);
	//}
    [[LaserProgram sharedInstance] moveToTimed:x y:y micros:micros];
}
//
///*
//distPerS is the distence per second (pps * 4)
//*/
void moveToSpeedLimit(float x, float y, int distPerS){
	float dx = (x - lastX);
	float dy = (y - lastY);
	int micros = 0;
	if(dx > dy){
		micros = (dx / distPerS) * 1000000.0;
	}else{
		micros = (dy / distPerS) * 1000000.0;
	}
    [[LaserProgram sharedInstance] moveToTimed:x y:y micros:micros];

	//moveToTimed(x, y, micros);
}
//
float lastRed = 0.0;
float lastGreen = 0.0;
float lastBlue = 0.0;
///*
//writes the values but not execute them
//*/
void setColour(float red, float green, float blue){
	if(lastRed != red){
        //setChVal_float(CH_R, red);
		//setChVal_float(CH_R, red);
        [[LaserController sharedInstance] setChVal_float:CH_R val:red];
		lastRed = red;
	}
	if(lastGreen != green){
        //setChVal_float(CH_G, green);
		//setChVal_float(CH_G, green);
        [[LaserController sharedInstance] setChVal_float:CH_G val:green];

		lastGreen = green;
	}
	if(lastBlue != blue){
        //setChVal_float(CH_B, blue);
		//setChVal_float(CH_B, blue);
        [[LaserController sharedInstance] setChVal_float:CH_B val:blue];

		lastBlue = blue;
	}
}
//
///*
//r radius of the cicle
//posX and posY center of the cicle
//*/
void cicle(float r, float posX, float posY){
	for(float i =0.0; i < 360.0; i+=4){
        [[LaserProgram sharedInstance] moveTo:sin(M_PI*i/180.0)*r+posX y:cos(M_PI*i/180.0)*r+posY];
		//moveTo(sin(M_PI*i/180.0)*r+posX, cos(M_PI*i/180.0)*r+posY);
        }
}
//
void rotataitingCicle(void){
	for(float i =0.0; i < 360.0; i+=20){
		cicle(0.2, sin(M_PI*i/180.0)*0.5, cos(M_PI*i/180.0)*0.5);
    }
}
//
//int HOUSE_WAIT_MICROS = 1000;
//float HOUSE_SIZE = 0.2;
//float ROOF_SIZE = 0.2; //invertete  (-1 is max 1 is min part of the house)
///*
//	 ^
//	/ \
//	|X|
//*/
void hoseOfNicolaus(void){
	moveToTimed(-1.0 * HOUSE_SIZE, -1.0 * HOUSE_SIZE, HOUSE_WAIT_MICROS);

	moveToTimed(HOUSE_SIZE, -1.0 * HOUSE_SIZE, HOUSE_WAIT_MICROS);

	moveToTimed(-1.0 * HOUSE_SIZE, ROOF_SIZE * HOUSE_SIZE, HOUSE_WAIT_MICROS);

	moveToTimed(HOUSE_SIZE, ROOF_SIZE * HOUSE_SIZE, HOUSE_WAIT_MICROS);

	moveToTimed(0.0, HOUSE_SIZE, HOUSE_WAIT_MICROS);

	moveToTimed(-1.0 * HOUSE_SIZE, ROOF_SIZE * HOUSE_SIZE, HOUSE_WAIT_MICROS);

        moveToTimed(-1.0 * HOUSE_SIZE, -1.0 * HOUSE_SIZE, HOUSE_WAIT_MICROS);

	moveToTimed(HOUSE_SIZE, ROOF_SIZE * HOUSE_SIZE, HOUSE_WAIT_MICROS);

	moveToTimed(HOUSE_SIZE, -1.0 * HOUSE_SIZE, HOUSE_WAIT_MICROS);
}
//
int selectWhatToDo(void){
	int  number;
	printf("Type in the number to select:\n");
	printf("0: quit\n");
	printf("1: paint a cicle\n");
	printf("2: paint a ciceling cicle\n");
	printf("3: paint a house\n");
	printf("4: execute ILDA-file\n");
	printf("5: options\n");
	scanf("%d", &number);
	return number;
}
//
//
void term_reset(void) {
    tcsetattr(STDIN_FILENO,TCSANOW,&stdin_orig);
    tcsetattr(STDIN_FILENO,TCSAFLUSH,&stdin_orig);
	int oldfl = fcntl(STDIN_FILENO, F_GETFL);
	if (oldfl == -1) {
	    /* handle error */
	}
	fcntl(STDIN_FILENO, F_SETFL, oldfl & ~O_NONBLOCK);
}
//
void term_nonblocking(void) {
    //struct termios stdin_orig;
    struct termios newt;
    if(tcgetattr(STDIN_FILENO, &stdin_orig) == -1){
        perror("could not back up terminal settings");
        return;
    }
    fcntl(STDIN_FILENO, F_SETFL, O_NONBLOCK); // non-blocking
    newt = stdin_orig;
    newt.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);

    atexit(term_reset);
}
//
void cleanStdin(void) {
    int ch;
    while ((ch = fgetc(stdin)) != EOF && ch != '\n') {
        /* null body */;
    }
}


// Function to restore original terminal settings
/*void term_reset(void) {
    if (tcsetattr(STDIN_FILENO, TCSANOW, &stdin_orig) == -1) {
        perror("Error restoring terminal settings");
    }

    int oldfl = fcntl(STDIN_FILENO, F_GETFL);
    if (oldfl == -1) {
        perror("Error getting file status flags");
    } else {
        if (fcntl(STDIN_FILENO, F_SETFL, oldfl & ~O_NONBLOCK) == -1) {
            perror("Error clearing O_NONBLOCK flag");
        }
    }
}*/

// Function to set terminal to non-blocking mode
/*
void term_nonblocking(void) {
    struct termios newt;

    if (tcgetattr(STDIN_FILENO, &stdin_orig) == -1) {
        perror("Could not back up terminal settings");
        exit(EXIT_FAILURE);
    }

    newt = stdin_orig;
    newt.c_lflag &= ~(ICANON | ECHO);
    if (tcsetattr(STDIN_FILENO, TCSANOW, &newt) == -1) {
        perror("Error setting terminal attributes");
        exit(EXIT_FAILURE);
    }

    int oldfl = fcntl(STDIN_FILENO, F_GETFL);
    if (oldfl == -1) {
        perror("Error getting file status flags");
        exit(EXIT_FAILURE);
    }

    if (fcntl(STDIN_FILENO, F_SETFL, oldfl | O_NONBLOCK) == -1) {
        perror("Error setting O_NONBLOCK flag");
        exit(EXIT_FAILURE);
    }

    if (atexit(term_reset) != 0) {
        perror("Error setting exit function");
        exit(EXIT_FAILURE);
    }
}

// Function to clear the standard input buffer
void cleanStdin(void) {
    int ch;
    while ((ch = getchar()) != EOF && ch != '\n') {
        // Discard character
    }
}*/

//
void options(void){
	printf("Type in the number to select:\n");
	printf("0: back\n");
	printf("1: scale X\n");
	printf("2: scale Y\n");
	int  selction;
	scanf("%d", &selction);
	if(selction == 0){
		return;
	}else if(selction == 1){
		printf("Actual x scaling: %f\n", scaleX);
		printf("Enter new: ");
		scanf("%f", &scaleX);
	}else if(selction == 2){
		printf("Actual y scaling: %f\n", scaleY);
		printf("Enter new: ");
		scanf("%f", &scaleY);
	}else{
		printf("%i is not a option.\n", selction);
	}
}
//
////int main(){
////	initILDA();
////	int runMainLoop = 1;
////	while(runMainLoop){
////		int  selction = selectWhatToDo();
////		if(selction == 0){
////			runMainLoop = 0; //quiting
////		}else if(selction < 1 || selction > 5){
////			printf("%i is not a option.\n", selction);
////			//runMainLoop = 0; //quiting
////		}else if(selction == 5){
////			options();
////		}else if(selction == 4){
////			char fileName[256];
////			cleanStdin();
////			printf("Please enter filename:\n");
////			fgets(fileName, sizeof(fileName), stdin);
////			char* fileNameTmp = strtok(fileName, "\n");
////			printf("open file: \"%s\"\n", fileNameTmp);
////			executeIldaFileByName(fileNameTmp, 1);
////		}else{
////			term_nonblocking();
////			printf("Type 's' to stop painting.");
////			int runPaintLoop = 1;
////			while(runPaintLoop){
////				if(selction == 1){
////					cicle(0.5, 0, 0);
////				}else if(selction == 2){
////					rotataitingCicle();
////				}else if(selction == 3){
////					hoseOfNicolaus();
////				}
////				int ch = getchar();
////				if(ch == 's'){
////					runPaintLoop = 0;
////				}
////			}
////			term_reset();
////		}
////	}
////	endILDA();
////	return 0;
////}
//
