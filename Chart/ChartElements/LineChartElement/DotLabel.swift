//
//  DotLabel.swift
//
//  Created by Aleksandr Makarov on 24.07.2018.
//  Copyright © 2018 Aleksandr Makarov. All rights reserved.
//

import UIKit

class DotLabel: UILabel {

    public var textFont = UIFont.boldSystemFont(ofSize: 11)
    public var color = UIColor.black
    public var strokeColor = UIColor.white

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /// нарисуем обводку к символам
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }

        ctx.setLineWidth(2);

        ctx.setLineJoin(CGLineJoin.round)
        ctx.setTextDrawingMode(CGTextDrawingMode.stroke)
        self.textColor = strokeColor
        super.drawText(in: rect)

        ctx.setTextDrawingMode(CGTextDrawingMode.fill)
        self.textColor = color
        self.shadowOffset = CGSize(width: 0, height: 0)
        super.drawText(in: rect)
    }

    fileprivate func configure() {
        font = textFont
    }
}
