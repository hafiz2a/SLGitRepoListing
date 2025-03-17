//
//  RepositoryDetailOverlay.swift
//  SLRepoListingTest
//
//  Created by Aziz Ahmad on 12/03/2025.
//

import UIKit

class RepositoryDetailOverlay: UIView {
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    var didTapClose: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = 12
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(closeButton)
        
        titleLabel.font = .boldSystemFont(ofSize: 18)
        descriptionLabel.numberOfLines = 3
        closeButton.setTitle("", for: .normal)
        closeButton.setImage(.close, for: .normal)
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }
    
    @objc private func closeTapped() {
        didTapClose?()
    }
    
    func configure(with repository: Repository) {
        titleLabel.text = repository.name
        descriptionLabel.text = repository.repoDesc
    }
}
