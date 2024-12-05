//
//  ViewController.swift
//  Collage
//
//  Created by Akanksha.A on 23/02/24.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet weak var titleOfScreen: UILabel!
    
    @IBOutlet weak var imagePreview: UIImageView! {
        didSet {
            imagePreview.layer.borderColor = UIColor.gray.cgColor
            imagePreview.layer.borderWidth = 2
            imagePreview.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var itemAdd: UIBarButtonItem!
    
    // MARK: - Private properties
    private var subscriptions = Set<AnyCancellable>()
    private let images = CurrentValueSubject<[UIImage], Never>([])
    let imagesArray = ["Tom", "shinchan", "Pikachu", "minion", "Jerry", "Doraemon"]
    @Published var selectedPhotosCount = 0
    var selectedPhotos: AnyPublisher<UIImage, Never> {
        return selectedPhotosSubject.eraseToAnyPublisher()
    }
    private let selectedPhotosSubject = PassthroughSubject<UIImage, Never>()
    
    // MARK: - View controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let collageSize = imagePreview.frame.size
        images
            .handleEvents(receiveOutput: {[weak self] photos in
                self?.updateUI(photos: photos)
            })
            .map { photos in
                UIImage.collage(images: photos, size: collageSize)
            }
            .assign(to: \.image, on: imagePreview)
            .store(in: &subscriptions)
        $selectedPhotosCount
//            .filter({ $0 > 0 })
            .map({ count in
                if count > 1 {
                    return "Selected \(count) photos"
                } else if count == 1 {
                    return "Selected 1 photo"
                } else {
                    return "Collage"
                }
            })
            .assign(to: \.text, on: self.titleOfScreen)
            .store(in: &subscriptions)
        let newPhotos = selectedPhotos
            .prefix { [unowned self]_ in
                return self.images.value.count < 6
            }
//            .filter { newImage in
//                return newImage.size.width > newImage.size.height
//            }
            .share()
        newPhotos
            .filter { [unowned self] _ in self.images.value.count == 5 }
            .flatMap { _ in
                self.alert(title: "Limit Reached", text: "To add more than 6 photos purchase Collage Pro")
            }
            .sink(receiveCompletion: {_ in}, receiveValue: {_  in})
            .store(in: &subscriptions)
        newPhotos
            .map { [unowned self] newImage in
                return self.images.value + [newImage]
            }
            .assign(to: \.value, on: images)
            .store(in: &subscriptions)
    }
    
    private func updateUI(photos: [UIImage]) {
        buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
        buttonClear.isEnabled = photos.count > 0
        itemAdd.isEnabled = photos.count < 6
        title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }
    
    // MARK: - Actions
    
    @IBAction func actionClear() {
        selectedPhotosCount = 0
        images.send([])
    }
    
    @IBAction func actionSave() {
        guard let image = imagePreview.image else { return }
        PhotoWriter.save(image)
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    self.showMessage("Error", description: error.localizedDescription)
                }
                self.actionClear()
            } receiveValue: { [unowned self] id in
                self.showMessage("Saved with id: \(id)")
            }
            .store(in: &subscriptions)
    }
    
    @IBAction func actionAdd() {
        let randomImageIndex = Int.random(in: 0...5)
        let imageName = imagesArray[randomImageIndex]
       
        let newImage = UIImage(named: imageName)!
        selectedPhotosSubject.send(newImage)
        selectedPhotosCount += 1
        
    }
    
    private func showMessage(_ title: String, description: String? = nil) {
        
        alert(title: title, text: description ?? "")
            .sink(receiveValue: { _ in })
            .store(in: &subscriptions)
    }
    
    
}

