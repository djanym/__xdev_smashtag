//
//  TweetDetailsTVC.swift
//  Smashtag
//
//  Created by Naili Concescu on 1438/12/16.
//  Copyright © 1438 Naili Concescu. All rights reserved.
//

import UIKit

class TweetDetailsImageCell: UITableViewCell {
	
	@IBOutlet weak var rowImage: UIImageView!
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	
	var imageURL: URL? { didSet{ updateUI() } }
	var imageObj: UIImage? {
		didSet{
			rowImage.image = imageObj
		}
	}
	
	private func updateUI(){
		setImage()
	}
	
	private func setImage(){
		spinner.startAnimating()
		
		guard let url = imageURL else { return }
		
		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			// For test purposes
			usleep(1000000)
			
			let contentsOfURL = try? Data(contentsOf: url)
			guard let imageData = contentsOfURL else { return }
			DispatchQueue.main.async {
				if url == self?.imageURL {
					self?.spinner.stopAnimating()
					self?.imageObj = UIImage(data: imageData)
				}
			}
		}
		
	}
	
	/*
	
	override func awakeFromNib() {
	super.awakeFromNib()
	// Initialization code
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
	super.setSelected(selected, animated: animated)
	
	// Configure the view for the selected state
	}*/
	
}
