//
//  ViewController.m
//  EZCropExample_OC
//
//  Created by Xiang Li on 4/8/21.
//

#import "ViewController.h"
@import EZCropController;

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, EZCropControllerDelegate>

@property (nonatomic, strong) UIImage *image;           // The image we'll be cropping
@property (nonatomic, strong) UIImageView *imageView;   // The image view to present the cropped image

@property (nonatomic, assign) CGRect croppedFrame;
@property (nonatomic, assign) EZCropRotation angle;

@end

@implementation ViewController

#pragma mark - Image Picker Delegate -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.image = image;

    [picker dismissViewControllerAnimated:YES completion:^{
        EZCropController *cropController = [[EZCropController alloc] initWithImage:image];
        cropController.delegate = self;
        [UIViewController swizzleShouldAutorotate];
        [self presentViewController:cropController animated:YES completion:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Gesture Recognizer -
- (void)didTapImageView
{
    // When tapping the image view, restore the image to the previous cropping state
    EZCropController* cropController = [[EZCropController alloc] initWithImage:self.image
                                                                      cropRect:self.croppedFrame
                                                                         angle:self.angle];
    cropController.delegate = self;
    [UIViewController swizzleShouldAutorotate];
    [self presentViewController:cropController animated:YES completion:nil];
}

#pragma mark - Cropper Delegate -

- (void)cropViewControllerCancel:(EZCropController * _Nonnull)cropViewController {
    [cropViewController dismissViewControllerAnimated:YES completion:^{
        [UIViewController swizzleShouldAutorotate];
    }];
}

- (void)cropViewController:(EZCropController *)cropViewController didCropTo:(UIImage *)image with:(CGRect)cropRect angle:(enum EZCropRotation)angle
{
    self.croppedFrame = cropRect;
    self.angle = angle;
    [self updateImageViewWithImage:image fromCropViewController:cropViewController];
}


- (void)updateImageViewWithImage:(UIImage *)image fromCropViewController:(EZCropController *)cropViewController
{
    self.imageView.image = image;
    [self layoutImageView];
    

    self.navigationItem.rightBarButtonItem.enabled = YES;

    self.imageView.hidden = NO;
    [cropViewController dismissViewControllerAnimated:YES completion:^{
        [UIViewController swizzleShouldAutorotate];
    }];
}

#pragma mark - Image Layout -
- (void)layoutImageView
{
    if (self.imageView.image == nil)
        return;

    CGFloat padding = 20.0f;

    CGRect viewFrame = self.view.bounds;
    viewFrame.size.width -= (padding * 2.0f);
    viewFrame.size.height -= ((padding * 2.0f));

    CGRect imageFrame = CGRectZero;
    imageFrame.size = self.imageView.image.size;

    if (self.imageView.image.size.width > viewFrame.size.width ||
        self.imageView.image.size.height > viewFrame.size.height)
    {
        CGFloat scale = MIN(viewFrame.size.width / imageFrame.size.width, viewFrame.size.height / imageFrame.size.height);
        imageFrame.size.width *= scale;
        imageFrame.size.height *= scale;
        imageFrame.origin.x = (CGRectGetWidth(self.view.bounds) - imageFrame.size.width) * 0.5f;
        imageFrame.origin.y = (CGRectGetHeight(self.view.bounds) - imageFrame.size.height) * 0.5f;
        self.imageView.frame = imageFrame;
    }
    else {
        self.imageView.frame = imageFrame;
        self.imageView.center = (CGPoint){CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds)};
    }
}

#pragma mark - Bar Button Items -
- (void)showCropViewController
{
    UIImagePickerController *standardPicker = [[UIImagePickerController alloc] init];
    standardPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    standardPicker.allowsEditing = NO;
    standardPicker.delegate = self;
    [self presentViewController:standardPicker animated:YES completion:nil];

}

- (void)sharePhoto:(id)sender
{
    if (self.imageView.image == nil)
        return;

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self.imageView.image] applicationActivities:nil];
    activityController.modalPresentationStyle = UIModalPresentationPopover;
    activityController.popoverPresentationController.barButtonItem = sender;
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - View Creation/Lifecycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"EZCropController", @"");

    self.navigationController.navigationBar.translucent = NO;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showCropViewController)];

#if TARGET_APP_EXTENSION
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewController)];
#else
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharePhoto:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
#endif

    self.imageView = [[UIImageView alloc] init];
    self.imageView.userInteractionEnabled = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];

    if (@available(iOS 11.0, *)) {
        self.imageView.accessibilityIgnoresInvertColors = YES;
    }

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageView)];
    [self.imageView addGestureRecognizer:tapRecognizer];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self layoutImageView];
}





@end
