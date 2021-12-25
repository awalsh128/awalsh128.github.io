---
title: Tips for Java performance on Android.
date: '2011-12-16T11:32:00.000-08:00'
author: awalsh128
tags:
- Java
- performance
- Android
modified_time: '2012-10-03T13:45:08.174-07:00'
blogger_id: tag:blogger.com,1999:blog-6363087137667886940.post-6150131899027638815
blogger_orig_url: https://awalsh128.blogspot.com/2011/12/tips-for-java-performance-on-android.html
---

While Java may be a higher level language that makes code writeability
easier, conventions must be broken when developing on Android to reap
performance gains. This is especially true for games where logic and
rendering must be done on a tight loop.

The Android developer page provides [helpful
tips](http://developer.android.com/guide/practices/design/performance.html)
for optimizing your Java code. Below are the optimizations that I have
found to improve performance.

1.  **Front load memory allocation at startup instead of dynamically.**

    We saw the largest performance gain here. The
    [GC](http://en.wikipedia.org/wiki/Garbage_collection_(computer_science))
    can kill performance in a CPU intensive application or game. If you
    pool your instances in an array instead of dynamically allocating
    it, you can save the GC calls from happening. This will result in a
    slightly larger memory footprint if you tweak it right.

    Below is code that provides a fixed-size generic list
    implementation; the internal array never grows/shrinks. The
    *executePendingRemoves* routine is needed since object removal must
    sometimes be put into a [critical
    region](http://en.wikipedia.org/wiki/Critical_section) with a
    [*synchronized*
    block](http://docs.oracle.com/javase/tutorial/essential/concurrency/locksync.html).
    You may want to queue up removals but still make them available to
    other threads up until the moment they are removed in bulk.

    ``` csharp
    public class List&ltT> {

     private int mCount;
     private T mItems[];
     private int mRemoveCount;
     private int[] mRemoveIndices; 
     
     @SuppressWarnings("unchecked")
     public List(int capacity) {
      mItems = (T[]) new Object[capacity];
      mRemoveIndices = new int[capacity];
      mCount = 0;
     }
     
     public void add(T item){
      mItems[mCount] = item;
      mCount++;
     }
     
     public void clear(){
      for(int index=0; index < mCount; index++)
      {
       mItems[index] = null;
      }
      mCount = 0;
     }
     
     public void executePendingRemoves() {
      for (int i=0;i < mRemoveCount; i++) {
       mItems[mRemoveIndices[i]] = null;
      }
      int newCount=0;
      for (int i=0;i < mCount; i++) {
       if (mItems[i] != null) {
        mItems[newCount] = mItems[i];
        newCount++;
       }
      }
      mCount = newCount;
      mRemoveCount = 0;
     }
     
     public T get(int index) { return mItems[index];}
     public int getCount() { return mCount;}
     public int getIndex(T item) {
      for (int i=0; i < mCount; i++) {
       if (mItems[i] == item) return i;
      }
      return -1;
     }
     public int getPendingRemoveCount() { return mRemoveCount; }
     public int[] getPendingRemoves() { return mRemoveIndices; }
     public Object[] getItems() { return mItems;}
     
     public void pendingRemoveAt(int index) {
      for (int i=0; i< mRemoveCount; i++) {
       if (index == mRemoveIndices[i])
        return;
       else if  (index < mRemoveIndices[i]) {
        int swapIndex = mRemoveIndices[i];
        mRemoveIndices[i] = index;
        index = swapIndex;
       }
      }
      mRemoveIndices[mRemoveCount] = index;
      mRemoveCount++;
     }
     
     public void removeAt(int index) {
      if (index < mCount) {
                for (int i = index; i < mCount; i++) {
                    if (i + 1 < mItems.length && i + 1 < mCount) {
                     mItems[i] = mItems[i + 1];
                    } else {
                     mItems[i]  = null;
                    }
                }
                mCount--;
            }
     }
     
     public T removeLast() {
      mCount--;
      
      final T item = mItems[mCount];
      mItems[mCount] = null;
      return item;
     }
     
    }
    ```

    Lastly is the pooling object that can be inherited by any
    application level instance (eg. *FlyingWizardsPool extends
    ObjectPool*). When you want to instantiate a flying wizard object,
    just type in *FlyingWizard wizard = wizardPool.checkOut();*.

    ``` csharp
    public abstract class ObjectPool&ltT> {

     private int mCapacity;
     private List&ltT> mPool;
     
     @SuppressWarnings({ "unchecked", "rawtypes" })
     public ObjectPool(int capacity) {
      mPool = new List(capacity);
      mCapacity = capacity;
      this.fill();
     }
     
     public void checkIn(T poolItem) {
      mPool.add(poolItem);
     }
     
     public T checkOut() {
      return mPool.removeLast();
     }
     
     public abstract void fill();
     
     public int getCount() {
      return mPool.getCount();
     }
     
     public int getCapacity() {
      return mCapacity;
     }

    }
    ```

    Below is an example implementation of the *ObjectPool* abstract
    class. Note how the *fill* routine is implemented. Also, front
    loading memory like this means that you will need an *initialize* on
    your instances so that the class fields can be put back to a \"just
    instantiated\" state. Normally we would use a constructor but to
    keep the allocation static, an *initialize* call is necessary.

    ``` csharp
    public static class FlyingWizardPool extends ObjectPool {
     public FlyingWizardPool(int capacity) {
      super(capacity);
     }

     public FlyingWizard checkOut(float x, float y, float destinationX, float destinationY) {
      FlyingWizard wizard = this.checkOut();
      wizard.initialize(x, y);
      return wizard;
     }
      
     @Override
     public void fill() {
      for (int i=0; i < this.getCapacity(); i++) {
       this.checkIn(new FlyingWizard());
      }
     }
    }
    ```

2.  **Choose larger block routines instead of calling out to helper
    subroutines.**

    Since the Dalvik is a register based architecture, every time a
    routine is called from another, the register values must be stored
    to memory before the call and loaded back in after the routine has
    returned. Avoiding helper routine inside commonly called routines
    will reduce this load/store overhead.

3.  **Remove [accessors](http://en.wikipedia.org/wiki/Mutator_method)
    and allow direct access to class fields.**

    Accessors are usually good form and observe the
    [ADT](http://en.wikipedia.org/wiki/Abstract_data_type). Although, to
    avoid the overhead involved in a routine call and additional
    allocation of memory for the copied out value, it is best to allow
    direct access to the class field. This makes it more difficult to
    protect the [conditions](http://en.wikipedia.org/wiki/Precondition)
    for the field but is a worthy sacrifice if it is called often.

4.  **Make routines static if they don\'t access class fields.**

    The Android team recommends using this for an approximate 15-20%
    performance gain. This means less work for the Dalvik during
    run-time optimization and the routine can be inlined for faster
    execution.

5.  **Use constants instead of enums.**

    This is more of a negligible optimization; it was delisted from
    Android\'s performance page. Instead of having an enum, you can keep
    the enumeration as an integer constant.

It is important to follow the ADT for good code writeability/readability
and bug minimization. Use these optimizations only on code that really
needs it. This means it should apply to routines and fields that are
called frequently by your application.
