//
//  SmashTweetTableVC.swift
//  Smashtag
//
//  Created by Naili Concescu on 1438/12/27.
//  Copyright © 1438 Naili Concescu. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class SmashTweetTableVC: TweetTableVC {
	
	// DB
	var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
	
	override func insertTweets(_ newTweets: [Twitter.Tweet]){
		super.insertTweets(newTweets)
		updateDB(with: newTweets)
	}
	
	private func updateDB(with tweets: [Twitter.Tweet]){
		container?.performBackgroundTask{ [weak self] context in
			for tweetInfo in tweets {
				_ = try? Tweet.findOrCreateTweet(matching: tweetInfo, in: context)
			}
			try? context.save()
			
			self?.printDBStatistics()
		}
	}
	
	private func printDBStatistics(){
		guard let context = container?.viewContext else { return }
		
		context.perform {
			if Thread.isMainThread {
				print("Is main thread")
			}
			else {
				print("Off main thread")
			}
			
			let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
			if let tweetCount = (try? context.fetch( request ) )?.count {
				print("\(tweetCount) tweets")
			}
			
			if let tweeterCount = try? context.count( for: TwitterUser.fetchRequest() ) {
				print("\(tweeterCount) users")
			}
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		
		if let identifier = segue.identifier {
			switch identifier {
			case "showMentionTweeters":
				if let tweetersTVC = segue.destination as? MentionTweetersTableVC {
					tweetersTVC.container = container
					tweetersTVC.mention = searchText
				}
			default: break
			}
		}
	}

}
