//
//  HLWTwoWayList.m
//  HLWCyclicScrollViewDemo
//
//  Created by tang on 16/9/1.
//  Copyright © 2016年 tang. All rights reserved.
//

#import "HLWDoubleLinkedCircularList.h"
#import "HLWDoubleWayNode.h"

@interface HLWDoubleLinkedCircularList ()

/*!
 使用数组allNodes来持有所有node对象。
 因为，_head的属性和node对象的previous、next属性都是weak，都不持有对象。
 */
@property (strong, nonatomic) NSMutableArray *allNodes;

@end

@implementation HLWDoubleLinkedCircularList

+ (id)doubleLinkedCircularListWithArray:(NSArray *)array
{
    return [[[self class] alloc] initWithArray:array];
}

- (id)initWithArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        id data;
        NSUInteger cnt = array.count;
        if (cnt > 0) {
            for (NSUInteger i = 0; i < cnt; i++) {
                data = array[i];
                HLWDoubleWayNode *node = [HLWDoubleWayNode doubleWayNodeWithData:data index:i];
                [self addNode:node];
            }
        }
    }
    return self;
}

-(NSMutableArray *)allNodes
{
    if (!_allNodes) {
        _allNodes = [NSMutableArray array];
    }
    return _allNodes;
}

- (void)addNode:(HLWDoubleWayNode *)node
{
    if ([self.allNodes containsObject:node]) {
        // list has alread contains the node , immediately return
        return ;
    }
    
    // first, save the node to array allNodes.
    [self.allNodes addObject:node];
    
    if (!_head) {
        // the node is the first
        _head = node;
        
        // make circle
        node.next = node;
        node.previous = node;
    } else {
        // the node is not the first, insert node to list's tail, that is, head's left
        
        // get head's left node
        HLWDoubleWayNode *leftNode = _head.previous;
        
        node.previous = leftNode;
        node.next = _head;
        
        leftNode.next = node;
        _head.previous = node;
    }
    
    // accumulate cout
    ++_count;
    
    [self printTwoCircle];
}

- (void)removeNode:(HLWDoubleWayNode *)node
{
    
}

-(void)print
{
    HLWDoubleWayNode *tmpNode = _head;
    NSLog(@"\n");
    NSLog(@"*********************************************");
    do {
        NSLog(@"index: %lu, data: %@", tmpNode.index, tmpNode.data);
        tmpNode = tmpNode.next;
    } while (tmpNode != _head);
    NSLog(@"*********************************************\n");

}

- (void)printTwoCircle
{
    HLWDoubleWayNode *tmpNode = _head;
    NSUInteger cnt = 0;
    NSLog(@"\n");
    NSLog(@"*********************************************");
    do {
        NSLog(@"index: %lu, data: %@", tmpNode.index, tmpNode.data);
        tmpNode = tmpNode.next;
        ++cnt;
    } while (tmpNode != _head || cnt < 2 * _count);
    NSLog(@"*********************************************\n");

}

- (void)dealloc
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

@end
