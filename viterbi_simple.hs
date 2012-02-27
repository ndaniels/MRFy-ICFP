type HMM = V.Vector HmmNode
type EmissionProbabilities = V.Vector Double
data HmmNode = 
     HmmNode { nodeNum :: Int
             , matchEmissions :: EmissionProbabilities
             , annotations :: Maybe EmissionAnnotationSet
             , insertionEmissions :: EmissionProbabilities
             , transitions :: TransitionProbabilities
             }
data TransitionProbabilities = 
     TransitionProbabilities { m_m :: TransitionProbability
                             , m_i :: TransitionProbability
                             , m_d :: TransitionProbability
                             , i_m :: TransitionProbability
                             , i_i :: TransitionProbability
                             , d_m :: TransitionProbability
                             , d_d :: TransitionProbability
                             }

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
                            trans m_m mat,
                            trans i_m ins,
                            trans d_m del
                            ]
          -- consume an observation but not a node
          | s == ins = let trans t prev =
                           (score + tProb hmm n t + eProb, ins:path)
                            where (score, path) = viterbi' prev n (o - 1)
                                  eProb = eProb' (iEmissions $ hmm ! n) (res o)
                        in minimum [
                            trans m_i mat,
                            trans i_i ins
                            ]
          -- consume a node but not an observation
          | s == del = let trans t prev = 
                              (score + tProb hmm (n-1) t, del:path)
                              where (score, path) = viterbi' prev (n - 1) o
                        in minimum [
                            trans m_d mat,
                            trans d_d del
                            ]
                            
        numNodes = Data.Vector.length hmm
        seqlen = Data.Vector.length query
        
        eProb' :: Vector a -> Int -> a
        eProb' emissions residue = emissions ! residue

        tProb :: HMM -> Int -> StateAcc -> Double
        tProb hmm nodenum state = case logProbability $ state (transitions (hmm ! nodenum)) of
                                           NonZero p -> p
                                           LogZero -> maxProb
        
