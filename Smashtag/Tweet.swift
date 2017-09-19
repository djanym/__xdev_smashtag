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
	class func findOrCreateTweet(matching tweetInfo: Twitter.Tweet, in context: NSManagedObjectContext) throws -> Tweet {
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
		tweet.created = tweetInfo.created as NSDate
		tweet.tweeter = try? TwitterUser.findOrCreateTwitterUser(matching: tweetInfo.user, in: context)
		
		return tweet
	}
}
