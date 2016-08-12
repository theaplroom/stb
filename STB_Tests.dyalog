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

    ∇ r←test_latch;c;sob;tid;d
      c←⎕NS''
      c.BIN←0
      sob←⎕NEW #.STB.Latch
      tid←c{
          d←⍵.Wait ¯1
          ⍺.BIN+←1
          ⍺ ∇ ⍵
      }&sob
      assert c.BIN=0
      sob.Open
      d←⎕DL 0.01
      assert c.BIN=1
      sob.Open
      sob.Open
      d←⎕DL 0.01
      assert c.BIN=3
      ⎕TKILL tid
      r←0
    ∇

    ∇ r←test_gate;c;sob;tid;d
      c←⎕NS''
      c.BIN←0
      sob←⎕NEW #.STB.Gate
      tid←c{
          d←⍵.Wait ¯1
          ⍺.BIN+←1
          d←⎕DL .08
          ⍺ ∇ ⍵
      }&sob
      assert c.BIN=0
      sob.Open
      d←⎕DL 1
      sob.Close
      assert c.BIN>10
      assert c.BIN<14
      ⎕TKILL tid
      r←0
    ∇

    :EndSection ⍝ Tests


:EndNamespace
