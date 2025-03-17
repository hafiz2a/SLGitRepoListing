//
//  UIImageView+Extensions.swift
//  SLRepoListingTest
//
//  Created by Aziz Ahmad on 12/03/2025.
//

import UIKit

extension UIImageView {
    func loadImage(from url: String) {
        if url.contains("http"){
            
            guard let imageURL = URL(string: url) else { return }
            
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: imageURL), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }
        }
        else {
            self.image = UIImage(named: url)
        }
    }
}
