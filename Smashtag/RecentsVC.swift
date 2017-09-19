//
//  RecentsVC.swift
//  Smashtag
//
//  Created by Naili Concescu on 1438/12/19.
//  Copyright © 1438 Naili Concescu. All rights reserved.
//

import UIKit

class RecentsVC: UITableViewController {
	
	private var terms: [String] {
		return Queries.terms
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Queries.terms.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "queryCell", for: indexPath)
		
		let index = indexPath.row
		cell.textLabel?.text = Queries.terms[index]
		
        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let searchTerm = terms[indexPath.row]
		if let controllers = tabBarController?.viewControllers, let nav = controllers[0] as? UINavigationController {
			nav.popToRootViewController(animated: false)
			if let searchVC = nav.contents as? TweetTableVC {
				searchVC.searchText = searchTerm
			}
		}
		
		// Switch to first tab
		tabBarController?.selectedIndex = 0
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			Queries.remove(term: terms[indexPath.row] )
			tableView.deleteRows(at: [indexPath], with: .middle)
		}
	}
	
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destinationVC = segue.destination.contents as? TweetTableVC, let cell = sender as? UITableViewCell {
			destinationVC.searchText = cell.textLabel?.text
		}
    }
	
}
