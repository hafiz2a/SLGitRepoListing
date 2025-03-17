//
//  RepositoryListView.swift
//  SLRepoListingTest
//
//  Created by Aziz Ahmad on 16/03/2025.
//
import UIKit

class RepositoryListView: UIView {

    // MARK: - Properties
    let tableView = UITableView()

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup
    private func setupUI() {
        addSubview(tableView)
        tableView.frame = bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        tableView.register(UINib(nibName: "RepositoryTVC", bundle: nil), forCellReuseIdentifier: "RepositoryTVC")
        tableView.register(RepositoryCollectionTVC.self, forCellReuseIdentifier: "RepositoryCollectionTVC")
    }
}
