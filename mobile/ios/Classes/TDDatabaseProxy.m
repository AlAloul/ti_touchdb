//
//  TDDatabaseProxy.m
//  titouchdb
//
//  Created by Paul Mietz Egli on 12/10/12.
//
//

#import "TDDatabaseProxy.h"
#import "TiProxy+Errors.h"
#import "TDDocumentProxy.h"
#import "TDQueryProxy.h"
#import "TDViewProxy.h"
#import "TDReplicationProxy.h"
#import "TDBridge.h"

@interface TDDatabaseProxy ()
@property (nonatomic, strong) CBLDatabase * database;
@property (nonatomic, strong) NSMutableDictionary * documentProxyCache;
@end

@implementation TDDatabaseProxy

{
    NSError * lastError;
}

extern NSString* const kCBLDatabaseChangeNotification;

- (id)initWithExecutionContext:(id<TiEvaluator>)context CBLDatabase:(CBLDatabase *)database {
    if (self = [super _initWithPageContext:context]) {
        self.database = database;
        self.documentProxyCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"TDDatabaseProxy [%@]", self.database.name];
}

#pragma mark Database Properties

- (id)name {
    return self.database.name;
}

- (id)lastSequenceNumber {
    return [NSNumber numberWithInt:self.database.lastSequenceNumber];
}

- (id)documentCount {
    return [NSNumber numberWithInt:self.database.documentCount];
}

- (id)maxRevTreeDepth {
    return NUMINT(self.database.maxRevTreeDepth);
}

- (void)setMaxRevTreeDepth:(id)value {
    self.database.maxRevTreeDepth = [value unsignedIntegerValue];
}

#pragma mark Public API

- (id)compact:(id)args {
    RELEASE_TO_NIL(lastError)

    BOOL result = [self.database compact:&lastError];
    return NUMBOOL(result);
}

- (id)deleteDatabase:(id)args {
    RELEASE_TO_NIL(lastError)

    BOOL result = [self.database deleteDatabase:&lastError];
    return NUMBOOL(result);
}

- (id)getDocument:(id)args {
    NSString * docID;
    ENSURE_ARG_OR_NULL_AT_INDEX(docID, args, 0, NSString);
    
    RELEASE_TO_NIL(lastError)
    
    if (!docID) {
        return [self createDocument:nil];
    }
    
    TDDocumentProxy * proxy = [self.documentProxyCache objectForKey:docID];
    if (!proxy) {
        CBLDocument * doc = [self.database documentWithID:docID];
        if (!doc) {
            return nil;
        }
        proxy = [[TDDocumentProxy alloc] initWithExecutionContext:[self executionContext] CBLDocument:doc];
        [self.documentProxyCache setObject:proxy forKey:docID];
    }
    return proxy;
}

- (id)existingDocumentWithID:(id)args {
    NSString * docID;
    ENSURE_ARG_AT_INDEX(docID, args, 0, NSString);
    
    RELEASE_TO_NIL(lastError)
    
    if (!docID) {
        // TODO set lastError
        return nil;
    }
    
    TDDocumentProxy * proxy = [self.documentProxyCache objectForKey:docID];
    if (!proxy) {
        CBLDocument * doc = [self.database existingDocumentWithID:docID];
        if (!doc) {
            return nil;
        }
        proxy = [[TDDocumentProxy alloc] initWithExecutionContext:[self executionContext] CBLDocument:doc];
        [self.documentProxyCache setObject:proxy forKey:docID];
    }
    return proxy;
}



- (id)error {
    return lastError ? [self errorDict:lastError] : nil;
}

- (id)createDocument:(id)args {
    RELEASE_TO_NIL(lastError)
    
    CBLDocument * doc = [self.database createDocument];
    TDDocumentProxy * proxy = [[TDDocumentProxy alloc] initWithExecutionContext:[self executionContext] CBLDocument:doc];
    [self.documentProxyCache setObject:proxy forKey:doc.documentID];
    return proxy;
}

/*
- (id)cachedDocumentWithID:(id)args {
    NSString * docID;
    ENSURE_ARG_OR_NULL_AT_INDEX(docID, args, 0, NSString);

    RELEASE_TO_NIL(lastError)
    
    return [self.documentProxyCache objectForKey:docID];
}

- (void)clearDocumentCache:(id)args {
    RELEASE_TO_NIL(lastError)
    
    [self.documentProxyCache removeAllObjects];
    [self.database clearDocumentCache];
}
*/

#pragma mark Queries and Views

- (id)createAllDocumentsQuery:(id)args {
    RELEASE_TO_NIL(lastError)
    
    CBLQuery * query = [self.database createAllDocumentsQuery];
    return [[TDQueryProxy alloc] initWithExecutionContext:[self executionContext] CBLQuery:query];
}

- (id)slowQueryWithMap:(id)args {
    KrollCallback * callback;
    ENSURE_ARG_AT_INDEX(callback, args, 0, KrollCallback);
    
    RELEASE_TO_NIL(lastError)
    
    CBLMapBlock map = [[TDBridge sharedInstance] mapBlockForCallback:callback inExecutionContext:[self executionContext]];
    CBLQuery * query = [self.database slowQueryWithMap:map];
    return [[TDQueryProxy alloc] initWithExecutionContext:[self executionContext] CBLQuery:query];
}

- (id)viewNamed:(id)args {
    NSString * name;
    ENSURE_ARG_AT_INDEX(name, args, 0, NSString);
    
    RELEASE_TO_NIL(lastError)
    
    CBLView * view = [self.database viewNamed:name];
    return [[TDViewProxy alloc] initWithExecutionContext:[self executionContext] CBLView:view];
}

- (id)existingViewNamed:(id)args {
    NSString * name;
    ENSURE_ARG_AT_INDEX(name, args, 0, NSString);
    
    RELEASE_TO_NIL(lastError)
    
    CBLView * view = [self.database existingViewNamed:name];
    return view ? [[TDViewProxy alloc] initWithExecutionContext:[self executionContext] CBLView:view] : nil;
}

- (id)defineValidation:(id)args {
    NSString * name;
    KrollCallback * callback;
    ENSURE_ARG_AT_INDEX(name, args, 0, NSString);
    ENSURE_ARG_OR_NULL_AT_INDEX(callback, args, 1, KrollCallback);
    
    RELEASE_TO_NIL(lastError)
    
    if (callback) {
        CBLValidationBlock validation = [[TDBridge sharedInstance] validationBlockForCallback:callback inExecutionContext:[self executionContext]];
        [self.database setValidationNamed:name asBlock:validation];
    }
    else {
        [self.database setValidationNamed:name asBlock:nil];
    }
    
    return nil;
}

- (id)defineFilter:(id)args {
    NSString * name;
    KrollCallback * callback;
    ENSURE_ARG_AT_INDEX(name, args, 0, NSString);
    ENSURE_ARG_OR_NULL_AT_INDEX(callback, args, 1, KrollCallback);
    
    RELEASE_TO_NIL(lastError)
    
    if (callback) {
        CBLFilterBlock filter = [[TDBridge sharedInstance] filterBlockForCallback:callback inExecutionContext:[self executionContext]];
        [self.database setFilterNamed:name asBlock:filter];
    }
    else {
        [self.database setFilterNamed:name asBlock:nil];
    }
    
    return nil;
}

#pragma mark Replication

- (id)allReplications {
    NSMutableArray * result = [NSMutableArray array];
    for (CBLReplication * r in [self.database allReplications]) {
        [result addObject:[[TDReplicationProxy alloc] initWithExecutionContext:[self executionContext] CBLReplication:r]];
    }
    return result;
}

- (id)createPushReplication:(id)args {
    NSString * urlstr;
    ENSURE_ARG_AT_INDEX(urlstr, args, 0, NSString);
    
    RELEASE_TO_NIL(lastError)
    
    NSURL * url = [NSURL URLWithString:urlstr];
    CBLReplication * replication = [self.database createPushReplication:url];
    return [[TDReplicationProxy alloc] initWithExecutionContext:[self executionContext] CBLReplication:replication];
}

- (id)createPullReplication:(id)args {
    NSString * urlstr;
    ENSURE_ARG_AT_INDEX(urlstr, args, 0, NSString);
    
    RELEASE_TO_NIL(lastError)
    
    NSURL * url = [NSURL URLWithString:urlstr];
    CBLReplication * replication = [self.database createPullReplication:url];
    return [[TDReplicationProxy alloc] initWithExecutionContext:[self executionContext] CBLReplication:replication];
}

/*
- (id)replicateWithURL:(id)args {
    NSString * urlstr;
    NSNumber * exclusive;
    ENSURE_ARG_AT_INDEX(urlstr, args, 0, NSString);
    ENSURE_ARG_OR_NULL_AT_INDEX(exclusive, args, 1, NSNumber);
    
    RELEASE_TO_NIL(lastError)
    
    NSURL * url = [NSURL URLWithString:urlstr];
    NSArray * repls = [self.database replicationsWithURL:url exclusively:[exclusive boolValue]];
    
    NSMutableArray * result = [NSMutableArray arrayWithCapacity:[repls count]];
    for (CBLReplication * repl in repls) {
        [result addObject:[[TDReplicationProxy alloc] initWithExecutionContext:[self executionContext] CBLReplication:repl]];
    }
    return result;
}
*/

- (id)internalURL {
    return self.database.internalURL;
}

#pragma mark Change Notifications

#define kDatabaseChangedEventName @"change"

- (void)databaseChanged:(NSNotification *)notification {
    [self fireEvent:kDatabaseChangedEventName withObject:nil];
}

- (void)_listenerAdded:(NSString*)type count:(int)count {
    if ([kDatabaseChangedEventName isEqualToString:type] && count == 1) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(databaseChanged:) name:kCBLDatabaseChangeNotification object:nil];
    }
}

- (void)_listenerRemoved:(NSString*)type count:(int)count {
    if ([kDatabaseChangedEventName isEqualToString:type] && count < 1) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kCBLDatabaseChangeNotification object:nil];
    }
}

@end
