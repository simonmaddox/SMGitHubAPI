//
//  GitHubCommit.h
//  GitHub
//
//  Created by Simon Maddox on 08/11/2010.
//  Copyright 2010 Sensible Duck Ltd. All rights reserved.
//

#import <CoreData/CoreData.h>

@class GitHubBranch;
@class GitHubUser;

@interface GitHubCommit :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * authored_date;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * tree;
@property (nonatomic, retain) NSString * committed_date;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) GitHubUser * author;
@property (nonatomic, retain) GitHubBranch * branch;
@property (nonatomic, retain) GitHubUser * committer;

@end



