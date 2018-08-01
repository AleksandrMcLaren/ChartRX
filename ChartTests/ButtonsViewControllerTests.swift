//
//  ButtonsViewControllerTests.swift
//  ChartTests
//
//  Created by Aleksandr Makarov on 26.07.2018.
//  Copyright © 2018 Aleksandr Makarov. All rights reserved.
//

import XCTest
@testable import Chart

class ButtonsViewControllerTests: XCTestCase {

    var buttons: ButtonsViewController!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        /// пустой запуск
        self.buttons = ButtonsViewController()
        self.buttons.viewDidLoad()

        /// запуск с данными
        self.buttons.dataSource = ["1W", "1M", "3M", "6M", "1Y", "2Y"]
        self.buttons.currentIndex = 0
        self.buttons.selectedIndex = { (index) in }
        self.buttons.uiButtons.font = UIFont.systemFont(ofSize: 12)
        self.buttons.uiButtons.normalColor = .black
        self.buttons.uiButtons.selectedColor = .white
        self.buttons.viewDidLoad()

        /// запуск с пустым массивом, выход за индекс массива
        self.buttons.dataSource = []
        self.buttons.currentIndex = 2
        self.buttons.viewDidLoad()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

        self.buttons = nil
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
