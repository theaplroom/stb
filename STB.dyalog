:Namespace STB

    :Class TOKEN
        (⎕IO ⎕ML)←1

        ∇ {r}←Reset
          :Access Private Shared
          r←0,{0::⍬ ⋄ (⎕INSTANCES⊃⊃⎕CLASS⍎⍵).HANDLE}⍕⎕THIS
        ∇

        :Field Private Shared ReadOnly MAX←2*31
        :Field Private Shared          INUSE←Reset
        :Field Public Instance         HANDLE←0

        ∇ make0
          :Access Public Instance
          :Implements Constructor
          INUSE,←HANDLE←{MAX|⍵+1}⍣{~⍺∊INUSE}⊢⊃⌽INUSE
        ∇

        ∇ Dispose
          :Implements Destructor
          ⎕TGET ⎕TPOOL{⍺/⍨⍺∊⍵}(+,-)HANDLE ⋄ INUSE~←HANDLE
        ∇

    :EndClass
    
    :Class SO: TOKEN
        (⎕IO ⎕ML)←1       

        ∇ {r}←Wait timeout
          :Access Public Instance
          :If timeout=¯1
              r←⊃⎕TGET HANDLE
          :Else
              r←⊃timeout ⎕TGET HANDLE
          :EndIf
        ∇        

    :EndClass

    :Class Latch: SO
        ∇ {r}←Open
          :Access Public
          {}0 ⎕TGET HANDLE ⋄ r←⎕TPUT HANDLE
        ∇
    :EndClass

    :Class Gate: SO
        ∇ {r}←Open
          :Access Public
          {}0 ⎕TGET-HANDLE ⋄ r←⎕TPUT-HANDLE
        ∇
        ∇ Close
          :Access Public
          {}⎕TGET{(⍵∊⎕TPOOL)/⍵}-HANDLE
        ∇
    :EndClass

    :Class Queue: SO
        ∇ {r}←Push data
          :Access Public Instance
          r←data ⎕TPUT HANDLE
        ∇
    :EndClass
    
    :Class SynchObject: SO
    ⍝ A latch with Data
                             
      :Field Public isSet←0

        ∇ {r}←Set data
          :Access Public Instance 
          'SynchObject already set' ⎕SIGNAL isSet/11 ⋄ {}0 ⎕TGET HANDLE ⋄ r←data ⎕TPUT HANDLE ⋄ isSet←1
        ∇               
        
        ∇ {r}←Wait timeout
          :Access Public Instance
          r←⎕BASE.Wait timeout ⋄ isSet←0
        ∇
    
    :EndClass

    :Class Mutex: SO
       ∇make0
       :Access Public
       :Implements Constructor
       Release
       ∇
       
       ∇{r}←Release
       :Access Public
       r←⎕TPUT HANDLE
       ∇

    :EndClass

    :Class ReadWrite
        :Field Private Instance TOKENS
        :Field Private Instance READ
        :Field Private Instance WRITE
        :Field Private Instance N

        ∇ make0
          :Access Public Instance
          :Implements Constructor
          TOKENS←2↑⎕NEW TOKEN
          READ WRITE←TOKENS.HANDLE
          ReleaseWrite
        ∇

        ∇ {r}←ReleaseRead
          :Access Public Instance
          ⍝ If WaitWrite has grabbed the WRITE lock it is waiting for N READ tokens
          ⍝ Else, just decrease the read lock count by 1
          ⎕TPUT(~r←WRITE∊|⎕TPOOL)/READ ⋄ N-←r  
        ∇

        ∇ {r}←ReleaseWrite
          :Access Public Instance   
          ⍝ At end of Write, number of readers is zero
          N←0 ⋄ ⎕TPUT r←-WRITE
        ∇

        ∇ {r}←WaitRead
          :Access Public Instance
          ⍝ ⎕TGET WRITE will block if a write is in progress
          ⍝ Once there are no writes, increase number of readers by 1
          ⎕TGET WRITE ⋄ N+←1 ⋄ r←N
        ∇

        ∇ {r}←WaitWrite
          :Access Public Instance
          ⍝ Must wait for all readers and writers to finish
          ⎕TGET-WRITE ⋄ r←⎕TGET(0⌈N)⍴READ
        ∇

    :EndClass

:EndNamespace
