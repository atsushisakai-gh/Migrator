//
//  MigrationHandler.swift
//  Pods
//
//  Created by 酒井篤 on 2015/09/14.
//
//

import UIKit

public class MigrationHandler: NSObject {
    
    var targetVersion: String
    
    var handler: () -> ()
    
    public init(targetVersion: String, handler: () -> ()) {
        self.targetVersion = targetVersion
        self.handler = handler
    }
    
    public func migrate() {
        self.handler()
    }
}
