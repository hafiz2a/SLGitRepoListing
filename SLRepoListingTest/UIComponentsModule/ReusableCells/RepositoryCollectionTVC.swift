//
//  RepositoryCollectionTVC.swift
//  SLRepoListingTest
//
//  Created by Aziz Ahmad on 12/03/2025.
//

import UIKit

class RepositoryCollectionTVC: UITableViewCell {
    
    var onRepositorySelected: ((Repository) -> Void)? // Callback for selection
    private let circularCollectionView = CircularCollectionView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(circularCollectionView)
        contentView.backgroundColor = .clear
        circularCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            circularCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            circularCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            circularCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            circularCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            circularCollectionView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    func configure(with repositories: [Repository], delegate: CircularCollectionViewDelegate) {
        circularCollectionView.delegate = delegate
        circularCollectionView.configure(with: repositories)
    }
}

