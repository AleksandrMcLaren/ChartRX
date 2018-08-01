//
//  ViewController.swift
//  Chart
//
//  Created by Aleksandr Makarov on 27.07.2018.
//  Copyright © 2018 Aleksandr Makarov. All rights reserved.
//

import UIKit

/** Пример использования LineChartViewController */

class ViewController: UIViewController {

    let lineChart = LineChartViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addChildViewController(self.lineChart)
        self.view.addSubview(self.lineChart.view)

        addViewConstraints()

        self.lineChart.isin = "12345"
    }

    func addViewConstraints() {
        let guide = self.view.safeAreaLayoutGuide

        self.lineChart.view.translatesAutoresizingMaskIntoConstraints = false
        self.lineChart.view.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        self.lineChart.view.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        self.lineChart.view.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        self.lineChart.view.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
    }
}

