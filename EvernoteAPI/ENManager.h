/*
 * EvernoteTest
 * ENManager.h
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

#import <Foundation/Foundation.h>

#import "THTTPClient.h"
#import "TBinaryProtocol.h"
#import "UserStore.h"
#import "NoteStore.h"
#import "NSData+MD5.h"

#ifdef _DEPLOYMENT

#define EVERNOTE_USER_STORE_URI			@"https://www.evernote.com/edam/user"
#define EVERNOTE_NOTE_STORE_BASE_URI	@"http://www.evernote.com/edam/note/"

#else

#define EVERNOTE_USER_STORE_URI			@"https://sandbox.evernote.com/edam/user"
#define EVERNOTE_NOTE_STORE_BASE_URI	@"http://sandbox.evernote.com/edam/note/"

#endif

#define EVERNOTE_API_COSUMER_KEY		@"YOUR COSUMER KEY"
#define EVERNOTE_API_COSUMER_SECRET		@"YOUR COSUMER SECRET"

@interface ENManager : NSObject {
    NSString					*username;
    NSString					*password;

	// don't access following instances without accessor
	EDAMAuthenticationResult	*_auth;
	EDAMNoteStoreClient			*_noteStoreClient;
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;

@property (nonatomic, readonly) EDAMAuthenticationResult *auth;
@property (nonatomic, readonly) EDAMNoteStoreClient *noteStoreClient;

#pragma mark - Class method

+ (ENManager*)sharedInstance;

#pragma mark - Important accessor

- (EDAMAuthenticationResult*)auth;
- (EDAMNoteStoreClient*)noteStoreClient;

#pragma mark - Instance method

- (void)releaseAuthorization;

#pragma mark - Fetch note and notebook

- (EDAMNotebook*)defaultNotebook;
- (EDAMNoteList*)notesWithNotebookGUID:(EDAMGuid)guid;
- (NSArray*)notebooks;
- (EDAMNote*)noteWithNoteGUID:(EDAMGuid)guid;

#pragma mark - Create note and notebook

- (EDAMNotebook*)createNewNotebookWithTitle:(NSString*)title;
- (EDAMNote*)createNote2Notebook:(EDAMGuid)notebookGuid title:(NSString*)title content:(NSString*)content;
- (EDAMNote*)createNote2Notebook:(EDAMGuid)notebookGuid title:(NSString*)title content:(NSString*)content resources:(NSArray*)resources;

#pragma mark - Remove(expunge) note

- (int)removeNote:(EDAMNote*)noteToBeRemoved;	// does not work

@end
