//
//  EZCropExample_OCTests.m
//  EZCropExample_OCTests
//
//  Created by Xiang Li on 4/26/21.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
@import EZCropController;
@interface EZCropExample_OCTests : XCTestCase

@end

@implementation EZCropExample_OCTests

- (void)testInitializeVC {
    UIGraphicsBeginImageContextWithOptions((CGSize){10, 10}, NO, 1.0f);
    CGContextFillRect(UIGraphicsGetCurrentContext(), (CGRect){0,0,10,10});
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    EZCropController* controller = [[EZCropController alloc]initWithImage:image];
    UIView *view = controller.view;
    XCTAssertNotNil(view);
}

- (void)testInitializeVCWithCropRectAndRotation {
    UIGraphicsBeginImageContextWithOptions((CGSize){10, 10}, NO, 1.0f);
    CGContextFillRect(UIGraphicsGetCurrentContext(), (CGRect){0,0,10,10});
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    EZCropController* controller = [[EZCropController alloc] initWithImage:image cropRect:(CGRect){2,2,3,3} angle:EZCropRotationOneHundredAndEighty];
    UIView *view = controller.view;
    XCTAssertNotNil(view);
}

@end
