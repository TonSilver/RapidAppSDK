//
//  RADataBase.h
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


// Notification about complenting of database opening operation (object is used database), may be with error
extern NSString *RADataBaseIsReadyNotification;
// Error occured during database initialization
extern NSString *RADataBaseIsReadyNotificationError;


@class RADataBase;
@protocol RADataBaseDelegate <NSObject>
@optional
- (void)primaryInitializationsForDataBase:(RADataBase *)database withContext:(NSManagedObjectContext *)context;
@end


@interface RADataBase : NSObject

// Delegate
@property (nonatomic, assign) id <RADataBaseDelegate> delegate;

// URL to database model, for example: [[NSBundle mainBundle] URLForResource:@"DataBase" withExtension:@"momd"]
@property (nonatomic, retain) NSURL *modelURL;
// Path to sqlite datbase, default: "RADataBase.sqlite" in NSCachesDirectory at NSUserDomainMask
@property (nonatomic, retain) NSURL *databaseURL;
// Name of database (ignored if databaseURL is defined)
@property (nonatomic, retain) NSString *databaseName;

// "Yes" when database is opened
@property (atomic, assign, readonly) BOOL isReady;
// Contains last error occured
@property (atomic, retain, readonly) NSError *lastError;

// DataBase model
@property (atomic, retain, readonly) NSManagedObjectModel *model;

// Both contexts are used without "Undo Manager"
@property (atomic, retain, readonly) NSManagedObjectContext *readContext;
@property (atomic, retain, readonly) NSManagedObjectContext *writeContext;

// Единажды создает экземпляр данного класса
+ (instancetype)shared;

// "Open" function is delayed and it will notify programm when it will be completed
- (void)open;
// Simple combination of "Close" and "Open" functions
- (void)reopen;
// Just "Closes" database and releases all memory
- (void)close;

// Saves database (only writeContext)
- (BOOL)save:(NSError **)error;

// Removes used database in file system and "Closes" database
- (void)clean;

#pragma mark Accessors

+ (id)objectOfEntity:(NSString *)entity withParams:(NSDictionary *)params fromContext:(NSManagedObjectContext *)context;
+ (id)objectsOfEntity:(NSString *)entity withParams:(NSDictionary *)params andNotSatisfyingParams:(NSDictionary *)notParams fromContext:(NSManagedObjectContext *)context;
+ (NSArray *)objectsOfEntity:(NSString *)entity withParams:(NSDictionary *)params fromContext:(NSManagedObjectContext *)context;

#pragma mark Updading system

- (void)beginUpdatingObjectsOfEntity:(NSEntityDescription *)entity confirmingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
- (id)updatingObjectOfEntity:(NSEntityDescription *)entity confirmingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;
- (void)endUpdatingObjectsOfEntity:(NSEntityDescription *)entity confirmingPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;

- (id)objectOfEntity:(NSEntityDescription *)entity confirmingPredicate:(NSPredicate *)predicate withValues:(NSDictionary *)values inContext:(NSManagedObjectContext *)context createIfAbsent:(BOOL)create;

@end
