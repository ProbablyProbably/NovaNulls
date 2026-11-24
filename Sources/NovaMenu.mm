#import <UIKit/UIKit.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import <objc/runtime.h>

static NSString * const kNovaPrefs = @"com.nova.modmenu.preferences";
static NSString * const kNovaMods = @"com.nova.modmenu.mods";

@interface NovaOverlayWindow : UIWindow
@end
@implementation NovaOverlayWindow
- (UIView *)hitTest:(CGPoint)p withEvent:(UIEvent *)event {
    UIView *v = [super hitTest:p withEvent:event];
    if (v == self.rootViewController.view) return nil;
    return v;
}
@end

@interface NovaMenuController : UIViewController <UIDocumentPickerDelegate>
@property(nonatomic,strong) UIButton *bubble;
@property(nonatomic,strong) UIView *panel;
@property(nonatomic,strong) UIStackView *list;
@property(nonatomic,strong) UILabel *status;
@property(nonatomic,strong) NSMutableArray<NSMutableDictionary *> *mods;
@property(nonatomic,strong) NovaOverlayWindow *overlay;
@end

@implementation NovaMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
    NSData *d = [[NSUserDefaults standardUserDefaults] dataForKey:kNovaMods];
    NSArray *saved = d ? [NSJSONSerialization JSONObjectWithData:d options:NSJSONReadingMutableContainers error:nil] : nil;
    self.mods = [NSMutableArray array];
    for (NSDictionary *m in saved) [self.mods addObject:[m mutableCopy]];
    [self buildBubble];
    [self buildPanel];
    self.panel.hidden = YES;
    [self refreshList];
}

- (void)buildBubble {
    self.bubble = [UIButton buttonWithType:UIButtonTypeSystem];
    self.bubble.frame = CGRectMake(18, 140, 58, 58);
    self.bubble.layer.cornerRadius = 29;
    self.bubble.backgroundColor = [UIColor colorWithRed:0.12 green:0.48 blue:0.95 alpha:0.96];
    [self.bubble setTitle:@"N" forState:UIControlStateNormal];
    [self.bubble setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.bubble.titleLabel.font = [UIFont boldSystemFontOfSize:25];
    self.bubble.layer.borderWidth = 2;
    self.bubble.layer.borderColor = UIColor.whiteColor.CGColor;
    [self.bubble addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bubble];
}

- (void)buildPanel {
    CGFloat w = MIN(390, UIScreen.mainScreen.bounds.size.width - 36);
    self.panel = [[UIView alloc] initWithFrame:CGRectMake(92, 110, w, 390)];
    self.panel.backgroundColor = [UIColor colorWithRed:0.055 green:0.075 blue:0.12 alpha:0.97];
    self.panel.layer.cornerRadius = 16;
    self.panel.layer.borderWidth = 1;
    self.panel.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.22].CGColor;
    [self.view addSubview:self.panel];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, w-32, 30)];
    title.text = @"NOVA  •  MOD MANAGER";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont boldSystemFontOfSize:16];
    [self.panel addSubview:title];

    UIButton *close = [self button:@"×" frame:CGRectMake(w-42, 7, 34, 32)];
    [close addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
    [self.panel addSubview:close];

    UIButton *import = [self button:@"＋ Import .NullsBrawlAssets" frame:CGRectMake(14, 48, w-28, 38)];
    [import addTarget:self action:@selector(importArchive) forControlEvents:UIControlEventTouchUpInside];
    [self.panel addSubview:import];

    self.status = [[UILabel alloc] initWithFrame:CGRectMake(16, 90, w-32, 22)];
    self.status.textColor = [UIColor colorWithWhite:0.78 alpha:1];
    self.status.font = [UIFont systemFontOfSize:11];
    self.status.text = @"Imported archives are stored in this app's Documents folder.";
    [self.panel addSubview:self.status];

    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(12, 116, w-24, 220)];
    scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.panel addSubview:scroll];
    self.list = [[UIStackView alloc] initWithFrame:CGRectMake(0, 0, w-24, 1)];
    self.list.axis = UILayoutConstraintAxisVertical;
    self.list.spacing = 7;
    [scroll addSubview:self.list];
    scroll.tag = 404;

    UIButton *settings = [self button:@"Settings" frame:CGRectMake(14, 344, (w-36)/2, 32)];
    [settings addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    [self.panel addSubview:settings];
    UIButton *hide = [self button:@"Hide menu" frame:CGRectMake(22+(w-36)/2, 344, (w-36)/2, 32)];
    [hide addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
    [self.panel addSubview:hide];
}

- (UIButton *)button:(NSString *)text frame:(CGRect)frame {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.frame = frame;
    b.backgroundColor = [UIColor colorWithRed:0.13 green:0.27 blue:0.43 alpha:1];
    b.layer.cornerRadius = 8;
    [b setTitle:text forState:UIControlStateNormal];
    [b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    b.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    return b;
}

- (void)togglePanel { self.panel.hidden = !self.panel.hidden; }

- (NSURL *)modsDirectory {
    NSURL *docs = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *dir = [docs URLByAppendingPathComponent:@"Mods" isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:dir withIntermediateDirectories:YES attributes:nil error:nil];
    return dir;
}

- (void)importArchive {
    UIDocumentPickerViewController *picker;
    if (@available(iOS 14.0, *)) picker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[UTType.item] asCopy:YES];
    else picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *source = urls.firstObject;
    if (!source) return;
    NSString *ext = source.pathExtension.lowercaseString;
    if (![ext isEqualToString:@"nullsbrawlassets"] && ![ext isEqualToString:@"zip"]) {
        self.status.text = @"Unsupported file. Choose a .NullsBrawlAssets or .zip archive.";
        return;
    }
    BOOL access = [source startAccessingSecurityScopedResource];
    NSString *base = source.lastPathComponent;
    NSString *safe = [base stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    NSURL *dest = [[self modsDirectory] URLByAppendingPathComponent:safe];
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:dest.path]) [[NSFileManager defaultManager] removeItemAtURL:dest error:nil];
    BOOL ok = [[NSFileManager defaultManager] copyItemAtURL:source toURL:dest error:&error];
    if (access) [source stopAccessingSecurityScopedResource];
    if (!ok) { self.status.text = error.localizedDescription ?: @"Import failed."; return; }
    NSMutableDictionary *entry = [@{@"name":base, @"path":dest.path, @"enabled":@NO, @"id":NSUUID.UUID.UUIDString} mutableCopy];
    [self.mods addObject:entry];
    [self saveMods];
    self.status.text = [NSString stringWithFormat:@"Imported %@", base];
    [self refreshList];
}

- (void)saveMods {
    NSData *d = [NSJSONSerialization dataWithJSONObject:self.mods options:0 error:nil];
    if (d) [[NSUserDefaults standardUserDefaults] setObject:d forKey:kNovaMods];
}

- (void)refreshList {
    for (UIView *v in self.list.arrangedSubviews) { [self.list removeArrangedSubview:v]; [v removeFromSuperview]; }
    for (NSUInteger i=0; i<self.mods.count; i++) {
        NSMutableDictionary *m = self.mods[i];
        UIView *row = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.list.bounds.size.width,42)];
        row.backgroundColor = [UIColor colorWithWhite:1 alpha:0.07];
        row.layer.cornerRadius = 7;
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(9,3,row.bounds.size.width-104,36)];
        name.text = m[@"name"]; name.textColor = UIColor.whiteColor; name.font = [UIFont systemFontOfSize:11]; name.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [row addSubview:name];
        UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectZero]; sw.transform = CGAffineTransformMakeScale(.72,.72); sw.on = [m[@"enabled"] boolValue]; sw.tag = (NSInteger)i;
        [sw addTarget:self action:@selector(toggleMod:) forControlEvents:UIControlEventValueChanged];
        sw.frame = CGRectMake(row.bounds.size.width-82,5,48,32); [row addSubview:sw];
        UIButton *del = [UIButton buttonWithType:UIButtonTypeSystem]; del.frame = CGRectMake(row.bounds.size.width-34,5,30,32); del.tag=(NSInteger)i; [del setTitle:@"−" forState:UIControlStateNormal]; [del setTitleColor:[UIColor colorWithRed:1 green:.4 blue:.4 alpha:1] forState:UIControlStateNormal]; [del addTarget:self action:@selector(deleteMod:) forControlEvents:UIControlEventTouchUpInside]; [row addSubview:del];
        [self.list addArrangedSubview:row];
        row.translatesAutoresizingMaskIntoConstraints = NO;
        [row.heightAnchor constraintEqualToConstant:42].active = YES;
        [row.widthAnchor constraintEqualToAnchor:self.list.widthAnchor].active = YES;
    }
    [self.list layoutIfNeeded];
    UIScrollView *scroll = [self.panel viewWithTag:404];
    scroll.contentSize = CGSizeMake(scroll.bounds.size.width, self.list.bounds.size.height);
    if (self.mods.count == 0) self.status.text = @"No archives imported yet.";
}

- (void)toggleMod:(UISwitch *)sender {
    if (sender.tag >= self.mods.count) return;
    self.mods[sender.tag][@"enabled"] = @(sender.isOn);
    [self saveMods];
    self.status.text = sender.isOn ? @"Mod marked enabled (requires a game-specific loader to affect gameplay)." : @"Mod disabled.";
}

- (void)deleteMod:(UIButton *)sender {
    if (sender.tag >= self.mods.count) return;
    NSDictionary *m = self.mods[sender.tag];
    NSString *path = m[@"path"];
    if (path.length) [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    [self.mods removeObjectAtIndex:sender.tag]; [self saveMods]; [self refreshList];
}

- (void)showSettings {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Nova settings" message:@"Menu preferences are saved on this device. Archive switches currently manage the imported archive list; they do not patch gameplay without a verified Null's Brawl loader/API." preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}
@end

static NovaOverlayWindow *gNovaWindow;
static void NovaInstallOverlay(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (gNovaWindow) return;
        UIWindowScene *scene = nil;
        for (UIScene *s in UIApplication.sharedApplication.connectedScenes) if ([s isKindOfClass:UIWindowScene.class] && s.activationState == UISceneActivationStateForegroundActive) { scene=(UIWindowScene *)s; break; }
        if (!scene) return;
        gNovaWindow = [[NovaOverlayWindow alloc] initWithWindowScene:scene];
        gNovaWindow.frame = scene.coordinateSpace.bounds;
        gNovaWindow.windowLevel = UIWindowLevelAlert - 2;
        NovaMenuController *vc = [NovaMenuController new];
        gNovaWindow.rootViewController = vc;
        gNovaWindow.backgroundColor = UIColor.clearColor;
        gNovaWindow.hidden = NO;
    });
}

__attribute__((constructor)) static void NovaEntry(void) {
    @autoreleasepool {
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(__unused NSNotification *n) { NovaInstallOverlay(); }];
        NovaInstallOverlay();
    }
}
