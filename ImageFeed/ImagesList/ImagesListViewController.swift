
import UIKit

final class ImagesListViewController: UIViewController {
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private var tableView: UITableView!
    
    private var photosName = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photosName = Array(0..<20).map{ "\($0)" }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        // Меняю картинки в ячейках
        if indexPath.row < photosName.count {
            cell.cellImage.image = UIImage(named: photosName[indexPath.row] ) ?? UIImage()
        }
        
        // Меняю дату в подписи
        cell.dateLabel.text = dateFormatter.string(from: Date())
        
        // Для каждой четной ячейки установливаю включённый лайк
        let tintedImage = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
        cell.likeButton.setImage(tintedImage, for: .normal)
        cell.likeButton.setTitle("", for: .normal)
        let likeTintColor: UIColor = indexPath.row.isMultiple(of: 2)
           ? .white.withAlphaComponent(0.5)
           :  UIColor(red: 245/255.0, green: 107/255.0, blue: 108/255.0, alpha: 1)
        cell.likeButton.tintColor = likeTintColor
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
    
    // Делаю так, чтобы картинка помещалась полностью
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < photosName.count else { return 0 }
        let imageHeight = Float(UIImage(named: photosName[indexPath.row])?.size.height ?? 0)
        let imageWidth = Float(UIImage(named: photosName[indexPath.row])?.size.width ?? 0)
        let tableViewWidth = Float(tableView.bounds.width)
        return CGFloat(tableViewWidth/imageWidth*imageHeight)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
            
            guard let imageListCell = cell as? ImagesListCell else {
                return UITableViewCell()
            }
            
            configCell(for: imageListCell, with: indexPath)
            return imageListCell
        }
}


