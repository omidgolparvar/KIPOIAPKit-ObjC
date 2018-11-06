//
//  KIAPKit+Main.h
//  KIPOIAPKit-ObjC
//
//  Created by Omid Golparvar on 8/26/18.
//  Copyright © 2018 Omid Golparvar. All rights reserved.
//

@import UIKit;

#import <KIAPKit+Delegate.h>

@interface KipoIAP : NSObject

+ (void)SetupMerchantKey:(NSString*)merchantKey;

+ (void)SetupDelegate:(id<KipoIAPDelegate>)delegate;

+ (void)Pay:(NSInteger)amount;

+ (bool)Check:(NSURL*)url;

@end
