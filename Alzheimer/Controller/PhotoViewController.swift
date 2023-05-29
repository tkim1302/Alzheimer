import UIKit
import CoreData

class PhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainNameLabel: UILabel!
    
    var fetchedResultsController: NSFetchedResultsController<Photos>!
    var isEditMode = false
    var selectedAlbum: Albums!
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var albumName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "PhotoCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "PhotoCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true

        let fetchRequest: NSFetchRequest<Photos> = Photos.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "albums == %@", selectedAlbum)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        mainNameLabel.text = albumName
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        let photo = fetchedResultsController.object(at: indexPath)
        
        if let imageData = photo.imageData {
            cell.imageView.image = UIImage(data: imageData)
        } else {
            cell.imageView.image = nil // or some placeholder image
        }
        cell.contentView.backgroundColor = .white
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditMode {
            let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
            cell.contentView.backgroundColor = .lightGray
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isEditMode {
            let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
            cell.contentView.backgroundColor = .white
        }
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        isEditMode = !isEditMode
        sender.title = isEditMode ? "Done" : "Edit"
        collectionView.allowsMultipleSelection = isEditMode
        
        if isEditMode {
            let alertController = UIAlertController(title: "Options", message: "Please select an option", preferredStyle: .actionSheet)
            
            let addPhotoAction = UIAlertAction(title: "Add Photo", style: .default) { _ in
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
            
            let deleteAction = UIAlertAction(title: "Delete Photo", style: .destructive)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            alertController.addAction(addPhotoAction)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true)
        } else {
            if let selectedIndexPaths = self.collectionView.indexPathsForSelectedItems {
                for indexPath in selectedIndexPaths {
                    let photoToDelete = self.fetchedResultsController.object(at: indexPath)
                    self.managedContext.delete(photoToDelete)
                }
                do {
                    try self.managedContext.save()
                } catch {
                    print("An error occurred while trying to delete photos.")
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
              let imageData = selectedImage.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        let newPhoto = Photos(context: self.managedContext)
        newPhoto.albums = self.selectedAlbum
        newPhoto.imageData = imageData
        newPhoto.creationDate = Date()
        
        do {
            try self.managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
}

extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 200)
    }
}
