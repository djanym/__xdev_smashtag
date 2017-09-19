//
//  TweetDetailsVC.swift
//  Smashtag
//
//  Created by Naili Concescu on 1438/12/15.
//  Copyright © 1438 Naili Concescu. All rights reserved.
//

import UIKit
import Twitter
import SafariServices

class TweetDetailsVC: UITableViewController {
	
	public var tweet: Twitter.Tweet? {
		didSet {
			guard let tweet = tweet else { return }
			initMensionSections(from: tweet)
			tableView.reloadData()
		}
	}
	
	// MARK: - Внутренняя структура данных
	
	private var mentionSections = [MentionSection]() // массив секций
	
	private struct MentionSection {  // секция
		var header: String
		var mentions: [MentionItem]
	}
	
	private enum MentionItem {     // строка
		case keyword(String)
		case image(URL, Double)
		
	}
	
	private func initMensionSections(from tweet:Twitter.Tweet) {
		var sections = [MentionSection]()
		
		if tweet.media.count > 0 {
			sections.append( MentionSection(header: "",
			                                mentions: tweet.media.map{ MentionItem.image($0.url, $0.aspectRatio) }))
		}
		if tweet.urls.count > 0 {
			sections.append( MentionSection(header: "Tweet URLs",
			                                mentions: tweet.urls.map{ MentionItem.keyword($0.keyword)}))
		}
		if tweet.hashtags.count > 0 {
			sections.append( MentionSection(header: "Tweet Hashtags",
			                                mentions: tweet.hashtags.map{ MentionItem.keyword($0.keyword)}))
		}
		if tweet.userMentions.count > 0 {
			sections.append( MentionSection(header: "Mentioned Users",
			                                mentions: tweet.userMentions.map{ MentionItem.keyword($0.keyword)}))
		}
		
		mentionSections = sections
	}

	override func viewDidLoad() {
        super.viewDidLoad()
		title = "Mentions"
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = tableView.rowHeight
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return mentionSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentionSections[section].mentions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let tweet = mentionSections[indexPath.section].mentions[indexPath.row]
		var cell: UITableViewCell
		
		switch tweet {
		case .image(let url, _):
			cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath)
			if let imageCell = cell as? TweetDetailsImageCell {
				imageCell.imageURL = url
			}
		case .keyword(let keyword):
			cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
			cell.textLabel?.text = keyword
		}
		
        return cell
	}
	
	// Set header per section
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return mentionSections[section].header
	}
	
	// Set row height
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let tweet = mentionSections[indexPath.section].mentions[indexPath.row]
		switch tweet {
		case .image(_, let ratio):
			return tableView.bounds.size.width / CGFloat(ratio)
		case .keyword:
			return UITableViewAutomaticDimension
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		var headerHeight = UITableViewAutomaticDimension
		let header = mentionSections[section].header
		switch header {
		case "":
			// hide the header 
			headerHeight = CGFloat.leastNonzeroMagnitude
		default: break
		}
		return headerHeight
	}
	
	/*
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let searchVC = TweetTableVC()
		//searchVC.show(self, sender: self)
		navigationController?.pushViewController(searchVC, animated: true)
		//navigationController!.popToViewController(navigationController!.viewControllers[1], animated: true)
		//		navigationController?.popToRootViewController(animated: true)
	}
*/
	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let identifier = segue.identifier {
			switch identifier {
			case "searchFromMention":
				if let tweetsVC = segue.destination as? TweetTableVC, let mentionCell = sender as? UITableViewCell {
					tweetsVC.searchText = mentionCell.textLabel?.text
					tweetsVC.navigationItem.backBarButtonItem = nil
				}
			case "showImage":
				if let imageVC = segue.destination.contents as? TweetImageVC, let mentionCell = sender as? TweetDetailsImageCell {
					imageVC.image = mentionCell.imageObj
				}
			default: break
			}
		}
    }
	
	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		if identifier == "searchFromMention" {
			if let mentionCell = sender as? UITableViewCell {
				guard let maybeURL = mentionCell.textLabel?.text else { return true }
				if let url = URL(string: maybeURL), UIApplication.shared.canOpenURL(url) {
					if #available(iOS 9.0, *) {
						let safariVC = SFSafariViewController(url: url)
						present(safariVC, animated: true, completion: nil)
					}
					else {
						UIApplication.shared.openURL(url)
					}
					//					if #available(iOS 10.0, *) {
					//						UIApplication.shared.open(url, options: [:],
					//						                          completionHandler: nil)
					//					}
					//					else {
					//						UIApplication.shared.openURL(url)
					//					}
					return false
				}
			}
		}
		return true
	}

}

extension UIViewController {
	// this var returns the "contents" of this UIViewController
	// which, if this UIViewController is a UINavigationController
	// means "the UIViewController contained in me (and visible)"
	// otherwise, it just means the UIViewController itself
	// could easily imagine extending this for UITabBarController too
	var contents: UIViewController {
		if let navcon = self as? UINavigationController {
			return navcon.visibleViewController ?? self
		} else {
			return self
		}
	}
}
