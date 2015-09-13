//
//  ManagerTests.swift
//  Migrator
//
//  Created by 酒井篤 on 2015/09/13.
//  Copyright (c) 2015年 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import Migrator

class ManagerTests: XCTestCase {
    
    let manager: Manager = Manager()

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        manager.reset()
    }

    func testLastMigratedVersionIsEmpty() {
        let lastVer = manager.lastMigratedVersion()
        XCTAssertTrue(lastVer == "")
    }
    
    func testLastMigratedVersionIsSaved() {
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("1.0.0", forKey: "com.radioboo.migratorLastVersionKey")
        defaults.synchronize()
        
        XCTAssertTrue(manager.lastMigratedVersion() == "1.0.0")
    }
    
    func testInitialVersionIsSaved() {
        manager.setInitialVersion("2.0.0")
        XCTAssertTrue(manager.lastMigratedVersion() == "2.0.0")

        manager.setInitialVersion("4.0.0")
        XCTAssertTrue(manager.lastMigratedVersion() == "2.0.0")
    }

}
