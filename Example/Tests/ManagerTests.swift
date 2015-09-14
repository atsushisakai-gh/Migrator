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

// Mocking
class ManagerMock : Manager {
    override func currentVersion() -> String {
        return "1.0.0"
    }
}

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
    
    func testShouldMigrateIsFalseBecauseEqual() {
        var managerMock: ManagerMock = ManagerMock()
        managerMock.setInitialVersion("0.0.9")
        XCTAssertFalse(managerMock.shouldMigrate() == true)
    }

    func testShouldMigrateIsFalseBecauseLess() {
        var managerMock: ManagerMock = ManagerMock()
        managerMock.setInitialVersion("1.0.0")
        XCTAssertFalse(managerMock.shouldMigrate() == true)
    }
    func testShouldMigrate() {
        var managerMock: ManagerMock = ManagerMock()
        managerMock.setInitialVersion("1.0.1")
        XCTAssertTrue(managerMock.shouldMigrate() == true)
    }
    
    func testMigrateHandlerSimply() {
        var migrated: Bool = false;
        
        let handler: MigrationHandler =  MigrationHandler(
            targetVersion: "2.0.0",
            handler: { () -> () in migrated = true }
        )
        manager.registerHandler(handler)
        manager.migrate()
        XCTAssertTrue(migrated)
    }
}
