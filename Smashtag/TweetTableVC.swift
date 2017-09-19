//
//  TweetTableVC.swift
//  Smashtag
//
//  Created by Naili Concescu on 1438/12/5.
//  Copyright © 1438 Naili Concescu. All rights reserved.
//

import UIKit
import Twitter

class TweetTableVC: UITableViewController, UITextFieldDelegate {
	
	private var tweets = [Array<Twitter.Tweet>]() {
		didSet {
			//print(tweets)
		}
	}
	
	private var lastTwitterRequest: Twitter.Request?
	
	var searchText: String? {
		didSet {
			searchTextField?.text = searchText
			searchTextField?.resignFirstResponder()
			Queries.add(search: searchText)
			lastTwitterRequest = nil
			tweets.removeAll()
			tableView.reloadData()
			searchForTweets()
			self.navigationItem.title = searchText
		}
	}
	
	@IBAction func refresh(_ sender: UIRefreshControl) {
		searchForTweets()
	}
	
	internal func insertTweets(_ newTweets: [Twitter.Tweet]){
		self.tweets.insert(newTweets, at: 0)
		self.tableView.insertSections([0], with: .fade)
	}
	
	private func searchForTweets() {
		if let request = lastTwitterRequest?.newer ?? twitterRequest() {
			lastTwitterRequest = request
			request.fetchTweets{ [weak self] newTweets in
				DispatchQueue.main.async {
					if request == self?.lastTwitterRequest {
						self?.insertTweets(newTweets)
					}
					self?.refreshControl?.endRefreshing()
				}
			}
		}
		else {
			refreshControl?.endRefreshing()
		}
	}
	
	private func twitterRequest() -> Twitter.Request? {
		if let query = searchText, !query.isEmpty {
			return Twitter.Request(search: query, count: 10)
		}
		return nil
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// Hide back button when transition is in process
		self.navigationItem.hidesBackButton = true
		// Clears stack history
		self.navigationController?.viewControllers = [self]
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.estimatedRowHeight = 50
		tableView.rowHeight = UITableViewAutomaticDimension
		
		if searchText == nil {
			if let lastSearch = Queries.terms.first {
				searchText = lastSearch
			}
		}
	}
	
	@IBOutlet weak var searchTextField: UITextField! {
		didSet {
			searchTextField.delegate = self
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == searchTextField {
			searchText = searchTextField.text
		}
		return true
	}

    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

	// Set cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet", for: indexPath)

        // Configure the cell...
		let tweet: Twitter.Tweet = tweets[indexPath.section][indexPath.row]
		
		if let tweetCell = cell as? TweetTableViewCell {
			tweetCell.tweet = tweet
			return tweetCell
		}
		
        return cell
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let identifier = segue.identifier {
			switch identifier {
				case "tweetDetails":
					if let tweetDetailsVC = segue.destination as? TweetDetailsVC, let tweetCell = sender as? TweetTableViewCell {
						tweetDetailsVC.tweet = tweetCell.tweet
					}
				default: break
			}
		}
	}

}
