:Namespace STB_Tests

    :Section Tools
    assert←{~⍵:'Assertion failed'⎕SIGNAL 11}

      expecterror←{
          0::⎕SIGNAL(⍺≡⊃⎕DMX.DM)↓11
          z←⍺⍺ ⍵
          ⎕SIGNAL 11
      }


    ∇ RunAll;tests
      ⎕←'Testing STB'
      tests←{⍵/⍨(⊂'test_')∊⍨5↑¨⍵}⎕NL-3
      run¨tests
    ∇

      run←{
          ⍞←⍵
          ⍞←('...OK',⎕UCS 10)⊣⍎⍵
      }

    :EndSection ⍝ Tools

    :Section Tests
    
    ∇ r←test_readwrite;c;writer;reader;rw;tids;delta
      c←⎕NS''
      c.stuff←0 2⍴0
      rw←⎕NEW #.STB.ReadWrite 

      reader←{
          d←⍵.WaitRead ¯1   ⍝ Get read lock
          z←⎕DL 0.2
          c.stuff⍪←⍺,⎕AI[3]  ⍝ Increment counter
          ⍵.ReleaseRead
          }
          
      writer←{
          d←⍵.WaitWrite ¯1  ⍝ Get read lock
          z←⎕DL 0.2
          c.stuff⍪←⍺,⎕AI[3] ⍝ Increment counter
          ⍵.ReleaseWrite
          }
                   
      tids←1 reader&rw   
      tids,←2 reader&rw
      tids,←3 writer&rw
      tids,←4 reader&rw
      
      ⎕DL 1  
      assert ~∨/tids∊⎕TNUMS
      assert (⊂c.stuff[;1])∊(1 2 3 4)(2 1 3 4) ⍝ valid orders of execution
      assert 0 2 2≡⌊0.5+{0.01×⍵-⊃⍵}¯2-/c.stuff[;2] ⍝ 0/200/200 msec delay
      ⍝ (2 reads should run more or less simulataneously,
      ⍝  then there should be 200ms to write and again to final read
      r←0
    ∇

    ∇ r←test_latch;c;sob;tid;d
      c←⎕NS''
      c.BIN←0
      sob←⎕NEW #.STB.Latch 

      tid←c{
          d←⍵.Wait ¯1 ⍝ Wait on latch with no timeout
          ⍺.BIN+←1    ⍝ Increment counter
          ⍺ ∇ ⍵       ⍝ Repeat via tail recursion
      }&sob        

      assert c.BIN=0
      sob.Open        ⍝ Open latch
      d←⎕DL 0.01
      assert c.BIN=1  ⍝ 0.01 seconds later, the count should be incremented
      sob.Open
      sob.Open
      d←⎕DL 0.01
      assert c.BIN=3  ⍝ Latch has now been released 3x
      ⎕TKILL tid
      r←0
    ∇

    ∇ r←test_gate;c;sob;tid;d
      c←⎕NS''
      c.BIN←0
      sob←⎕NEW #.STB.Gate

      tid←c{
          d←⍵.Wait ¯1 ⍝ Wait forever
          ⍺.BIN+←1    ⍝ Increment counter
          d←⎕DL .08   ⍝ Every 0.08s
          ⍺ ∇ ⍵       ⍝ Repeat
      }&sob          

      assert c.BIN=0
      sob.Open        ⍝ Open Gate
      d←⎕DL 1         ⍝ For 1s
      sob.Close
      assert c.BIN>10 ⍝ Rather iffy
      assert c.BIN<14 ⍝    tests :-)
      ⎕TKILL tid
      r←0
    ∇

    ∇ r←test_queue;c;q;data;tid
      q←⎕NEW #.STB.Queue                   
      c←⎕NS ''

      tid←c{
          ⍺.stuff←⍵.Wait¨3⍴¯1 ⍝ Wait forever (3x)
      }&q

      q.Push¨data←'one' 'two' 'three'
      ⎕DL 0.2
      assert c.stuff≡data
      ⎕tkill tid
      r←0
    ∇
    
    ∇ r←test_synchobject;so;tid
      so←⎕NEW #.STB.SynchObject                   

      tid←{              
          z←⎕DL 0.1 
          ⍵.Set 42 
      }&so

      assert 42=so.Wait ¯1

      so.Set 0
      :Trap 11
         so.Set 2 ⍝ Should signal 11 - already set
         assert 0 ⍝ We should not get here
      :EndTrap                                   
      assert 0=so.Wait ¯1
      r←0
    ∇

    ∇ r←test_mutex;c;data;tid;m;delay
      m←⎕NEW #.STB.Mutex                   
      c←⎕NS ''       
      c.stuff←0 2⍴0
      delay←0.1

      m.Wait ¯1 ⍝ grab the mutex

      tid←c{
          z←⍵.Wait ¯1
          c.stuff⍪←2,⎕AI[3]
          z←⎕DL delay 
          z←⍵.Release
      }&m  
      c.stuff⍪←1,⎕AI[3]
      ⎕DL delay
      m.Release
      m.Wait ¯1
      c.stuff⍪←3,⎕AI[3]   
      m.Release
      assert c.stuff[;1]≡1 2 3
      assert (1000×delay)∧.≤|2 -/c.stuff[;2]
      r←0
    ∇

    :EndSection ⍝ Tests


:EndNamespace
