type HMMState = Int
type StatePath = [ HMMState ]
data HMMState = Match | Insertion | Deletion
type EProbs = V.Vector Double
data TProb  = 
     TProb { logProbability::LogProbability
           , fromState::HMMState
           , toState::HMMState
           }
data TProbs =
     TProbs { m_m :: TProb
            , m_i :: TProb
            , m_d :: TProb
            , i_m :: TProb
            , i_i :: TProb
            , d_m :: TProb
            , d_d :: TProb
            }
data HmmNode =
     HmmNode { nodeNum :: Int
             , matchEmissions :: EProbs
             , insertionEmissions :: EProbs
             , transitions :: TProbs
             }
type HMM = V.Vector HmmNode