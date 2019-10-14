//
//  VTPhotoViewController.swift
//  Virtual Tourist
//
//  Created by Ben Lewis on 10/14/19.
//  Copyright © 2019 Ben Lewis. All rights reserved.
//

import UIKit
import Kingfisher
import CoreData

class VTPhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pin: Pin!
    
    var dataController: DataController!
    
    var photos = [Photo]()
    
    var page = 1
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let photo = photos[indexPath.row]
        if let image = photo.image {
            cell.imageView.image = UIImage(data: image)
        } else if let url = photo.url {
            cell.imageView.kf.setImage(with: URL(string: url)!, placeholder: UIImage(named: "placeholder")) { result in
                switch result {
                case .success(let value):
                    photo.image = value.image.pngData()
                    try? self.dataController.viewContext.save()
                case .failure(let error):
                    print("Error: url = \(url); error = \(error.errorDescription ?? "")")
                }
            }
        }
        return cell
    }
    
    fileprivate func loadPhotos() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        if let photos = try? dataController.viewContext.fetch(fetchRequest) {
            if photos.count == 0{
                fetchPhotos()
            } else {
                self.photos = photos
                pin.photos = NSSet(array: photos)
                try? dataController.viewContext.save()
                self.collectionView.reloadData()
            }
        } else {
            fetchPhotos()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPhotos()
    }

    func fetchPhotos(_ page: Int = 1, _ perPage: Int = 15) {
        VTClient.shared.getPhotos(pin.latitude, pin.longitude, page: page, perPage: perPage){ result in
            switch result {
            case .error(let message):
                print(message)
            case .success(let vtPhotos):
                let context = self.dataController.viewContext
                let photos: [Photo] = vtPhotos.photos.map { vtPhoto in
                    let photo = Photo(context: context)
                    photo.url = self.imageUrl(vtPhoto)
                    return photo
                }
                if let oldPhotos = self.pin.photos {
                    for e in oldPhotos {
                        let photo = e as! Photo
                        context.delete(photo)
                    }
                }
                self.page = page
                self.photos = photos
                self.pin.photosAvailable = Int32(vtPhotos.total)!
                self.pin.photos = NSSet(array: photos)
                try? self.dataController.viewContext.save()
                self.collectionView.reloadData()
            }
        }
    }
    
    

    func imageUrl(_ photo: VTPhoto) -> String {
        return "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).png"
    }
    
    @IBAction func refreshPhotos(_ sender: Any) {
        
        if pin.photosAvailable < 16 {
            fetchPhotos()
            return
        }
        let lastPage = Int(pin.photosAvailable)/15 + 1
        let oldPage = page
        var newPage = Int.random(in: 1...lastPage)
        while newPage == oldPage {
            newPage = Int.random(in: 1...lastPage)
        }
        page = newPage
        fetchPhotos(newPage)
    }
}


