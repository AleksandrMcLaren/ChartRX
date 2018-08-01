//
//  LineChartModel.swift
//
//  Created by Aleksandr Makarov on 27.07.2018.
//  Copyright © 2018 Aleksandr Makarov. All rights reserved.
//

import UIKit

/// Состояния кнопок.
struct LineChartState {
    var dropListIndex: Int = 0
    var bottomButtonsIndex: Int = 0
}

/// Данные одного из выбранных состояний.
struct LineChartModel {
    var dataPoint = [CGFloat]()
    var xAxisTitles = [String]()
}

/// Список данных. Содержит данные по периодам.
struct ChartListData {
    var dataPeriods = [LineChartModel]()

    init() {
        fillData()
    }
}

extension ChartListData {

    /** Заполним данные рандомно */

    mutating func fillData() {
        createWeekData()
        create1MonthData()
        create3MonthData()
        create6MonthData()
        create1YearData()
        create2YearData()
    }

    mutating func createWeekData() {
        var periodData = LineChartModel()
        periodData.xAxisTitles = ["23.07", "24.07", "25.07", "26.07", "27.07", "28.07", "29.07"]
        periodData.dataPoint = genRandomCount(7)
        self.dataPeriods.append(periodData)
    }

    mutating func create1MonthData() {
        var periodData = LineChartModel()
        periodData.xAxisTitles = ["", "", "", "", "", "", "",
                                  "", "", "", "", "", "", ""]
        periodData.dataPoint = genRandomCount(31)
        self.dataPeriods.append(periodData)
    }

    mutating func create3MonthData() {
        var periodData = LineChartModel()
        periodData.xAxisTitles = ["05", "06", "07"]
        periodData.dataPoint = genRandomCount(3)
        self.dataPeriods.append(periodData)
    }

    mutating func create6MonthData() {
        var periodData = LineChartModel()
        periodData.xAxisTitles = ["02", "03", "04", "05", "06", "07"]
        periodData.dataPoint = genRandomCount(6)
        self.dataPeriods.append(periodData)
    }

    mutating func create1YearData() {
        var periodData = LineChartModel()
        periodData.xAxisTitles = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
        periodData.dataPoint = genRandomCount(12)
        self.dataPeriods.append(periodData)
    }

    mutating func create2YearData() {
        var periodData = LineChartModel()
        periodData.xAxisTitles = ["", "", "", "", "", "", "", "", "", "", "", ""]
        periodData.dataPoint = genRandomCount(24)
        self.dataPeriods.append(periodData)
    }
}

extension ChartListData {

    func genRandomCount(_ count: Int) -> [CGFloat] {
        var rr = [CGFloat]()
        for _ in 0..<count {
            let point = genRandom(min: 1.5, max: 100)
            let roundPoint = point.roundTo(places: 2)
            rr.append(CGFloat(roundPoint))
        }

        return rr
    }

    func genRandom(min: Double, max: Double) -> Double {
        return Double(arc4random()) / 0xFFFFFFFF * (max - min) + min
    }
}

extension Double {
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
