//
//  CircularCollectionView.swift
//  SLRepoListingTest
//
//  Created by Aziz Ahmad on 12/03/2025.
//

import UIKit

protocol CircularCollectionViewDelegate: AnyObject {
    func didSelectRepository(_ repository: Repository)
}

class CircularCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var repositories: [Repository] = []
    weak var delegate: CircularCollectionViewDelegate?
    
    private let collectionView: UICollectionView
    private let pageControl = UIPageControl()
    
    private var actualItemCount: Int { repositories.count }
    
    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.7, height: 100)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(frame: frame)
        
        setupCollectionView()
        setupPageControl()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.decelerationRate = .fast
        let nib = UINib(nibName: "RepositoryCVC", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "RepositoryCVC")

        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupPageControl() {
        pageControl.currentPage = 0
        pageControl.hidesForSinglePage = true
        pageControl.pageIndicatorTintColor = .slBg
        pageControl.currentPageIndicatorTintColor = .lightGray
        addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    func configure(with repositories: [Repository]) {
        guard repositories.count > 1 else { return }
        self.repositories = repositories
        pageControl.numberOfPages = actualItemCount
        collectionView.reloadData()
        
        // Scroll to middle fake dataset
        let initialIndex = actualItemCount * 100
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath(item: initialIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    // MARK: - Collection View Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actualItemCount * 1000  // Large number to simulate infinite scrolling
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RepositoryCVC", for: indexPath) as? RepositoryCVC else {
            return UICollectionViewCell()
        }
        
        let actualIndex = indexPath.item % actualItemCount  // Wrap around index
        cell.configure(with: repositories[actualIndex])
        return cell
    }
    
    // MARK: - Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let actualIndex = indexPath.item % actualItemCount
        delegate?.didSelectRepository(repositories[actualIndex])
    }
    
    // MARK: - Collection View Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width * 0.7, height: collectionView.frame.height)
    }
    
    // MARK: - Infinite Scrolling Fix
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
        let actualIndex = visibleIndex % actualItemCount
        
        pageControl.currentPage = actualIndex
    }
}



