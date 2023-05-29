import UIKit
import CoreData
import Photos
import AVFoundation


class MemoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AlbumCellDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var mainName: UILabel!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var currentCell: AlbumCollectionViewCell?
    var currentAlbumName: String?
    
    var fetchedResultsController: NSFetchedResultsController<Albums>!
    var isEditMode = false
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainName.text =  "Love Ones <3"
        let nib = UINib(nibName: "AlbumCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "AlbumCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true

        let fetchRequest: NSFetchRequest<Albums> = Albums.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePickerController.allowsEditing = true
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCollectionViewCell
        cell.delegate = self

        let album = fetchedResultsController.object(at: indexPath)

        cell.nameLabel.text = album.name
        cell.audioFilename = album.audioFilename
        if let imageData = album.coverImage, let image = UIImage(data: imageData) {
            cell.imageView.image = image
        } else {
            cell.imageView.image = nil // or a placeholder image
        }

        cell.contentView.backgroundColor = .white // Resetting cell's color to default.

        return cell
    }



    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditMode {
            // Show some visual change to indicate selection
            let cell = collectionView.cellForItem(at: indexPath) as! AlbumCollectionViewCell
            cell.contentView.backgroundColor = .lightGray
        } else {
            // Trigger segue to PhotoViewController when not in edit mode
            performSegue(withIdentifier: "ShowPhotosSegue", sender: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isEditMode {
            // Reset the visual change
            let cell = collectionView.cellForItem(at: indexPath) as! AlbumCollectionViewCell
            cell.contentView.backgroundColor = .white
        }
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        isEditMode = !isEditMode
        sender.title = isEditMode ? "Done" : "Edit"
        collectionView.allowsMultipleSelection = isEditMode
        
        if isEditMode {
            let alertController = UIAlertController(title: "Options", message: "Please select an option", preferredStyle: .actionSheet)
            
            let addPersonAction = UIAlertAction(title: "Add Person", style: .default) { _ in
                let albumController = UIAlertController(title: "New Album", message: "Enter a name of your love one", preferredStyle: .alert)
                albumController.addTextField { textField in
                    textField.placeholder = "Album name"
                }
                let addAction = UIAlertAction(title: "Add", style: .default) { _ in
                    let albumName = albumController.textFields?.first?.text ?? ""
                    self.currentAlbumName = albumName
                    let newAlbum = Albums(context: self.managedContext)
                    newAlbum.name = albumName
                    
                    do {
                        try self.managedContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }

                    // After adding the album, present the image picker
                    self.present(self.imagePickerController, animated: true, completion: nil)
                }

                albumController.addAction(addAction)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                albumController.addAction(cancelAction)
                self.present(albumController, animated: true)
            }
            
            let deleteAction = UIAlertAction(title: "Delete Person", style: .destructive)
            
            let addPictureAction = UIAlertAction(title: "Add Pictures", style: .default)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            alertController.addAction(addPersonAction)
            alertController.addAction(deleteAction)
            alertController.addAction(addPictureAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true)
        } else {
            if let selectedIndexPaths = self.collectionView.indexPathsForSelectedItems {
                for indexPath in selectedIndexPaths {
                    let albumToDelete = self.fetchedResultsController.object(at: indexPath)
                    self.managedContext.delete(albumToDelete)
                }
                do {
                    try self.managedContext.save()
                    collectionView.reloadData()
                } catch {
                    print("An error occurred while trying to delete albums.")
                }
            }
        }
    }

    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotosSegue",
           let destinationVC = segue.destination as? PhotoViewController,
           let indexPath = sender as? IndexPath {
            let selectedAlbum = fetchedResultsController.object(at: indexPath)
            destinationVC.selectedAlbum = selectedAlbum
            destinationVC.albumName = selectedAlbum.name
        }
    }
    func startRecording(albumName: String) {
        let audioFilename = "\(albumName).m4a"

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let audioURL = documentsDirectory.appendingPathComponent(audioFilename)

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        self.currentAlbumName = audioFilename

        do {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder.record()

            // Save audioFilename for later use
            currentCell?.audioFilename = audioFilename

            // Provide visual feedback that recording has started
            let alertController = UIAlertController(title: "Recording...", message: "Press Stop when you're done recording.", preferredStyle: .alert)
            let stopAction = UIAlertAction(title: "Stop", style: .default) { _ in
                self.finishRecording(success: true)
            }
            alertController.addAction(stopAction)
            self.present(alertController, animated: true, completion: nil)

            print("Started recording audio at URL: \(audioURL)")
        } catch {
            finishRecording(success: false)
        }
    }

    func finishRecording(success: Bool) {
        if let recorder = audioRecorder {
            recorder.stop()
            audioRecorder = nil
        }

        if success {
            print("Recording successful.")

            guard let albumName = self.currentAlbumName else { return }
            let audioURL = getDocumentsDirectory().appendingPathComponent(albumName)

            // Check if the audio file exists at the URL
            let fileExists = FileManager.default.fileExists(atPath: audioURL.path)
            print("Audio file exists at URL: \(fileExists), URL: \(audioURL)")

            let fetchRequest: NSFetchRequest<Albums> = Albums.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", albumName)
            if let result = try? self.managedContext.fetch(fetchRequest), let album = result.first {
                album.audioFilename = self.currentAlbumName
                album.coverImage = album.coverImage
                do {
                    try self.managedContext.save()
                    print("Saved audio filename: \(album.audioFilename ?? "")")
                } catch {
                    print("Could not save. \(error)")
                }
            }
        } else {
            print("Recording failed.")
        }
    }






    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

 

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            print("Error: \(info)")
            return
        }

        guard let imageData = selectedImage.jpegData(compressionQuality: 1) else {
            print("Could not convert image to Data.")
            return
        }

        let fetchRequest: NSFetchRequest<Albums> = Albums.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", self.currentAlbumName ?? "")
        do {
            let fetchedResults = try self.managedContext.fetch(fetchRequest)
            if let currentAlbum = fetchedResults.first {
                currentAlbum.coverImage = imageData
                if let audioFilename = self.currentAlbumName {
                    print("Saving audio filename: \(audioFilename)")
                    currentAlbum.audioFilename = audioFilename
                } else {
                    print("No audio filename to save")
                }
                try self.managedContext.save()
            } else {
                print("Could not fetch the current album.")
            }
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }

        if let albumName = currentAlbumName {
            startRecording(albumName: albumName)
        }
    }


    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)

    }
    
    


}

extension MemoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 220)
    }
}

extension MemoryViewController{

    func playButtonTapped(cell: AlbumCollectionViewCell) {
        // Set the current cell
        currentCell = cell

        // Play the recording for this album
        if let audioFilename = cell.audioFilename {
            let audioURL = getDocumentsDirectory().appendingPathComponent(audioFilename)

            let audioFileURL = audioURL.appendingPathExtension("m4a")
            print("Audio URL: \(audioFileURL)")

            // Verify the audio file exists at the path
            if !FileManager.default.fileExists(atPath: audioFileURL.path) {
                print("No file found at path: \(audioFileURL.path)")
                return
            }

            // Check the size of the audio file
            do {
                let resources = try audioFileURL.resourceValues(forKeys: [.fileSizeKey])
                let fileSize = resources.fileSize!
                print("File size: \(fileSize)")
                if fileSize == 0 {
                    print("File is empty")
                    return
                }
            } catch {
                print("Error getting file size: \(error)")
            }

            // Try to play the file
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
                audioPlayer?.play()
            } catch let error {
                print("Couldn't load file: \(error)")
            }
        }
    }


}
