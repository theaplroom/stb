# STB - The Synchronisation ToolBox
Based on Dyalog "tokens" (system functions ⎕TGET/⎕TPUT), the file STB.Dyalog contains a namespace STB, which in turn contains a number of classes which implement a number of common synchronisation patterns, which are briefly described below.

## Unit Tests
The file STB_Test contains a set of unit tests, which put each class through it's paces. See STB_Test.RunAll.

## Implemented Patterns
In the following, name beginning with **i** represent instances of the class being described (**iLatch** is an instance of **Latch**).

### Latch
Any number of threads will block on **iLatch.Wait**, with a random single thread being release on each call to **iLatch.Open**.
### Gate
Allow access to proceed past **iGate.Wait** if a call has been made to **iGate.Open**, until the next call to **iGate.Close**.
### Mutex
Mutual Exclusion zone: only allow one thread to proceed past **iMutex.Wait**, the next thread will be allowed to proceed upon **iMutex.Release** (an inverted gate; it is open upon instantiation).
### Queue
One or more threads can **iQueue.Push** values into a FIFO queue, from which the values will emerge in order upon calls to **Queue.Wait**.
### SynchObject
A queue which has a maximum length of 1 (an error will be signalled if a second call to **iSyncObject.Set** is made before the value had been retrieved using **iSyncObject.Wait**
### ReadWrite
A readwrite allows any number of threads to simultaneously proceed past **iReadWrite.WaitRead**. However only one thread can proceed past **iReadWrite.WaitWrite**. A WaitWrite will wait for all read and write locks to be released (using ReleaseRead and ReleaseWrite respectively), and subsequently block all subsequent read and write locks until ReleaseWrite is called.


