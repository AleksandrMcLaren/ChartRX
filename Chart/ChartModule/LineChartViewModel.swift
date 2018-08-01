//
//  LineChartViewModel.swift
//
//  Created by Aleksandr Makarov on 27.07.2018.
//  Copyright © 2018 Aleksandr Makarov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol LineChartViewModelPresentable: class {
    /// Данные выпадающего списка.
    var dropListTitles: BehaviorRelay<[String]> { get set }
    /// Данные кнопок периодов.
    var bottomButtonTitles: BehaviorRelay<[String]> { get set }
    /// Текущий индекс периода.
    var bottomButtonsIndex: BehaviorRelay<Int> { get set }
    /// Данные лейб по оси x
    var xAxisTitles: BehaviorRelay<[String]> { get set }
    /// Данные графика.
    var chartData: BehaviorRelay<[CGFloat]> { get set }
    /// Процесс загрузки данных.
    var isLoading: BehaviorRelay<Bool> { get set }

    /// Получить данные.
    func fetchData(isin: String)
    /// Сообщает о новом выбранном индексе выпадающего списка.
    func dropListSelected(_ index: Int)
    /// Сообщает о новом выбранном индексе кнопок периодов.
    func bottomButtonsSelected(_ index: Int)
}

class LineChartViewModel: LineChartViewModelPresentable {

    // MARK: - LineChartViewModelPresentable

    public var dropListTitles: BehaviorRelay<[String]> = BehaviorRelay.init(value: [])
    public var bottomButtonTitles: BehaviorRelay<[String]> = BehaviorRelay.init(value: [])
    public var bottomButtonsIndex: BehaviorRelay<Int> = BehaviorRelay.init(value: 0)
    public var xAxisTitles: BehaviorRelay<[String]> = BehaviorRelay.init(value: [])
    public var chartData: BehaviorRelay<[CGFloat]> = BehaviorRelay.init(value: [])
    public var isLoading: BehaviorRelay<Bool> = BehaviorRelay.init(value: false)

    public func fetchData(isin: String) {
        /// симулируем запрос данных
        self.isLoading.accept(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.downloadData(isin: isin, completion: { [weak self] in
                self?.isLoading.accept(false)
            })
        }
    }

    public func dropListSelected(_ index: Int) {
        self.state.dropListIndex = index
        performCurrentData()
    }

    public func bottomButtonsSelected(_ index: Int) {
        self.state.bottomButtonsIndex = index
        performCurrentData()
    }

    // MARK: -

    /// Хранит списки данных.
    fileprivate var listData = [ChartListData]()
    /// Хранит по умолчанию/выбранные пользователем состояния кнопок.
    fileprivate var state = LineChartState()
    /// Применить данные по текущим состояниям.
    fileprivate func performCurrentData() {
        if self.state.dropListIndex < self.listData.count {
            let currentListData = self.listData[self.state.dropListIndex]
            if self.state.bottomButtonsIndex < currentListData.dataPeriods.count {
                let currentData = currentListData.dataPeriods[self.state.bottomButtonsIndex]
                self.xAxisTitles.accept(currentData.xAxisTitles)
                self.chartData.accept(currentData.dataPoint)
            }
        }
    }
}

extension LineChartViewModel {

    func downloadData(isin: String, completion: (() -> Void)?) {
        let parseQueue = DispatchQueue(label: "LineChartViewModel.downloadData")
        parseQueue.async {
            /// создадим данные кнопок
            let dropListTitles = ["YIELD", "PRICE"]
            let bottomButtonTitles = ["1W", "1M", "3M", "6M", "1Y", "2Y"]
            /// создадим данные графиков
            let yield = ChartListData()
            let price = ChartListData()
            self.listData.append(yield)
            self.listData.append(price)
            /// отправим данные контроллеру
            DispatchQueue.main.async {
                self.dropListTitles.accept(dropListTitles)
                self.bottomButtonTitles.accept(bottomButtonTitles)
                self.bottomButtonsIndex.accept(0)
                self.performCurrentData()
                completion?()
            }
        }
    }
}
