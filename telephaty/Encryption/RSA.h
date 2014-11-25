//
//  RSA.h
//  Telephaty
//
//  Created by PEDRO MUÑOZ CABRERA on 12/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSASettings : NSObject

@property (nonatomic, assign) SecPadding padding;

@end

@interface RSA : NSObject

+ (SecKeyRef)addKey:(NSString *)key withTag:(NSString *)tag public:(BOOL)publickey;

+ (NSString *)encrypt:(NSString *)string withKey:(SecKeyRef)publicKey;
+ (NSString *)decrypt:(NSString *)data withKey:(SecKeyRef)privateKey;

+ (NSData *)signData:(NSData *)data withPadding:(SecPadding)padding andIdentifier:(NSString *)identifier;
+ (BOOL)verifyData:(NSData *)data againstSignature:(NSData *)signature withPadding:(SecPadding)padding andPublicKey:(SecKeyRef)publicKey;

@end
