# EZCropController

**EZCropController** is designed for cropping `UIImage` and try to edit images in the same interactive way that **"Photos"** in the system

[![Build Example](https://github.com/InterPro-Solutions/EZCropController/workflows/Build%20Example%20app/badge.svg)](https://github.com/InterPro-Solutions/EZCropController/actions?query=workflow%3A%22Build%20Example%20app%22)
[![Run Example Tests](https://github.com/InterPro-Solutions/EZCropController/workflows/Run%20Example%20Tests/badge.svg)](https://github.com/InterPro-Solutions/EZCropController/actions?query=workflow%3A%22Run%20Example%20Tests%22)

![Portrait Orientation](./screenshot/portrait_record.gif)

![Landscape Orientation](./screenshot/landscape_record.gif)

## Requirements
- iOS 11.0 or later
- Swift 5
- Swift package manager 5.3
## Installation

<details>
  <summary>Swift Package Manager</summary>
  
  Add the following to your `Package.swift`:
``` swift
dependencies: [
  // ...
  .package(url: "https://github.com/InterPro-Solutions/EZCropController.git"),
],
```
</details>

## Examples

<details>
  <summary>Basic Implementation</summary>

#### Swift
```swift
class ViewController : UIViewController, EZCropControllerDelegate {
    func showCropController() {
        let image: UIImage = ... //Load an image
        let cropViewController = EZCropViewController(image: image)
        cropViewController.delegate = self
        present(cropViewController, animated: true, completion: {
            // Pass should autoRotate of EZCropController to the RootViewController of UIWindow
            UIViewController.swizzleShouldAutorotate()
        })
    }

    func cropViewControllerCancel(_ cropViewController: EZCropController) {
        cropViewController.dismiss(animated: true, completion: {
            // disable swizzle
            UIViewController.swizzleShouldAutorotate()
        })
    }

    func cropViewController(_ cropViewController: EZCropController, 
                            didCropTo image: UIImage, 
                            with cropRect: CGRect, 
                            angle: EZCropRotation) 
    {
        // `image` is cropped
        // `cropRect` is in the original coordinate of original image
        // `angle` The direction of cropped image
    }

}
```

#### Objective-C
```objc
- (void)showCropController {
    UIImage *image = ... 
    EZCropController *cropViewController = [[TOCropViEZCropControllerewController alloc] initWithImage:image];
    cropViewController.delegate = self;
    [self presentViewController:cropViewController animated:YES completion:^{
        [UIViewController swizzleShouldAutorotate];
    }];
}

- (void)cropViewControllerCancel:(EZCropController * _Nonnull)cropViewController {
    [cropViewController dismissViewControllerAnimated:YES completion:^{
        [UIViewController swizzleShouldAutorotate];
    }];
}

- (void)cropViewController:(EZCropController *)cropViewController 
                 didCropTo:(UIImage *)image 
                      with:(CGRect)cropRect 
                     angle:(enum EZCropRotation)angle
{
    // `image` is cropped
    // `cropRect` is in the original coordinate of original image
    // `angle` The direction of cropped image
}
```
</details>

<details>
  <summary>Initializes cropping in a specific rect and rotation</summary>

#### Swift
```swift
- func showCropController()
{
    let image : UIImage = ... 
    let rect : CGRect = ...
    let angle : EZCropRotation = ...
    let cropViewController = EZCropController(image: image, cropRect: rect, angle: angle)
    cropViewController.delegate = self
    UIViewController.swizzleShouldAutorotate()
    self.present(cropViewController, animated: true, completion: nil)

}
```

#### Objective-C

```objc
- (void)showCropController
{
    UIImage *image = ... 
    CGRect rect = ...
    EZCropRotation angle = ...
    EZCropController* cropController = [[EZCropController alloc] initWithImage:image
                                                                      cropRect:rect
                                                                         angle:angle];
    cropController.delegate = self;
    [UIViewController swizzleShouldAutorotate];
    [self presentViewController:cropController animated:YES completion:nil];
}
```
</details>

Please explore more detail of example in **EZCropExample**
