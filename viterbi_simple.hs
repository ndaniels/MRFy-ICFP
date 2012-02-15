viterbi :: Alphabet -> QuerySequence -> HMM -> (Score, StatePath)
viterbi alpha query hmm = flipSnd $ DL.minimum $
                        [viterbi' mat (numNodes - 1) (seqlen - 1),
                         viterbi' ins (numNodes - 1) (seqlen - 1),
                         viterbi' del (numNodes - 1) (seqlen - 1)
                        ]
  where viterbi' state node obs = Memo.memo3 (Memo.arrayRange (mat, end)) 
                                  (Memo.arrayRange (0, numNodes))
                                  (Memo.arrayRange (0, seqlen)) 
                                  viterbi'' state node obs
        viterbi'' s n o
          -- consume an observation AND a node
          | s == mat = let trans t prev = 
                           (score + tProb hmm (n-1) t + eProb, mat:path)
                            where (score, path) = viterbi' prev (n - 1) (o - 1)
                                  eProb = eProb' (mEmissions $ hmm ! n) (res o)
                        in minimum $ [
                            transition m_m mat,
                            transition i_m ins,
                            transition d_m del
                            ]
          -- consume an observation but not a node
          | s == ins = let trans t prev =
                           (score + tProb hmm n t + eProb, ins:path)
                            where (score, path) = viterbi' prev n (o - 1)
                                  eProb = eProb' (iEmissions $ hmm ! n) (res o)
                        in minimum [
                            transition m_i mat,
                            transition i_i ins
                            ]
          -- consume a node but not an observation
          | s == del = let trans t prev = 
                              (score + tProb hmm (n-1) t, del:path)
                              where (score, path) = viterbi' prev (n - 1) o
                        in minimum [
                            transition m_d mat,
                            transition d_d del
                            ]
