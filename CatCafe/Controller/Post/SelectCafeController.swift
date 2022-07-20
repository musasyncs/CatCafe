//
//  SelectCafeController.swift
//  CatCafe
//
//  Created by Ewen on 2022/6/14.
//

import UIKit

protocol SelectCafeControllerDelegate: AnyObject {
    func didSelectCafe(_ cafe: Cafe)
}

class SelectCafeController: UITableViewController {
    
    weak var delegate: SelectCafeControllerDelegate?
    
    private var cafes = [Cafe]()
    private var filteredCafes = [Cafe]()
    
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - View
    private lazy var backBarButtonItem = UIBarButtonItem(
        image: SFSymbols.arrow_left?
            .withTintColor(.ccGrey)
            .withRenderingMode(.alwaysOriginal),
        style: .plain,
        target: self,
        action: #selector(dismissSelectCafe)
    )
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        setupSearchController()
        
        fetchCafes()
    }
    
    // MARK: - API
    private func fetchCafes() {
        CafeService.fetchAllCafes { [weak self] cafes in
            guard let self = self else { return }
            self.cafes = cafes
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Action
    @objc func dismissSelectCafe() {
        dismiss(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension SelectCafeController {
    private func setupTableView() {
        tableView.register(PlaceCell.self, forCellReuseIdentifier: PlaceCell.identifier)
        tableView.rowHeight = 64
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.placeholder = "搜尋"
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = .darkGray
        navigationItem.titleView = searchController.searchBar
        navigationItem.leftBarButtonItem = backBarButtonItem
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SelectCafeController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteredCafes.count : cafes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PlaceCell.identifier,
            for: indexPath) as? PlaceCell
        else {
            return UITableViewCell()
        }

        let cafe = inSearchMode ? filteredCafes[indexPath.row] : cafes[indexPath.row]
        cell.viewModel = PlaceCellViewModel(cafe: cafe)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cafe = inSearchMode ? filteredCafes[indexPath.row] : cafes[indexPath.row]
        delegate?.didSelectCafe(cafe)
        
        searchController.isActive = false
        dismiss(animated: true)
    }
    
}

// MARK: - UISearchResultsUpdating
extension SelectCafeController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filteredCafes = cafes.filter({
            $0.title.contains(searchText) || $0.address.contains(searchText)
        })
        tableView.reloadData()
    }
    
}
