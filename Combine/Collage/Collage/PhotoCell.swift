//
//  PhotoCell.swift
//  Collage
//
//  Created by Akanksha.A on 23/02/24.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    @IBOutlet var preview: UIImageView!
      var representedAssetIdentifier: String!

    override func prepareForReuse() {
        super.prepareForReuse()
        if let preview = preview {
            preview.image = nil
        }
    }

      func flash() {
        preview.alpha = 0
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
          self?.preview.alpha = 1
        })
      }

}
