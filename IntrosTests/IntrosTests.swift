//
//  IntrosTests.swift
//  IntrosTests
//
//  Created by Ben Navetta on 1/7/16.
//  Copyright © 2016 Ben Navetta. All rights reserved.
//

import XCTest
@testable import Intros

class IntrosTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSetup() {
        XCTAssertTrue(AppSetup.test, "Should be in test mode")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
