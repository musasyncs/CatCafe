//
//  SearchInputView.swift
//  CatCafe
//
//  Created by Ewen on 2022/7/1.
//

import UIKit
import MapKit

struct CafeItem {
    let address: String
    let id: String
    let lat: Double
    let long: Double
    let phoneNumber: String
    let title: String
    let website: String
    
    var isSelected: Bool
}

let height1: CGFloat = UIScreen.height * 0.4
let height2: CGFloat = UIScreen.height * 0.8

enum ExpansionState {
    case notExpanded
    case partiallyExpanded
    case fullyExpanded
}

protocol SearchInputViewDelegate: AnyObject {
    func animateBottomConstraint(constant: CGFloat, goalState: ExpansionState)
    func shouldHideCenterButton(_ shouldHide: Bool)
    func selectedAnnotation(withCafe cafe: Cafe)
}

class MenuView: UIView {
    
    weak var delegate: SearchInputViewDelegate?
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
        configureIndicatorView()
        configureTableView()
        configureGestureRecognizers()
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
        delegate?.animateBottomConstraint(constant: (height2 - 88), goalState: .notExpanded)
    }
    
    private func toPartial() {
        self.delegate?.shouldHideCenterButton(false)
        delegate?.animateBottomConstraint(constant: height1, goalState: .partiallyExpanded)
    }
    
    private func toFull() {
        delegate?.shouldHideCenterButton(true)
        delegate?.animateBottomConstraint(constant: 0, goalState: .fullyExpanded)
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
    func configureIndicatorView() {
        addSubview(indicatorView)
        indicatorView.anchor(top: topAnchor, paddingTop: 8, width: 40, height: 8)
        indicatorView.centerX(inView: self)
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SearchCell.self, forCellReuseIdentifier: SearchCell.identifier)
        tableView.rowHeight = 64
        tableView.showsVerticalScrollIndicator = false
        
        addSubview(tableView)
        tableView.anchor(top: indicatorView.bottomAnchor,
                         left: leftAnchor,
                         bottom: bottomAnchor,
                         right: rightAnchor,
                         paddingTop: 8)
    }
    
    func configureGestureRecognizers() {
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
            withIdentifier: SearchCell.identifier,
            for: indexPath
        ) as? SearchCell else { return UITableViewCell() }
        
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
