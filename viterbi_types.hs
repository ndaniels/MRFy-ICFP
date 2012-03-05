type HMMState = Int
type StatePath = [ HMMState ]
data HMMState = Match | Insert | Delete
type EProbs = V.Vector Double
data LogProb = LogZero | NonZero Double
data TProb  =
     TProb { logProbability::LogProb
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
             , matEmissions :: EProbs
             , insEmissions :: EProbs
             , transitions :: TProbs
             }
type HMM = V.Vector HmmNode