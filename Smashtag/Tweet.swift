//
//  Tweet.swift
//  Smashtag
//
//  Created by Naili Concescu on 1438/12/27.
//  Copyright © 1438 Naili Concescu. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class Tweet: NSManagedObject {
	class func findOrCreateTweet(matching tweetInfo: Twitter.Tweet, searchTerm: String, in context: NSManagedObjectContext) throws -> Tweet {
		let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
		request.predicate = NSPredicate(format: "unique = %@", tweetInfo.identifier)
		do {
			let matches = try context.fetch(request)
			if matches.count > 0 {
				assert(matches.count == 1, "\(#file).\(#function) -- database inconsistency")
				return matches[0]
			}
		}
		catch {
			throw error
		}
		
		let tweet = Tweet(context: context)
		tweet.unique = tweetInfo.identifier
		tweet.text = tweetInfo.text
		//tweet.created = tweetInfo.created as NSDate
		tweet.tweeter = try? TwitterUser.findOrCreateTwitterUser(matching: tweetInfo.user, in: context)
		
		// Add popular statistics from new mention only
		try? Popular.addOrUpdateMentions(from: tweetInfo, for: searchTerm, in: context)
		
		return tweet
	}
	
	class func tweetCountFor(mention: String?, tweeter: TwitterUser) -> Int{
		guard let mention = mention else { return 0 }
		let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
		request.predicate = NSPredicate(format: "text CONTAINS[cd] %@ AND tweeter = %@", mention, tweeter)
		return ( try? tweeter.managedObjectContext!.count(for: request) ) ?? 0
	}
}
