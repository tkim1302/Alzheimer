import UIKit
import CoreData

class PhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // CollectionView and a label outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainNameLabel: UILabel!
    
    // Core Data fetched results controller for Photos entity
    var fetchedResultsController: NSFetchedResultsController<Photos>!
    // Boolean variable to toggle edit mode
    var isEditMode = false
    // Album selected for showing photos in the collection view
    var selectedAlbum: Albums!
    // Getting the managedContext for CoreData operations
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // Variable to hold the name of the album
    var albumName: String?
    
    // Overridden viewDidLoad method from UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Registering PhotoCollectionViewCell nib for collection view
        let nib = UINib(nibName: "PhotoCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "PhotoCell")
        
        // Setting delegate and data source for the collection view
        collectionView.delegate = self
        collectionView.dataSource = self
        // Allowing multiple selection in the collection view
        collectionView.allowsMultipleSelection = true

        // Creating fetch request for Photos entity
        let fetchRequest: NSFetchRequest<Photos> = Photos.fetchRequest()
        // Fetching photos that belong to the selected album
        fetchRequest.predicate = NSPredicate(format: "albums == %@", selectedAlbum)
        // Sorting photos by creation date
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        // Initialising fetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        // Setting the fetchedResultsController delegate
        fetchedResultsController.delegate = self
        
        // Attempting to fetch the photos
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // Setting the main label to show album's name
        mainNameLabel.text = albumName
    }
    
    // Collection view data source method for number of items in section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // If there are fetched sections, return their count, else return 0
        guard let sections = fetchedResultsController.sections else { return 0 }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    // Collection view data source method for cell at index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Dequeue a reusable cell from the collection view
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        // Fetching the photo for the current index path
        let photo = fetchedResultsController.object(at: indexPath)
        
        // If the photo has imageData, set it as the cell's image, else set a placeholder
        if let imageData = photo.imageData {
            cell.imageView.image = UIImage(data: imageData)
        } else {
            cell.imageView.image = nil // or some placeholder image
        }
        // Setting the cell's background color
        cell.contentView.backgroundColor = .white
       
        return cell
    }
    
    // Collection view delegate method when an item is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // If in edit mode, change the cell's background color
        if isEditMode {
            let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
            cell.contentView.backgroundColor = .lightGray
        }
    }
    
    // Collection view delegate method when an item is deselected
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // If in edit mode, change the cell's background color back to white
        if isEditMode {
            let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
            cell.contentView.backgroundColor = .white
        }
    }
    
    // Function to handle edit button tap
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        // Toggle edit mode
        isEditMode = !isEditMode
        // Change sender title based on current edit mode status
        sender.title = isEditMode ? "Done" : "Edit"
        // Set multiple selection based on edit mode status
        collectionView.allowsMultipleSelection = isEditMode
        
        // If in edit mode, present an action sheet with options to add or delete photos
        if isEditMode {
            let alertController = UIAlertController(title: "Options", message: "Please select an option", preferredStyle: .actionSheet)
            
            let addPhotoAction = UIAlertAction(title: "Add Photo", style: .default) { _ in
                // Present image picker when add photo is selected
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
            
            let deleteAction = UIAlertAction(title: "Delete Photo", style: .destructive)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            // Add actions to the alert controller
            alertController.addAction(addPhotoAction)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)
            
            // Present the alert controller
            present(alertController, animated: true)
        } else {
            // If not in edit mode, delete all selected photos
            if let selectedIndexPaths = self.collectionView.indexPathsForSelectedItems {
                for indexPath in selectedIndexPaths {
                    let photoToDelete = self.fetchedResultsController.object(at: indexPath)
                    self.managedContext.delete(photoToDelete)
                }
                do {
                    // Save changes to managed context after deleting photos
                    try self.managedContext.save()
                } catch {
                    print("An error occurred while trying to delete photos.")
                }
            }
        }
    }
    
    // Image picker delegate method for when an image is selected
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Getting selected image and converting to data
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
              let imageData = selectedImage.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        // Creating a new Photo entity with selected image data
        let newPhoto = Photos(context: self.managedContext)
        newPhoto.albums = self.selectedAlbum
        newPhoto.imageData = imageData
        newPhoto.creationDate = Date()
        
        // Attempting to save new photo to managed context
        do {
            try self.managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        // Dismiss image picker after an image is selected
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Fetched results controller delegate method for when the content changes
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Reload collection view data when content changes
        collectionView.reloadData()
    }
}

// Extension to handle layout for collection view
extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    // Method to define size for items in the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 200)
    }
}
