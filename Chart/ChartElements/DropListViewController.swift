//
//  DropListViewController.swift
//
//  Created by Aleksandr Makarov on 25.07.2018.
//  Copyright © 2018 Aleksandr Makarov. All rights reserved.
//

import UIKit

/** Класс реализует выпадающий список.
    Список реализован через UITableView.
    Принимает заголовки строк таблицы через dataSource:
    Сообщает о выбранной строке в selectedRow: */

protocol DropListPresentable {
    /// Шрифт строк.
    var textLabelFont: UIFont { get set }
    /// Сообщит о выбранной строке.
    var selectedRow: ((_ row: Int) -> Void)? { get set }
    /** Максимальная высота открытого списка, чтобы не выйти за границы экрана.
     Если контент открытой таблицы больше maxHeight, включится скролл таблицы. */
    var maxHeight: CGFloat? { get set }
    /// Задает массив строк списка.
    var dataSource: [String]? { get set }
    /// Закрывает список. Можно вызвать, например, после изменения ориентации устроства.
    func hide()
}

class DropListViewController: UIViewController, DropListPresentable {

    // MARK: - DropListPresentable

    public var dataSource: [String]? {
        didSet {
            self.tableSource = dataSource ?? [String]()
            self.tableView.reloadData()
            /// для новых данных возьмем новую высоту
            self.viewHeight.max = CGFloat(tableSource.count) * self.viewHeight.min
        }
    }

    public var selectedRow: ((_ row: Int) -> Void)?
    public var textLabelFont = UIFont.boldSystemFont(ofSize: 12)
    public var maxHeight: CGFloat?

    public func hide() {
        if self.isDrop {
            hideList()
        }
    }

    // MARK: -

    fileprivate var tableSource = [String]()
    fileprivate var isDrop = false
    fileprivate let cellId = "cell"
    fileprivate let shadowView: UIView = UIView()
    fileprivate var heightShadowConstraint: NSLayoutConstraint!
    fileprivate var heightTableConstraint: NSLayoutConstraint!

    fileprivate struct ViewHeight {
        var min: CGFloat = 0
        var max: CGFloat = 0
    }

    fileprivate var viewHeight = ViewHeight()

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.layer.masksToBounds = true
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1)) /// уберем разделитель последней  ячейки
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(shadowView)
        self.shadowView.addSubview(self.tableView)
        addViewConstraints()

        configureView()
        configureShadow()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if self.viewHeight.min == 0 {
            /// при первом фрейме обновим высоты
            self.viewHeight.min = self.view.bounds.height
            self.viewHeight.max = CGFloat(self.tableSource.count) * self.viewHeight.min
            /// обновим ограничения
            self.heightShadowConstraint.constant = self.viewHeight.min
            self.heightTableConstraint.constant = self.viewHeight.min
            /// сделаем радиус таблицы
            self.tableView.layer.cornerRadius = self.viewHeight.min / 2
        }
    }

    fileprivate func addViewConstraints() {
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        self.shadowView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.shadowView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.shadowView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.heightShadowConstraint = shadowView.heightAnchor.constraint(equalToConstant: 0)
        self.heightShadowConstraint.isActive = true

        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: self.shadowView.topAnchor).isActive = true
        self.tableView.leadingAnchor.constraint(equalTo: self.shadowView.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.shadowView.trailingAnchor).isActive = true
        self.heightTableConstraint = self.tableView.heightAnchor.constraint(equalToConstant: 0)
        self.heightTableConstraint.isActive = true
    }

    fileprivate func configureView() {
        self.view.backgroundColor = .clear
        self.view.layer.masksToBounds = false
    }

    fileprivate func configureShadow() {
        shadowView.backgroundColor = UIColor.clear
        shadowView.layer.shadowColor = UIColor.darkGray.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2.5)
        shadowView.layer.shadowOpacity = 0.4
        shadowView.layer.shadowRadius = 4.0
    }

    // MARK: - Управление списком

    /// Открывает список.
    fileprivate func dropList() {
        guard let paths = dropRowPaths() else {
            return
        }

        self.isDrop = true

        var needsScroll = false
        var maxViewHeight = self.viewHeight.max
        if let maxHeight = self.maxHeight, maxViewHeight > maxHeight {
            maxViewHeight = maxHeight
            needsScroll = true
        }

        self.heightShadowConstraint.constant = maxViewHeight
        self.heightTableConstraint.constant = maxViewHeight
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame.size = CGSize(width: self.view.frame.width, height: maxViewHeight)
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.tableView.isScrollEnabled = needsScroll
        }

        self.tableView.beginUpdates()
        self.tableView.insertRows(at: paths, with: .automatic)
        self.tableView.endUpdates()
    }

    /// Закрывает список.
    fileprivate func hideList() {
        guard let paths = dropRowPaths() else {
            return
        }

        self.isDrop = false

        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: paths, with: .automatic)
        self.tableView.endUpdates()

        self.heightShadowConstraint.constant = self.viewHeight.min
        self.heightTableConstraint.constant = self.viewHeight.min
        UIView.animate(withDuration: 0.3, animations: {
            self.view.frame.size = CGSize(width: self.view.frame.width, height: self.viewHeight.min)
            self.view.layoutIfNeeded()
        }) { (finished) in
            self.tableView.isScrollEnabled = false
        }
    }

    /** Возвращает массив IndexPath с первого индекса.
     т.е. тех которые участвуют в анимации открытия/закрытия. */
    fileprivate func dropRowPaths() -> [IndexPath]? {
        return self.tableSource.indexPaths(after: 0, section: 0)
    }

    fileprivate func selected(row: Int) {
        if !self.isDrop {
            /// откроем список
            dropList()
            return
        }

        if row == 0 {
            /// закрыли список
            hideList()
        } else {
            let valueByRow = self.tableSource[row]
            /// выбрали новую строку, поставим ее наверх
            moveToFirstRowIndex(row)
            /// закроем список после перезагрузки таблицы
            DispatchQueue.main.async {
                self.hideList()
                /// сообщим о выборе новой строки после отработки анимации закрытия списка
                DispatchQueue.main.async {
                    if let originalIndex = self.dataSource?.index(of: valueByRow) {
                        self.selectedRow?(originalIndex)
                    }
                }
            }
        }
    }

    /** Перемещает строку с index в нулевой индекс tableSource,
     остальные элементы остаются по своей сортировке,
     обновляет таблицу. */
    fileprivate func moveToFirstRowIndex(_ index: Int) {
        if let element = self.tableSource[guarded: index],
            var newListValues = self.dataSource,
            let originalIndex = newListValues.index(of: element) {
            newListValues.remove(at: originalIndex)
            newListValues.insert(element, at: 0)
            self.tableSource = newListValues
            self.tableView.reloadData()
        }
    }
}

extension DropListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.isDrop ? self.tableSource.count : 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)

        if let text = self.tableSource[guarded: indexPath.row] {
            cell.textLabel?.text = text
            cell.textLabel?.font = self.textLabelFont
            cell.selectionStyle = .none
            cell.accessoryType = (indexPath.row == 0 ? .disclosureIndicator : .none)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewHeight.min
    }
}

extension DropListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        selected(row: indexPath.row)
    }
}

extension Array {

    /// Возвращает массив IndexPath после заданного индекса.
    func indexPaths(after i: Int, section: Int) -> [IndexPath]? {
        guard i < self.endIndex else {
            return nil
        }

        var paths = [IndexPath]()
        var idx = self.index(after: i)
        while idx != self.endIndex {
            let path = IndexPath(row: idx, section: section)
            paths.append(path)
            self.formIndex(after: &idx)
        }

        return paths
    }

    /// Возвращает элемент по индексу или nil.
    subscript(guarded idx: Int) -> Element? {
        guard (self.startIndex..<self.endIndex).contains(idx) else {
            return nil
        }

        return self[idx]
    }
}
