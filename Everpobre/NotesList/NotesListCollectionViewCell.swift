//
//  NotesListCollectionViewCell.swift
//  Everpobre
//
//  Created by Charles Moncada on 11/10/18.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import UIKit

class NotesListCollectionViewCell: UICollectionViewCell {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
	var item: Note!

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	func configure(with item: Note) {
		backgroundColor = .white
		titleLabel.text = item.title
		creationDateLabel.text = (item.creationDate as Date?)?.customStringLabel()
        let nsData = item.image
        if let imageNsData = nsData, let imageData = imageNsData as Data?{
            DispatchQueue.global(qos: .default).async {
                let optionalImage: UIImage? = UIImage(data: imageData)
                guard let image = optionalImage else { return }
                
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
                
            }
        }
	}
}
