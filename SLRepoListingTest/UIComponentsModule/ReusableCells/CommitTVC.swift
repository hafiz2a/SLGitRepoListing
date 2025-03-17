//
//  CommitTVC.swift
//  SLRepoListingTest
//
//  Created by Aziz Ahmad on 12/03/2025.
//

import UIKit

class CommitTableViewCell: UITableViewCell {
    static let identifier = "CommitTableViewCell"
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 2
        return label
    }()
    
    func configure(with commit: Commit) {
        messageLabel.text = commit.message
    }
}
