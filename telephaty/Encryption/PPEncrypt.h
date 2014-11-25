//
//  PPEncrypt.h
//  PPEncrypt
//
//  Created by Juan on 3/3/14.
//  Copyright (c) 2014 Alvarez Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PPEncryptRSASize) {
    PPEncryptRSASize512 = 512,
    PPEncryptRSASize768 = 768,
    PPEncryptRSASize1024 = 1024,
    PPEncryptRSASize2048 = 2048
};

@interface PPEncryptSettings : NSObject

@property (nonatomic, assign) PPEncryptRSASize rsaSize;
@property (nonatomic, assign) SecPadding padding;

@end

@interface PPEncrypt : NSObject

+ (SecKeyRef)addKey:(NSString *)key withTag:(NSString *)tag public:(BOOL)publickey;

+ (NSString *)encrypt:(NSString *)string withKey:(SecKeyRef)publicKey;
+ (NSString *)decrypt:(NSString *)data withKey:(SecKeyRef)privateKey;

+ (NSData *)signData:(NSData *)data withPadding:(SecPadding)padding andIdentifier:(NSString *)identifier;
+ (BOOL)verifyData:(NSData *)data againstSignature:(NSData *)signature withPadding:(SecPadding)padding andPublicKey:(SecKeyRef)publicKey;

@end
