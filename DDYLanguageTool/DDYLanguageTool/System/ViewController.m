#import "ViewController.h"
#import "DDYAuthorityManager.h"

@interface ViewController ()

@property (nonatomic, strong) UIImage *imgNormal;

@property (nonatomic, strong) UIImage *imgSelect;

@property (nonatomic, strong) NSMutableArray *buttonArray;
// CLLocationManager实例必须是全局的变量，否则授权提示弹框可能不会一直显示。
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation ViewController

- (NSMutableArray *)buttonArray {
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"HomeNavigationItemTitle", nil);
    _imgNormal = [self circleBorderWithColor:[UIColor grayColor] radius:8];
    _imgSelect = [self circleImageWithColor:[UIColor greenColor] radius:8];
    NSArray *authArray = @[@"HomeAuthMicphone",
                           @"HomeAuthCamera",
                           @"HomeAuthAlbum",
                           @"HomeAuthContacts",
                           @"HomeAuthEvent",
                           @"HomeAuthReminder"];
    for (NSInteger i = 0; i < authArray.count; i++) {
        @autoreleasepool {
            UIButton *button = [self generateButton:i title:authArray[i]];
            [self.buttonArray addObject:button];
            if ([[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"%ld_auth", button.tag]]) {
                [self performSelectorOnMainThread:@selector(handleClick:) withObject:button waitUntilDone:YES];
            }
        }
    }
    
    // 主动请求网络 先让系统弹出联网权限提示框
    [[DDYAuthorityManager sharedManager] ddy_GetNetAuthWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    // 定位
    if ([CLLocationManager locationServicesEnabled]) {
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager requestWhenInUseAuthorization];
    }
}

- (UIButton *)generateButton:(NSInteger)tag title:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
    [button setImage:_imgNormal forState:UIControlStateNormal];
    [button setImage:_imgSelect forState:UIControlStateSelected];
    [button addTarget:self action:@selector(handleClick:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:NSLocalizedString(title, nil) forState:UIControlStateNormal];
    [button setTag:tag+100];
    [self.view addSubview:button];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setFrame:CGRectMake(self.view.bounds.size.width/2.-70, tag*45 + 100, 140, 30)];
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor redColor].CGColor;
    return button;
}

- (void)handleClick:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:[NSString stringWithFormat:@"%ld_auth", sender.tag]];
    DDYAuthorityManager *manager = [DDYAuthorityManager sharedManager];
    if (sender.tag == 100) {
        [manager ddy_AudioAuthAlertShow:YES result:^(BOOL isAuthorized, AVAuthorizationStatus authStatus) {
            sender.selected = isAuthorized;
        }];
    } else if (sender.tag == 101) {
        if ([manager isCameraAvailable]) {
            [manager ddy_CameraAuthAlertShow:YES result:^(BOOL isAuthorized, AVAuthorizationStatus authStatus) {
                sender.selected = isAuthorized;
            }];
        } else {
            sender.selected = NO;
            NSLog(@"摄像头不可用");
        }
    } else if (sender.tag == 102) {
        [manager ddy_AlbumAuthAlertShow:YES result:^(BOOL isAuthorized, PHAuthorizationStatus authStatus) {
            sender.selected = isAuthorized;
        }];
    } else if (sender.tag == 103) {
        [manager ddy_ContactsAuthAlertShow:YES result:^(BOOL isAuthorized, DDYContactsAuthStatus authStatus) {
            sender.selected = isAuthorized;
        }];
    } else if (sender.tag == 104) {
        [manager ddy_EventAuthAlertShow:YES result:^(BOOL isAuthorized, EKAuthorizationStatus authStatus) {
            sender.selected = isAuthorized;
        }];
    } else if (sender.tag == 105) {
        [manager ddy_ReminderAuthAlertShow:YES result:^(BOOL isAuthorized, EKAuthorizationStatus authStatus) {
            sender.selected = isAuthorized;
        }];
    } else if (sender.tag == 106) {
        if (@available(iOS 10.0, *)) {
            [manager ddy_NetAuthAlertShow:YES result:^(BOOL isAuthorized, CTCellularDataRestrictedState authStatus) {
                sender.selected = isAuthorized;
            }];
        } else {
            sender.selected = YES;
        }
    } else if (sender.tag == 107) {
        [manager ddy_PushNotificationAuthAlertShow:YES result:^(BOOL isAuthorized) {
            sender.selected = isAuthorized;
        }];
    } else if (sender.tag == 108) {
        if ([CLLocationManager locationServicesEnabled]) {
            [manager ddy_LocationAuthType:DDYCLLocationTypeInUse alertShow:YES result:^(BOOL isAuthorized, CLAuthorizationStatus authStatus) {
                sender.selected = isAuthorized;
            }];
        } else {
            sender.selected = NO;
            NSLog(@"定位服务未开启");
        }
        
    } else if (sender.tag == 109) {
        if (@available(iOS 10.0, *)) {
            [manager ddy_SpeechAuthAlertShow:YES result:^(BOOL isAuthorized, SFSpeechRecognizerAuthorizationStatus authStatus) {
                sender.selected = isAuthorized;
            }];
        } else {
            sender.selected = NO;
        }
    } else {
        NSLog(@"Demo仅供参考");
    }
}

#pragma mark 绘制圆形图片
- (UIImage *)circleImageWithColor:(UIColor *)color radius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, radius*2.0, radius*2.0);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillEllipseInRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark 绘制圆形框
- (UIImage *)circleBorderWithColor:(UIColor *)color radius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, radius*2.0, radius*2.0);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddArc(context, radius, radius, radius-1, 0, 2*M_PI, 0);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextStrokePath(context);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
