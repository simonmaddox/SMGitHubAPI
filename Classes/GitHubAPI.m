//
//  GitHubAPI.m
//  GitHub
//
//  Created by Simon Maddox on 07/11/2010.
//  Copyright 2010 Sensible Duck Ltd. All rights reserved.
//

#import "GitHubAPI.h"

#import "SFHFKeychainUtils.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"

#import "GitHubUser.h"
#import "GitHubPlan.h"
#import "GitHubRepository.h"
#import "GitHubBranch.h"
#import "GitHubCommit.h"

#define KeyChainService @"GitHub"
#define ReturnDataFormat @"json"

@interface GitHubAPI () <ASIHTTPRequestDelegate>

- (GitHubUser *) userForURL:(NSURL *)url;

- (GitHubRepository *) repositoryForDictionary:(NSDictionary *)repoDictionary;
- (NSSet *) usersForRepository:(GitHubRepository *)repo ofType:(NSString *)type;
- (GitHubBranch *) branchWithName:(NSString *)name ref:(NSString *) ref;
- (GitHubCommit *) commitForDictionary:(NSDictionary *) dictionary;

- (NSDictionary *) dataForURL:(NSURL *)url;
- (NSString *)applicationDocumentsDirectory;

@end


@implementation GitHubAPI

@synthesize username, me;

- (void) dealloc
{
	self.username = nil;
	self.me = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Authentication
- (BOOL) authenticateWithUsername:(NSString *)gitHubUsername password:(NSString *)gitHubPassword
{
	NSError *error = nil;	
	[SFHFKeychainUtils storeUsername:gitHubUsername andPassword:gitHubPassword forServiceName:KeyChainService updateExisting:YES error:&error];
	self.username = gitHubUsername;
	
	GitHubUser *user = [self userForURL:[NSURL URLWithString:@"http://github.com/api/v2/json/user/show"]];
	
	if (user.plan != nil){
		self.me = user;
		return YES;
	} else {
		NSLog(@"%@", user);
		return NO;
	}
}

- (void) logout
{
	NSError *error = nil;
	[SFHFKeychainUtils deleteItemForUsername:self.username andServiceName:KeyChainService error:&error];
}

#pragma mark -
#pragma mark Users

- (GitHubUser *) userForURL:(NSURL *)url
{
	NSDictionary *userDictionary = [self dataForURL:url];
	
	GitHubPlan *plan = nil;
	NSMutableDictionary *userDictionaryWithoutPlan = [NSMutableDictionary dictionaryWithDictionary:userDictionary];
	
	if ([userDictionary valueForKeyPath:@"user.plan"] != nil){
		plan = [NSEntityDescription insertNewObjectForEntityForName:[[NSEntityDescription entityForName:@"GitHubPlan" inManagedObjectContext:self.managedObjectContext] name] inManagedObjectContext:self.managedObjectContext];
		
		for (NSString *key in [userDictionary valueForKeyPath:@"user.plan"]){
			[plan setValue:[[userDictionary valueForKeyPath:@"user.plan"] objectForKey:key] forKey:key];
		}
		
		[[userDictionaryWithoutPlan objectForKey:@"user"] removeObjectForKey:@"plan"];
	}	
	
	
	GitHubUser *user = [NSEntityDescription insertNewObjectForEntityForName:[[NSEntityDescription entityForName:@"GitHubUser" inManagedObjectContext:self.managedObjectContext] name] inManagedObjectContext:self.managedObjectContext];
	
	for (NSString *key in [userDictionaryWithoutPlan valueForKeyPath:@"user"]){
		id value = [[userDictionaryWithoutPlan valueForKeyPath:@"user"] objectForKey:key];
		if ([value isEqual:[NSNull null]]){
			value = nil;
		}
		
		[user setValue:value forKey:key];
	}
	
	[user setPlan:plan];
	
	return user;
}

- (GitHubUser *) userForUsername:(NSString *)gitHubUsername
{
	return [self userForURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://github.com/api/v2/json/user/show/%@", gitHubUsername]]];
}

#pragma mark -
#pragma mark Repositories

- (GitHubRepository *) repositoryForURL:(NSURL *)url
{
	return [self repositoryForDictionary:[self dataForURL:url]];	
}

- (void) addAllDataToRepository:(GitHubRepository *) repo
{
	[self addExtraUsersToRepository:repo];
	[self addNetworkToRepository:repo];
	[self addBranchesToRepository:repo];
	
	for (GitHubBranch *branch in [repo branches]){
		[self addCommitsForBranch:branch];
	}
}

- (void) addRepositoriesToUser:(GitHubUser *) user
{
	NSDictionary *repos = [self dataForURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://github.com/api/v2/json/repos/show/%@", [user login]]]];

	for (NSDictionary *repoDict in [repos objectForKey:@"repositories"]){
		GitHubRepository *repo = [self repositoryForDictionary:repoDict];
		[repo setOwnerUser:user];
		[user addRepositoriesObject:repo];
	}
}

- (GitHubRepository *) repositoryForDictionary:(NSDictionary *)repoDictionary
{

	GitHubRepository *repo = [NSEntityDescription insertNewObjectForEntityForName:[[NSEntityDescription entityForName:@"GitHubRepository" inManagedObjectContext:self.managedObjectContext] name] inManagedObjectContext:self.managedObjectContext];
		
	for (NSString *key in repoDictionary){
		id value = [repoDictionary objectForKey:key];
		if ([value isEqual:[NSNull null]]){
			value = nil;
		}
		
		if ([key isEqualToString:@"description"]){
			key = @"description_noClash";
		}
		
		[repo setValue:value forKey:key];
	}
	
	return repo;
}

- (NSSet *) usersForRepository:(GitHubRepository *)repo ofType:(NSString *)type
{
	NSDictionary *users = [self dataForURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://github.com/api/v2/json/repos/show/%@/%@/%@", [repo owner], [repo name], type]]];
	
	NSMutableSet *userSet = [NSMutableSet set];
	
	GitHubUser *user = nil;
	
	// FIXME: This is a nasty hack because GitHub returns a different response structure for collaborators and watchers to contributors
	if ([type isEqualToString:@"collaborators"] || [type isEqualToString:@"watchers"]){
		for (NSString *theUser in [users objectForKey:type]){
			user = [self userForUsername:theUser];
		}
	} else {
		for (NSDictionary *theUser in [users objectForKey:type]){
			user = [self userForUsername:[theUser objectForKey:type]];
		}
	}
	
	[userSet addObject:user];
	
	return [NSSet setWithSet:userSet];
}

- (void) addCollaboratorsToRepository:(GitHubRepository *) repo
{
	[repo addCollaboratorUsers:[self usersForRepository:repo ofType:@"collaborators"]];
}

- (void) addWatchersToRepository:(GitHubRepository *)repo
{
	[repo addWatcherUsers:[self usersForRepository:repo ofType:@"watchers"]];
}

- (void) addContributorsToRepository:(GitHubRepository *) repo
{
	[repo addContributorUsers:[self usersForRepository:repo ofType:@"contributors"]];
}

- (void) addExtraUsersToRepository:(GitHubRepository *) repo
{
	[self addCollaboratorsToRepository:repo];
	[self addWatchersToRepository:repo];
	[self addContributorsToRepository:repo];
}

- (void) addNetworkToRepository:(GitHubRepository *) repo
{
	NSDictionary *repos = [self dataForURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://github.com/api/v2/json/repos/show/%@/%@/network", [repo owner], [repo name]]]];
	
	for (NSDictionary *repository in [repos objectForKey:@"network"]){
		GitHubRepository *networkRepo = [self repositoryForDictionary:repository];
		[repo addNetworkObject:networkRepo];
	}
}

#pragma mark -
#pragma mark Branches

- (void) addBranchesToRepository:(GitHubRepository *)repo
{
	NSDictionary *branches = [self dataForURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://github.com/api/v2/json/repos/show/%@/%@/branches", [repo owner], [repo name]]]];
	for (NSString *key in [branches objectForKey:@"branches"]){
		GitHubBranch *theBranch = [self branchWithName:key ref:[[branches objectForKey:@"branches"] objectForKey:key]];
		[repo addBranchesObject:theBranch];
	}
}

- (GitHubBranch *) branchWithName:(NSString *)name ref:(NSString *) ref
{
	GitHubBranch *branch = [NSEntityDescription insertNewObjectForEntityForName:[[NSEntityDescription entityForName:@"GitHubBranch" inManagedObjectContext:self.managedObjectContext] name] inManagedObjectContext:self.managedObjectContext];
	[branch setName:name];
	[branch setRef:ref];
	
	return branch;
}

#pragma mark -
#pragma mark Commits

- (void) addCommitsForBranch:(GitHubBranch *) branch
{
	NSMutableArray *commits = [NSMutableArray array];
	NSDictionary *commitDictionary = [self dataForURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://github.com/api/v2/json/commits/list/%@/%@/%@", branch.repository.owner, branch.repository.name, branch.name]]];
		
	for (NSDictionary *thisCommit in [commitDictionary objectForKey:@"commits"]){	
		GitHubCommit *commit = [self commitForDictionary:thisCommit];
		[commit setBranch:branch];
		[commits addObject:commit];
	}
	
	[branch addCommits:[NSSet setWithArray:commits]];
}

- (GitHubCommit *) commitForDictionary:(NSDictionary *) dictionary
{
	GitHubCommit *commit = [NSEntityDescription insertNewObjectForEntityForName:[[NSEntityDescription entityForName:@"GitHubCommit" inManagedObjectContext:self.managedObjectContext] name] inManagedObjectContext:self.managedObjectContext];
	
	[commit setUrl:[dictionary objectForKey:@"url"]];
	[commit setId:[dictionary objectForKey:@"id"]];
	[commit setCommitted_date:[dictionary objectForKey:@"committed_date"]];
	[commit setAuthored_date:[dictionary objectForKey:@"authored_date"]];
	[commit setMessage:[dictionary objectForKey:@"message"]];
	[commit setTree:[dictionary objectForKey:@"tree"]];
	
	
	GitHubUser *author = [self userForUsername:[dictionary valueForKeyPath:@"author.login"]];
	[commit setAuthor:author];
	
	GitHubUser *committer = [self userForUsername:[dictionary valueForKeyPath:@"committer.login"]];
	[commit setCommitter:committer];
	
	return commit;
	
}

#pragma mark -
#pragma mark HTTP Requests

// TODO: Abstract this into NSOperationQueue
- (NSDictionary *) dataForURL:(NSURL *)url
{
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	
	if (self.username != nil){
		[request setUsername:self.username];
		NSError *error = nil;
		[request setPassword:[SFHFKeychainUtils getPasswordForUsername:self.username andServiceName:KeyChainService error:&error]];
	}
	
	[request setDelegate:self];
	[request setDidFailSelector:@selector(requestFailed:)];
	[request setDidFinishSelector:@selector(requestFinished:)];
	
	httpRequestComplete = NO;
	
	[request startAsynchronous];
	
	while (!httpRequestComplete){
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
	
	NSDictionary *thisFetch = [NSDictionary dictionaryWithDictionary:lastFetch];
	[lastFetch release]; lastFetch = nil;
	
	return thisFetch;
}

- (void) requestFailed:(ASIHTTPRequest *) request
{
	//lastError = [[request error] copy];
	NSLog(@"HTTP ERROR: %@ FOR URL: %@", [request error], [request originalURL]);
	httpRequestComplete = YES;
}

- (void) requestFinished:(ASIHTTPRequest *) request
{
	lastFetch = [[NSDictionary alloc] initWithDictionary:[[request responseString] JSONValue]];
	httpRequestComplete = YES;
	
	NSLog(@"%@", [request responseString]);
}

#pragma mark -
#pragma mark CoreData

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
		[managedObjectContext_ setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    }
    return [managedObjectContext_ retain];
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"GitHub" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"GitHub.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator_;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


@end
