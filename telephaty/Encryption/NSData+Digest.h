//
//  NSData+Digest.h
//  Telephaty
//
//  Created by PEDRO MUÑOZ CABRERA on 12/11/14.
//  Copyright (c) 2014. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSData (Digest)

- (NSData *)MD5Digest;
- (NSData *)SHA1Digest;
- (NSData *)SHA224Digest;
- (NSData *)SHA256Digest;
- (NSData *)SHA384Digest;
- (NSData *)SHA512Digest;

@end
