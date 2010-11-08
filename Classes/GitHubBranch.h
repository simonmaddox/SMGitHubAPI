//
//  GitHubBranch.h
//  GitHub
//
//  Created by Simon Maddox on 08/11/2010.
//  Copyright 2010 Sensible Duck Ltd. All rights reserved.
//

#import <CoreData/CoreData.h>

@class GitHubRepository;

@interface GitHubBranch :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * ref;
@property (nonatomic, retain) GitHubRepository * repository;
@property (nonatomic, retain) NSSet* commits;

@end


@interface GitHubBranch (CoreDataGeneratedAccessors)
- (void)addCommitsObject:(NSManagedObject *)value;
- (void)removeCommitsObject:(NSManagedObject *)value;
- (void)addCommits:(NSSet *)value;
- (void)removeCommits:(NSSet *)value;

@end

