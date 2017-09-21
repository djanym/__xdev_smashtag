//
//  PopularityTVC.swift
//  Smashtag
//
//  Created by Naili Concescu on 1438/12/29.
//  Copyright © 1438 Naili Concescu. All rights reserved.
//

import UIKit
import CoreData

class PopularityTVC: FetchedResultsTableViewController {

	var searchText: String? { didSet { updateUI() } }
	
	// DB
	var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
	
	private var fetchedResultsController: NSFetchedResultsController<TwitterUser>?
	
	private var searchSections = [Section]()
	
	private struct Section {
		var headerTitle: String
		var type: SectionType
		var rows: NSFetchedResultsController<Popular>
		enum SectionType {
			case tweeters
			case hashtags
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		title = searchText
	}
	
	private func updateUI(){
		initSections()
		tableView.reloadData()
	}
	
	private func initSections(){
		searchSections = [Section]() // clean sections
		
		if let context = container?.viewContext, let searchText = searchText {
			let request : NSFetchRequest<Popular> = Popular.fetchRequest()
			request.predicate = NSPredicate(format: "term = %@ AND type = %@ AND count > 1", searchText, "tweeter")
			request.sortDescriptors = [NSSortDescriptor(key: "count", ascending: false)]
			
			let tweeters = NSFetchedResultsController<Popular>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
			tweeters.delegate = self
			try? tweeters.performFetch()
			
			if let sections = tweeters.sections, sections[0].numberOfObjects > 0 {
				searchSections.append( Section(headerTitle: "Tweeters", type: .tweeters, rows: tweeters ) )
			}
			
			request.predicate = NSPredicate(format: "term = %@ AND type = %@ AND count > 1", searchText, "hashtag")
			let hashtags = NSFetchedResultsController<Popular>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
			hashtags.delegate = self
			try? hashtags.performFetch()
			
			if let sections = hashtags.sections, sections[0].numberOfObjects > 0 {
				searchSections.append( Section(headerTitle: "Hashtags", type: .hashtags, rows: hashtags ) )
			}
		}
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return searchSections.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let sections = searchSections[section].rows.sections, sections.count > 0 {
			return sections[0].numberOfObjects
		}
		return 0
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return searchSections[section].headerTitle
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let mention = searchSections[indexPath.section].rows.object(at: IndexPath(row: indexPath.row, section: 0))
		cell.textLabel?.text = mention.mention
		cell.detailTextLabel?.text = String(mention.count)
		cell.detailTextLabel?.textColor = UIColor.blue
		
		return cell
	}
}
