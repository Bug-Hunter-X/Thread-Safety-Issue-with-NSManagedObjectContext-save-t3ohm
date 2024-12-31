In Objective-C, a common yet subtle error arises when dealing with `NSManagedObjectContext` and its interaction with the main thread.  Specifically, attempting to save changes to the context from a background thread can lead to unexpected crashes or data inconsistencies. This is because the `NSManagedObjectContext` is not thread-safe; it must interact with the main thread's run loop for proper operation. 

```objectivec
- (void)processDataInBackground:(NSData *)data {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ 
        // ... process the data ...
        [self.managedObjectContext performBlock:^{ // Correct way
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Error saving context: %@", error);
            }
        }];
    });
}
```

Incorrectly, saving may be attempted directly from the background thread: 
```objectivec
- (void)processDataInBackground:(NSData *)data {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ 
        // ... process the data ...
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) { //INCORRECT: Not thread-safe
            NSLog(@"Error saving context: %@", error);
        }
    });
}
```