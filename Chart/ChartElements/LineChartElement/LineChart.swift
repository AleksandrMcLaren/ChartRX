//
//  LineChart.swift
//
//  Created by Aleksandr Makarov on 24.07.2018.
//  Copyright © 2018 Aleksandr Makarov. All rights reserved.
//

import UIKit
import QuartzCore

/** Класс реализует линейный график */

protocol LineChartViewPresentable {
    /// Конфигурация лейб вершин графиков.
    associatedtype DotLabels
    var dotLabels: DotLabels { get set }
    /// Ширина линии графика.
    var lineWidth: CGFloat { get set }
    /// Цвета линий графиков.
    var colors: [UIColor] { get set }
    /// Конфигурация значений по оси x.
    associatedtype Coordinate
    var x: Coordinate { get set }
    /// Конфигурация значений по оси y.
    var y: Coordinate { get set }
    /** Добавляет данные вершин графика. Рисует график.
        Можно добавлять более одного массива данных графика. */
    func addLine(_ data: [CGFloat])
    /// Чистит данные, стирает линии.
    func clearAll()
}

open class LineChart: UIView, LineChartViewPresentable {

    // MARK: - LineChartViewPresentable

    /// Конфигурация по умолчанию.
    open var dotLabels = DotLabels()
    open var lineWidth: CGFloat = 2

    open var x: Coordinate = Coordinate()
    open var y: Coordinate = Coordinate()

    /// Цвета линий.
    open var colors: [UIColor] = [
        UIColor(red:0.83, green:0.46, blue:0.51, alpha:1.00),
        UIColor(red: 0.121569, green: 0.466667, blue: 0.705882, alpha: 1),
        UIColor(red: 1, green: 0.498039, blue: 0.054902, alpha: 1),
        UIColor(red: 0.172549, green: 0.627451, blue: 0.172549, alpha: 1),
        UIColor(red: 0.839216, green: 0.152941, blue: 0.156863, alpha: 1),
        UIColor(red: 0.580392, green: 0.403922, blue: 0.741176, alpha: 1),
        UIColor(red: 0.54902, green: 0.337255, blue: 0.294118, alpha: 1),
        UIColor(red: 0.890196, green: 0.466667, blue: 0.760784, alpha: 1),
        UIColor(red: 0.498039, green: 0.498039, blue: 0.498039, alpha: 1),
        UIColor(red: 0.737255, green: 0.741176, blue: 0.133333, alpha: 1),
        UIColor(red: 0.0901961, green: 0.745098, blue: 0.811765, alpha: 1)
    ]

    /// Добавляет данные виршин графика.
    public func addLine(_ data: [CGFloat]) {
        self.dataStore.append(data)
        self.setNeedsDisplay()
    }

    /// Чистит данные, стирает линии.
    public func clearAll() {
        self.dataStore.removeAll()
        self.setNeedsDisplay()
    }

    // MARK: -

    public struct Labels {
        public var visible: Bool = true
        public var values: [String] = []
        public var textFont = UIFont.boldSystemFont(ofSize: 12)
        public var textColor = UIColor(red:0.16, green:0.16, blue:0.16, alpha:1.00)
    }
    
    public struct Grid {
        public var count: Int = 10
        public var color: UIColor = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.00)
    }
    
    public struct Axis {
        public var insets = UIEdgeInsets(top: 65, left: 40, bottom: 50, right: 25)
    }
    
    public struct Coordinate {
        public var labels: Labels = Labels()
        public var grid: Grid = Grid()
        public var axis: Axis = Axis()

        fileprivate var linear: LinearScale!
        fileprivate var scale: ((CGFloat) -> CGFloat)!
        fileprivate var invert: ((CGFloat) -> CGFloat)!
        fileprivate var ticks: (CGFloat, CGFloat, CGFloat)!
    }

    public struct DotLabels {
        public var visible: Bool = true
        public var textFont = UIFont.boldSystemFont(ofSize: 12)
        public var textColor = UIColor(red:0.16, green:0.16, blue:0.16, alpha:1.00)
        public var textStrokeColor = UIColor.white
    }

    /// Величины вычесляются при инициализации.
    fileprivate var drawingHeight: CGFloat = 0 {
        didSet {
            let max = getMaximumValue()
            let min = getMinimumValue()
            self.y.linear = LinearScale(domain: [min, max], range: [0, drawingHeight])
            self.y.scale = self.y.linear.scale()
            self.y.ticks = self.y.linear.ticks(self.y.grid.count)
        }
    }
    fileprivate var drawingWidth: CGFloat = 0 {
        didSet {
            let dataCount = (dataStoreExistValue() ? dataStore[0].count : 0)
            self.x.linear = LinearScale(domain: [0.0, CGFloat(dataCount - 1)], range: [0, drawingWidth])
            self.x.scale = self.x.linear.scale()
            self.x.invert = self.x.linear.invert()
            self.x.ticks = self.x.linear.ticks(self.x.grid.count)
        }
    }
    
    /// Хранит данные вершин.
    fileprivate var dataStore: [[CGFloat]] = []
    /// Хранит линии.
    fileprivate var lineLayerStore: [CAShapeLayer] = []
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func draw(_ rect: CGRect) {

        let context = UIGraphicsGetCurrentContext()
        context?.clear(rect)

        self.drawingHeight = self.bounds.height - (self.y.axis.insets.top + self.y.axis.insets.bottom)
        self.drawingWidth = self.bounds.width - (self.x.axis.insets.left + self.x.axis.insets.right)
        
        /// стерем labels
        self.subviews.forEach({ $0.removeFromSuperview() })

        /// стерем линии
        self.lineLayerStore.forEach({ $0.removeFromSuperlayer() })
        self.lineLayerStore.removeAll()

        guard dataStoreExistValue() else {
            /// нет данных, ничего не рисуем
            return
        }

        /// нарисуем сетку
        drawGrid()

        /// нарисуем оси
        if self.x.labels.visible {
            drawXAxisLabels()
        }

        if self.y.labels.visible {
            drawYAxisLabels()
        }

        /// нарисуем линии графиков
        for (lineIndex, _) in self.dataStore.enumerated() {
            drawLine(lineIndex)
        }

        /// нарисуем лейбы вершин графиков
        if self.dotLabels.visible {
            for (lineIndex, _) in self.dataStore.enumerated() {
                drawDotLabels(lineIndex)
            }
        }

        /// нарисуем нижнюю линию
        drawBottomLine()
    }

    /// Рисует линию графика.
    fileprivate func drawLine(_ lineIndex: Int) {
        guard lineIndex < self.dataStore.count, !self.dataStore[lineIndex].isEmpty else {
            return
        }

        let data = self.dataStore[lineIndex]
        let path = UIBezierPath()
        let yBottom = self.bounds.height - self.y.axis.insets.bottom

        var xValue = self.x.scale(0) + self.x.axis.insets.left
        var yValue = yBottom - self.y.scale(data[0])
        path.move(to: CGPoint(x: xValue, y: yValue))

        for index in 1..<data.count {
            xValue = self.x.scale(CGFloat(index)) + self.x.axis.insets.left
            yValue = yBottom - self.y.scale(data[index])
            path.addLine(to: CGPoint(x: xValue, y: yValue))
        }
        
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = path.cgPath
        layer.strokeColor = (lineIndex < colors.count ? colors[lineIndex].cgColor : UIColor.black.cgColor)
        layer.fillColor = nil
        layer.lineWidth = lineWidth
        self.layer.addSublayer(layer)

        self.lineLayerStore.append(layer)
    }

    /// Рисует сетку.
    fileprivate func drawGrid() {
        drawXGrid()
        drawYGrid()
    }

    /// Рисует линии сетки по оси x.
    fileprivate func drawXGrid() {
        let path = UIBezierPath()
        var x1: CGFloat
        let y1: CGFloat = self.bounds.height
        let y2: CGFloat = 0
        let (start, stop, step) = self.x.ticks
        for i in stride(from: start, through: stop, by: step){
            x1 = self.x.scale(i) + self.x.axis.insets.left
            path.move(to: CGPoint(x: x1, y: y1))
            path.addLine(to: CGPoint(x: x1, y: y2))
        }

        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = path.cgPath
        layer.strokeColor = self.x.grid.color.cgColor
        layer.fillColor = nil
        self.layer.addSublayer(layer)

        self.lineLayerStore.append(layer)
    }

    /// Рисует линии сетки по оси y.
    fileprivate func drawYGrid() {
        let path = UIBezierPath()
        let x1: CGFloat = 0
        let x2: CGFloat = self.bounds.width

        let min = getMinimumValue()
        var y1: CGFloat = self.bounds.height - self.y.scale(min) - self.y.axis.insets.bottom
        path.move(to: CGPoint(x: x1, y: y1))
        path.addLine(to: CGPoint(x: x2, y: y1))

        if dataStoreExistValue() {
            let (start, stop, step) = self.y.ticks
            for i in stride(from: start, through: stop, by: step){
                y1 = self.bounds.height - self.y.scale(i) - self.y.axis.insets.bottom
                path.move(to: CGPoint(x: x1, y: y1))
                path.addLine(to: CGPoint(x: x2, y: y1))
            }
        }

        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.path = path.cgPath
        layer.strokeColor = self.y.grid.color.cgColor
        layer.fillColor = nil
        self.layer.addSublayer(layer)

        self.lineLayerStore.append(layer)
    }

    /// Добавляет лейбы по оси x.
    fileprivate func drawXAxisLabels() {
        guard dataStoreExistValue() else {
            return
        }

        let xAxisData = self.dataStore[0]
        let (_, _, step) = self.x.linear.ticks(xAxisData.count)
        let width = self.x.scale(step)
        let height = self.x.labels.textFont.lineHeight
        let x = self.x.axis.insets.left - (width / 2)
        let y = self.bounds.height - height - 12

        for (index, _) in xAxisData.enumerated() {
            let xValue = x + self.x.scale(CGFloat(index))
            let label = UILabel(frame: CGRect(x: xValue, y: y, width: width, height: height))
            label.font = self.x.labels.textFont
            label.textColor = self.x.labels.textColor
            label.textAlignment = .center
            label.text = (index < self.x.labels.values.count ? self.x.labels.values[index] : "")
            self.addSubview(label)
        }
    }

    /// Добавляет лейбы по оси y.
    fileprivate func drawYAxisLabels() {
        let width = self.y.axis.insets.left - 3
        let yBottom = self.bounds.height - self.y.axis.insets.bottom * 1.5

        let min = getMinimumValue()
        var yValue = yBottom - self.y.scale(min)
        let frame = CGRect(x: 0, y: yValue, width: width, height: self.y.axis.insets.bottom)
        drawYLabel(frame: frame, value: min)

        if dataStoreExistValue() {
            let (start, stop, step) = self.y.ticks
            for i in stride(from: start, through: stop, by: step){
                yValue = yBottom - self.y.scale(i)
                let frame = CGRect(x: 0, y: yValue, width: width, height: self.y.axis.insets.bottom)
                drawYLabel(frame: frame, value: i)
            }
        }
    }
    
    fileprivate func drawYLabel(frame: CGRect, value: CGFloat) {
        let label = UILabel(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height))
        label.font = self.y.labels.textFont
        label.textColor = self.y.labels.textColor
        label.textAlignment = .right
        label.text = String(Int(round(value)))
        self.addSubview(label)
    }

    /// Добавляет описание вершин графиков.
    fileprivate func drawDotLabels(_ lineIndex: Int) {
        guard lineIndex < self.dataStore.count, !self.dataStore[lineIndex].isEmpty else {
            return
        }

        var data = self.dataStore[lineIndex]
        let yBottom = self.bounds.height - self.y.axis.insets.bottom - 2
        for index in 1..<data.count {
            let value = data[index]

            let label = DotLabel()
            label.textFont = self.dotLabels.textFont
            label.color = self.dotLabels.textColor
            label.strokeColor = self.dotLabels.textStrokeColor
            label.text = value.description
            label.sizeToFit()
            
            let xValue = self.x.scale(CGFloat(index)) + self.x.axis.insets.left - label.frame.width / 2
            let yValue = yBottom - self.y.scale(value) - label.frame.height

            label.frame.origin = CGPoint(x: xValue, y: yValue)
            self.addSubview(label)
        }
    }

    /// Рисует нижнюю линию границу.
    fileprivate func drawBottomLine() {
        self.x.grid.color.setStroke()

        let x1: CGFloat = 0
        let x2: CGFloat = self.bounds.width
        let y: CGFloat = self.bounds.height

        let path = UIBezierPath()
        path.move(to: CGPoint(x: x1, y: y))
        path.addLine(to: CGPoint(x: x2, y: y))
        path.stroke()
    }

    /// Возвращает максимальное значение данных.
    fileprivate func getMaximumValue() -> CGFloat {
        guard dataStoreExistValue() else {
            return 0
        }

        var max: CGFloat = 1
        for data in self.dataStore {
            if let newMax = data.max(), newMax > max {
                max = newMax
            }
        }
        return max
    }

    /// Возвращает минимальное значение данных.
    fileprivate func getMinimumValue() -> CGFloat {
        guard dataStoreExistValue() else {
            return 0
        }

        var min: CGFloat = CGFloat.greatestFiniteMagnitude
        for data in self.dataStore {
            if let newMin = data.min(), newMin < min {
                min = newMin
            }
        }
        return min
    }

    /// Проверка что в хранилище есть хоть одно значение.
    func dataStoreExistValue() -> Bool {
        if !self.dataStore.isEmpty, let first = self.dataStore.first, !first.isEmpty {
            return true
        } else {
            return false
        }
    }
}
