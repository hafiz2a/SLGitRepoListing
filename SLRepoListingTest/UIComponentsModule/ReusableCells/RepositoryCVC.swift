//
//  RepositoryCVC.swift
//  SLRepoListingTest
//
//  Created by Aziz Ahmad on 12/03/2025.
//

import UIKit

class RepositoryCVC: UICollectionViewCell {
    @IBOutlet weak var repoName: UILabel!
    @IBOutlet weak var repoImageView: UIImageView!
    @IBOutlet weak var repoContentView: UIView!
    static let reuseIdentifier = "RepositoryCVC"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        repoContentView.layer.cornerRadius = 12
        repoContentView.layer.masksToBounds = false
        repoContentView.layer.shadowColor = UIColor.black.cgColor
        repoContentView.layer.shadowOpacity = 0.3
        repoContentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        repoContentView.layer.shadowRadius = 4
    }
    
    func configure(with repository: Repository) {
        repoName.text = repository.name
        repoImageView.loadImage(from: repository.avatarUrl ?? "square-placeholder.png") // Assuming GitHub's repo has an associated image URL
    }
}

