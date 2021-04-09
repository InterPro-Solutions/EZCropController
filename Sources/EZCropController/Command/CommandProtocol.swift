//
//  File.swift
//  
//
//  Created by Xiang Li on 3/26/21.
//

import UIKit
import Combine

internal protocol CommandProtocol : AnyObject {
    func execute(_ gesture:UIGestureRecognizer?, params:Dictionary<String,Any>?);
    func undo();
}

