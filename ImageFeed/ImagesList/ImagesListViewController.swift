
import UIKit

class ImagesListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        photosName = Array(0...20).map{ "\($0)" }
    }

    @IBOutlet private var tableView: UITableView!
    private var photosName = [String]()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        // Меняю картинки в ячейках
        if indexPath.row < photosName.count {
            cell.cellImage.image = UIImage(named: photosName[indexPath.row] ) ?? UIImage()
        } else { }
        
        // Меняю дату в подписи
        cell.dateLabel.text = dateFormatter.string(from: Date())
        
        // Для каждой четной ячейки установливаю включённый лайк
        let tintedImage = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
        cell.likeButton.setImage(tintedImage, for: .normal)
        cell.likeButton.tintColor = UIColor.white.withAlphaComponent(0.5)
        cell.likeButton.setTitle("", for: .normal)
        if indexPath.row.isMultiple(of: 2) { } else {
            cell.likeButton.tintColor = UIColor(red: 245/255.0, green: 107/255.0, blue: 108/255.0, alpha: 1)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
    
    // Делаю так, чтобы картинка помащалась полностью
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < photosName.count {
            let imageHeight: Int = Int(UIImage(named: photosName[indexPath.row])?.size.height ?? 0)
            let imageWidth: Int = Int(UIImage(named: photosName[indexPath.row])?.size.width ?? 0)
            let tableViewWidth: Int = Int(tableView.bounds.width)
            return CGFloat(tableViewWidth/imageWidth*imageHeight)
        } else { return 0.0 }
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


