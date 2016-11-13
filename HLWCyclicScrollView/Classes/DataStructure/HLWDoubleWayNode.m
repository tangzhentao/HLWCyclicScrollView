//
//  HLWTwoWayList.m
//  HLWCyclicScrollViewDemo
//
//  Created by tang on 16/9/1.
//  Copyright © 2016年 tang. All rights reserved.
//

#import "HLWDoubleWayNode.h"

@implementation HLWDoubleWayNode

+ (id)doubleWayNodeWithData:(id)data;
{
    return [self doubleWayNodeWithData:data index:0];
}

+ (id)doubleWayNodeWithData:(id)data index:(NSUInteger)index
{
    return [[[self class] alloc] initWithData:data index:(NSUInteger)index];
}

- (id)initWithData:(id)data index:(NSUInteger)index
{
    self = [super init];
    if (self) {
        _data = data;
        _index = index;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"[%@ %@], index: %u", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.index);
}

@end
