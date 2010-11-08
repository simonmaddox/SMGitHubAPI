//
//  GitHubPlan.h
//  GitHub
//
//  Created by Simon Maddox on 07/11/2010.
//  Copyright 2010 Sensible Duck Ltd. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface GitHubPlan :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * private_repos;
@property (nonatomic, retain) NSNumber * collaborators;
@property (nonatomic, retain) NSNumber * space;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSManagedObject * users;

@end



