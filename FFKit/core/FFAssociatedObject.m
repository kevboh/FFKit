//
//  NSObjectAssociatedObject.m
//  FFKit
//
//  Created by Jacob Sologub on 6/6/16.
//  Copyright © 2016 Jacob Sologub. All rights reserved.
//

#import "FFAssociatedObject.h"
#import <objc/runtime.h>

@interface NSObject (FFKitAssociatedObject)
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSString*>* associatedObjectKeyLookup;
@end
@implementation NSObject (FFKitAssociatedObject)
@dynamic associatedObjectKeyLookup;

- (NSMutableDictionary<NSString*, NSString*>*) associatedObjectKeyLookup {
    return [
        FFAssociatedObject <NSMutableDictionary<NSString*, NSString*>*>
        getOrCreate: self
        forSelector: @selector (associatedObjectKeyLookup)
        policy: FFAssociatedObjectPolicyRetainNonatomic
        type: [NSMutableDictionary class]
    ];
}
@end

@implementation FFAssociatedObject

+ (id) get: (id) object forKey: (NSString*) key {
    return [[[FFAssociatedObject alloc] init] get: object forKey: key policy: FFAssociatedObjectPolicyRetainNonatomic type: [NSObject class] create: NO];
}

+ (id) getOrCreate: (id) object forKey: (NSString*) key {
    return [FFAssociatedObject getOrCreate: object forKey: key type: [NSObject class]];
}

+ (id) getOrCreate: (id) object forKey: (NSString*) key type: (Class) type {
    return [FFAssociatedObject getOrCreate: object forKey: key policy: FFAssociatedObjectPolicyRetainNonatomic type: type];
}

+ (id) getOrCreate: (id) object forKey: (NSString*) key policy: (FFAssociatedObjectPolicy) policy {
    return [FFAssociatedObject getOrCreate: object forKey: key policy: policy type: [NSObject class]];
}

+ (id) getOrCreate: (id) object forKey: (NSString*) key policy: (FFAssociatedObjectPolicy) policy type: (Class) type {
    return [[[FFAssociatedObject alloc] init] get: object forKey: key policy: policy type: type create: YES];
}

- (id) get: (id) object forKey: (NSString*) key policy: (FFAssociatedObjectPolicy) policy type: (Class) type create: (BOOL) create {
    self.associatedObjectKeyLookup [key] = key;
    id result = objc_getAssociatedObject (object, (__bridge const void*) (self.associatedObjectKeyLookup [key]));
    if (create == YES && result == nil) {
        result = [type new];
        
        const objc_AssociationPolicy objc_policy = [FFAssociatedObject objc_AssociationPolicyFromFFAssociatedObjectPolicy: policy];
        objc_setAssociatedObject (object, (__bridge const void*) (self.associatedObjectKeyLookup [key]), result, objc_policy);
    }
    
    return result;
}

+ (id) get: (id) object forSelector: (SEL) selector {
    return [[[FFAssociatedObject alloc] init] get: object forSelector: selector policy: FFAssociatedObjectPolicyRetainNonatomic type: [NSObject class] create: NO];
}

+ (id) getOrCreate: (id) object forSelector: (SEL) selector type: (Class) type {
    return [FFAssociatedObject getOrCreate: object forSelector: selector policy: FFAssociatedObjectPolicyRetainNonatomic type: type];
}

+ (id) getOrCreate: (id) object forSelector: (SEL) selector policy: (FFAssociatedObjectPolicy) policy type: (Class) type {
    return [[[FFAssociatedObject alloc] init] get: object forSelector: selector policy: policy type: type create: YES];
}

- (id) get: (id) object forSelector: (SEL) selector policy: (FFAssociatedObjectPolicy) policy type: (Class) type create: (BOOL) create {
    id result = objc_getAssociatedObject (object, selector);
    if (create == YES && result == nil) {
        result = [type new];
        
        const objc_AssociationPolicy objc_policy = [FFAssociatedObject objc_AssociationPolicyFromFFAssociatedObjectPolicy: policy];
        objc_setAssociatedObject (object, selector, result, objc_policy);
    }
    
    return result;
}

+ (void) set: (id) object value: (id) value forKey: (NSString*) key {
    [FFAssociatedObject set: object value: value forKey: key policy: FFAssociatedObjectPolicyRetainNonatomic];
}

+ (void) set: (id) object value: (id) value forKey: (NSString*) key policy: (FFAssociatedObjectPolicy) policy {
    [[[FFAssociatedObject alloc] init] set: object value: value forKey: key policy: policy];
}

- (void) set: (id) object value: (id) value forKey: (NSString*) key policy: (FFAssociatedObjectPolicy) policy {
    self.associatedObjectKeyLookup [key] = key;
    
    const objc_AssociationPolicy objc_policy = [FFAssociatedObject objc_AssociationPolicyFromFFAssociatedObjectPolicy: policy];
    objc_setAssociatedObject (object, (__bridge const void*) (self.associatedObjectKeyLookup [key]), value, objc_policy);
}

+ (void) set: (id) object value: (id) value forSelector: (SEL) selector {
    [FFAssociatedObject set: object value: value forSelector: selector policy: FFAssociatedObjectPolicyRetainNonatomic];
}

+ (void) set: (id) object value: (id) value forSelector: (SEL) selector policy: (FFAssociatedObjectPolicy) policy {
    [[[FFAssociatedObject alloc] init] set: object value: value forSelector: selector policy: policy];
}

- (void) set: (id) object value: (id) value forSelector: (SEL) selector policy: (FFAssociatedObjectPolicy) policy {
    const objc_AssociationPolicy objc_policy = [FFAssociatedObject objc_AssociationPolicyFromFFAssociatedObjectPolicy: policy];
    objc_setAssociatedObject (object, selector, value, objc_policy);
}

+ (objc_AssociationPolicy) objc_AssociationPolicyFromFFAssociatedObjectPolicy: (FFAssociatedObjectPolicy) policy {
    objc_AssociationPolicy result = OBJC_ASSOCIATION_ASSIGN;
    if (policy == FFAssociatedObjectPolicyRetainNonatomic) {
        result = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
    }
    else if (policy == FFAssociatedObjectPolicyCopyNonatomic) {
        result = OBJC_ASSOCIATION_COPY_NONATOMIC;
    }
    else if (policy == FFAssociatedObjectPolicyRetain) {
        result = OBJC_ASSOCIATION_RETAIN;
    }
    else if (policy == FFAssociatedObjectPolicyCopy) {
        result = OBJC_ASSOCIATION_COPY;
    }
    
    return result;
}

@end
