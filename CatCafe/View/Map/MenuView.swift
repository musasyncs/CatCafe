//
//  SearchInputView.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/1.
//

import UIKit
import MapKit

let height1: CGFloat = UIScreen.height * 0.3
let height2: CGFloat = UIScreen.height * 0.7

enum ExpansionState {
    case notExpanded
    case partiallyExpanded
    case fullyExpanded
}

protocol MenuViewDelegate: AnyObject {
    func animateBottomConstraint(constant: CGFloat, goalState: ExpansionState)
    func shouldHideCenterButton(_ shouldHide: Bool)
    func selectedAnnotation(withCafe cafe: Cafe)
}

class MenuView: UIView {
    
    weak var delegate: MenuViewDelegate?
    var mapController: MapController?
    var expansionState: ExpansionState!
        
    var cafes = [Cafe]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var tableView = UITableView()
   
    let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.layer.cornerRadius = 4
        view.alpha = 0.5
        return view
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupIndicatorView()
        setupTableView()
        setupGestureRecognizers()
        expansionState = .notExpanded
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper Functions
    private func dismissOnSearch() {
        toPartial()
    }
    
    private func dismissOnSelect() {
        toPartial()
    }
    
    private func toNotExpand() {
        delegate?.shouldHideCenterButton(false)
        delegate?.animateBottomConstraint(constant: (height2 - 108), goalState: .notExpanded)
    }
    
    private func toPartial() {
        self.delegate?.shouldHideCenterButton(false)
        delegate?.animateBottomConstraint(constant: height1, goalState: .partiallyExpanded)
    }
    
    private func toFull() {
        delegate?.shouldHideCenterButton(true)
        delegate?.animateBottomConstraint(constant: -75, goalState: .fullyExpanded)
    }
    
    // MARK: - Actions
    @objc func handleSwipeGesture(sender: UISwipeGestureRecognizer) {
        if sender.direction == .up {
            switch expansionState {
            case .notExpanded:
                toPartial()
            case .partiallyExpanded:
                toFull()
            case .fullyExpanded:
                return
            case .none:
                return
            }
        } else {
            switch expansionState {
            case .notExpanded:
                return
            case .partiallyExpanded:
                toNotExpand()
            case .fullyExpanded:
                toPartial()
            case .none:
                return
            }
        }
    }
    
}

extension MenuView {
    func setupIndicatorView() {
        addSubview(indicatorView)
        indicatorView.anchor(top: topAnchor, paddingTop: 16, width: 40, height: 8)
        indicatorView.centerX(inView: self)
    }
    
    func setupTableView() {
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MapCell.self, forCellReuseIdentifier: MapCell.identifier)
        tableView.rowHeight = 64
        tableView.showsVerticalScrollIndicator = false
        
        addSubview(tableView)
        tableView.anchor(top: indicatorView.bottomAnchor,
                         left: leftAnchor,
                         bottom: bottomAnchor,
                         right: rightAnchor,
                         paddingTop: 16)
    }
    
    func setupGestureRecognizers() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeUp.direction = .up
        addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeDown.direction = .down
        addGestureRecognizer(swipeDown)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MenuView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cafes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MapCell.identifier,
            for: indexPath
        ) as? MapCell else { return UITableViewCell() }
        
        if let controller = mapController {
            cell.delegate = controller
        }
        
        cell.cafe = cafes[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var selectedCafe = cafes[indexPath.row]
        delegate?.selectedAnnotation(withCafe: selectedCafe)
        dismissOnSelect()
        
        cafes[0].isSelected = false
        selectedCafe.isSelected = true
        cafes.remove(at: indexPath.row)
        cafes.insert(selectedCafe, at: 0)
        
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}
