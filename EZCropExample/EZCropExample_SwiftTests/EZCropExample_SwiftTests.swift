//
//  EZCropExample_SwiftTests.swift
//  EZCropExample_SwiftTests
//
//  Created by Xiang Li on 4/26/21.
//

import XCTest
import UIKit
import EZCropController
class EZCropExample_SwiftTests: XCTestCase {
    func testInitializeVC() throws {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 10, height: 10), false, 1.0)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 10, height: 10));
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        let controller = EZCropController(image: image!)
        let view = controller.view;
        XCTAssertNotNil(view);
    }

    func testInitializeVCWithCropRectAndRotation() throws {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 10, height: 10), false, 1.0)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 10, height: 10));
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        let controller = EZCropController(image: image!, cropRect: CGRect(x: 2, y: 2, width: 3, height: 3), angle: .twoHunderdAndSeventy)
        let view = controller.view;
        XCTAssertNotNil(view);
    }

}
