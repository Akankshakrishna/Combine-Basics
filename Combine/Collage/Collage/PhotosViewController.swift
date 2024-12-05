//
//  PhotosViewController.swift
//  Collage
//
//  Created by Akanksha.A on 26/02/24.
//

import Combine
import UIKit
import Photos

private let reuseIdentifier = "PhotoCell"

class PhotosViewController: UICollectionViewController {
    
    // MARK: - Public properties
    var selectedPhotos: AnyPublisher<UIImage, Never> {
        return selectedPhotosSubject.eraseToAnyPublisher()
    }
    let imagesArray = ["Tom", "shinchan", "Pikachu", "minion", "Jerry", "Doraemon"]
    
    // MARK: - Private properties
    private let selectedPhotosSubject = PassthroughSubject<UIImage, Never>()
    
    private lazy var photos = PhotosViewController.loadPhotos()
    private lazy var imageManager = PHCachingImageManager()
    
    private lazy var thumbnailSize: CGSize = {
        let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        return CGSize(width: cellSize.width * UIScreen.main.scale,
                      height: cellSize.height * UIScreen.main.scale)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        self.collectionView.reloadData()
        // Do any additional setup after loading the view.
//        PHPhotoLibrary.fetchAuthorizationStatus { [weak self] status in
//            if status {
//                self?.photos = PhotosViewController.loadPhotos()
//                
//                DispatchQueue.main.async {
//                    self?.collectionView.reloadData()
//                }
//            }
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        selectedPhotosSubject.send(completion: .finished)
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        print("Photos are \(photos.count)")
//        return photos.count
        return imagesArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let asset = photos.object(at: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.preview?.image = image
            } else {
                print("Error: Image is nil for asset \(asset.localIdentifier)")
                cell.preview?.image = UIImage(named: "IMG_1907")
            }
        })
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = photos.object(at: indexPath.item)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell {
            cell.flash()
        }
        imageManager.requestImage(for: asset, targetSize: view.frame.size, contentMode: .aspectFill, options: nil, resultHandler: { [weak self] image, info in
            guard let self = self,
                  let image = image,
                  let info = info
            else { return }
            
            if let isThumbnail = info[PHImageResultIsDegradedKey as String] as? Bool, isThumbnail {
                return
            }
            
            self.selectedPhotosSubject.send(image)
            
        })
    }
    
}
// MARK: - Fetch assets
extension PhotosViewController {
    
    static func loadPhotos() -> PHFetchResult<PHAsset> {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let assets = PHAsset.fetchAssets(with: allPhotosOptions)
        print("Number of assets: \(assets.count)")
        return assets
    }
    
}
