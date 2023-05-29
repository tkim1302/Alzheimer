import UIKit

protocol AlbumCellDelegate: AnyObject {
    func playButtonTapped(cell: AlbumCollectionViewCell)
}

class AlbumCollectionViewCell: UICollectionViewCell {
    weak var delegate: AlbumCellDelegate?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var audioFilename: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        //imageView.contentMode = .scaleAspectFill
        //imageView.clipsToBounds = true
    }

    @IBAction func playButtonTapped(_ sender: UIButton) {
        print("Play button tapped")
        delegate?.playButtonTapped(cell: self)
    }
}
