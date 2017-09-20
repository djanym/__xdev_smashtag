//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Naili Concescu on 1438/12/5.
//  Copyright © 1438 Naili Concescu. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {

	@IBOutlet weak var tweetProfileImageView: UIImageView!
	@IBOutlet weak var tweetCreatedLabel: UILabel!
	@IBOutlet weak var tweetUserLabel: UILabel!
	@IBOutlet weak var tweetTextLabel: UILabel!
	@IBOutlet weak var spinnerProfileImage: UIActivityIndicatorView!
	
	struct Palette {
		static let hashtagColor = UIColor.purple
		static let urlColor = UIColor.blue
		static let userColor = UIColor.orange
	}
	
	// public API of this UITableViewCell subclass
	// each row in the table has its own instance of this class
	// and each instance will have its own tweet to show
	// as set by this var
	var tweet: Twitter.Tweet? { didSet { updateUI() } }
	
	// whenever our public API tweet is set
	// we just update our outlets using this method
	private func updateUI() {
		tweetTextLabel?.attributedText = setTextLabel(tweet)
		tweetUserLabel?.text = tweet?.user.description
		//tweetUserLabel?.textColor = UIColor.blue
		setProfileImage(tweet)
		
		
		if let created = tweet?.created {
			let formatter = DateFormatter()
			if Date().timeIntervalSince(created) > 24*60*60 {
				formatter.dateStyle = .short
			} else {
				formatter.timeStyle = .short
			}
			tweetCreatedLabel?.text = formatter.string(from: created)
		} else {
			tweetCreatedLabel?.text = nil
		}
	}
	
	private func setProfileImage(_ tweet: Twitter.Tweet?){
		tweetProfileImageView?.image = nil
		spinnerProfileImage.startAnimating()
		
		if let profileImageURL = tweet?.user.profileImageURL {
			DispatchQueue.global(qos: .userInitiated).async { [weak self] in
				
				// For test purposes
				usleep(1000000)
				
				let contentsOfURL = try? Data(contentsOf: profileImageURL)
				if let imageData = contentsOfURL  {
					
					DispatchQueue.main.async {
						
						if profileImageURL == self?.tweet?.user.profileImageURL {
							self?.spinnerProfileImage.stopAnimating()
							self?.tweetProfileImageView?.image = UIImage(data: imageData)
						}
					}
					
					
				}
				
			}
		}

	}
	
	private func setTextLabel(_ tweet: Twitter.Tweet?) -> NSMutableAttributedString {
		guard let tweet = tweet else {return NSMutableAttributedString(string: "")}
		let tweetText: String = tweet.text
		//for _ in tweet.media {tweetText += " 📷"}
		
		let attributedText = NSMutableAttributedString(string: tweetText)
		
		attributedText.setMensionsColor(tweet.hashtags, color: Palette.hashtagColor)
		attributedText.setMensionsColor(tweet.urls, color: Palette.urlColor)
		attributedText.setMensionsColor(tweet.userMentions, color: Palette.userColor)
		
		return attributedText
	}
}

// MARK: - Расширение

private extension NSMutableAttributedString {
	func setMensionsColor(_ mensions: [Mention], color: UIColor) {
		for mension in mensions {
			addAttribute(NSAttributedStringKey.foregroundColor, value: color,
			             range: mension.nsrange)
		}
	}
}
