//
//  DropListViewControllerTests.swift
//  ChartTests
//
//  Created by Aleksandr Makarov on 26.07.2018.
//  Copyright © 2018 Aleksandr Makarov. All rights reserved.
//

import XCTest
@testable import Chart

class DropListViewControllerTests: XCTestCase {

    var dropList: DropListViewController!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        /// пустой запуск
        self.dropList = DropListViewController()
        self.dropList.viewDidLoad()

        /// запуск с данными
        self.dropList = DropListViewController()
        self.dropList.setDataSource(["YIELD", "PRICE"])
        self.dropList.selectedRow = { (row) in }
        self.dropList.textLabelFont = UIFont.systemFont(ofSize: 12)
        self.dropList.viewDidLoad()

        /// запуск с пустым массивом
        self.dropList.setDataSource([])
        self.dropList.viewDidLoad()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

        self.dropList = nil
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
