//
//  ButtonsViewController.swift
//
//  Created by Aleksandr Makarov on 25.07.2018.
//  Copyright © 2018 Aleksandr Makarov. All rights reserved.
//

import UIKit

/** Класс реализует горизонтальный список кнопок.
    Список реализован через UIStackView с UIButton.
    Принимает заголовки кнопок через dataSource:
    Сообщает о выбранном индексе в selectedIndex: */

protocol ButtonsPresentable {
    /// Заголовки кнопок. Количество кнопок соответсвует количеству заголовков.
    var dataSource: [String] { get set }
    /// Конфигурация кнопок.
    associatedtype UIButtons
    var uiButtons: UIButtons { get set }
    /// getter подсветит кнопку по индексу. setter вернет текущий индекс.
    var currentIndex: Int { get set }
    /// Сообщит о выбранном индексе.
    var selectedIndex: ((_ index: Int) -> Void)? { get set }
}

class ButtonsViewController: UIViewController, ButtonsPresentable {

    // MARK: - ButtonsPresentable

    public var dataSource = [String]() {
        didSet {
            createButtons()
            createStackViewWithButtons()
        }
    }
    public var selectedIndex: ((_ index: Int) -> Void)?
    public var currentIndex: Int = 0 {
        didSet {
            self.highlightedButton(with: self.currentIndex)
        }
    }

    public struct  UIButtons {
        public var normalColor = UIColor(red:0.16, green:0.16, blue:0.16, alpha:1.00)
        public var selectedColor = UIColor(red:0.50, green:0.59, blue:0.80, alpha:1.00)
        public var font = UIFont.boldSystemFont(ofSize: 12)
    }

    /// Конфигурация по умолчанию.
    open var uiButtons = UIButtons()

    // MARK: -

    fileprivate var listButtons = [UIButton]()
    fileprivate var stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear

        view.addSubview(self.stackView)
        addViewConstraints()

        /// подсветим нужный индекс при старте
        highlightedButton(with: self.currentIndex)
    }

    fileprivate func addViewConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.stackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }

    fileprivate func createButtons() {
        listButtons.removeAll()

        for title in self.dataSource {
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.setTitleColor(uiButtons.normalColor, for: .normal)
            button.setTitleColor(uiButtons.selectedColor, for: .selected)
            button.titleLabel?.font = uiButtons.font
            button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
            button.isExclusiveTouch = true
            listButtons.append(button)
        }
    }

    fileprivate func createStackViewWithButtons() {
        self.stackView.removeAllArrangedSubviews()

        self.stackView.alignment = .fill
        self.stackView.distribution = .fillEqually
        self.stackView.axis = .horizontal
        self.stackView.spacing = 1.0

        for button in self.listButtons {
            self.stackView.addArrangedSubview(button)
        }
    }

    @objc fileprivate func tapped(sender: UIButton) {
        if let index = self.listButtons.index(of: sender) {
            self.currentIndex = index
            /// дадим кнопке сменить состояние, затем отправим сообщение
            DispatchQueue.main.async {
                self.selectedIndex?(index)
            }
        }
    }

    /// Выделяет кнопку по индексу, сбрасывает выделение остальных.
    fileprivate func highlightedButton(with index: Int) {
        for (i, button) in self.listButtons.enumerated() {
            button.isSelected = (i == index ? true : false)
        }
    }
}

extension UIStackView {

    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }

        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}
