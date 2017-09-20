//
//  MentionTweetersTableVC.swift
//  Smashtag
//
//  Created by Naili Concescu on 1438/12/29.
//  Copyright © 1438 Naili Concescu. All rights reserved.
//

import UIKit
import CoreData

class MentionTweetersTableVC: FetchedResultsTableViewController {
	
	var mention: String? { didSet { updateUI() } }
	// DB
	var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
	
	fileprivate var fetchedResultsController: NSFetchedResultsController<TwitterUser>?
	
	private func updateUI(){
		if let context = container?.viewContext, mention != nil {
			
			let request : NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
			request.predicate = NSPredicate(format: "ANY tweets.text CONTAINS[cd] %@ AND ! handle BEGINSWITH[c] %@", mention!, "weather")
			request.sortDescriptors = [NSSortDescriptor(key: "handle", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)) )]
			
			fetchedResultsController = NSFetchedResultsController<TwitterUser>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
			// This was in the lection 11. But wWhy ???
			fetchedResultsController?.delegate = self
			try? fetchedResultsController?.performFetch()
			tableView.reloadData()
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "tweeterCell", for: indexPath)
		if let tweeter = fetchedResultsController?.object(at: indexPath) {
			cell.textLabel?.text = tweeter.handle
			let tweetCount = Tweet.tweetCountFor(mention: mention, tweeter: tweeter)
			cell.detailTextLabel?.text = "\(tweetCount) tweet" + ( tweetCount > 1 ? "s" : "")
			cell.detailTextLabel?.textColor = UIColor.red
		}
		return cell
	}

}

extension MentionTweetersTableVC
{
	// MARK: UITableViewDataSource
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultsController?.sections?.count ?? 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let sections = fetchedResultsController?.sections, sections.count > 0 {
			return sections[section].numberOfObjects
		} else {
			return 0
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if let sections = fetchedResultsController?.sections, sections.count > 0 {
			return sections[section].name
		} else {
			return nil
		}
	}
	
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return fetchedResultsController?.sectionIndexTitles
	}
	
	override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
	}
}
