//
//  RepositoryTVC.swift
//  SLRepoListingTest
//
//  Created by Aziz Ahmad on 12/03/2025.
//

import UIKit

class RepositoryTVC: UITableViewCell {
    static let reuseIdentifier = "RepositoryTVC"
    
    @IBOutlet weak var repoContentView: UIView!
    @IBOutlet weak var lbl_repoName: UILabel!
    @IBOutlet weak var commitStackView: UIStackView!
    @IBOutlet weak var commitStackHeightConstraint: NSLayoutConstraint!
    var onExpand: (() -> Void)? // Callback when cell is expanded
    var isExpanded = false {
        didSet {
            commitStackView.isHidden = !isExpanded
            
        }
    }

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
        lbl_repoName.text = repository.name
        isExpanded = repository.isExpanded
        if isExpanded{
            commitStackHeightConstraint.constant = 70
        }else {
            commitStackHeightConstraint.constant = 35
        }

    }

    @IBAction func toggleButtonTapped(_ sender: Any) {
        isExpanded.toggle()
        
        onExpand?()
    }
    @objc private func expandTapped() {
        
    }
    
    func configureCommits(_ commits: [Commit]) {
        if isExpanded{
            commitStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            for commit in commits.prefix(3) {
                let label = UILabel()
                label.text = commit.message
                label.font = .systemFont(ofSize: 14)
                commitStackView.addArrangedSubview(label)
            }
        }else{
            commitStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        }
        
    }
}
