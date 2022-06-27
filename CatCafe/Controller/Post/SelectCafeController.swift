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
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        configureSearchController()
        
        fetchCafes()
    }
    
    // MARK: - API
    
    func fetchCafes() {
        CafeService.fetchAllCafes { cafes in
            self.cafes = cafes
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Helpers
    
    func setupTableView() {
        tableView.register(PlaceCell.self, forCellReuseIdentifier: PlaceCell.identifier)
        tableView.rowHeight = 64
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
}

// MARK: - UITableViewDataSource / UITableViewDelegate

extension SelectCafeController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteredCafes.count : cafes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PlaceCell.identifier,
            for: indexPath) as? PlaceCell
        else { return UITableViewCell() }
        
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
        self.tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate

extension SelectCafeController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
}
