# ildaBlueToothObjective-C
bluetooth support for Chinese galvo RGB controllers (in theory, the real protocol needs to be reverse-engineered but this is like the stubs for the interface)

PLEASE CONTRIBUTE, the lead developer is basically learning about Bluetooth packet sniffing in order to figure this out, if you have any links that relate to RGB galvo animation lasers the Bluetooth connects as a serial port via on Mac OS. Specifically the source, but if you're trying to sell your stuff maybe I'll add the link. I'm basically just missing the knowledge on the bluetooth protocol Light Elf uses. iOS/tvOS ready.


动画激光投影仪源
rgb galvo 动画激光投影仪源 DQF9 蓝牙 git github 源代码固件
alternative firmwares/boards:

https://github.com/maximus64/sd_rgb500_cfw

https://github.com/zrrraa/X-Laser

https://oshwhub.com/small-horn-projection-team/x-laser

https://www.bilibili.com/video/BV12m411z7Wr/?vd_source=1d0c07486a3bd3b0adb8ac548bf6453e

https://www.amazon.com/Waterproof-Animation-Projector-Christmas-Lighting/dp/B0DND2D46K?pd_rd_w=9r1Qj&content-id=amzn1.sym.c388ca75-4c14-4d9d-947d-5dcde63263f5&pf_rd_p=c388ca75-4c14-4d9d-947d-5dcde63263f5&pf_rd_r=ET6B5N7QT842YCDZT0RD&pd_rd_wg=5qQJN&pd_rd_r=316645d1-b59c-4b2b-b203-36c6baacb5fc&psc=1&ref_=pd_bap_d_grid_rp_csi_prsubs_0_pr_t


edit
```
#define ILDA_DEVICE_UUID            @"19EE35F9-C927-D4B7-0D30-BBAC6D1B19AD"
#define DEVICE_INFORMATION_SERVICE_UUID @"180A"
//#define ILDA_SERVICE_UUID        @"E8D21DFE-1831-8863-A3B6-2FFF68F83219"
#define ILDA_SERVICE_UUID           @"FF00"
#define ILDA_SERVICE_TWO            @"0000FF00-0000-1000-8000-00805F9B34FB"
#define ILDA_CHARACTERISTIC_READ_UUID  @"0000FF01-0000-1000-8000-00805F9B34FB"

#define ILDA_CHARACTERISTIC_WRITE_UUID @"0000FF02-0000-1000-8000-00805F9B34FB"

//ILDA_DEVICE_UUID should be the the bluetooth's device UUID (might need BLE scanners to get it)
//ILDA_SERVICE_TWO is the SERVICE for ILDA_CHARACTERISTIC_READ_UUID and ILDA_CHARACTERISTIC_WRITE_UUID CHARACTERISTIC

```


include your files:
```


#import "LaserClient.h"
#import "ltc2656.h"
#import "ildaNode.h"
#import "ildaFile.h"
          
//property is UIView linked in storyboard with predefined transform
@property (strong, nonatomic) IBOutlet UIView *LaserViewUIView;

//in viewDidLoad for UIViewController
- (void)viewDidLoad {
          [super viewDidLoad];



          dispatch_async(dispatch_get_main_queue(), ^{
           LaserMenuController *laserMenuController = [LaserMenuController sharedInstance];
          
           // Add LaserMenuController as a child view controller
           [self addChildViewController:laserMenuController];
          
           // Set the frame of the LaserMenuController's view to fit inside LaserViewUIView
           laserMenuController.view.frame = self.LaserViewUIView.bounds;
          
           // Add the LaserMenuController's view to LaserViewUIView
           [self.LaserViewUIView addSubview:laserMenuController.view];
          
           // Notify the LaserMenuController that it was added to a parent
           [laserMenuController didMoveToParentViewController:self];
          });
}
