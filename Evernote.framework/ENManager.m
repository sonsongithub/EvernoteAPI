/*
 * EvernoteTest
 * ENManager.m
 *
 * Copyright (c) Yuichi YOSHIDA, 11/05/30
 * All rights reserved.
 * 
 * BSD License
 *
 * Redistribution and use in source and binary forms, with or without modification, are 
 * permitted provided that the following conditions are met:
 * - Redistributions of source code must retain the above copyright notice, this list of
 *  conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this list
 *  of conditions and the following disclaimer in the documentation and/or other materia
 * ls provided with the distribution.
 * - Neither the name of the "Yuichi YOSHIDA" nor the names of its contributors may be u
 * sed to endorse or promote products derived from this software without specific prior 
 * written permission.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY E
 * XPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES O
 * F MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SH
 * ALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENT
 * AL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROC
 * UREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS I
 * NTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRI
 * CT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF T
 * HE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "ENManager.h"


static ENManager *sharedManager;

@implementation ENManager

@synthesize auth, noteStoreClient;

@synthesize username, password;

#pragma mark - Class method

+ (ENManager*)sharedInstance {
	if (sharedManager == nil) {
		sharedManager = [[ENManager alloc] init];
	}
	return sharedManager;
}

#pragma mark - Important accessor

- (EDAMAuthenticationResult*)auth {
	if (_auth == nil) {
		@try {
			THTTPClient *userStoreHttpClient = [[[THTTPClient alloc] initWithURL:[NSURL URLWithString:EVERNOTE_USER_STORE_URI]] autorelease];
			TBinaryProtocol *userStoreProtocol = [[[TBinaryProtocol alloc] initWithTransport:userStoreHttpClient] autorelease];
			EDAMUserStoreClient *userStore = [[[EDAMUserStoreClient alloc] initWithProtocol:userStoreProtocol] autorelease];
			
			EDAMAuthenticationResult* authResult = [userStore authenticate:username :password :EVERNOTE_API_COSUMER_KEY :EVERNOTE_API_COSUMER_SECRET];
			
			DNSLog(@"Authentication was successful for: %@", [[authResult user] username]);
			DNSLog(@"Authentication token: %@", [authResult authenticationToken]);
			
			if ([userStore checkVersion:@"Cocoa EDAMTest" :[EDAMUserStoreConstants EDAM_VERSION_MAJOR] :[EDAMUserStoreConstants EDAM_VERSION_MINOR]]) {
				[_auth release];
				_auth = [authResult retain];
			}
		}
		@catch (NSException *exception) {
			DNSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
			[self releaseAuthorization];
			return nil;
		}
		@finally {
		}
	}
	return _auth;
}

- (EDAMNoteStoreClient*)noteStoreClient {
	if (_noteStoreClient == nil) {
		if (self.auth) {
			@try {
				NSString *noteStoreUriBase = [[[NSString alloc] initWithString:EVERNOTE_NOTE_STORE_BASE_URI] autorelease];
				NSURL *noteStoreUri =  [[[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", noteStoreUriBase, [[self.auth user] shardId]] ]autorelease];
				THTTPClient *noteStoreHttpClient = [[[THTTPClient alloc] initWithURL:noteStoreUri] autorelease];
				TBinaryProtocol *noteStoreProtocol = [[[TBinaryProtocol alloc] initWithTransport:noteStoreHttpClient] autorelease];
				EDAMNoteStoreClient *noteStore = [[[EDAMNoteStoreClient alloc] initWithProtocol:noteStoreProtocol] autorelease];
				
				if (noteStore) {
					[_noteStoreClient release];
					_noteStoreClient = [noteStore retain];
				}
			}
			@catch (NSException *exception) {
				DNSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
				[self releaseAuthorization];
				return nil;
			}
			@finally {
			}
		}
	}
	return _noteStoreClient;
}

#pragma mark - Instance method

- (void)releaseAuthorization {
	DNSLogMethod
	[_auth release];
	_auth = nil;
	[_noteStoreClient release];
	_noteStoreClient = nil;
}

#pragma mark - Fetch note and notebook

- (EDAMNotebook*)defaultNotebook {
	NSArray *notebooks = [self notebooks];

	if ([notebooks count] == 0)
		return nil;
	
	EDAMNotebook *defaultNotebook = [notebooks objectAtIndex:0];
	
	if ([notebooks count] == 0)
		return defaultNotebook;
	
	for (int i = 0; i < [notebooks count]; i++) {
		EDAMNotebook* notebook = (EDAMNotebook*)[notebooks objectAtIndex:i];
		if ([notebook defaultNotebook]) {
			return notebook;
		}
	}
	return defaultNotebook;
}

-  (EDAMNoteList*)notesWithNotebookGUID:(EDAMGuid)guid {
	EDAMNoteFilter *filter = [[[EDAMNoteFilter alloc] initWithOrder:NoteSortOrder_CREATED ascending:YES words:nil notebookGuid:guid tagGuids:nil timeZone:nil inactive:NO] autorelease];	
	if (self.noteStoreClient) {
		@try {
			return [self.noteStoreClient findNotes:[self.auth authenticationToken] :filter :0 :[EDAMLimitsConstants EDAM_USER_NOTES_MAX]];
		}
		@catch (NSException *exception) {
			DNSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
			[self releaseAuthorization];
			return nil;
		}
		@finally {
		}
	}
	return nil;
}

- (NSArray*)notebooks {
	if (self.noteStoreClient) {
		@try {
			NSArray *notebooks = [self.noteStoreClient listNotebooks:[self.auth authenticationToken]];
			return [NSArray arrayWithArray:notebooks];
		}
		@catch (NSException *exception) {
			DNSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
			[self releaseAuthorization];
			return nil;
		}
		@finally {
		}
	}
	return [NSArray array];
}

- (EDAMNote*)noteWithNoteGUID:(EDAMGuid)guid {
	if (self.noteStoreClient) {
		@try {
			return [self.noteStoreClient getNote:[self.auth authenticationToken] :guid :YES :YES :YES :YES];
		}
		@catch (NSException *exception) {
			DNSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
			[self releaseAuthorization];
			return nil;
		}
		@finally {
		}
	}
	return nil;
}

#pragma mark - Create note and notebook

- (EDAMNotebook*)createNewNotebookWithTitle:(NSString*)title {
	EDAMNotebook *createdNewNotebook = nil;
	if (self.noteStoreClient) {
		@try {
			EDAMNotebook *newNotebook = [[EDAMNotebook alloc] init];
			[newNotebook setName:title];
			createdNewNotebook = [self.noteStoreClient createNotebook:[self.auth authenticationToken] :newNotebook];
			[newNotebook release];
		}
		@catch (NSException *exception) {
			DNSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
			[self releaseAuthorization];
			return nil;
		}
		@finally {
			if (createdNewNotebook)
				return createdNewNotebook;
		}
	}
	return nil;
}

- (EDAMNote*)createNote2Notebook:(EDAMGuid)notebookGuid title:(NSString*)title content:(NSString*)content {
	EDAMNote *createdNewNote = nil;
	if (self.noteStoreClient) {
		@try {
			EDAMNote *newNote = [[EDAMNote alloc] init];
			[newNote setNotebookGuid:notebookGuid];
			[newNote setTitle:title];
			[newNote setContent:content];
			[newNote setCreated:(long long)[[NSDate date] timeIntervalSince1970] * 1000];
			createdNewNote = [self.noteStoreClient createNote:[self.auth authenticationToken] :newNote];
			[newNote release];
		}
		@catch (NSException *exception) {
			DNSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
			[self releaseAuthorization];
			return nil;
		}
		@finally {
			if (createdNewNote)
				return createdNewNote;
		}
	}
	return nil;
}

- (EDAMNote*)createNote2Notebook:(EDAMGuid)notebookGuid title:(NSString*)title content:(NSString*)content resources:(NSArray*)resources {
	EDAMNote *createdNewNote = nil;
	if (self.noteStoreClient) {
		@try {
			EDAMNote *newNote = [[EDAMNote alloc] init];
			[newNote setNotebookGuid:notebookGuid];
			[newNote setTitle:title];
			[newNote setContent:content];
			[newNote setCreated:(long long)[[NSDate date] timeIntervalSince1970] * 1000];
			[newNote setResources:resources];
			createdNewNote = [self.noteStoreClient createNote:[self.auth authenticationToken] :newNote];
			[newNote release];
		}
		@catch (NSException *exception) {
			DNSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
			[self releaseAuthorization];
			return nil;
		}
		@finally {
			if (createdNewNote)
				return createdNewNote;
		}
	}
	return nil;
}

#pragma mark - Remove(expunge) note, but not supported?

// currently not supported to remove notes with API....?

- (int)removeNote:(EDAMNote*)noteToBeRemoved {
	int result = 0;
	if (self.noteStoreClient) {
		@try {
			result = [self.noteStoreClient expungeNote:[self.auth authenticationToken] :[noteToBeRemoved guid]];
		}
		@catch (NSException *exception) {
			DNSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
			[self releaseAuthorization];
			return result;
		}
		@finally {
			return result;
		}
	}
	return result;
}

#pragma mark - Override

- (id)retain {
	// for singleton design pattern
	return self;
}

- (void)release {
	// for singleton design pattern
}

- (void)dealloc {
    [password release];
	[username release];
	[_auth release];
	[_noteStoreClient release];
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(releaseAuthorization) name:UIApplicationWillResignActiveNotification  object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(releaseAuthorization) name:UIApplicationDidEnterBackgroundNotification  object:nil];
    }
    return self;
}

@end
