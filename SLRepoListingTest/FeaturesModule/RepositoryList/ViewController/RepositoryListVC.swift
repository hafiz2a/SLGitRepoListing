//
//  RepositoryListVC.swift
//  SLRepoListingTest
//
//  Created by Aziz Ahmad on 12/03/2025.
//

import UIKit

class RepositoryListVC: UIViewController {

    // MARK: - Properties
    private let viewModel: RepositoryVM
    private let repositoryListView = RepositoryListView()

    // MARK: - Initializer (Dependency Injection)
    init(viewModel: RepositoryVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func loadView() {
        view = repositoryListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setupTableView()
    }

    // MARK: - Setup TableView
    private func setupTableView() {
        repositoryListView.tableView.delegate = self
        repositoryListView.tableView.dataSource = self
    }

    // MARK: - Bindings
    private func setupBindings() {
        viewModel.didUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.repositoryListView.tableView.reloadData()
            }
        }

        viewModel.didUpdateCommits = { [weak self] updatedIndexes in
            DispatchQueue.main.async {
                let indexPaths = updatedIndexes.map { IndexPath(row: $0, section: 0) }
                self?.repositoryListView.tableView.reloadRows(at: indexPaths, with: .fade)
            }
        }
    }

    // MARK: - Navigation
    private func openDetail(for repository: Repository) {
        let detailVC = viewModel.goToDetails(for: repository)
        detailVC.modalPresentationStyle = .overCurrentContext
        detailVC.modalTransitionStyle = .crossDissolve
        present(detailVC, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate, CircularCollectionViewDelegate
extension RepositoryListVC: UITableViewDataSource, UITableViewDelegate, CircularCollectionViewDelegate {

    func didSelectRepository(_ repository: Repository) {
        openDetail(for: repository)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + viewModel.visibleRepositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryCollectionTVC", for: indexPath) as! RepositoryCollectionTVC
            cell.configure(with: Array(viewModel.repositories.prefix(5)), delegate: self)
            cell.onRepositorySelected = { [weak self] repo in self?.openDetail(for: repo) }
            return cell
        } else {
            let repository = viewModel.visibleRepositories[indexPath.row - 1]
            let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryTVC.reuseIdentifier, for: indexPath) as! RepositoryTVC

            cell.configure(with: repository)
            cell.configureCommits(viewModel.getCommits(for: repository))

            cell.onExpand = { [weak self] in
                self?.viewModel.toggleExpanded(for: repository, forIndex: indexPath.row - 1)
                tableView.reloadRows(at: [indexPath], with: .fade)
            }

            if indexPath.row == viewModel.visibleRepositories.count - 2 {
                viewModel.loadNextBatch()
            }

            return cell
        }
    }

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: { $0.row >= viewModel.visibleRepositories.count - 2 }) {
            viewModel.loadNextBatch()
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let visibleRows = tableView.indexPathsForVisibleRows, !visibleRows.isEmpty else { return }
        viewModel.fetchCommitsForVisibleCells(indexPaths: visibleRows)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row > 0 {
            openDetail(for: viewModel.visibleRepositories[indexPath.row - 1])
        }
    }
}



