//
//  LineChartTests.swift
//  ChartTests
//
//  Created by Aleksandr Makarov on 26.07.2018.
//  Copyright © 2018 Aleksandr Makarov. All rights reserved.
//

import XCTest
@testable import Chart

class LineChartTests: XCTestCase {

    var lineChart: LineChart!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        let data: [CGFloat] = [3, 4, 8, 11, 13, 15]
        let data2: [CGFloat] = [1, 3, 5, 5, 17, 20]
        let data3: [CGFloat] = [1, 3, -5, -6, -17, 10, 20, 0]
        let xLabels: [String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]

        /// пустой запуск
        self.lineChart = LineChart()
        self.lineChart.draw(UIScreen.main.bounds)

        /// запуск с данными
        self.lineChart.x.labels.visible = true
        self.lineChart.x.grid.count = 5
        self.lineChart.y.grid.count = 5
        self.lineChart.x.labels.values = xLabels
        self.lineChart.y.labels.visible = true
        self.lineChart.addLine(data)
        self.lineChart.addLine(data2)
        self.lineChart.addLine(data3)
        self.lineChart.draw(UIScreen.main.bounds)

        /// метод
        self.lineChart.clearAll()

        /// запуск с пустым массивом
        self.lineChart.addLine([])
        self.lineChart.x.labels.values = []
        self.lineChart.draw(UIScreen.main.bounds)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

        self.lineChart = nil
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
